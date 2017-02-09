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
	
	@IBAction func didClickSend(_ sender: Any) {
		
	}
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		SocketIOManager.sharedInstance.startSocket()
		SocketIOManager.sharedInstance.establishConnection()
		SocketIOManager.sharedInstance.socket.on("connect") { (data, ack) in
			print("connected")
			SocketIOManager.sharedInstance.registerUser().timingOut(after: 100, callback: { (data) in
				print("WOO")
			})
		}
        
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
	
	override func viewWillAppear(_ animated: Bool) {
		self.title = user.username
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(someAction), for: .touchUpInside)
		let barButton = UIBarButtonItem(customView: infoButton)
		self.navigationItem.rightBarButtonItem = barButton
	}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func keyboardWillShow(sender: NSNotification) {
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
	
	public func someAction() {
		let storyboard = UIStoryboard(name: "UserDetailsView", bundle: Bundle.main)
		
		let viewController = storyboard.instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
		viewController.currentUser = user
		
		let navController = UINavigationController(rootViewController: viewController)
		let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(dismissDetails))

		navController.navigationItem.rightBarButtonItem = button
		present(navController, animated: true, completion: nil)
	}
	
	func dismissDetails() {
		dismiss(animated:true, completion:nil)
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
