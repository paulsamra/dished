//
//  DAFindFriendsController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/19/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import AddressBook

protocol DAFindFriendsDataSourceDelegate: class {
    func findFriendsDataSourceDidFinishLoadingFriends(dataSource: DAFindFriendsDataSource)
    func findFriendsDataSourceDidFailToLoadFriends(dataSource: DAFindFriendsDataSource)
}

class DAFindFriendsDataSource {
    
    var friends = [DAFriend]()
    var registerDataTask: NSURLSessionTask? = nil
    weak var delegate: DAFindFriendsDataSourceDelegate? = nil

    func contactsAccessAllowed() -> Bool {
        let status = SwiftAddressBook.authorizationStatus()
        
        if status == ABAuthorizationStatus.Authorized {
            return true
        }
        
        return false
    }

    func loadFriends() {
        swiftAddressBook?.requestAccessWithCompletion {
            granted, error in

            let mobileContacts = self.mobileContactsWithContacts(swiftAddressBook?.allPeople)
            self.getRegisterStatusForContacts(mobileContacts, completion: {
                friends in
                
                if friends == nil {
                    self.delegate?.findFriendsDataSourceDidFailToLoadFriends(self)
                    return
                }
                
                self.friends = friends!
                self.friends.sort() {
                    $0.name < $1.name
                }
                
                self.delegate?.findFriendsDataSourceDidFinishLoadingFriends(self)
            })
        }
    }
    
    private func getRegisterStatusForContacts(contacts: [[String:String]], completion: ([DAFriend]?) -> ()) {
        let options = NSJSONWritingOptions.PrettyPrinted
        let jsonData = NSJSONSerialization.dataWithJSONObject(contacts, options: options, error: nil)
        
        if jsonData != nil {
            registerDataTask?.cancel()

            let jsonString = NSString(data: jsonData!, encoding: NSUTF8StringEncoding) as String
            
            let apiManager = DAAPIManager.sharedManager()
            let url = kUserContactsRegisteredURL
            let parameters = [kContactsKey: jsonString]
            
            registerDataTask = apiManager.POSTRequest(url, withParameters: parameters, success: {
                response in
                
                let results = response.objectForKey(kDataKey) as [NSDictionary]
                var friends = [DAFriend]()
                
                for contact in results {
                    let friend = DAFriend()
                    friend.name = contact[kNameKey] as? String ?? ""
                    friend.phoneNumber = contact[kPhoneKey] as? String ?? ""
                    friend.registered = contact["registered"] as? Bool ?? false
                    friend.image = contact["img_thumb"] as? String ?? ""
                    
                    if friend.registered {
                        friend.username = contact[kUsernameKey] as? String ?? ""
                        friend.following = contact["follows"] as? Bool ?? false
                        friend.userID = ( contact[kIDKey] as? String ?? "" ).toInt() ?? 0
                    }
                    else {
                        friend.invited = contact["invited"] as? Bool ?? false
                    }
                    
                    if friend.username != DAUserManager.sharedManager().username {
                        friends.append(friend)
                    }
                }
                
                completion(friends)
            },
            failure: {
                error, retry in
                println(error)
                completion(nil)
            })
        }
        else {
            completion(nil)
        }
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
            for record: ABRecord in person as NSSet {
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
        let name = person.compositeName as String?
        let email = person.emails?[0].value as String?
        var number = phoneNumber
        
        let nonDecimalSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let decimals = number.componentsSeparatedByCharactersInSet(nonDecimalSet)
        number = "".join(decimals)
        
        if number[0] == "1" {
            number = number.substringFromIndex(advance(number.startIndex, 1))
        }
        
        if countElements(number) != 10 {
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