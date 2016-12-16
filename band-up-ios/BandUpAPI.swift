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
	private let service = Service(baseURL: "https://band-up-server.herokuapp.com")
	
	var nearme: Resource { return resource("/near-me") }
	
	let bandUpAPI = BandUpAPI()
}
