//
//  SettingsTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == 5 {
			guard let bundleName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] else {
				return nil
			}
			guard let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] else {
				return "\(bundleName)"
			}
			guard let bundleBuild = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] else {
				return "\(bundleName) \(bundleVersion)"
			}
			
			return "\(bundleName) \(bundleVersion) (\(bundleBuild))"
		}
		return nil
	}
}
