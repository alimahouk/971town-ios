//
//  NSOProductBrandViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOProductBrandViewController: UITableViewController,
                                     UIAdaptivePresentationControllerDelegate,
                                     UITextFieldDelegate {
        private let brandSearchField: UITextField
        private var brandSearchResults: Array<NSOBrand> = []
        private let brandSearchResultsTableHeaderView: UIView
        private static let brandTableViewCellIdentifier: String = "BrandCell"
        private let emptyListMessageTitleLabel: UILabel
        private let emptyListMessageSubtitleLabel: UILabel
        private let emptyListMessageView: UIStackView
        private let infoLabel: UILabel
        private var searchButton: UIBarButtonItem?
        private var viewIsLoaded: Bool = false
        
        public var product: NSOProduct
        
        init() {
                self.product = NSOProduct()
                
                let searchIconView = UIImageView(
                        image: UIImage(systemName: "magnifyingglass")?.withTintColor(.systemGray,
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
                self.brandSearchField = UITextField()
                self.brandSearchField.autocapitalizationType = .words
                self.brandSearchField.autocorrectionType = .yes
                self.brandSearchField.backgroundColor = .systemGray6
                self.brandSearchField.clearButtonMode = .always
                self.brandSearchField.enablesReturnKeyAutomatically = true
                self.brandSearchField.font = .systemFont(ofSize: 18)
                self.brandSearchField.layer.cornerRadius = softRoundCornerRadius
                self.brandSearchField.layer.masksToBounds = true
                self.brandSearchField.leftView = searchIconContainer
                self.brandSearchField.leftViewMode = .always
                self.brandSearchField.placeholder = "Search brands…"
                self.brandSearchField.returnKeyType = .search
                self.brandSearchField.tag = 1
                self.brandSearchField.textContentType = .organizationName
                self.brandSearchField.sizeToFit()
                
                self.emptyListMessageTitleLabel = UILabel()
                self.emptyListMessageTitleLabel.font = .boldSystemFont(ofSize: 18)
                self.emptyListMessageTitleLabel.text = "No Brands Found"
                self.emptyListMessageTitleLabel.textAlignment = .center
                self.emptyListMessageTitleLabel.sizeToFit()
                
                self.emptyListMessageSubtitleLabel = UILabel()
                self.emptyListMessageSubtitleLabel.numberOfLines = 0
                self.emptyListMessageSubtitleLabel.text = "You need to add the brand first and then return here to finish adding this product."
                self.emptyListMessageSubtitleLabel.textAlignment = .center
                self.emptyListMessageSubtitleLabel.textColor = .systemGray
                self.emptyListMessageSubtitleLabel.sizeToFit()
                
                self.emptyListMessageView = UIStackView()
                self.emptyListMessageView.axis = .vertical
                self.emptyListMessageView.isHidden = true
                
                self.emptyListMessageView.addArrangedSubview(self.emptyListMessageTitleLabel)
                self.emptyListMessageView.addArrangedSubview(self.emptyListMessageSubtitleLabel)
                
                self.infoLabel = UILabel()
                self.infoLabel.textColor = .systemGray
                self.infoLabel.numberOfLines = 0
                self.infoLabel.text = "What's the brand of this product?"
                self.infoLabel.sizeToFit()
                
                self.brandSearchResultsTableHeaderView = UIView(
                        frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 0,
                                height: self.infoLabel.bounds.height + self.brandSearchField.bounds.height + 50
                        )
                )
                self.brandSearchResultsTableHeaderView.addSubview(self.infoLabel)
                self.brandSearchResultsTableHeaderView.addSubview(self.brandSearchField)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.tableView.keyboardDismissMode = .interactive
                self.tableView.tableHeaderView = self.brandSearchResultsTableHeaderView
                
                self.tableView.addSubview(self.emptyListMessageView)
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductBrandViewController.brandTableViewCellIdentifier)
                
                self.title = "Product Brand"
                
                self.brandSearchField.delegate = self
                self.brandSearchField.addTarget(
                        self,
                        action: #selector(self.textFieldDidChange),
                        for: .editingChanged
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func checkForSimilarBrands(_ brands: Array<NSOBrand>) {
                self.brandSearchResults.removeAll()
                guard let enteredName = self.brandSearchField.text else { return }
                var aliasFormattedName = String(enteredName.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                aliasFormattedName = aliasFormattedName.lowercased()
                
                for brand in brands {
                        if brand.name!.localizedStandardContains(enteredName)
                                || brand.alias!.localizedStandardContains(aliasFormattedName){
                                self.brandSearchResults.append(brand)
                        }
                }
                
                if !self.brandSearchResults.isEmpty {
                        self.presentBrandSearchResults()
                } else {
                        self.presentEmptyBrandSearchResults()
                }
                
                self.brandSearchField.isEnabled = true
                self.enableFormButtons()
        }
        
        private func enableFormButtons() {
                var searchQuery: String? = nil
                
                if var searchFieldString = self.brandSearchField.text {
                        searchFieldString = searchFieldString.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !searchFieldString.isEmpty {
                                searchQuery = searchFieldString
                        }
                }
                
                if searchQuery != nil {
                        self.searchButton?.isEnabled = true
                } else {
                        self.searchButton?.isEnabled = false
                }
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if !product.tags.isEmpty {
                        ret = false
                }
                
                return ret
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                
                let confirmationAlert = UIAlertController(
                        title: "Discard Product?",
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
        
        private func presentBrandSearchResults() {
                guard !self.brandSearchResults.isEmpty else { return }
                
                self.emptyListMessageView.isHidden = true
                self.tableView.allowsSelection = true
                self.tableView.reloadData()
        }
        
        private func presentBrandSearchView(giveFocus: Bool = true) {
                self.brandSearchField.isEnabled = true
                self.emptyListMessageView.isHidden = true
                self.tableView.allowsSelection = true
                
                if giveFocus {
                        self.brandSearchField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        private func presentEmptyBrandSearchResults() {
                guard self.brandSearchResults.isEmpty else { return }
                
                self.tableView.reloadData()
                self.emptyListMessageView.isHidden = false
        }
        
        private func presentProductNameViewController() {
                let productNameViewController = NSOProductNameViewController(product: self.product)
                self.navigationController?.pushViewController(productNameViewController,
                                                              animated: true)
        }
        
        @objc
        private dynamic func searchBrands() {
                guard var brandName = self.brandSearchField.text else { return }
                brandName = brandName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                self.brandSearchField.text = brandName   // Give the user feedback of what characters are illegal.
                
                if !brandName.isEmpty {
                        self.brandSearchField.isEnabled = false
                        self.searchButton?.isEnabled = false
                        self.tableView.allowsSelection = false
                        
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
                                                                                self.presentBrandSearchView()
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
                                                                                self.presentBrandSearchView()
                                                                        }
                                                                )
                                                        )
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                }
                                        } else if let apiResponse = apiResponse {
                                                DispatchQueue.main.async {
                                                        self.checkForSimilarBrands(apiResponse.brands)
                                                }
                                        }
                                }
                        )
                }
        }
        
        override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
                let brand = self.brandSearchResults[indexPath.row]
                
                let brandViewController = NSOBrandViewController(brand: brand)
                self.navigationController?.pushViewController(brandViewController,
                                                              animated: true)
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let brand = self.brandSearchResults[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductBrandViewController.brandTableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + brand.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = brand.name
                
                cell.accessoryType = .detailButton
                cell.contentConfiguration = content
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let brand = self.brandSearchResults[indexPath.row]
                self.product.brand = brand
                self.product.tags.removeAll()
                
                self.presentProductNameViewController()
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                return self.brandSearchResults.count
        }
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
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
                        self.presentBrandSearchView()
                        
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.searchButton
                self.navigationController?.presentationController?.delegate = self
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.searchButton == nil {
                                self.searchButton = UIBarButtonItem(
                                        title: "Search",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.searchBrands)
                                )
                        }
                        
                        self.emptyListMessageView.frame = CGRect(
                                x: 40,
                                y: (self.view.bounds.height / 2) - 50 - (self.view.safeAreaInsets.top / 2),
                                width: self.view.bounds.width - 80,
                                height: 100
                        )
                        
                        self.infoLabel.frame = CGRect(
                                x: 20,
                                y: 10,
                                width: self.brandSearchResultsTableHeaderView.bounds.width - 40,
                                height: self.infoLabel.bounds.height
                        )
                        
                        self.brandSearchField.frame = CGRect(
                                x: 20,
                                y: self.infoLabel.frame.origin.y + self.infoLabel.bounds.height + 10,
                                width: self.brandSearchResultsTableHeaderView.bounds.width - 40,
                                height: self.brandSearchField.bounds.height + 10
                        )
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
        }
}
