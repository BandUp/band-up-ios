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
		super.init()
    }
	
    var socket: SocketIOClient

    func establishConnection() {
		if socket.status == .disconnected || socket.status == .notConnected {
			print("Connecting...")
			ChatSocket.sharedInstance.socket.on("connect") { (data, ack) in
				print("Connected. Registering...")
				self.registerUser().timingOut(after: 5, callback: { (data) in
					if data.count > 0 {
						if let successful = data[0] as? Bool {
							if successful {
								print("Registration Successful")
							} else {
								print("Could not register. Username already taken")
							}
						}
					}
				})
			}
			socket.connect()
		} else {
			print("Already connected")
		}
    }
    
    func closeConnection() {
		print("Disonnecting...")
		socket.off("connect")
        socket.disconnect()
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
