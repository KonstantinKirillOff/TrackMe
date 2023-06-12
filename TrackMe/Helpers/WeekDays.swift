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
	
	static func getDayFromNumber(dayNumber: String) -> WeekDay {
		if dayNumber == "2" {
			return WeekDay.monday
		} else if dayNumber == "3" {
			return WeekDay.tuesday
		} else if dayNumber == "4" {
			return WeekDay.wednesday
		} else if dayNumber == "5" {
			return WeekDay.thursday
		} else if dayNumber == "6" {
			return WeekDay.friday
		} else if dayNumber == "7" {
			return WeekDay.saturday
		} else {
			return WeekDay.sunday
		}
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
