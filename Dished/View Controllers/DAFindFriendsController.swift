//
//  DAFindFriendsController.swift
//  Dished
//
//  Created by Ryan Khalili on 3/19/15.
//  Copyright (c) 2015 Dished. All rights reserved.
//

import UIKit
import AddressBook

class DAFindFriendsController: NSObject {
    
    var friends = [DAFriend]()
    
    func getFriends(completion: (Bool) -> ()) {
        friends.removeAll(keepCapacity: false)
        
        swiftAddressBook?.requestAccessWithCompletion {
            granted, error in
            
            if !granted {
                completion(false)
                return
            }
            
            let mobileContacts = self.mobileContactsWithContacts(swiftAddressBook?.allPeople)
            self.getRegisterStatusForContacts(mobileContacts, completion: {
                success in
                completion(success)
            })
        }
    }
    
    func getRegisterStatusForContacts(contacts: [[String:String]], completion: (Bool) -> ()) {
        let options = NSJSONWritingOptions.PrettyPrinted
        if let jsonData = NSJSONSerialization.dataWithJSONObject(contacts, options: options, error: nil) {
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as String
            
            let parameters = [kContactsKey: jsonString]
            DAAPIManager.sharedManager().POSTRequest(kUserContactsRegisteredURL, withParameters: parameters, success: {
                response in
                
                let results = response.objectForKey(kDataKey) as [NSDictionary]
                for contact in results {
                    let friend = DAFriend()
                    friend.name = contact[kNameKey] as String
                    friend.phoneNumber = contact[kPhoneKey] as String
                    friend.registered = contact["registered"] as Bool
                    
                    if friend.registered {
                        friend.username = contact[kUsernameKey] as String
                    }
                    else {
                        friend.invited = contact["invited"] as Bool
                    }
                    
                    self.friends.append(friend)
                }
                
                completion(true)
            },
            failure: {
                error, retry in
                println(error)
                completion(false)
            })
        }
    }
    
    private func mobileContactsWithContacts(contacts: [SwiftAddressBookPerson]?) -> [[String:String]] {
        var mobileContacts = [Dictionary<String,String>]()
        
        if let people = swiftAddressBook?.allPeople {
            for person in people {
                if let numbers = person.phoneNumbers {
                    for number in numbers {
                        let options = NSStringCompareOptions.CaseInsensitiveSearch
                        if number.label?.rangeOfString("Mobile", options: options, range: nil, locale: nil) != nil {
                            mobileContacts.append(processContact(person, phoneNumber: number.value as String))
                            break
                        }
                        else if number.label?.rangeOfString("iPhone", options: options, range: nil, locale: nil) != nil {
                            mobileContacts.append(processContact(person, phoneNumber: number.value as String))
                            break
                        }
                    }
                }
            }
        }
        
        return mobileContacts
    }
    
    func processContact(person: SwiftAddressBookPerson, phoneNumber: String) -> [String:String] {
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
            number = ""
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