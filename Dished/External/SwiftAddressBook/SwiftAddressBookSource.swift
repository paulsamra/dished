
//
//  SwiftAddressBookSource.swift
//  Pods
//
//  Created by Socialbit - Tassilo Karge on 09.03.15.
//
//

import Foundation
import AddressBook

//MARK: Wrapper for ABAddressBookRecord of type ABSource

public class SwiftAddressBookSource : SwiftAddressBookRecord {

	public var sourceType : SwiftAddressBookSourceType {
		get {
			let sourceType : CFNumber = ABRecordCopyValue(internalRecord, kABSourceTypeProperty).takeRetainedValue() as CFNumber
			var rawSourceType : Int32? = nil
			CFNumberGetValue(sourceType, CFNumberGetType(sourceType), &rawSourceType)
			return SwiftAddressBookSourceType(abSourceType: rawSourceType!)
		}
	}

	public var searchable : Bool {
		get {
			let sourceType : CFNumber = ABRecordCopyValue(internalRecord, kABSourceTypeProperty).takeRetainedValue() as CFNumber
			var rawSourceType : Int32? = nil
			CFNumberGetValue(sourceType, CFNumberGetType(sourceType), &rawSourceType)
			let andResult = kABSourceTypeSearchableMask & rawSourceType!
			return andResult != 0
		}
	}

	public var sourceName : String? {
		get {
			let value: AnyObject? = ABRecordCopyValue(internalRecord, kABSourceNameProperty)?.takeRetainedValue()
			if value != nil {
				return value as CFString
			}
			else {
				return nil
			}
		}
	}
}
