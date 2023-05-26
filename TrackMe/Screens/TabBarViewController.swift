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
		
		let trackersVC = UINavigationController(rootViewController: TrackersViewController())
		trackersVC.tabBarItem = UITabBarItem(title: "Трэкеры",
											 image: UIImage(named: "TrackersTabBar"),
											 selectedImage: nil)
		
		let statisticsVC = UINavigationController(rootViewController: StatisticsViewController())
		statisticsVC.tabBarItem = UITabBarItem(title: "Статистика",
											   image: UIImage(named: "StatisticTabBar"),
											   selectedImage: nil)
		
		self.viewControllers = [trackersVC, statisticsVC]
	}
}

