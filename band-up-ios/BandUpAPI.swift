//
//  BandUpAPI.swift
//  band-up-ios
//
//  Created by Bergþór on 19.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import Foundation
import Siesta

class BandUpAPI: Service {
	
	static let sharedInstance = BandUpAPI()
	static let cookieKey = "cookie"
	static let setCookieKey = "set-cookie"
	static let hasFinishedSetup = "hasFinishedSetup"
	
	init() {
		super.init(baseURL: Constants.BAND_UP_ADDRESS)
		
		// Put the header onto every request.
		configure() {
			let uDef = UserDefaults.standard
			guard let storedHeaders = uDef.dictionary(forKey: DefaultsKeys.headers) else {
				return
			}

			if $0.headers[BandUpAPI.cookieKey] == nil {
				$0.headers[BandUpAPI.cookieKey] = (storedHeaders as! [String:String])[BandUpAPI.cookieKey]
			}
		}
		
		// Get the header of a response and save it.
		// Also save the hasFinishedSetup variable if it is in the payload.
		configure() {
			$0.decorateRequests { _, req in
				req.onSuccess({ (response) in
					if response.headers[BandUpAPI.setCookieKey] != nil {
						self.headers = response.headers
						UserDefaults.standard.set(self.getCookie(), forKey: DefaultsKeys.headers)
					}
					
					if let finishedSetup = response.jsonDict[BandUpAPI.hasFinishedSetup] as! Bool? {
						UserDefaults.standard.set(finishedSetup, forKey: DefaultsKeys.finishedSetup)
					}
				})
			}
		}
		
		// Display the login screen when receiving a 401.
		configure(whenURLMatches: { $0 != self.login.url }) {
			$0.decorateRequests { _, req in
				req.onFailure { error in
					if error.httpStatusCode == 401 {
						(UIApplication.shared.delegate as! AppDelegate).showLoginScreen()
						self.invalidateConfiguration()
					}
				}
			}
		}
	}
	
	var headers =    [String:String]()
	var register:    Resource { return resource("/signup-local") }
	var login:       Resource { return resource("/login-local") }
	var instruments: Resource { return resource("/instruments") }
	var genres:      Resource { return resource("/genres") }
	var isLoggedIn:  Resource { return resource("/isLoggedIn") }
	var matches:     Resource { return resource("/matches") }
	var nearby:      Resource { return resource("/nearby-users") }
	var like:        Resource { return resource("/like") }
    var profile:     Resource { return resource("/user") }
    var chatHistory: Resource { return resource("/chat_history") }
	var editProfile: Resource { return resource("/edit-user") }
	
	private func getCookie () -> [String:String] {
		if let setCookie = self.headers[BandUpAPI.setCookieKey] {
			return [BandUpAPI.cookieKey : setCookie]
		} else {
			return [:]
		}
	}
}
