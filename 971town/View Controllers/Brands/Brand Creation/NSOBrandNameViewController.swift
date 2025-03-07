//
//  NSOBrandNameViewController.swift
//  971town
//
//  Created by Ali Mahouk on 13/02/2023.
//

import API
import UIKit


class NSOBrandNameViewController: UIViewController,
                                  UIAdaptivePresentationControllerDelegate,
                                  UITableViewDataSource,
                                  UITableViewDelegate,
                                  UITextFieldDelegate {
        private var cancelButton: UIBarButtonItem?
        private let brandNameField: UITextField
        private var nextButton: UIBarButtonItem?
        private var similarBrands: Array<NSOBrand> = []
        private let similarBrandsTableView: UITableView
        private static let similarBrandsTableViewCellIdentifier: String = "BrandCell"
        private var viewIsLoaded: Bool = false
        
        public var brand: NSOBrand?
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                let searchIconView = UIImageView(
                        image: UIImage(systemName: "tag")?.withTintColor(.systemGray,
                                                                         renderingMode: .alwaysOriginal)
                )
                searchIconView.contentMode = .center
                searchIconView.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: 35,
                        height: 18
                )
                let searchIconContainer = UIView(frame: searchIconView.bounds)
                searchIconContainer.addSubview(searchIconView)
                
                let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
                self.brandNameField = UITextField()
                self.brandNameField.autocapitalizationType = .words
                self.brandNameField.autocorrectionType = .yes
                self.brandNameField.backgroundColor = .systemGray6
                self.brandNameField.clearButtonMode = .always
                self.brandNameField.enablesReturnKeyAutomatically = true
                self.brandNameField.font = .systemFont(ofSize: 18)
                self.brandNameField.isHidden = true
                self.brandNameField.layer.cornerRadius = softRoundCornerRadius
                self.brandNameField.layer.masksToBounds = true
                self.brandNameField.leftView = searchIconContainer
                self.brandNameField.leftViewMode = .always
                self.brandNameField.layer.opacity = 0.0
                self.brandNameField.placeholder = "Brand Name"
                self.brandNameField.returnKeyType = .next
                self.brandNameField.tag = 1
                self.brandNameField.textContentType = .organizationName
                self.brandNameField.sizeToFit()
                
                self.similarBrandsTableView = UITableView()
                self.similarBrandsTableView.isHidden = true
                self.similarBrandsTableView.layer.opacity = 0.0
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.title = "Add a Brand"
                
                self.brandNameField.delegate = self
                self.brandNameField.addTarget(
                        self,
                        action: #selector(self.textFieldDidChange),
                        for: .editingChanged
                )
                
                self.similarBrandsTableView.dataSource = self
                self.similarBrandsTableView.delegate = self
                
                self.similarBrandsTableView.register(UITableViewCell.self,
                                                     forCellReuseIdentifier: NSOBrandNameViewController.similarBrandsTableViewCellIdentifier)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func checkForSimilarBrands(_ brands: Array<NSOBrand>) {
                self.similarBrands.removeAll()
                
                guard let enteredName = self.brandNameField.text else { return }
                var aliasFormattedName = String(enteredName.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                aliasFormattedName = aliasFormattedName.lowercased()
                
                for brand in brands {
                        if brand.name!.localizedStandardContains(enteredName)
                                || brand.alias!.localizedStandardContains(aliasFormattedName) {
                                self.similarBrands.append(brand)
                        }
                }
                
                if !self.similarBrands.isEmpty {
                        self.presentSimilarBrands()
                } else {
                        self.presentBrandAliasViewController()
                }
        }
        
        @objc
        private dynamic func dismissView() {
                self.navigationController?.dismiss(animated: true)
        }
        
        @objc
        private dynamic func enableFormButtons() {
                if let brandName = self.brandNameField.text {
                        if brandName.isEmpty {
                                self.nextButton?.isEnabled = false
                        } else {
                                self.nextButton?.isEnabled = true
                        }
                }
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if let brand = self.brand {
                        if !brand.tags.isEmpty {
                                ret = false
                        }
                }
                
                return ret
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                
                let confirmationAlert = UIAlertController(
                        title: "Discard Brand?",
                        message: "Any info you entered so far will be lost.",
                        preferredStyle: .alert
                )
                confirmationAlert.addAction(
                        UIAlertAction(
                                title: "Discard",
                                style: .destructive,
                                handler: { action in
                                        self.navigationController?.dismiss(animated: true)
                                }
                        )
                )
                confirmationAlert.addAction(
                        UIAlertAction(title: "Back",
                                      style: .cancel)
                )
                self.navigationController?.present(confirmationAlert,
                                                   animated: true)
                
                generator.notificationOccurred(.warning)
        }
        
        private func presentBrandAliasViewController() {
                let brandAliasViewController = NSOBrandAliasViewController(brand: self.brand!)
                self.navigationController?.pushViewController(brandAliasViewController,
                                                              animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Reset the view.
                        self.presentBrandNameEntryView(giveFocus: false)
                }
        }
        
        private func presentBrandNameEntryView(giveFocus: Bool = true) {
                guard self.similarBrands.isEmpty else { return }
                
                self.brandNameField.isEnabled = true
                self.brandNameField.isHidden = false
                self.brandNameField.textColor = .black
                
                let animator = UIViewPropertyAnimator(duration: 0.2,
                                                      curve: .easeOut) {
                        self.brandNameField.frame.origin = CGPoint(x: self.view.safeAreaInsets.left + 20,
                                                                   y: (self.view.bounds.height / 2) - 200)
                        self.brandNameField.layer.opacity = 1.0
                        
                        self.similarBrandsTableView.frame.origin = CGPoint(x: 0,
                                                                           y: self.view.safeAreaInsets.top + 100)
                        self.similarBrandsTableView.layer.opacity = 0.0
                }
                animator.addCompletion({ _ in
                        self.similarBrands = []
                        
                        self.similarBrandsTableView.isHidden = true
                        self.similarBrandsTableView.reloadData()
                        
                        if giveFocus {
                                self.brandNameField.becomeFirstResponder()
                        }
                })
                animator.startAnimation()
                
                self.enableFormButtons()
        }
        
        private func presentSimilarBrands() {
                guard !self.similarBrands.isEmpty else { return }
                
                self.brandNameField.isEnabled = true
                self.brandNameField.isHidden = false
                self.brandNameField.textColor = .systemYellow
                self.brandNameField.resignFirstResponder()
                
                self.similarBrandsTableView.reloadData()
                self.similarBrandsTableView.isHidden = false
                
                let animator = UIViewPropertyAnimator(duration: 0.2,
                                                      curve: .easeOut) {
                        self.brandNameField.frame.origin = CGPoint(x: self.view.safeAreaInsets.left + 20,
                                                                   y: self.view.safeAreaInsets.top + 20)
                        
                        self.similarBrandsTableView.frame = CGRect(
                                x: 0,
                                y: self.brandNameField.frame.origin.y + self.brandNameField.bounds.height + 20,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,
                                height: self.view.bounds.height - self.view.safeAreaInsets.top - self.brandNameField.frame.origin.y - self.brandNameField.bounds.height - 20
                        )
                        self.similarBrandsTableView.layer.opacity = 1.0
                }
                animator.startAnimation()
                
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func searchBrands() {
                guard var brandName = self.brandNameField.text else { return }
                brandName = brandName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                self.brandNameField.text = brandName   // Give the user feedback of what characters are illegal.
                
                if self.brand != nil && brandName == self.brand!.name {
                        self.presentBrandAliasViewController()
                } else if !brandName.isEmpty {
                        self.brandNameField.isEnabled = false
                        self.nextButton?.isEnabled = false
                        
                        let request = NSOGetBrandsRequest(query: brandName)
                        NSOAPI.shared.getBrands(
                                request: request,
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
                                                                        style: .default,
                                                                        handler: { action in
                                                                                self.presentBrandNameEntryView()
                                                                        }
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
                                                                        style: .default,
                                                                        handler: { action in
                                                                                self.presentBrandNameEntryView()
                                                                        }
                                                                )
                                                        )
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                }
                                        } else if let apiResponse = apiResponse {
                                                self.brand = NSOBrand(name: brandName)
                                                
                                                DispatchQueue.main.async {
                                                        if apiResponse.brands.isEmpty {
                                                                self.presentBrandAliasViewController()
                                                        } else {
                                                                self.checkForSimilarBrands(apiResponse.brands)
                                                        }
                                                }
                                        }
                                }
                        )
                }
        }
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
                return self.similarBrands.count
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let brand = self.similarBrands[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOBrandNameViewController.similarBrandsTableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + brand.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = brand.name
                
                cell.accessoryType = .detailButton
                cell.contentConfiguration = content
                
                return cell
        }
        
        func tableView(_ tableView: UITableView,
                       didSelectRowAt indexPath: IndexPath) {
                let brand = self.similarBrands[indexPath.row]
                let brandViewController = NSOBrandViewController(brand: brand)
                brandViewController.allowsCreationWorkflows = false
                self.navigationController?.pushViewController(brandViewController,
                                                              animated: true)
        }
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
                if let textFieldString = textField.text {
                        if textFieldString.isEmpty {
                                textField.textColor = .black
                        }
                }
                
                self.enableFormButtons()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                if textField.tag == 1 {
                        self.searchBrands()
                }
                
                return false
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                self.presentBrandNameEntryView()
                self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.nextButton
                self.navigationController?.presentationController?.delegate = self
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
                        }
                        
                        if self.nextButton == nil {
                                self.nextButton = UIBarButtonItem(
                                        title: "Next",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.searchBrands)
                                )
                        }
                        
                        self.brandNameField.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 20,
                                y: (self.view.bounds.height / 2) - 200,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: self.brandNameField.bounds.height + 10
                        )
                        self.view.addSubview(self.brandNameField)
                        
                        let similarBrandsWarningLabel = UILabel()
                        similarBrandsWarningLabel.numberOfLines = 0
                        similarBrandsWarningLabel.text = "Brands with similar names already exist! Check the brands below to make sure you're not adding a duplicate. Otherwise, tap \(self.nextButton!.title!) to go ahead."
                        
                        let similarBrandsWarningLabelSize = similarBrandsWarningLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        similarBrandsWarningLabel.frame = CGRect(
                                x: 20,
                                y: 0,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: similarBrandsWarningLabelSize.height
                        )
                        
                        let similarBrandsTableHeaderView = UIView(
                                frame: CGRect(
                                        x: 0,
                                        y: 0,
                                        width: 0,
                                        height: similarBrandsWarningLabelSize.height + 15
                                )
                        )
                        similarBrandsTableHeaderView.addSubview(similarBrandsWarningLabel)
                        
                        self.similarBrandsTableView.tableHeaderView = similarBrandsTableHeaderView
                        self.similarBrandsTableView.contentInset = UIEdgeInsets(
                                top: 0,
                                left: self.view.safeAreaInsets.left,
                                bottom: self.view.safeAreaInsets.bottom,
                                right: self.view.safeAreaInsets.right
                        )
                        self.similarBrandsTableView.frame = CGRect(
                                x: 0,
                                y: self.view.safeAreaInsets.top + 100,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,
                                height: self.view.bounds.height - self.view.safeAreaInsets.top - self.brandNameField.frame.origin.y - self.brandNameField.bounds.height - 20
                        )
                        self.view.addSubview(self.similarBrandsTableView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if let selectedIndexPath = self.similarBrandsTableView.indexPathForSelectedRow {
                        self.similarBrandsTableView.deselectRow(at: selectedIndexPath,
                                                                animated: animated)
                }
        }
}
