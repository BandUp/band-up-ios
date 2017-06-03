//
//  User.swift
//  band-up-ios
//
//  Created by Bergþór on 29.12.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class User: CustomStringConvertible {

	// MARK: - Variables
	var id:                  String       = ""
	var aboutme:             String       = ""
	var dateOfBirth:         Date?
	var distance:            Double?      = 0.0
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

	// MARK: - Initializers
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

	// MARK: - Instance Functions
	func getAge() -> Int {
		let calendar = Calendar.current
		let now = Date()
		if let safeDate = self.dateOfBirth {
			let ageComponents = calendar.dateComponents([.year], from: safeDate, to: now)
			return ageComponents.year!
		} else {
			return -1
		}
	}

	func getBirthString() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		if let safeDate = self.dateOfBirth {
			let formattedDate = dateFormatter.string(from: safeDate)
			let age = getAge()
			return String(format:"\(formattedDate) (\(age))")
		} else {
			return ""
		}
	}

	func getAgeString() -> String {
		if self.dateOfBirth != nil {
			let yearOld = NSLocalizedString("age_year_plural", comment: "")
			return "\(self.getAge()) \(yearOld)"
		} else {
			return NSLocalizedString("age_not_available", comment: "Appears whenever the age is not available.")
		}
	}

	func getDistance(myLocation:CLLocation) -> Int {
		if !self.location.valid {
			return -1
		}
		let userLocation = CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
		return Int(userLocation.distance(from: myLocation))
	}

	func getDistanceString(between location:CLLocation? = nil) -> String {
		let localizedNoDistance = "no_distance_available".localized

		if !self.location.valid && self.distance == nil {
			return localizedNoDistance
		}

		if location == nil {
			if let distance = self.distance {
				return getDistanceString(distance: distance*1000)
			} else {
				return localizedNoDistance
			}
		} else {
			guard let location = location else { return localizedNoDistance }
			if self.location.valid {
				let userLocation = CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
				let distance = location.distance(from: userLocation)
				return getDistanceString(distance: distance)
			} else {
				guard let distance = self.distance else {
					return localizedNoDistance
				}
				return getDistanceString(distance: distance*1000)
			}
		}

	}

	// MARK: - Private Functions
	private func getDistanceString(distance:Double) -> String {
		var shouldUseMetric = true
		let defObj = UserDefaults.standard.object(forKey: DefaultsKeys.Settings.usesImperial)
		if defObj == nil {
			shouldUseMetric = Locale.current.usesMetricSystem
		} else {
			if let defObj = defObj as? Bool {
				shouldUseMetric = !defObj
			}
		}
		let formatter = MKDistanceFormatter()

		if shouldUseMetric {
			formatter.units = .metric
		} else {
			formatter.units = .imperial
		}
		formatter.unitStyle = .abbreviated
		let formattedDistance = formatter.string(fromDistance: CLLocationDistance(distance))
		return String(format: "distance_from_you".localized, formattedDistance)
	}

	var description: String {
		
		var bla = [String:String]()
		
		bla["ID"] = id
		bla["Name"] = username
		bla["About Me"] = aboutme
		bla["Image"] = image.description
		
		var desc = "\(User.self)\n"
		
		for (key, value) in bla {
			desc += String(format: "%25s: %s\n", (key as NSString).utf8String!, (value as NSString).utf8String!)
		}
		
		return desc
	}
}

extension User: Equatable {

	public static func == (lhs: User, rhs: User) -> Bool {
		return lhs.id == rhs.id
	}

}

extension User: NSCopying {
	func copy(with zone: NSZone? = nil) -> Any {
		let copy = User()
		copy.id = self.id
		copy.aboutme = self.aboutme
		copy.dateOfBirth = self.dateOfBirth
		copy.distance = self.distance
		copy.favouriteInstrument = self.favouriteInstrument
		copy.genres = self.genres
		copy.image = self.image
		copy.instruments = self.instruments
		copy.isLiked = self.isLiked
		copy.location = self.location
		copy.percentage = self.percentage
		copy.soundCloudId = self.soundCloudId
		copy.soundCloudSongName = self.soundCloudSongName
		copy.soundCloudURL = self.soundCloudURL
		copy.status = self.status
		copy.username = self.username
		return copy
	}
}
