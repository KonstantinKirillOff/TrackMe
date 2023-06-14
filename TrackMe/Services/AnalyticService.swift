//
//  AnalyticService.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 05.06.2023.
//

import Foundation
import YandexMobileMetrica

protocol AnalyticServiceProtocol {
	func sendEvent(event: AnalyticServiceManager.Events, parameters: [AnyHashable : Any])
}

final class AnalyticServiceManager: AnalyticServiceProtocol {
	static let shared = AnalyticServiceManager()
	
	private init() {}
	
	enum Events: String {
		case open
		case close
		case click
	}
	
	enum EventParameters: String {
		case screen
		case item
	}
	
	enum Screens: String {
		case main
	}
	
	enum Items: String {
		case add_track
		case track
		case filter
		case edit
		case delete
	}
	
	func activate() {
		guard let configuration = YMMYandexMetricaConfiguration(apiKey: "a2271c55-ea27-4cfc-bfb4-8946d6c427a2") else { return }
		YMMYandexMetrica.activate(with: configuration)
	}
	
	func sendEvent(event: Events, parameters: [AnyHashable : Any]) {
		YMMYandexMetrica.reportEvent(event.rawValue, parameters: parameters) { error in
			print("REPORT ERROR: @", error.localizedDescription)
		}
	}
}
