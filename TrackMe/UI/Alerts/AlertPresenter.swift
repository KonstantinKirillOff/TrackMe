//
//  AlertPresenter.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 21.05.2023.
//

import UIKit

protocol IAlertPresenterProtocol {
	func preparingAlertController(alertTitle: String?, alertMessage: String, alertActions: [UIAlertAction], alertType: UIAlertController.Style)
}

protocol IAlertPresenterDelegate: AnyObject {
	func showAlert(alert: UIAlertController)
}

struct AlertPresenter: IAlertPresenterProtocol {
	weak var delegate: IAlertPresenterDelegate?
		
	func preparingAlertController(alertTitle: String?, alertMessage: String, alertActions: [UIAlertAction], alertType: UIAlertController.Style) {
		let alert = UIAlertController(title: alertTitle,
									  message: alertMessage,
									  preferredStyle: alertType)
		
		alertActions.forEach { action in
			alert.addAction(action)
		}
		
		delegate?.showAlert(alert: alert)
	}
}
