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
    
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	
	@IBAction func didClickSend(_ sender: UIButton) {
		if (txtMessage.text?.characters.count)! <= 0 {
			return
		}

		btnSend.isEnabled = false

		ChatSocket.sharedInstance.send(message: txtMessage.text!, to: user.id).timingOut(after: 0) { (data) in
			if data.count > 0 {
				if data[0] as! Bool {
					print("Message sent.")
				} else {
					print("Sending message failed on server.")
				}
			}

			let msg = ChatMessage()
			msg.message = self.txtMessage.text!
			self.btnSend.isEnabled = true
			self.txtMessage.text = ""
			self.txtMessage.isEnabled = true

			self.chatHistory.append(msg)

			self.tableView.reloadData()
			if self.chatHistory.count >= 2 {
				self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-2, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
			}

			if self.chatHistory.count >= 1 {
				self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.estimatedRowHeight = 44
		self.tableView.rowHeight = UITableViewAutomaticDimension
		ChatSocket.sharedInstance.startSocket()
		ChatSocket.sharedInstance.establishConnection()

		ChatSocket.sharedInstance.socket.on("recv_privatemsg") { (dataList, callback) in
			if dataList.count < 2 {
				return
			}


			let msg = ChatMessage()
			msg.message = dataList[1] as! String
			msg.sender = dataList[0] as! String
			
			self.chatHistory.append(msg)
			self.tableView.reloadData()
			// self.tableView.insertRows(at: [IndexPath(row:self.chatHistory.count-1, section: 0)], with: .bottom)
			self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-2, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
			self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)

		}
		ChatSocket.sharedInstance.socket.on("connect") { (data, ack) in
			print("Connected. Registering...")
			ChatSocket.sharedInstance.registerUser().timingOut(after: 0, callback: { (data) in
				if data.count > 0 {
					if data[0] as! Bool {
						print("Registration Successful")
					} else {
						print("Could not register. Username already taken")
					}
				}
			})
		}

		BandUpAPI.sharedInstance.chatHistory.child(user.id).load().onSuccess({ (response) in
			self.activityIndicator.stopAnimating()
            if let history = response.jsonDict["chatHistory"] {
                for message in history as! NSArray {
                    self.chatHistory.append(ChatMessage(message as! NSDictionary))
                }
            }

            self.tableView.reloadData()
			self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)

        }).onFailure({ (error) in
			self.activityIndicator.stopAnimating()
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
		if chatHistory.count > 0 {
			self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
		}
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
		viewController.shouldDisplayLike = false
		viewController.currentUser = user
		
		let navController = UINavigationController(rootViewController: viewController)
		let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissDetails))
		button.tintColor = UIColor.bandUpYellow

		navController.navigationBar.barStyle = .black
		viewController.navigationItem.rightBarButtonItem = button
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
		var cell: UITableViewCell

		if chatHistory[indexPath.row].sender == user.id {
			cell = tableView.dequeueReusableCell(withIdentifier: "chat_message_cell_other", for: indexPath)
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "chat_message_cell_me", for: indexPath)
		}

        let messageCell = cell.viewWithTag(1) as! UILabel
		let messageViewCell = cell.viewWithTag(2)
        messageCell.text = chatHistory[indexPath.row].message
		messageCell.sizeToFit()
		// messageCell.clipsToBounds = true
		messageViewCell?.layer.cornerRadius = 12
        return cell
    }
	
}
