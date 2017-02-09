//
//  UserLocation.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation

class UserLocation: CustomStringConvertible {
	convenience init(_ dictionary: NSDictionary) {
		self.init()
		
		if let jsonLat = dictionary["lat"] as? Double {
			self.latitude = jsonLat
		}
		
		if let jsonLon = dictionary["lon"] as? Double {
			self.longitude = jsonLon
		}
		
		if let jsonValid = dictionary["valid"] as? Bool {
			self.valid = jsonValid
		}
		
	}
	
	var latitude:  Double = 0.0
	var longitude: Double = 0.0
	var valid:     Bool   = false
	
	var description: String {
		return "\(UserLocation.self)\n\tLatitude:\(latitude)\n\tLongitude:\(longitude)\n\tValid:\(valid)"
	}
}
