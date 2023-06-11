//
//  EditCountDaysVIew.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import UIKit

protocol EditCountDaysViewDelegate: AnyObject {
	func checkDay()
	func uncheckDay()
}

final class EditCountDaysView: UIStackView {
	weak var delegate: EditCountDaysViewDelegate?
	private var countDay: Int = 0 {
		didSet {
			if countDay < 0 { countDay = 0 }
		}
	}
	
	private lazy var minusButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = Colors.ypOrange
		button.setImage(UIImage(named: "buttonMinus"), for: .normal)
		button.addTarget(self, action: #selector(minusButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private lazy var plusButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.tintColor = Colors.ypOrange
		button.setImage(UIImage(named: "buttonPlus"), for: .normal)
		button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private lazy var countLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Colors.ypBlack
		label.font = UIFont.ypBoldSize32
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		addSubview()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func config(countDay: Int, isChecked: Bool, canCheck: Bool) {
		self.countDay = countDay
		setCountLabelText(with: self.countDay)
		
		guard !canCheck else {
			minusButton.isEnabled = false
			plusButton.isEnabled = false
			return
		}
		
		if isChecked {
			minusButton.isEnabled = true
			plusButton.isEnabled = false
		} else {
			minusButton.isEnabled = false
			plusButton.isEnabled = true
		}
	}
	
	private func setupView() {
		backgroundColor = .clear
		translatesAutoresizingMaskIntoConstraints = false
		distribution = .fill
		axis = .horizontal
		spacing = 24
	}
	
	private func addSubview() {
		[minusButton, countLabel, plusButton].forEach { addArrangedSubview($0) }
		[minusButton, plusButton].forEach({
			$0.widthAnchor.constraint(equalToConstant: 34).isActive = true
			$0.heightAnchor.constraint(equalToConstant: 34).isActive = true
		})
	}
	
	private func setCountLabelText(with count: Int) {
		countLabel.text = String.localizedStringWithFormat(
			NSLocalizedString("DayCount", comment: "count check days"), count)
	}
	
	@objc
	private func minusButtonTapped() {
		minusButton.showAnimation { [weak self] in
			guard let self else { return }
			self.countDay -= 1
			self.setCountLabelText(with: self.countDay)
			self.minusButton.isEnabled = false
			self.plusButton.isEnabled = true
			self.delegate?.uncheckDay()
		}
	}
	
	@objc
	private func plusButtonTapped() {
		plusButton.showAnimation { [weak self] in
			guard let self else { return }
			self.countDay += 1
			self.setCountLabelText(with: self.countDay)
			self.minusButton.isEnabled = true
			self.plusButton.isEnabled = false
			self.delegate?.checkDay()
		}
	}
}


