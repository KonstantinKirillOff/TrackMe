//
//  Date+Extension.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 07.06.2023.
//

import Foundation

extension Date {
	var getShortDate: Date? {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .none
		dateFormatter.dateStyle = .short
		let date = dateFormatter.string(from: self)
		return dateFormatter.date(from: date)
	}
	
	var stringDateRecordFormat: String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .none
		dateFormatter.dateStyle = .short
		return dateFormatter.string(from: self)
	}
}
