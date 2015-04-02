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
    
    var friends = [DAFriend]()
    weak var delegate: DADataSourceDelegate? = nil
    private var registerDataTask: NSURLSessionTask? = nil
    
    init(delegate: DADataSourceDelegate) {
        self.delegate = delegate
    }

    func contactsAccessAllowed() -> Bool {
        let status = SwiftAddressBook.authorizationStatus()
        
        if status == ABAuthorizationStatus.Authorized {
            return true
        }
        
        return false
    }
    
    func getAddressBook() -> APAddressBook {
        let addressBook = APAddressBook()
        addressBook.fieldsMask = APContactField.PhonesWithLabels | APContactField.CompositeName | APContactField.Emails
        
        addressBook.filterBlock = {
            var isMobile = false
            
            for phoneWithLabel in $0.phonesWithLabels as [APPhoneWithLabel] {
                let options = NSStringCompareOptions.CaseInsensitiveSearch
                let label = phoneWithLabel.label
                let iphone = label.rangeOfString("iphone", options: options, range: nil, locale: nil) != nil
                let mobile = label.rangeOfString("mobile", options: options, range: nil, locale: nil) != nil
                
                isMobile |= iphone || mobile
            }
            
            return isMobile
        }
        
        addressBook.sortDescriptors = [
            NSSortDescriptor(key: "compositeName", ascending: true)
        ]
        
        return addressBook
    }

    func loadData() {
        let addressBook = getAddressBook()
        
        addressBook.loadContacts({
            contacts, error in
            
            if error != nil {
                self.delegate?.dataSourceDidFailToLoadData(self, withError: error)
            }
            else {
                let mobileContacts = self.mobileContactsWithContacts2(contacts as [APContact])
                self.getRegisterStatusForContacts(mobileContacts, completion: {
                    friends in
                    
                    if friends == nil {
                        self.delegate?.dataSourceDidFailToLoadData(self, withError: nil)
                        return
                    }
                    
                    self.friends = friends!
                    self.friends.sort() {
                        $0.name < $1.name
                    }
                    
                    self.delegate?.dataSourceDidFinishLoadingData(self)
                })
            }
        })
        
//        SwiftAddressBook.sharedInstance()?.requestAccessWithCompletion {
//            granted, error in
//
//            let mobileContacts = self.mobileContactsWithContacts(SwiftAddressBook.sharedInstance()?.allPeople)
//            self.getRegisterStatusForContacts(mobileContacts, completion: {
//                friends in
//                
//                if friends == nil {
//                    self.delegate?.dataSourceDidFailToLoadData(self, withError: nil)
//                    return
//                }
//                
//                self.friends = friends!
//                self.friends.sort() {
//                    $0.name < $1.name
//                }
//                
//                self.delegate?.dataSourceDidFinishLoadingData(self)
//            })
//        }
    }
    
    func cancelLoadingData() {
        registerDataTask?.cancel()
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
                    let friend = self.processFriendData(contact)
                    
                    if friend.username != DAUserManager.sharedManager().username {
                        friends.append(friend)
                    }
                }
                
                completion(friends)
            },
            failure: {
                error, retry in
                completion(nil)
                return
            })
        }
        else {
            completion(nil)
        }
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
    
    private func mobileContactsWithContacts2(contacts: [APContact]) -> [[String:String]] {
        var mobileContacts = [[String:String]]()
        
        var unifiedContacts = [String:[String:String]]()
        
        for contact in contacts {
            var attributes = unifiedContacts[contact.compositeName] ?? [String:String]()
            
            for phoneWithLabel in contact.phonesWithLabels as [APPhoneWithLabel] {
                attributes[phoneWithLabel.label] = phoneWithLabel.phone
            }
            
            if contact.emails.count > 0 {
                attributes["email"] = contact.emails.first as? String
            }
            
            unifiedContacts[contact.compositeName] = attributes
        }
        
        for (contact, attributes) in unifiedContacts {
            var number: String?
            
            if let iphone = attributes["iPhone"] {
                number = processPhoneNumber(iphone)
            }
            else if let mobile = attributes["mobile"] {
                number = processPhoneNumber(mobile)
            }
            
            if number == nil {
                continue
            }
            
            let dict = dictionaryWithName(contact, number: number, email: attributes["email"])
            mobileContacts.append(dict)
        }
        
        return mobileContacts
    }
    
    private func mobileContactsWithContacts(contacts: [SwiftAddressBookPerson]?) -> [[String:String]] {
        var mobileContacts = [[String:String]]()
        
        var unifiedContacts = NSMutableSet()
        
        if let people = SwiftAddressBook.sharedInstance()?.allPeople {
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
    
    private func processPhoneNumber(number: String) -> String? {
        let nonDecimalSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let decimals = number.componentsSeparatedByCharactersInSet(nonDecimalSet)
        var strippedNumber = "".join(decimals)
        
        if strippedNumber[0] == "1" {
            strippedNumber = strippedNumber.substringFromIndex(advance(strippedNumber.startIndex, 1))
        }
        
        if countElements(strippedNumber) != 10 {
            return nil
        }
        
        return strippedNumber
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