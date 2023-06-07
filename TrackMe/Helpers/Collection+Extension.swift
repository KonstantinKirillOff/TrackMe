//
//  Collection+Extension.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import Foundation

extension Collection {
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
