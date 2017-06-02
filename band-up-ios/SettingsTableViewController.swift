//
//  SettingsTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 9.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import MARKRangeSlider
import MessageUI
import MapKit

class SettingsTableViewController: UITableViewController {

	// MARK: - IBOutlets
	@IBOutlet weak var schMatches: UISwitch!
	@IBOutlet weak var schInactive: UISwitch!
	@IBOutlet weak var schMessages: UISwitch!
	@IBOutlet weak var schImperial: UISwitch!
	@IBOutlet weak var lblRadius: UILabel!
	@IBOutlet weak var rangeSlider: MARKRangeSlider!
	@IBOutlet weak var lblAges: UILabel!
	@IBOutlet weak var sldRadius: UISlider!

	// MARK: - IBActions
	@IBAction func agesChanged(_ sender: MARKRangeSlider) {
		let maxAge = Int(round(sender.rightValue))
		let minAge = Int(round(sender.leftValue))
		if minAge != maxAge {
			let locString = "settings_age_between".localized
			lblAges.text = String(format: locString, String(minAge), String(maxAge))
		} else {
			let locString = "settings_age_single".localized
			lblAges.text = String(format: locString, String(minAge))
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

		// Set up the distance formatter.
		let formatter = MKDistanceFormatter()
		formatter.unitStyle = .full

		if schImperial.isOn {
			formatter.units = .imperial
		} else {
			formatter.units = .metric
		}

		// Selected distance in kilometers.
		let distance = ((round(sender.value / 5)) * 5)

		let formattedDistance = formatter.string(fromDistance: CLLocationDistance(distance*1000))
		let distanceString = String(format: localizedString, formattedDistance)

		// Set the title text of the distance slider.
		lblRadius.text = distanceString

		sender.setValue(distance, animated: true)
	}

	// MARK: - UITableViewController Overrides
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

		let leftAge = UserDefaults.standard.float(forKey: DefaultsKeys.Settings.minAge)
		let rightAge = UserDefaults.standard.float(forKey: DefaultsKeys.Settings.maxAge)

		sldRadius.setValue(radius, animated: false)
		radiusChanged(sldRadius)
		rangeSlider.setLeftValue(CGFloat(leftAge), rightValue: CGFloat(rightAge))
		agesChanged(rangeSlider)
	}

	// MARK: - UITableView Overrides
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

	override func tableView(_ tableView: UITableView,
	                        didSelectRowAt indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: Storyboard.settings, bundle: Bundle.main)

		switch indexPath.section {
			case 3:
				displayMailComposer()
				break
			case 4:
				switch indexPath.row {
					case 0:
						let privacyVC = storyboard.instantiateViewController(withIdentifier: ControllerID.privacy)
						navigationController?.pushViewController(privacyVC, animated: true)
						break
					case 1:
						let openSourceVC = storyboard.instantiateViewController(withIdentifier: ControllerID.openSource)
						navigationController?.pushViewController(openSourceVC, animated: true)
						break
					default:
						break
				}
			case 5:
				displayDeleteAccountAlert()
				tableView.deselectRow(at: indexPath, animated: true)
				break
			default:
				break
		}
	}

	// MARK: - Helper Functions
	func initializeNotificationSettings(forKey key: String, value: Bool) {
		if UserDefaults.standard.object(forKey: key) == nil {
			UserDefaults.standard.set(value, forKey: key)
		}
	}

	func displayMailComposer() {
		let mailVC = MFMailComposeViewController()
		mailVC.mailComposeDelegate = self
		mailVC.setToRecipients([Constants.supportEmail])
		guard let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] else {
			return
		}
		guard let bundleBuild = Bundle.main.infoDictionary?[kCFBundleVersionKey as String] else {
			return
		}

		let subject = String(format: "Help with Band Up for iOS %@ (%@)", String(describing: bundleVersion), String(describing: bundleBuild))
		mailVC.setSubject(subject)

		present(mailVC, animated: true, completion: nil)
	}

	func displayDeleteAccountAlert() {
		let alertController = UIAlertController (title: "settings_alert_delete_title".localized, message: "settings_alert_delete_message".localized, preferredStyle: .actionSheet)

		let settingsAction = UIAlertAction(title: "settings_delete_account".localized, style: .destructive) { (_) -> Void in
			BandUpAPI.sharedInstance.deleteAccount.request(.delete).onSuccess { (response) in
				let storyboard = UIStoryboard(name: Storyboard.setup, bundle: Bundle.main)
				if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
					appDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()
					BandUpAPI.sharedInstance.invalidateConfiguration()
					BandUpAPI.sharedInstance.headers = [:]
					UserDefaults.standard.set([:], forKey: DefaultsKeys.headers)
				} else {
					print("Could not find AppDelegate")
				}
				}.onFailure { (error) in
					let failAlertController = UIAlertController(title: "settings_alert_delete_error_title".localized, message: "settings_alert_delete_error_message".localized, preferredStyle: .alert)

					let okAction = UIAlertAction(title: "search_ok".localized, style: .default, handler: nil)

					failAlertController.addAction(okAction)
					failAlertController.preferredAction = okAction

					self.present(failAlertController, animated: true, completion: nil)
			}
		}

		let cancelAction = UIAlertAction(title: "search_cancel".localized, style: .cancel, handler: nil)

		alertController.addAction(cancelAction)
		alertController.addAction(settingsAction)
		alertController.preferredAction = settingsAction

		present(alertController, animated: true, completion: nil)
	}

}

// MARK: - Extensions
// MARK: Mail Composer
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {

	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}

}

// MARK: UIImage From Color
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
