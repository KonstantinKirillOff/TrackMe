//
//  SettingsManager.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 08.06.2023.
//

import Foundation

final class SettingsManager  {
	static let shared = SettingsManager()
	let userDefaults = UserDefaults.standard
	
	var pinnedCategoryIsCreated: Bool {
		get {
			userDefaults.bool(forKey: Keys.pinnedCategoryIsCreated.rawValue)
		}
		set {
			userDefaults.set(newValue, forKey: Keys.pinnedCategoryIsCreated.rawValue)
		}
	}
	
	var pinnedCategoryId: String {
		get {
			userDefaults.string(forKey: Keys.pinnedCategoryId.rawValue) ?? ""
		}
		set {
			userDefaults.set(newValue, forKey: Keys.pinnedCategoryId.rawValue)
		}
	}
	
	private enum Keys: String {
		case pinnedCategoryIsCreated, pinnedCategoryId
	}
}
