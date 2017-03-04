//
//  band_up_iosTests.swift
//  band-up-iosTests
//
//  Created by Bergþór on 16.2.2017.
//  Copyright © 2017 Bad Melody. All rights reserved.
//

@testable import band_up_ios
import XCTest
import CoreLocation

class UserInitTests: XCTestCase {

	var userDictionary: [String:Any] = [:]
	var user = User()

	override func setUp() {
		super.setUp()
		userDictionary["username"] = "TestName"
		userDictionary["aboutme"] = "Hello my Friends!"
		userDictionary["_id"] = "asdf1234"
		userDictionary["distance"] = 13.56
		userDictionary["favoriteinstrument"] = "myInstrument"
		userDictionary["genres"] = ["Genre1", "Genre2"]
		userDictionary["instruments"] = ["Instrument1", "Instrument2"]
		userDictionary["isLiked"] = true
		userDictionary["percentage"] = 50
		userDictionary["soundCloudId"] = 600
		userDictionary["soundCloudSongName"] = "SCSongName"
		userDictionary["soundcloudurl"] = "SCURL"
		userDictionary["status"] = "MyStatus"

	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testInitWithDictionary() {
		// Arrange

		// Act
		user = User(userDictionary as NSDictionary)

		// Assert
		XCTAssert(user.username == "TestName")
		XCTAssert(user.aboutme == "Hello my Friends!")
		XCTAssert(user.id == "asdf1234")
		XCTAssert(user.distance == 13.56)
		XCTAssert(user.favouriteInstrument == "myInstrument")

		XCTAssert(user.genres.count == 2)
		XCTAssert(user.genres.contains("Genre1"))
		XCTAssert(user.genres.contains("Genre2"))

		XCTAssert(user.instruments.count == 2)
		XCTAssert(user.instruments.contains("Instrument1"))
		XCTAssert(user.instruments.contains("Instrument2"))

		XCTAssert(user.isLiked == true)
		XCTAssert(user.percentage == 50)
		XCTAssert(user.soundCloudId == 600)
		XCTAssert(user.soundCloudSongName == "SCSongName")
		XCTAssert(user.soundCloudURL == "SCURL")
		XCTAssert(user.status == "MyStatus")

	}

	func testInitEmpty() {
		// Arrange

		// Act
		user = User()

		// Assert
		XCTAssert(user.username == "")
		XCTAssert(user.aboutme == "")
		XCTAssert(user.id == "")
		XCTAssert(user.distance == 0)
		XCTAssert(user.favouriteInstrument == "")
		XCTAssert(user.genres.count == 0)
		XCTAssert(user.instruments.count == 0)
		XCTAssert(user.isLiked == false)
		XCTAssert(user.percentage == 0)
		XCTAssert(user.soundCloudId == 0)
		XCTAssert(user.soundCloudSongName == "")
		XCTAssert(user.soundCloudURL == "")
		XCTAssert(user.status == "")
	}

	func testUserParsing() {
		// This is an example of a performance test case.
		self.measure {
			self.user = User(self.userDictionary as NSDictionary)
		}
	}

	func testDistanceStringInvalidLocation() {
		// Arrange
		var userLocationDictionary: [String:Any] = [:]
		userLocationDictionary["lat"] = 64.0
		userLocationDictionary["lon"] = -21.0
		userLocationDictionary["valid"] = false

		userDictionary["location"] = userLocationDictionary

		user = User(userDictionary as NSDictionary)

		// Act
		let expectedString = NSLocalizedString("no_distance_available", comment: "")

		// Assert
		XCTAssertEqual(user.getDistanceString(), expectedString)
	}

	func testDistanceStringValidLocation() {
		// Arrange
		var userLocationDictionary: [String:Any] = [:]
		userLocationDictionary["lat"] = 64.0
		userLocationDictionary["lon"] = -21.0
		userLocationDictionary["valid"] = true

		userDictionary["location"] = userLocationDictionary

		user = User(userDictionary as NSDictionary)

		// Act
		let expectedString = NSLocalizedString("km_distance", comment: "")

		// Assert
		XCTAssertEqual(user.getDistanceString(), expectedString)
	}

}
