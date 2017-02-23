//
//  SocketIO.swift
//  band-up-ios
//
//  Created by Elvar Laxdal on 04/02/2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import SocketIO

class ChatSocket: NSObject {
    static let sharedInstance = ChatSocket()
    
    override init() {
        super.init()
    }
	
    var socket: SocketIOClient = SocketIOClient(socketURL: Constants.bandUpAddress!)

    func establishConnection() {
		print("Connecting...")
        socket.connect()
    }
    
    func closeConnection() {
		print("Disonnecting")
        socket.disconnect()
    }
	
	func startSocket() {
		let configuration: SocketIOClientConfiguration

		if let headers = UserDefaults.standard.dictionary(forKey: DefaultsKeys.headers) as? [String:String] {
			configuration = [.log(false),
			                 .forcePolling(true),
			                 .extraHeaders(headers)]
		} else {
			configuration = [.log(false),
			                 .forcePolling(true)]
		}

		socket = SocketIOClient(socketURL: Constants.bandUpAddress!, config: configuration)
	}
	
	func registerUser() -> OnAckCallback {
		return socket.emitWithAck("adduser", "")
	}

	func send(message: String, to userId: String) -> OnAckCallback {
		var dict = [String:Any]()

		dict["message"] = message
		dict["nick"] = userId
		return socket.emitWithAck("privatemsg", dict as SocketData)
	}
	
}
