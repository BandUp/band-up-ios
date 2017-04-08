//
//  SearchTableViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 9.3.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import MARKRangeSlider

class SearchTableViewController: UITableViewController {

	@IBOutlet weak var txtName: UITextField!
	@IBOutlet weak var tagInstruments: BMItemBoxList!
	@IBOutlet weak var tagGenres: BMItemBoxList!
	@IBOutlet weak var lblAges: UILabel!
	@IBOutlet weak var rangeSlider: MARKRangeSlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

		tagInstruments.strings = ["No Instrument Selected"]
		tagGenres.strings = ["No Genre Selected"]

		rangeSlider.disableOverlapping = false
		rangeSlider.rangeImage = UIImage.fromColor(color: .bandUpYellow)
		rangeSlider.tintColor = UIColor.bandUpYellow
		rangeSlider.setMinValue(CGFloat(Constants.minAge), maxValue: CGFloat(Constants.maxAge))
		rangeSlider.setLeftValue(CGFloat(Constants.minAge), rightValue: CGFloat(Constants.maxAge))
		updateAges()

		let nameString = "search_find_username".localized
		let nameStr = NSAttributedString(string: nameString, attributes: [NSForegroundColorAttributeName:UIColor.gray])

		txtName.attributedPlaceholder = nameStr
		tableView.keyboardDismissMode = .interactive

		txtName.keyboardAppearance = .dark

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(didTapSearch))
		self.navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(didTapCancel))
		self.title = "search_title".localized
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func didTapSearch() {
		print("Search")
		dismiss(animated: true, completion: nil)
	}

	func didTapCancel() {
		print("Search")
		dismiss(animated: true, completion: nil)
	}

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}

	@IBAction func agesChanged(_ sender: MARKRangeSlider) {
		updateAges()
	}

	func updateAges() {
		let maxAge = Int(round(rangeSlider.rightValue))
		let minAge = Int(round(rangeSlider.leftValue))
		if minAge != maxAge {
			let locString = "settings_age_between".localized
			lblAges.text = String(format: locString, String(minAge), String(maxAge))
		} else {
			let locString = "settings_age_single".localized
			lblAges.text = String(format: locString, String(minAge))
		}
	}

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
