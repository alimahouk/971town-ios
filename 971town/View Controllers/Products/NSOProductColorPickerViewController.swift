//
//  NSOProductColorPickerViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


protocol NSOProductColorPickerViewControllerDelegate {
        func colorPickerViewControllerDidFinish(_ viewController: NSOProductColorPickerViewController)
        func colorPickerViewControllerDidSelectColor(_ viewController: NSOProductColorPickerViewController)
}


class NSOProductColorPickerViewController: UICollectionViewController {
        private var cancelButton: UIBarButtonItem?
        private static let collectionViewHeaderIdentifier: String = "ColorPickerViewControllerHeader"
        private static let collectionViewCellIdentifier: String = "ColorPickerViewControllerColorCell"
        private var colorPreviews: Array<UIView> = []
        private var colors: Array<NSOProductColor> = []
        private var doneButton: UIBarButtonItem?
        private var lastSelectedIndexPath: IndexPath?
        private let progressIndicator: UIAlertController
        private var selectedColorNameLabel: UILabel
        private var viewIsLoaded: Bool = false
        
        public var delegate: NSOProductColorPickerViewControllerDelegate?
        public var selectedColor: NSOProductColor?
        
        
        init() {
                self.selectedColorNameLabel = UILabel()
                self.selectedColorNameLabel.textAlignment = .center
                self.selectedColorNameLabel.textColor = .systemGray2
                
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.isUserInteractionEnabled = false
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressIndicator = UIAlertController(
                        title: "Loading…",
                        message: nil,
                        preferredStyle: .alert
                )
                self.progressIndicator.view.addSubview(activityIndicatorView)
                
                let layout = UICollectionViewFlowLayout()
                layout.headerReferenceSize = CGSize(width: 0,
                                                    height: 50)
                layout.scrollDirection = .vertical
                
                super.init(collectionViewLayout: layout)
                
                self.title = "Colors"
                
                self.collectionView.register(UICollectionReusableView.self,
                                             forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                             withReuseIdentifier: NSOProductColorPickerViewController.collectionViewHeaderIdentifier)
                self.collectionView.register(UICollectionViewCell.self,
                                             forCellWithReuseIdentifier: NSOProductColorPickerViewController.collectionViewCellIdentifier)
                
                let progressIndicatorViews = [
                        "activityIndicatorView": activityIndicatorView
                ] as [String : Any]
                var progressIndicatorConstraints = NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-(20)-[activityIndicatorView]-(20)-|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: progressIndicatorViews
                )
                progressIndicatorConstraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|-(20)-[activityIndicatorView]",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: progressIndicatorViews
                )
                self.progressIndicator.view.addConstraints(progressIndicatorConstraints)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        private dynamic func dismissView() {
                self.navigationController?.dismiss(animated: true)
        }
        
        private func enableFormButtons() {
                self.doneButton?.isEnabled = true
        }
        
        private func getColors() {
                self.navigationController?.present(self.progressIndicator,
                                                   animated: true)
                
                NSOAPI.shared.getProductColorList(
                        responseHandler: { apiResponse, errorResponse, networkError in
                                if let networkError = networkError {
                                        print(networkError)
                                        
                                        DispatchQueue.main.async {
                                                let alert = UIAlertController(
                                                        title: "Network Issues",
                                                        message: "An error occurred. Try again later?",
                                                        preferredStyle: .alert
                                                )
                                                alert.addAction(
                                                        UIAlertAction(
                                                                title: ":(",
                                                                style: .default
                                                        )
                                                )
                                                self.navigationController?.present(alert,
                                                                                   animated: true)
                                        }
                                } else if let errorResponse = errorResponse {
                                        DispatchQueue.main.async {
                                                let alert = UIAlertController(
                                                        title: "",
                                                        message: errorResponse.error.errorMessage,
                                                        preferredStyle: .alert
                                                )
                                                alert.addAction(
                                                        UIAlertAction(
                                                                title: "Oh, No!",
                                                                style: .default
                                                        )
                                                )
                                                self.navigationController?.present(alert,
                                                                                   animated: true)
                                        }
                                } else if let apiResponse = apiResponse {
                                        self.colors = apiResponse.productColors
                                        
                                        DispatchQueue.main.async {
                                                self.presentColorPreviews()
                                                
                                                if self.selectedColor == nil {
                                                        self.selectColor(at: self.colors.count)
                                                } else {
                                                        for (i, color) in self.colors.enumerated() {
                                                                if color.hex == self.selectedColor?.hex {
                                                                        self.selectColor(at: i)
                                                                        
                                                                        break
                                                                }
                                                        }
                                                }
                                        }
                                }
                        }
                )
        }
        
        private func presentColorPreviews() {
                for color in self.colors {
                        let colorPreview = UIView()
                        colorPreview.backgroundColor = UIColor(hex: color.hex)
                        colorPreview.layer.masksToBounds = true
                        self.colorPreviews.append(colorPreview)
                }
                
                let clearColorIconView = UIImageView(
                        image: UIImage(systemName: "xmark",
                                       withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))?
                                .withTintColor(.systemGray,
                                               renderingMode: .alwaysOriginal)
                )
                clearColorIconView.contentMode = .center
                
                let clearColorPreview = UIView()
                clearColorPreview.layer.borderColor = UIColor.systemGray.cgColor
                clearColorPreview.layer.borderWidth = 0.5
                clearColorPreview.layer.masksToBounds = true
                clearColorPreview.addSubview(clearColorIconView)
                self.colorPreviews.append(clearColorPreview)
                
                self.collectionView.reloadData()
                self.progressIndicator.dismiss(animated: true)
        }
        
        private func selectColor(at index: Int) {
                let selectedColor: NSOProductColor?
                
                if index < self.colors.count {
                        selectedColor = self.colors[index]
                } else {
                        selectedColor = nil
                }
                
                if let lastIndexPath = self.lastSelectedIndexPath {
                        self.collectionView.deselectItem(at: lastIndexPath,
                                                         animated: false)
                        
                        let colorPreview = self.colorPreviews[lastIndexPath.row]
                        colorPreview.layer.borderWidth = 0.0
                }
                
                let colorPreview = self.colorPreviews[index]
                colorPreview.layer.borderColor = UIColor.systemBlue.cgColor
                colorPreview.layer.borderWidth = 4.0
                
                self.lastSelectedIndexPath = IndexPath(row: index, section: 0)
                self.selectedColor = selectedColor
                
                if let selectedColor = selectedColor {
                        self.selectedColorNameLabel.text = selectedColor.name
                } else {
                        self.selectedColorNameLabel.text = "No Color"
                }
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getColors()
                        
                        self.viewIsLoaded = true
                }
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.cancelButton == nil {
                                self.cancelButton = UIBarButtonItem(
                                        barButtonSystemItem: .close,
                                        target: self,
                                        action: #selector(self.dismissView)
                                )
                                self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
                        }
                        
                        if self.doneButton == nil {
                                self.doneButton = UIBarButtonItem(
                                        title: "Done",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.dismissView)
                                )
                                self.doneButton?.isEnabled = false
                                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.doneButton
                        }
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame.size = self.view.bounds.size
                
                self.collectionView.backgroundColor = .clear
                self.collectionView.backgroundView = blurEffectView
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                
                if self.selectedColor != nil {
                        self.delegate?.colorPickerViewControllerDidFinish(self)
                }
        }
}


// MARK: - UICollectionViewDataSource

extension NSOProductColorPickerViewController {
        override func numberOfSections(in collectionView: UICollectionView) -> Int {
                return 1
        }
        
        override func collectionView(_ collectionView: UICollectionView,
                                     numberOfItemsInSection section: Int) -> Int {
                return self.colorPreviews.count // Use this array because it also includes the clear color.
        }
        
        override func collectionView(_ collectionView: UICollectionView,
                                     cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSOProductColorPickerViewController.collectionViewCellIdentifier,
                                                              for: indexPath)
                cell.backgroundColor = .clear
                
                for subview in cell.contentView.subviews {
                        subview.removeFromSuperview()
                }
                
                let colorPreview = self.colorPreviews[indexPath.row]
                colorPreview.frame = CGRect(
                        x: 4,
                        y: 4,
                        width: cell.bounds.width - 8,
                        height: cell.bounds.height - 8
                )
                colorPreview.layer.cornerRadius = colorPreview.bounds.width / 2
                cell.contentView.addSubview(colorPreview)
                
                if indexPath.row == self.colors.count {
                        let clearColorIcon = colorPreview.subviews.first!
                        clearColorIcon.frame = colorPreview.bounds
                }
                
                return cell
        }
        
        override func collectionView(_ collectionView: UICollectionView,
                                     viewForSupplementaryElementOfKind kind: String,
                                     at indexPath: IndexPath) -> UICollectionReusableView {
                let headerView = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: NSOProductColorPickerViewController.collectionViewHeaderIdentifier,
                        for: indexPath
                )
                
                for subview in headerView.subviews {
                        subview.removeFromSuperview()
                }
                
                self.selectedColorNameLabel.frame = CGRect(
                        x: 20,
                        y: 0,
                        width: headerView.bounds.width - 40,
                        height: headerView.bounds.height
                )
                headerView.addSubview(self.selectedColorNameLabel)
                
                return headerView
        }
}


// MARK: - UICollectionViewDelegate

extension NSOProductColorPickerViewController {
        override func collectionView(_ collectionView: UICollectionView,
                                     didSelectItemAt indexPath: IndexPath) {
                self.selectColor(at: indexPath.row)
                self.delegate?.colorPickerViewControllerDidSelectColor(self)
                self.enableFormButtons()
        }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension NSOProductColorPickerViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
                return CGSize(width: (collectionView.bounds.width / 5) - 30,
                              height: (collectionView.bounds.width / 5) - 30)
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
                return UIEdgeInsets(
                        top: 15,
                        left: 15,
                        bottom: 15,
                        right: 15
                )
        }
}
