//
//  ViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 28.03.2023.
//

import UIKit

final class TabBarViewController: UITabBarController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let trackersVC = TrackersViewController()
		let dataProvider = DataProvider(TrackerStore(),
									TrackerCategoryStore(),
									TrackerRecordStore(),
									delegate: trackersVC)
		
		trackersVC.initialize(dataProvider: dataProvider)
		
		let trackersScreen = UINavigationController(rootViewController: trackersVC)
		let trackerScreenTitle = NSLocalizedString("tabBarItemTracker", comment: "Text displayed on tapBat for trackers screen")
		trackersScreen.tabBarItem = UITabBarItem(title: trackerScreenTitle,
											 image: UIImage(named: "TrackersTabBar"),
											 selectedImage: nil)
		
		let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
		let statisticsScreenTitle = NSLocalizedString("tabBarItemStatistics", comment: "Text displayed on tapBat for statistics screen")
		statisticsVC.tabBarItem = UITabBarItem(title: statisticsScreenTitle,
											   image: UIImage(named: "StatisticTabBar"),
											   selectedImage: nil)
		
		self.viewControllers = [trackersScreen, statisticsVC]
	}
}

