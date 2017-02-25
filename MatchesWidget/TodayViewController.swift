//
//  TodayViewController.swift
//  MatchesWidget
//
//  Created by Bergþór on 24.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
		activityIndicator.startAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
		activityIndicator.stopAnimating()
        print("Widget Update")
        completionHandler(NCUpdateResult.noData)
    }
    
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 4
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
		let image = cell.viewWithTag(1) as! UIImageView
		let name = cell.viewWithTag(2) as! UILabel
		let message = cell.viewWithTag(3) as! UILabel
		image.clipsToBounds = true
		image.layer.cornerRadius = image.frame.width/2
		name.text = "Username \(indexPath.row+1)"
		if indexPath.row == 0 {
			message.isHidden = false
		} else {
			message.isHidden = true
		}

		return cell
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

		let frameWidth: CGFloat = collectionView.frame.width
		let itemWidth: CGFloat = (frameWidth / CGFloat(4.0))


		return CGSize(width: itemWidth, height: CGFloat(110))
	}
}
