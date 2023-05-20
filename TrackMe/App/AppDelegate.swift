//
//  AppDelegate.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 28.03.2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
		window?.makeKeyAndVisible()
		window?.rootViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

		return true
	}
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "TrackersCoreDataModel")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			print("storeDescription: \(storeDescription)")
			if let error = error as NSError? {
				assertionFailure("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
}

