//
//  Constants.swift
//  band-up-ios
//
//  Created by Bergþór on 5.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation
import UIKit

class Constants {
	// https://band-up-server.herokuapp.com
	// http://192.168.99.1:3000
	// http://192.168.1.5:3000
	// http://192.168.1.14:3000
	
	static var bandUpAddress = URL(string: "https://band-up-server.herokuapp.com")
	static var maxAge = 99
	static var minAge = 13
	
	static var setupInstruments : SetupViewObject = {
		let setupObjectInstruments = SetupViewObject(setupResource: BandUpAPI.sharedInstance.instruments)
		
		setupObjectInstruments.doneButtonText = "Next"
		setupObjectInstruments.titleUpperLeft = "Let's get started"
		setupObjectInstruments.setupViewIndex = 1
		setupObjectInstruments.setupViewCount = 2
		setupObjectInstruments.titleHint      = "What instruments do you play?"
		
		return setupObjectInstruments
	}()
	
	static var setupGenres : SetupViewObject =  {
		let setupObjectGenres = SetupViewObject(setupResource: BandUpAPI.sharedInstance.genres)
		
		setupObjectGenres.doneButtonText    = "Finish"
		setupObjectGenres.titleUpperLeft    = "Let's get started"
		setupObjectGenres.setupViewIndex    = 2
		setupObjectGenres.setupViewCount    = 2
		setupObjectGenres.titleHint         = "What is your taste in music?"
		setupObjectGenres.shouldFinishSetup = true
		
		return setupObjectGenres
	}()
	
	static var completeSetup : [SetupViewObject] = {
		return [setupInstruments, setupGenres]
	}()
}

extension UIColor {
	// 0xFFD302
	static let bandUpYellow = UIColor(red:255/255.0, green:211/255.0, blue:2/255.0, alpha: 1.0)

	// 0xE5C404
	static let bandUpDarkYellow = UIColor(red:229/255.0, green:196/255.0, blue:4/255.0, alpha: 1.0)

	// 0x0D0D0D
	static let bandUpGrey = UIColor(red: 13/255.0, green: 13/255.0, blue: 13/255.0, alpha: 1)
}
