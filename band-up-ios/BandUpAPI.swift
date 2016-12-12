//
//  BandUpAPI.swift
//  band-up-ios
//
//  Created by Bergþór on 19.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import Foundation
import Siesta

class BandUpAPI {
	private let service = Service(baseURL: "http://192.168.1.5:3000")
	
	func logIn(username: String, password: String) {
		if let auth = "\(username):\(password)".data(using: String.Encoding.utf8) {
			basicAuthHeader = "Basic \(auth.base64EncodedString())"
		}
	}
	
	private var basicAuthHeader: String? {
		didSet {
			// These two calls are almost always necessary when you have changing auth for your API:
			
			service.invalidateConfiguration()  // So that future requests for existing resources pick up config change
			service.wipeResources()            // Scrub all unauthenticated data
			
			// Note that wipeResources() broadcasts a “no data” event to all observers of all resources.
			// Therefore, if your UI diligently observes all the resources it displays, this call prevents sensitive
			// data from lingering in the UI after logout.
		}
	}
}
