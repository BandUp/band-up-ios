//
//  User.swift
//  band-up-ios
//
//  Created by Bergþór on 29.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import Foundation

class User: CustomStringConvertible {
	convenience init(_ dictionary: NSDictionary) {
		self.init()
		
		// ID
		if let jsonID = dictionary["_id"] as? String {
			self.id = jsonID
		}
		
		// About Me
		if let jsonAboutMe = dictionary["aboutme"] as? String {
			self.aboutme = jsonAboutMe
		}
		
		// Date of Birth
		if let jsonBirth = dictionary["dateOfBirth"] as? String {
			let dateFormatter = DateFormatter()
			dateFormatter.locale = Locale(identifier:"en_US_POSIX")
			dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"
			self.dateOfBirth = dateFormatter.date(from: jsonBirth)!
		}
		
		// Distance
		if let jsonDistance = dictionary["distance"] as? Double {
			self.distance = jsonDistance
		}
		
		// Favourite Instrument
		if let jsonFavInstrument = dictionary["favoriteinstrument"] as? String {
			self.favouriteInstrument = jsonFavInstrument
		}
		
		// Genres
		if let jsonGenres = dictionary["genres"] as? [String] {
			self.genres = jsonGenres
		}
		
		// Image
		if let jsonImage = dictionary["image"] as? NSDictionary {
			self.image = UserImage(jsonImage)
		}
		
		// Instruments
		if let jsonInstruments = dictionary["instruments"] as? [String] {
			self.instruments = jsonInstruments
		}
		
		// Is Liked
		if let jsonIsLiked = dictionary["isLiked"] as? Bool {
			self.isLiked = jsonIsLiked
		}
		
		// Location
		if let jsonLocation = dictionary["location"] as? NSDictionary {
			self.location = UserLocation(jsonLocation)
		}
		
		// Percentage
		if let jsonPercentage = dictionary["percentage"] as? Int {
			self.percentage = jsonPercentage
		}
		
		// SoundCloud ID
		if let jsonSCID = dictionary["soundCloudId"] as? Int {
			self.soundCloudId = jsonSCID
		}
		
		// SoundCloud Song Name
		if let jsonSCSongName = dictionary["soundCloudSongName"] as? String {
			self.soundCloudSongName = jsonSCSongName
		}
		
		// SoundCloud URL
		if let jsonSCURL = dictionary["soundcloudurl"] as? String {
			self.soundCloudURL = jsonSCURL
		}
		
		// Status
		if let jsonStatus = dictionary["status"] as? String {
			self.status = jsonStatus
		}
		
		// Username
		if let jsonUsername = dictionary["username"] as? String {
			self.username = jsonUsername
		}
	}
	
	var id:                  String       = ""
	var aboutme:             String       = ""
	var dateOfBirth:         Date         = Date()
	var distance:            Double       = 0.0
	var favouriteInstrument: String       = ""
	var genres:              [String]     = []
	var image:               UserImage    = UserImage()
	var instruments:         [String]     = []
	var isLiked:             Bool         = false
	var location:            UserLocation = UserLocation()
	var percentage:          Int          = 0
	var soundCloudId:        Int          = 0
	var soundCloudSongName:  String       = ""
	var soundCloudURL:       String       = ""
	var status:              String       = ""
	var username:            String       = ""
	
	func getAge() -> Int{
		let calendar = Calendar.current
		let now = Date()
		
		let ageComponents = calendar.dateComponents([.year], from: self.dateOfBirth, to: now)
		return ageComponents.year!
	}
	
	var description: String {
		
		var bla = [String:String]()
		
		bla["ID"] = id;
		bla["Name"] = username;
		bla["About Me"] = aboutme;
		bla["Image"] = image.description;
		
		var desc = "\(User.self)\n"
		
		for (key, value) in bla {
			desc += String(format: "%25s: %s\n", (key as NSString).utf8String!, (value as NSString).utf8String!)
		}
		
		return desc;
	}
}

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
	
	var description: String {
		var bla = [String:String]()
		
		bla["URL"] = url;
		bla["Public ID"] = publicId;
		
		var desc = "\(UserImage.self)\n"
		
		for (key, value) in bla {
			desc += String(format: "%25s: %s\n", (key as NSString).utf8String!, (value as NSString).utf8String!)
		}
		
		return desc;
	}
	
}
