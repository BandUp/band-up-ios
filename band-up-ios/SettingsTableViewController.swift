//
//  SettingsTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import MARKRangeSlider

class SettingsTableViewController: UITableViewController {

	@IBOutlet weak var schMatches: UISwitch!
	@IBOutlet weak var schInactive: UISwitch!
	@IBOutlet weak var schMessages: UISwitch!
	@IBOutlet weak var schImperial: UISwitch!
	@IBOutlet weak var lblRadius: UILabel!
	@IBOutlet weak var rangeSlider: MARKRangeSlider!
	@IBOutlet weak var lblAges: UILabel!
	@IBOutlet weak var sldRadius: UISlider!

	@IBAction func agesChanged(_ sender: MARKRangeSlider) {
		let maxAge = Int(round(sender.rightValue))
		let minAge = Int(round(sender.leftValue))
		if minAge != maxAge {
			lblAges.text = "\(minAge) til \(maxAge)"
		} else {
			lblAges.text = "\(minAge)"
		}


		UserDefaults.standard.set(sender.rightValue, forKey: DefaultsKeys.Settings.maxAge)
		UserDefaults.standard.set(sender.leftValue, forKey: DefaultsKeys.Settings.minAge)
	}

	@IBAction func matchesChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: DefaultsKeys.Settings.shouldNotifyMatches)
	}

	@IBAction func inactiveChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: DefaultsKeys.Settings.shouldNotifyInactivity)
	}

	@IBAction func messagesChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: DefaultsKeys.Settings.shouldNotifyMessage)
	}

	@IBAction func imperialChanged(_ sender: UISwitch) {
		UserDefaults.standard.set(sender.isOn, forKey: DefaultsKeys.Settings.usesImperial)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UnitsChanged"), object: nil, userInfo: ["usesImperial": sender.isOn])
		radiusChanged(sldRadius)

	}

	@IBAction func radiusChanged(_ sender: UISlider) {
		UserDefaults.standard.set(sender.value, forKey: DefaultsKeys.Settings.radius)
		let localizedString = NSLocalizedString("settings_radius", comment: "")
		var resultString: String
		if schImperial.isOn {
			let distance = Int(((round(sender.value / 5)) * 5)*0.621371192)
			let distanceString = String(format: localizedString, String(distance))
			let localizedUnits = NSLocalizedString("settings_distance_mi", comment: "")
			resultString = "\(distanceString) \(localizedUnits)"
		} else {
			let distance = Int((round(sender.value / 5)) * 5)
			let distanceString = String(format: localizedString, String(distance))
			let localizedUnits = NSLocalizedString("settings_distance_km", comment: "")
			resultString = "\(distanceString) \(localizedUnits)"
		}
		lblRadius.text = resultString
		sender.setValue((round(sender.value / 5)) * 5, animated: true)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if UserDefaults.standard.object(forKey: DefaultsKeys.Settings.usesImperial) == nil {
			UserDefaults.standard.set(!Locale.current.usesMetricSystem, forKey: DefaultsKeys.Settings.usesImperial)
		}
		rangeSlider.disableOverlapping = false
		rangeSlider.rangeImage = UIImage.fromColor(color: .bandUpYellow)
		rangeSlider.tintColor = UIColor.bandUpYellow
		rangeSlider.setMinValue(CGFloat(Constants.minAge), maxValue: CGFloat(Constants.maxAge))
		rangeSlider.setLeftValue(CGFloat(Constants.minAge), rightValue: CGFloat(Constants.maxAge))

		initializeNotificationSettings(forKey: DefaultsKeys.Settings.shouldNotifyMatches, value: true)
		initializeNotificationSettings(forKey: DefaultsKeys.Settings.shouldNotifyInactivity, value: true)
		initializeNotificationSettings(forKey: DefaultsKeys.Settings.shouldNotifyMessage, value: true)

		let shouldNotifyMatches = UserDefaults.standard.bool(forKey: DefaultsKeys.Settings.shouldNotifyMatches)
		let shouldNotifyInactivity = UserDefaults.standard.bool(forKey: DefaultsKeys.Settings.shouldNotifyInactivity)
		let shouldNotifyMessage = UserDefaults.standard.bool(forKey: DefaultsKeys.Settings.shouldNotifyMessage)

		let usesImperial = UserDefaults.standard.bool(forKey: DefaultsKeys.Settings.usesImperial)

		schMatches.isOn = shouldNotifyMatches
		schInactive.isOn = shouldNotifyInactivity
		schMessages.isOn = shouldNotifyMessage
		schImperial.isOn = usesImperial

		let radius = UserDefaults.standard.float(forKey: DefaultsKeys.Settings.radius)

		sldRadius.setValue(radius, animated: false)
		radiusChanged(sldRadius)
	}

	func initializeNotificationSettings(forKey key: String, value: Bool) {
		if UserDefaults.standard.object(forKey: key) == nil {
			UserDefaults.standard.set(value, forKey: key)
		}
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

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "SettingsView", bundle: Bundle.main)

		switch indexPath.section {
			case 4:
				switch indexPath.row {
					case 0:
						let privacyVC = storyboard.instantiateViewController(withIdentifier: "PrivacyViewController")
						navigationController?.pushViewController(privacyVC, animated: true)
						break
					case 1:
						let openSourceVC = storyboard.instantiateViewController(withIdentifier: "OpenSourceTableViewController")
						navigationController?.pushViewController(openSourceVC, animated: true)
						break
					default:
						break
				}
			default:
				break
		}
	}

}

extension UIImage {
	static func fromColor(color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		context!.setFillColor(color.cgColor)
		context!.fill(rect)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return img!
	}
}
