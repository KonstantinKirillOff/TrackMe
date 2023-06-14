//
//  FiltersProvider.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import UIKit

protocol FilterCollectionViewProviderDelegate: AnyObject {
	func getTrackerWithFilter(_ newFilter: FilterType)
}

protocol FilterCollectionViewProviderProtocol: AnyObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
	func setFilter(selectedFilter: FilterType)
}

enum FilterType: String, CaseIterable {
	case allTrackers
	case trackersForToday
	case completed
	case notCompleted
	
	var filterTitle: String {
		switch self {
		case .allTrackers:
			return NSLocalizedString("allTrackers", comment: "")
		case .trackersForToday:
			return NSLocalizedString("trackersForToday", comment: "")
		case .completed:
			return NSLocalizedString("completed", comment: "")
		case .notCompleted:
			return NSLocalizedString("notCompleted", comment: "")
		}
	}
}

final class FilterCollectionViewProvider: NSObject {
	weak var delegate: FilterCollectionViewProviderDelegate?
	private var selectedFilter: FilterType?
	
	private func configCellLayer(at indexPath: IndexPath, cell: FiltersCollectionViewCell) {
		if indexPath.row == 0 {
			cell.layer.masksToBounds = true
			cell.layer.cornerRadius = 16
			cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		}

		if indexPath.row == FilterType.allCases.count - 1 {
			cell.layer.masksToBounds = true
			cell.layer.cornerRadius = 16
			cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
			cell.hideLineView()
		}
	}
}

extension FilterCollectionViewProvider: UICollectionViewDataSource {
	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: FiltersCollectionViewCell.cellReuseIdentifier,
			for: indexPath
		) as? FiltersCollectionViewCell,
		let selectedFilter else {
			return UICollectionViewCell()
		}
	  
		let checkmarkIsHidden = selectedFilter == FilterType.allCases[safe: indexPath.row]
		let filterLabelText = FilterType.allCases[safe: indexPath.row]?.filterTitle
		configCellLayer(at: indexPath, cell: cell)
		cell.config(filterLabelText: filterLabelText, checkmarkIsHidden: checkmarkIsHidden)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		FilterType.allCases.count
	}
}

extension FilterCollectionViewProvider: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let width = UIScreen.main.bounds.width - 16 * 2
		return CGSize(width: width, height: 75)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		.zero
	}
}

extension FilterCollectionViewProvider: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let newFilter = FilterType.allCases[safe: indexPath.row] else { return }
		delegate?.getTrackerWithFilter(newFilter)
	}
}

extension FilterCollectionViewProvider: FilterCollectionViewProviderProtocol {
	func setFilter(selectedFilter: FilterType) {
		self.selectedFilter = selectedFilter
	}
}
