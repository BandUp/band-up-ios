//
//  ChatViewController.swift
//  band-up-ios
//
//  Created by Elvar Laxdal on 26/01/2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

	// MARK: - IBOutlets
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var txtMessage: UITextField!
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!

	// MARK: - Variables
	var user = User()
	var chatHistory = [ChatMessage]()

	let chatCellOther = "chat_message_cell_other"
	let chatCellMe    = "chat_message_cell_me"

	// MARK: - IBActions
	@IBAction func didClickSend(_ sender: UIButton) {
		if (txtMessage.text?.characters.count)! <= 0 {
			return
		}

		btnSend.isEnabled = false

		ChatSocket.sharedInstance.send(message: txtMessage.text!, to: user.id).timingOut(after: 0) { (data) in
			if data.count > 0 {
				guard let successful = data[0] as? Bool else {
					return
				}

				if successful {
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

	// MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
		self.tableView.estimatedRowHeight = 44
		self.tableView.rowHeight = UITableViewAutomaticDimension
		ChatSocket.sharedInstance.establishConnection()

		ChatSocket.sharedInstance.socket.on("recv_privatemsg") { (dataList, callback) in
			if dataList.count < 2 {
				return
			}

			let msg = ChatMessage()
			if let recvMessage = dataList[1] as? String {
				msg.message = recvMessage
			}

			if let recvSender = dataList[0] as? String {
				msg.sender = recvSender
			}

			self.chatHistory.append(msg)

			self.tableView.reloadData()
			if self.chatHistory.count >= 2 {
				self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-2, section: 0), at: UITableViewScrollPosition.bottom, animated: false)
			}

			if self.chatHistory.count >= 1 {
				self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
			}

		}

		BandUpAPI.sharedInstance.chatHistory.child(user.id).load().onSuccess { (response) in
			self.activityIndicator.stopAnimating()
            if let history = response.jsonDict["chatHistory"] as? NSArray {
                for message in history {
					if let message = message as? NSDictionary {
						self.chatHistory.append(ChatMessage(message))
					}
                }
            }

            self.tableView.reloadData()
			self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: false)

        }.onFailure { (error) in
			self.activityIndicator.stopAnimating()
            print(error)
        }
		
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
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		ChatSocket.sharedInstance.socket.off("recv_privatemsg")
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Helper Functions
	func keyboardWillShow(sender: NSNotification) {
		let info = sender.userInfo!

		guard let frameEnd = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
			return
		}

		guard let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
			return
		}

		let keyboardSize = frameEnd.cgRectValue.height
		bottomConstraint.constant = keyboardSize - bottomLayoutGuide.length

		let duration: TimeInterval = animationDuration.doubleValue

		UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
		if chatHistory.count > 0 {
			self.tableView.scrollToRow(at: IndexPath(row:self.chatHistory.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
		}
	}
	
	func keyboardWillHide(sender: NSNotification) {
		let info = sender.userInfo!
		guard let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else {
			return
		}
		
		let duration: TimeInterval = animationDuration.doubleValue
		bottomConstraint.constant = 0

		UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
	}
	
	public func someAction() {
		let storyboard = UIStoryboard(name: Storyboard.userDetails, bundle: Bundle.main)
		
		if let viewController = storyboard.instantiateViewController(withIdentifier: ControllerID.userDetails) as? UserDetailsViewController {
			viewController.shouldDisplayLike = false
			viewController.currentUser = user

			let navController = UINavigationController(rootViewController: viewController)
			let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissDetails))
			button.tintColor = UIColor.bandUpYellow

			navController.navigationBar.barStyle = .black
			viewController.navigationItem.rightBarButtonItem = button
			present(navController, animated: true, completion: nil)
		}

	}
	
	func dismissDetails() {
		dismiss(animated:true, completion:nil)
	}

}
// MARK: - Extensions
extension ChatViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell

		if chatHistory[indexPath.row].sender == user.id {
			cell = tableView.dequeueReusableCell(withIdentifier: chatCellOther, for: indexPath)
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: chatCellMe, for: indexPath)
		}

		if let messageCell = cell.viewWithTag(1) as? UILabel {
			messageCell.text = chatHistory[indexPath.row].message
			messageCell.sizeToFit()
		} else {
			print("Could not find MessageCell UILabel")
		}

		let messageViewCell = cell.viewWithTag(2)
		messageViewCell?.layer.cornerRadius = 12

        return cell
    }
	
}
