//
//  RemoteImageView.swift
//  band-up-ios
//
//  Created by Bergþór on 24.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

import UIKit
import Siesta

protocol RemoteImageViewDelegate: class {
	func didFinishLoading()
	func imageWillLoad()
}

class RemoteImageView: UIImageView {
	static var imageCache: Service = Service()

	var placeholderImage: UIImage?

	weak var delegate: RemoteImageViewDelegate?

	var imageURL: URL? {
		get {
			return imageResource?.url
		}
		set {
			imageResource = RemoteImageView.imageCache.resource(absoluteURL: newValue)
		}
	}

	var imageResource: Resource? {
		willSet {
			imageResource?.removeObservers(ownedBy: self)
			imageResource?.cancelLoadIfUnobserved(afterDelay: 0.05)
		}

		didSet {

			self.image = nil
			if let delegate = delegate {
				delegate.imageWillLoad()
				let resource = imageResource?.loadIfNeeded()
				if resource == nil {
					delegate.didFinishLoading()
				}
			} else {
				_ = imageResource?.loadIfNeeded()
			}

			imageResource?.addObserver(owner: self) { [weak self] _ in

				let imageResult: UIImage? = self?.imageResource?.typedContent()

				if !(self?.imageResource?.isLoading)! {
					if imageResult != nil {
						self?.image = imageResult
					} else {
						self?.image = self?.placeholderImage
					}

					if let delegate = self?.delegate {
						delegate.didFinishLoading()
					}
				}

			}
		}
	}
}
