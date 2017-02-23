//
//  SettingsTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

	@IBOutlet weak var schImperial: UISwitch!

	@IBAction func imperialChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: DefaultsKeys.settings.usesImperial)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if UserDefaults.standard.object(forKey: DefaultsKeys.settings.usesImperial) == nil {
			UserDefaults.standard.set(!Locale.current.usesMetricSystem, forKey: DefaultsKeys.settings.usesImperial)
		}

		let usesImperial = UserDefaults.standard.bool(forKey: DefaultsKeys.settings.usesImperial)
		schImperial.isOn = usesImperial
	}
	
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

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		let colorView = UIView()
		colorView.backgroundColor = UIColor.darkGray
		cell.selectedBackgroundView = colorView
		return cell
	}
}
