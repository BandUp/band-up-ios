//
//  ChatMessage.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import Foundation

class ChatMessage {

	// MARK: - Variables
	var sender: String = ""
	var message: String = ""
	var timestamp: Date

	// MARK: - Initializers
	init() {
		timestamp = Date()
	}
	
	convenience init(sender: String, message: String, timestamp: Date) {
		self.init()
		self.sender = sender
		self.message = message
		self.timestamp = timestamp
	}
	
	convenience init(_ dictionary: NSDictionary) {
		self.init()
		
		if let jsonSender = dictionary["sender"] as? String {
			self.sender = jsonSender
		}
		
		if let jsonMessage = dictionary["message"] as? String {
			self.message = jsonMessage
		}
		
		if let jsonDateString = dictionary["timestamp"] as? String {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
			let date = dateFormatter.date(from:jsonDateString)!
			let calendar = Calendar.current
			let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
			self.timestamp = calendar.date(from:components)!
		}
	}
}
