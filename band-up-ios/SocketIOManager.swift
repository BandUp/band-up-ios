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
    
    // https://band-up-server.herokuapp.com
    // http://192.168.99.1:3000
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://192.168.99.1:3000") as! URL)

    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}

let socketIO = SocketIOManager()
