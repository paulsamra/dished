//
//  DAFindFriendsController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/19/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import AddressBook

class DAFindFriendsDataSource: DADataSource {
    
    var friends = [String:[DAFriend]]()
    var sections = [String]()
    weak var delegate: DADataSourceDelegate? = nil
    private var registerDataTask: NSURLSessionTask? = nil
    
    init() {
        
    }

    func contactsAccessAllowed() -> Bool {
        let status = SwiftAddressBook.authorizationStatus()
        
        if status == ABAuthorizationStatus.Authorized {
            return true
        }
        
        return false
    }
    
    func friendForIndexPath(indexPath: NSIndexPath) -> DAFriend {
        let sectionIndex = sections[indexPath.section]
        return friends[sectionIndex]?[indexPath.row] ?? DAFriend()
    }

    func loadData() {
        swiftAddressBook?.requestAccessWithCompletion {
            granted, error in
            
            if error == nil {
                let contacts = swiftAddressBook?.allPeople
                let mobileContacts = self.mobileContactsWithContacts(contacts)
                self.getRegisterStatusForContacts(mobileContacts)
            }
            else {
                self.delegate?.dataSourceDidFailToLoadData(self, withError: nil)
            }
        }
    }
    
    func cancelLoadingData() {
        registerDataTask?.cancel()
    }
    
    private func getRegisterStatusForContacts(contacts: [[String:String]]) {
        let options = NSJSONWritingOptions.PrettyPrinted
        let jsonData = NSJSONSerialization.dataWithJSONObject(contacts, options: options, error: nil)
        
        if jsonData != nil {
            registerDataTask?.cancel()

            let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as! String
            
            let apiManager = DAAPIManager.sharedManager()
            let url = kUserContactsRegisteredURL
            let parameters = [kContactsKey: jsonString]
            
            registerDataTask = apiManager.POSTRequest(url, withParameters: parameters, success: {
                response in
                
                let results = response.objectForKey(kDataKey) as! [NSDictionary]
                var friendList = [DAFriend]()
                
                for contact in results {
                    let friend = self.processFriendData(contact)
                    
                    if friend.username != DAUserManager.sharedManager().username {
                        friendList.append(friend)
                    }
                }
                
                friendList.sort() {
                    $0.name.capitalizedString < $1.name.capitalizedString
                }
                
                let friendDict = friendList.groupBy(groupingFunction: {
                    self.keyForFriend($0)
                })
                
                self.friends = friendDict
                self.sections = self.friends.keys.array.sorted() {
                    $0 < $1
                }
                
                self.delegate?.dataSourceDidFinishLoadingData(self)
            },
            failure: {
                error, retry in
                
                if retry {
                    self.getRegisterStatusForContacts(contacts)
                }
                else {
                    self.delegate?.dataSourceDidFailToLoadData(self, withError: error)
                }
            })
        }
        else {
            self.delegate?.dataSourceDidFailToLoadData(self, withError: nil)
        }
    }
    
    private func keyForFriend(friend: DAFriend) -> String {
        if friend.name.isEmpty {
            return ""
        }
        
        return friend.name[0]!.capitalizedString
    }
    
    private func processFriendData(data: NSDictionary) -> DAFriend {
        let friend = DAFriend()
        friend.name = data[kNameKey] as? String ?? ""
        friend.phoneNumber = data[kPhoneKey] as? String ?? ""
        friend.registered = data["registered"] as? Bool ?? false
        friend.image = data[kImgThumbKey] as? String ?? ""
        
        if friend.registered {
            friend.username = data[kUsernameKey] as? String ?? ""
            friend.following = data["follows"] as? Bool ?? false
            friend.userID = ( data[kIDKey] as? String ?? "" ).toInt() ?? 0
        }
        else {
            friend.invited = data["invited"] as? Bool ?? false
        }
        
        return friend
    }
    
    private func mobileContactsWithContacts(contacts: [SwiftAddressBookPerson]?) -> [[String:String]] {
        var mobileContacts = [[String:String]]()
        
        var unifiedContacts = NSMutableSet()
        
        if let people = swiftAddressBook?.allPeople {
            for person in people {
                var set = NSMutableSet()
                set.addObject(person.internalRecord)
                
                let linked = person.allLinkedPeople ?? [SwiftAddressBookPerson]()
                
                for link in linked {
                    set.addObject(link.internalRecord)
                }
                
                unifiedContacts.addObject(set)
            }
        }
        
        for person in unifiedContacts {
            for record: ABRecord in person as! NSSet {
                if let abPerson = SwiftAddressBookRecord(record: record).convertToPerson() {
                    if let contact = contactForPerson(abPerson) {
                        mobileContacts.append(contact)
                        break
                    }
                }
            }
        }
        
        return mobileContacts
    }
    
    private func contactForPerson(person: SwiftAddressBookPerson) -> [String:String]? {
        var contact: [String:String]?
        
        if person.phoneNumbers == nil {
            return nil
        }
        
        for number in person.phoneNumbers! {
            let options = NSStringCompareOptions.CaseInsensitiveSearch
            let label = number.label ?? ""
            let iphone = label.rangeOfString("iphone", options: options, range: nil, locale: nil)
            let mobile = label.rangeOfString("mobile", options: options, range: nil, locale: nil)
            
            if mobile != nil || iphone != nil {
                contact = processContact(person, phoneNumber: number.value as String)
            }
        }
        
        return contact
    }
    
    private func processContact(person: SwiftAddressBookPerson, phoneNumber: String) -> [String:String]? {
        let name = person.compositeName
        var email: String? = nil
        if let emails = person.emails {
            email = emails.isEmpty ? nil : emails[0].value
        }
        var number = phoneNumber
        
        if name == nil {
            return nil
        }
        else {
            if name!.isEmpty {
                return nil
            }
        }
        
        let nonDecimalSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let decimals = number.componentsSeparatedByCharactersInSet(nonDecimalSet)
        number = "".join(decimals)
        
        if number.isEmpty {
            return nil
        }
        
        if number[0] == "1" {
            number = number.substringFromIndex(advance(number.startIndex, 1))
        }
        
        if count(number) != 10 {
            return nil
        }
        
        return dictionaryWithName(name, number: number, email: email)
    }
    
    private func dictionaryWithName(name: String?, number: String?, email: String?) -> [String:String] {
        return [
            kNameKey: name ?? "",
            kPhoneKey: number ?? "",
            kEmailKey: email ?? ""
        ]
    }
}