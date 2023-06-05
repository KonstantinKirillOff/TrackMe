//
//  AnalyticService.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 05.06.2023.
//

import Foundation
import YandexMobileMetrica

protocol AnalyticServiceProtocol {
	func sendEvent(event: String, parameters: [AnyHashable : Any])
}

final class AnalyticServiceManager: AnalyticServiceProtocol {
	static let shared = AnalyticServiceManager()
	
	func activate() {
		guard let configuration = YMMYandexMetricaConfiguration(apiKey: "a2271c55-ea27-4cfc-bfb4-8946d6c427a2") else { return }
		YMMYandexMetrica.activate(with: configuration)
	}
	
	func sendEvent(event: String, parameters: [AnyHashable : Any]) {
		YMMYandexMetrica.reportEvent(event, parameters: parameters) { error in
			print("REPORT ERROR: @", error.localizedDescription)
		}
	}
	
	private init() {}
}
