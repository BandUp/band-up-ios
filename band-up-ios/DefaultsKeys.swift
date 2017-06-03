//
//  DefaultsKeys.swift
//  band-up-ios
//
//  Created by Bergþór on 27.1.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation

struct DefaultsKeys {
	static let headers = "headers"                // [String:String]
	static let finishedSetup = "hasFinishedSetup" // Bool

	static let lastKnownLocation = "lastKnownLocation"

	struct Settings {
		static let usesImperial = "settingsImperial"             // Bool
		static let shouldNotifyMatches = "settingsNewMatches"    // Bool
		static let shouldNotifyInactivity = "settingsInactivity" // Bool
		static let shouldNotifyMessage = "settingsMessage"       // Bool
		static let radius = "settingsRadius"                     // Double
		static let maxAge = "settingsMaxAge"                     // Int
		static let minAge = "settingsMinAge"                     // Int
	}
}
