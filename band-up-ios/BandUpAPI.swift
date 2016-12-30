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
		// http://192.168.1.5:3000
		super.init(baseURL: "https://band-up-server.herokuapp.com")
	}
	
	var register:    Resource { return resource("/signup-local") }
	var login:       Resource { return resource("/login-local") }
	var instruments: Resource { return resource("/instruments") }
	var genres:      Resource { return resource("/genres") }
	var isLoggedIn:  Resource { return resource("/isLoggedIn") }
	
	var nearby:      Resource { return resource("/nearby-users") }
	
	
	
}

let bandUpAPI = BandUpAPI()
