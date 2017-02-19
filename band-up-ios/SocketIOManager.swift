//
//  SocketIO.swift
//  band-up-ios
//
//  Created by Elvar Laxdal on 04/02/2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    override init() {
        super.init()
    }
	
    var socket: SocketIOClient = SocketIOClient(socketURL: Constants.BAND_UP_ADDRESS!)

    func establishConnection() {
		print("Connecting")
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
	
	func startSocket() {
		socket = SocketIOClient(socketURL: Constants.BAND_UP_ADDRESS!, config: [.log(true), .forcePolling(true), .extraHeaders(UserDefaults.standard.dictionary(forKey: DefaultsKeys.headers) as! [String:String])])
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
