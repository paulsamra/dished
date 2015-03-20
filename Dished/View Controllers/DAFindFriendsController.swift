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
        swiftAddressBook?.requestAccessWithCompletion {
            granted, error in
            
            if !granted {
                completion(false)
                return
            }
            
            let mobileContacts = self.mobileContactsWithContacts(swiftAddressBook?.allPeople)
            self.getRegisterStatusForContacts(mobileContacts, completion: {
                completion(true)
            })
            
            completion(false)
        }
    }
    
    func getRegisterStatusForContacts(contacts: [[String:String]], completion: () -> ()) {
        let options = NSJSONWritingOptions.PrettyPrinted
        if let jsonData = NSJSONSerialization.dataWithJSONObject(contacts, options: options, error: nil) {
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as String
            
            let parameters = [kContactsKey: jsonString]
            DAAPIManager.sharedManager().POSTRequest(kUserContactsRegisteredURL, withParameters: parameters, success: {
                response in
                println(response)
                println(contacts.count)
                completion()
            },
            failure: {
                error, retry in
                println(error)
                completion()
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
                            let name = person.compositeName as String?
                            var number = number.value as String
                            let email = person.emails?[0].value as String?
                            
                            let nonDecimalSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
                            let decimals = number.componentsSeparatedByCharactersInSet(nonDecimalSet)
                            number = "".join(decimals)
                            
                            mobileContacts.append(dictionaryWithName(name, number: number, email: email))
                        }
                    }
                }
            }
        }
        
        return mobileContacts
    }
    
    private func dictionaryWithName(name: String?, number: String?, email: String?) -> [String:String] {
        return [
            kNameKey: name ?? "",
            kPhoneKey: number ?? "",
            kEmailKey: email ?? ""
        ]
    }
}