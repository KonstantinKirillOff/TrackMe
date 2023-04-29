//
//  CustomTextField.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 29.04.2023.
//

import UIKit

final class BaseTextField: UITextField {
	
	let textPadding = UIEdgeInsets(top: 27, left: 16, bottom: 27, right: 16)
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		let rect = super.textRect(forBounds: bounds)
		return rect.inset(by: textPadding)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		let rect = super.editingRect(forBounds: bounds)
		return rect.inset(by: textPadding)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		autocorrectionType = UITextAutocorrectionType.no
		keyboardType = UIKeyboardType.default
		returnKeyType = UIReturnKeyType.done
		clearButtonMode = UITextField.ViewMode.whileEditing
		
		font = UIFont.systemFont(ofSize: 17)
		backgroundColor = UIColor.ypBackground
		layer.cornerRadius = 16
		placeholder  = "Введите название трэкера"
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
