//
//  WeekDays.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 22.04.2023.
//

import Foundation

enum WeekDay: String, CaseIterable {
	case monday = "Пн"
	case tuesday = "Вт"
	case wednesday = "Ср"
	case thursday = "Чт"
	case friday = "Пт"
	case saturday = "Сб"
	case sunday = "Вс"
	
	static func getWeekDayInNumber(for date: Date) -> String {
		String(Calendar.current.component(.weekday, from: date))
	}
	
	func getNumberDay() -> String {
		switch self {
		case .monday:
			return "2"
		case .tuesday:
			return "3"
		case .wednesday:
			return "4"
		case .thursday:
			return "5"
		case .friday:
			return "6"
		case .saturday:
			return "7"
		case .sunday:
			return "1"
		}
	}
	
	func getDayOnRussian() -> String {
		switch self {
		case .monday:
			return "Понедельник"
		case .tuesday:
			return "Вторник"
		case .wednesday:
			return "Среда"
		case .thursday:
			return "Четверг"
		case .friday:
			return "Пятница"
		case .saturday:
			return "Суббота"
		case .sunday:
			return "Воскресенье"
		}
	}
}
