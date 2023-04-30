//
//  UIColor+Extension.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 29.04.2023.
//

import UIKit

extension UIColor {
	static let ypBackground = UIColor(named: "YPBackground")
	static let ypGray = UIColor(named: "YPGray")
	static let ypBlue = UIColor(named: "YPBlue")
	static let ypBlack = UIColor(named: "YPBlack")
	static let ypRed = UIColor(named: "YPRed")
	static let ypWhite = UIColor(named: "YPWhite")
	static let ypLightGray = UIColor(named: "YPLightGray")
}

extension UIColor {
	var toHexString: String {
		let components = self.cgColor.components
		let r: CGFloat = components?[0] ?? 0.0
		let g: CGFloat = components?[1] ?? 0.0
		let b: CGFloat = components?[2] ?? 0.0
		
		return String.init(
			format: "%02lX%02lX%02lX",
			lroundf(Float(r * 255)),
			lroundf(Float(g * 255)),
			lroundf(Float(b * 255))
		)
	}
	
	static func color(fromHex hex: String) -> UIColor {
		var rgbValue:UInt64 = 0
		Scanner(string: hex).scanHexInt64(&rgbValue)
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}

