//
//  ListItem.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation

class ListItem {
	init(id : String, name: String) {
		self.name = name
		self.id = id
	}
	
	var name : String = ""
	var id : String = ""
}