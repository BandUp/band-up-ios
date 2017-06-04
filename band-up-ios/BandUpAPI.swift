//
//  BandUpAPI.swift
//  band-up-ios
//
//  Created by Bergþór on 19.11.2016.
//  Copyright © 2016 Bad Melody. All rights reserved.
//

import Foundation
import Siesta

class BandUpAPI: Service {

	static let sharedInstance = BandUpAPI()

	// MARK: - Constants
	static let cookieKey = "cookie"
	static let setCookieKey = "set-cookie"
	static let hasFinishedSetup = "hasFinishedSetup"
	// MARK: - Variables
	var activeRequests = 0
	var headers =      [String:String]()
	// MARK: - Initializers
	init() {
		super.init(baseURL: Constants.bandUpAddress)

		// Put the header onto every request.
		configure {
			let uDef = UserDefaults.standard
			guard let storedHeaders = uDef.dictionary(forKey: DefaultsKeys.headers) else {
				return
			}

			if $0.headers[BandUpAPI.cookieKey] == nil {
				if let storedHeaders = storedHeaders as? [String:String] {
					$0.headers[BandUpAPI.cookieKey] = storedHeaders[BandUpAPI.cookieKey]
				}
			}
		}

		// Get the header of a response and save it.
		// Also save the hasFinishedSetup variable if it is in the payload.
		configure {
			$0.useNetworkActivityIndicator()
			$0.decorateRequests { _, req in
				req.onSuccess { (response) in
					if response.headers[BandUpAPI.setCookieKey] != nil {
						self.headers = response.headers
						UserDefaults.standard.set(self.getCookie(), forKey: DefaultsKeys.headers)
					}
					
					if let finishedSetup = response.jsonDict[BandUpAPI.hasFinishedSetup] as? Bool {
						UserDefaults.standard.set(finishedSetup, forKey: DefaultsKeys.finishedSetup)
					}
				}
			}
		}
		
		// Display the login screen when receiving a 401.
		configure(whenURLMatches: { $0 != self.login.url }) {
			$0.decorateRequests { _, req in
				req.onFailure { error in
					if error.httpStatusCode == 401 {
						if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
							appDelegate.showLoginScreen(animated: true)
							self.invalidateConfiguration()
							self.headers = [:]
							UserDefaults.standard.set([:], forKey: DefaultsKeys.headers)
							UserDefaults.standard.removeObject(forKey: DefaultsKeys.finishedSetup)
						} else {
							print("Couldn't find AppDelegate")
						}
					}
				}
			}
		}

		configure(whenURLMatches: { $0 == self.deleteAccount.url || $0 == self.logout.url }) {
			$0.decorateRequests { _, req in
				req.onSuccess { (response) in
					self.invalidateConfiguration()
					self.headers = [:]
					UserDefaults.standard.set([:], forKey: DefaultsKeys.headers)
					UserDefaults.standard.removeObject(forKey: DefaultsKeys.finishedSetup)

				}
			}
		}
	}

	// MARK: - Resources
	var register:       Resource { return resource("/signup-local")    }
	var login:          Resource { return resource("/login-local")     }
	var instruments:    Resource { return resource("/instruments")     }
	var genres:         Resource { return resource("/genres")          }
	var isLoggedIn:     Resource { return resource("/isLoggedIn")      }
	var matches:        Resource { return resource("/matches")         }
	var nearby:         Resource { return resource("/v2/users/nearby") }
	var like:           Resource { return resource("/like")            }
    var profile:        Resource { return resource("/user")            }
    var chatHistory:    Resource { return resource("/chat_history")    }
	var editProfile:    Resource { return resource("/edit-user")       }
	var deleteAccount:  Resource { return resource("/user-delete")     }
	var logout:         Resource { return resource("/logout")          }
	var loginGoogle:    Resource { return resource("/login-google")    }
	var loginFacebook:  Resource { return resource("/login-facebook")  }
	var profilePicture: Resource { return resource("/profile-picture") }
	var resetPassword:  Resource { return resource("/reset-password")  }

	// MARK: - Helper Functions
	private func getCookie() -> [String:String] {
		if let setCookie = self.headers[BandUpAPI.setCookieKey] {
			return [BandUpAPI.cookieKey : setCookie]
		} else {
			return [:]
		}
	}
	
}
