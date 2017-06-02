//
//  ErrorViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 1.6.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

	@IBOutlet weak var btnSettings: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
		self.parent?.navigationItem.rightBarButtonItem = nil

		btnSettings.layer.backgroundColor = UIColor.bandUpYellow.cgColor
		btnSettings.layer.cornerRadius = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func didTapSettings(_ sender: Any) {
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
		} else {
			// Fallback on earlier versions
		}
	}
}
