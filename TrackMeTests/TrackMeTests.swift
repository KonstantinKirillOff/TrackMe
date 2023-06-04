//
//  TrackMeTests.swift
//  TrackMeTests
//
//  Created by Konstantin Kirillov on 04.06.2023.
//

import XCTest
import SnapshotTesting
@testable import TrackMe

final class TrackMeTests: XCTestCase {
	func testTrackersScreen() throws {
		let uuid = UUID()
		let mockCategory = TrackerCategory(id: uuid,
										   name: "TrackerCategory",
										   trackers: [])
		
		let currentDayWeek = String(Calendar.current.component(.weekday, from: Date()))
		let setWithWeekDays = Set([currentDayWeek])
		let newTracker = Tracker(id: uuid,
								 name: "Tracker",
								 color: .blue,
								 emoji: "💩",
								 schedule: setWithWeekDays)
		
		let trackersVC = TrackersViewController()
		let dataProvider = DataProvider(TrackerStore(),
										TrackerCategoryStore(),
										TrackerRecordStore(),
										delegate: trackersVC)
		
		try? dataProvider.deleteAllTrackers()
		try? dataProvider.deleteAllCategories()
		
		try? dataProvider.addNewCategory(mockCategory)
		let mockCategoryCoreData = dataProvider.fetchCategory(by: uuid.uuidString)!
		try? dataProvider.addTracker(newTracker, category: mockCategoryCoreData)
		
		trackersVC.initialize(dataProvider: dataProvider)
		
		let trackersScreen = UINavigationController(rootViewController: trackersVC)
		trackersScreen.tabBarItem = UITabBarItem(title: "Трэкеры",
												 image: UIImage(named: "TrackersTabBar"),
												 selectedImage: nil)
		
		assertSnapshots(matching: trackersScreen, as: [.image(traits: .init(userInterfaceStyle: .light))])
		assertSnapshots(matching: trackersScreen, as: [.image(traits: .init(userInterfaceStyle: .dark))])
	}
}
