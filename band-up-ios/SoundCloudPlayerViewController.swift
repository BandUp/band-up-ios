//
//  SoundCloudPlayerViewController.swift
//  band-up-ios
//
//  Created by Bergþór on 4.3.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import AVFoundation
import Soundcloud

class SoundCloudPlayerViewController: UIViewController {

	// MARK: - IBOutlets
	@IBOutlet weak var songSlider: UISlider!
	@IBOutlet weak var lblTimeElapsed: UILabel!
	@IBOutlet weak var lblTimeTotal: UILabel!
	// MARK: - Variables
	var player = AVPlayer()
	var trackUrl: String?

	// MARK: - UIViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	override func viewWillAppear(_ animated: Bool) {
		if trackUrl == nil || trackUrl == "" {
			self.lblTimeTotal.isHidden = true
			self.lblTimeElapsed.isHidden = true
			self.songSlider.isHidden = true

		}

		Soundcloud.resolve(URI: trackUrl!) { [weak self] response in

			if case .failure(let error) = response.response {
				dump(error)
			} else {
				guard let result = response.response.result else {
					return
				}

				guard let trackList = result.tracks else {
					return
				}
				if trackList[0].streamable {
					let playerItem = AVPlayerItem(url:trackList[0].streamURL!)
					self?.player = AVPlayer(playerItem:playerItem)
					self?.player.rate = 1.0
					//player.play()
					self?.songSlider.maximumValue = Float(playerItem.asset.duration.seconds)

					let bla = DateFormatter()
					bla.dateFormat = "mm:ss"
					let timeString = bla.string(from: Date(timeIntervalSince1970: playerItem.asset.duration.seconds))
					self?.lblTimeTotal.text = timeString

					let interval = CMTimeMakeWithSeconds(0.1, Int32(NSEC_PER_SEC))

					self?.player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { (time) in
						self?.self.songSlider.setValue(Float(time.seconds), animated: false)
						let bla = DateFormatter()
						bla.dateFormat = "mm:ss"
						let timeString = bla.string(from: Date(timeIntervalSince1970: time.seconds))
						self?.self.lblTimeElapsed.text = timeString
					}
					self?.lblTimeTotal.isHidden = false
					self?.lblTimeElapsed.isHidden = false
					self?.songSlider.isHidden = false
				}
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		player.pause()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
