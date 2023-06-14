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
		let mockDataProvider = MockDataProvider()
		mockDataProvider.initilizeMock()
		
		let datePickerDate = "2023-06-13T00:00:00+0000"
		let dateFormatter = ISO8601DateFormatter()
		let specificDate = dateFormatter.date(from: datePickerDate)!
		
		let trackersVC = TrackersViewController()
		trackersVC.initialize(dataProvider: mockDataProvider, date: specificDate)
		
		let trackersScreen = UINavigationController(rootViewController: trackersVC)
				trackersScreen.tabBarItem = UITabBarItem(title: "Трэкеры",
														 image: UIImage(named: "TrackersTabBar"),
														 selectedImage: nil)
		
		assertSnapshots(matching: trackersScreen, as: [.image(traits: .init(userInterfaceStyle: .light))])
		assertSnapshots(matching: trackersScreen, as: [.image(traits: .init(userInterfaceStyle: .dark))])
	}
}

final class MockDataProvider: IDataProviderProtocol {
	var category: TrackerCategory!
	var numberOfSections: Int = 1
	
	func numberOfRowsInSection(_ section: Int) -> Int {
		category.trackers.count
	}
	
	func nameOfSection(_ section: Int) -> String {
		category.name
	}
	
	func addTracker(_ record: TrackMe.Tracker, category: TrackMe.TrackerCategoryCoreData) throws {}
	
	func changeTracker(tracker: TrackMe.Tracker, category: TrackMe.TrackerCategoryCoreData) throws {}
	
	func getTrackerCoreData(at indexPath: IndexPath) -> TrackMe.TrackerCoreData? { nil }
	
	func fetchTracker(by id: String) -> TrackMe.TrackerCoreData? { nil }
	
	func getTrackerObject(at: IndexPath) -> TrackMe.Tracker? {
		category.trackers[at.row]
	}
	
	func countRecordForTracker(trackerID: String) -> Int { 6 }
	
	func trackerTrackedToday(date: Date, trackerID: String) -> Bool { true }
	
	func addTrackerRecord(_ trackerRecord: TrackMe.TrackerRecord, for tracker: TrackMe.TrackerCoreData) throws {}
	
	func deleteRecord(date: Date, trackerID: String) {}
	
	func deleteAllTrackers() throws {}
	
	func deleteTracker(by id: String) throws {}
	
	func addNewCategory(_ trackerCategory: TrackMe.TrackerCategory) throws {}
	
	func fetchCategory(by id: String) -> TrackMe.TrackerCategoryCoreData? { nil }
	
	func deleteAllCategories() throws {}
	
	func fetchResultControllerIsEmpty() -> Bool { false }
	
	func addFiltersForFetchResultController(searchControllerText searchString: String,
											currentDay day: Date,
											filtersForTrackerList: TrackMe.FilterType) throws {}
	
	func changePinStatusForTracker(tracker: TrackMe.Tracker, pinStatus: TrackMe.PinStatus) throws {}
	
	func initilizeMock() {
		let currentDayWeek = String(Calendar.current.component(.weekday, from: Date()))
		let setWithWeekDays = Set([currentDayWeek])
		category = TrackerCategory(id: UUID(),
								   name: "TrackerCategory",
								   trackers:
									[
										Tracker(id: UUID(),
												name: "Tracker",
												color: .blue,
												emoji: "💩",
												schedule: setWithWeekDays,
												isHabit: false,
												idCategoryBeforePin: nil,
												isPinned: false)
									])
	}
	
	
}
