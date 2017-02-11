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
	
	init() {
		super.init(baseURL: Constants.BAND_UP_ADDRESS)
		
		configure() {
			let uDef = UserDefaults.standard
			guard let storedHeaders = uDef.dictionary(forKey: defaultsKeys.headers) else {
				return
			}
			
			if $0.headers[BandUpAPI.cookieKey] == nil {
				$0.headers[BandUpAPI.cookieKey] = (storedHeaders as! [String:String])[BandUpAPI.cookieKey]
			}
		}
		
		configure() {
			$0.decorateRequests { _, req in
				req.onSuccess({ (request) in
					if request.headers[BandUpAPI.setCookieKey] != nil {
						self.headers = request.headers
						UserDefaults.standard.set(self.getCookie(), forKey: defaultsKeys.headers)
					}
				})
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
	
	private func getCookie () -> [String:String] {
		if let setCookie = self.headers[BandUpAPI.setCookieKey] {
			return [BandUpAPI.cookieKey : setCookie]
		} else {
			return [:]
		}
	}
}
