//
//  ChatViewController.swift
//  band-up-ios
//
//  Created by Elvar Laxdal on 26/01/2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    var user = User()
    var chatHistory = [ChatMessage]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bandUpAPI.chatHistory.child(user.id).load().onSuccess({ (response) in
            if let history = response.jsonDict["chatHistory"] {
                for message in history as! NSArray {
                    self.chatHistory.append(ChatMessage(message as! NSDictionary))
                }
            }
            self.tableView.reloadData()
        }).onFailure({ (error) in
            print(error)
        })
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func keyboardWillShow(sender: NSNotification) {
		print("ASDF")
		let info = sender.userInfo!
		let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
		bottomConstraint.constant = keyboardSize - bottomLayoutGuide.length
		
		let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		
		UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
	}
	
	func keyboardWillHide(sender: NSNotification) {
		let info = sender.userInfo!
		let duration: TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
		bottomConstraint.constant = 0
		
		UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
	}
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_message_cell", for: indexPath)
        let lblMessage = cell.viewWithTag(1) as! UILabel
        lblMessage.text = chatHistory[indexPath.row].message
        return cell
    }
}

class ChatMessage {
    var sender: String = ""
    var message: String = ""
    var timestamp: Date
    
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
