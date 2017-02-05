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
	init() {
		super.init(baseURL: Constants.BAND_UP_ADDRESS)
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
	
	func getCookie () -> [String:String] {
		if let setCookie = self.headers["set-cookie"] {
			return ["cookie" : setCookie]
		} else {
			return [:]
		}
	}
}

let bandUpAPI = BandUpAPI()
