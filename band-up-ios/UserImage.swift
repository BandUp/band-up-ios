//
//  UserImage.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation
import UIKit

class UserImage: CustomStringConvertible {
	convenience init(_ dictionary: NSDictionary) {
		self.init()
		
		if let jsonUrl = dictionary["url"] as? String {
			self.url = jsonUrl
		}
		
		if let jsonPublicId = dictionary["public_id"] as? String {
			self.publicId = jsonPublicId
		}
	}
	
	var publicId: String = ""
	var url:      String = ""
	var image:    UIImage = UIImage()
	
	var description: String {
		var bla = [String:String]()
		
		bla["URL"] = url
		bla["Public ID"] = publicId
		
		var desc = "\(UserImage.self)\n"
		
		for (key, value) in bla {
			desc += String(format: "%25s: %s\n", (key as NSString).utf8String!, (value as NSString).utf8String!)
		}
		
		return desc
	}
	
}
