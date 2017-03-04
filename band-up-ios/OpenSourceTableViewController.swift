//
//  OpenSourceTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 24.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class OpenSourceTableViewController: UITableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		title = NSLocalizedString("settings_open_source", comment: "")
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			UIApplication.shared.openURL(NSURL(string: "https://github.com/bustoutsolutions/siesta")! as URL)
		} else if indexPath.section == 1 {
			UIApplication.shared.openURL(NSURL(string: "https://github.com/ykyouhei/KYDrawerController")! as URL)
		} else if indexPath.section == 2 {
			UIApplication.shared.openURL(NSURL(string: "https://github.com/socketio/socket.io-client-swift")! as URL)
		} else if indexPath.section == 3 {
			UIApplication.shared.openURL(NSURL(string: "https://github.com/skywinder/ActionSheetPicker-3.0")! as URL)
		} else if indexPath.section == 4 {
			UIApplication.shared.openURL(NSURL(string: "https://github.com/mokagio/UICollectionViewLeftAlignedLayout")! as URL)
		} else if indexPath.section == 5 {
			UIApplication.shared.openURL(NSURL(string: "https://github.com/vadymmarkov/MARKRangeSlider")! as URL)
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let headerView = view as? UITableViewHeaderFooterView else {
			return
		}
		
		headerView.tintColor = UIColor.bandUpYellow
	}
	
}
