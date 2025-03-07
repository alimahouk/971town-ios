//
//  NSOProductVariantViewController.swift
//  971town
//
//  Created by Ali Mahouk on 13/03/2023.
//

import API
import UIKit


protocol NSOProductVariantViewControllerDelegate {
        func variantViewControllerDidCancel(_ viewController: NSOProductVariantViewController)
        func variantViewController(_ viewController: NSOProductVariantViewController,
                                   didSelect parentProduct: NSOProduct)
}


class NSOProductVariantViewController: UITableViewController,
                                       UIAdaptivePresentationControllerDelegate,
                                       UITextFieldDelegate {
        public enum VariantViewControllerMode {
                case creation
                case search
        }
        
        private var cancelButton: UIBarButtonItem?
        private let productSearchField: UITextField
        private var productSearchResults: Array<NSOProduct> = []
        private let productSearchResultsTableHeaderView: UIView
        private static let productTableViewCellIdentifier: String = "ProductCell"
        private let emptyListMessageTitleLabel: UILabel
        private let emptyListMessageSubtitleLabel: UILabel
        private let emptyListMessageView: UIStackView
        private let infoLabel: UILabel
        private var searchButton: UIBarButtonItem?
        private var viewIsLoaded: Bool = false
        
        public var delegate: NSOProductVariantViewControllerDelegate?
        public var mode: VariantViewControllerMode = .creation
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
                self.productSearchField = UITextField()
                self.productSearchField.autocapitalizationType = .words
                self.productSearchField.autocorrectionType = .yes
                self.productSearchField.backgroundColor = .systemGray6
                self.productSearchField.clearButtonMode = .always
                self.productSearchField.enablesReturnKeyAutomatically = true
                self.productSearchField.font = .systemFont(ofSize: 18)
                self.productSearchField.layer.cornerRadius = softRoundCornerRadius
                self.productSearchField.layer.masksToBounds = true
                self.productSearchField.leftView = searchIconContainer
                self.productSearchField.leftViewMode = .always
                self.productSearchField.placeholder = "Search products…"
                self.productSearchField.returnKeyType = .search
                self.productSearchField.tag = 1
                self.productSearchField.sizeToFit()
                
                self.emptyListMessageTitleLabel = UILabel()
                self.emptyListMessageTitleLabel.font = .boldSystemFont(ofSize: 18)
                self.emptyListMessageTitleLabel.text = "No Products Found"
                self.emptyListMessageTitleLabel.textAlignment = .center
                self.emptyListMessageTitleLabel.sizeToFit()
                
                self.emptyListMessageSubtitleLabel = UILabel()
                self.emptyListMessageSubtitleLabel.numberOfLines = 0
                self.emptyListMessageSubtitleLabel.text = "You need to add the main product first and then return here to finish adding this variant."
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
                self.infoLabel.text = "What product is this a variant of?"
                self.infoLabel.sizeToFit()
                
                self.productSearchResultsTableHeaderView = UIView(
                        frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 0,
                                height: self.infoLabel.bounds.height + self.productSearchField.bounds.height + 50
                        )
                )
                self.productSearchResultsTableHeaderView.addSubview(self.infoLabel)
                self.productSearchResultsTableHeaderView.addSubview(self.productSearchField)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.tableView.keyboardDismissMode = .interactive
                self.tableView.tableHeaderView = self.productSearchResultsTableHeaderView
                
                self.tableView.addSubview(self.emptyListMessageView)
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductVariantViewController.productTableViewCellIdentifier)
                
                self.title = "Product Variant"
                
                self.productSearchField.delegate = self
                self.productSearchField.addTarget(
                        self,
                        action: #selector(self.textFieldDidChange),
                        for: .editingChanged
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func checkForSimilarProducts(_ products: Array<NSOProduct>) {
                self.productSearchResults.removeAll()
                
                guard let enteredName = self.productSearchField.text else { return }
                var aliasFormattedName = String(enteredName.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                aliasFormattedName = aliasFormattedName.lowercased()
                
                for product in products {
                        if product.name!.localizedStandardContains(enteredName)
                                || product.alias!.localizedStandardContains(aliasFormattedName) {
                                self.productSearchResults.append(product)
                        }
                }
                
                if !self.productSearchResults.isEmpty {
                        self.presentProductSearchResults()
                } else {
                        self.presentEmptyProductSearchResults()
                }
                
                self.productSearchField.isEnabled = true
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func dismissView() {
                if self.mode == .search {
                        self.delegate?.variantViewControllerDidCancel(self)
                } else {
                        self.navigationController?.dismiss(animated: true)
                }
        }
        
        private func enableFormButtons() {
                var searchQuery: String? = nil
                
                if var searchFieldString = self.productSearchField.text {
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
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
                if self.mode == .search {
                        self.delegate?.variantViewControllerDidCancel(self)
                }
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
                                        if self.mode == .search {
                                                self.delegate?.variantViewControllerDidCancel(self)
                                        } else {
                                                self.dismissView()
                                        }
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
        
        private func presentProductSearchResults() {
                guard !self.productSearchResults.isEmpty else { return }
                
                self.emptyListMessageView.isHidden = true
                self.tableView.allowsSelection = true
                self.tableView.reloadData()
        }
        
        private func presentProductSearchView(giveFocus: Bool = true) {
                self.productSearchField.isEnabled = true
                self.emptyListMessageView.isHidden = true
                self.tableView.allowsSelection = true
                
                if giveFocus {
                        self.productSearchField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        private func presentEmptyProductSearchResults() {
                guard self.productSearchResults.isEmpty else { return }
                
                self.tableView.reloadData()
                self.emptyListMessageView.isHidden = false
        }
        
        @objc
        private dynamic func searchProducts() {
                guard var productName = self.productSearchField.text else { return }
                productName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                self.productSearchField.text = productName   // Give the user feedback of what characters are illegal.
                
                if !productName.isEmpty {
                        self.productSearchField.isEnabled = false
                        self.searchButton?.isEnabled = false
                        self.tableView.allowsSelection = false
                        
                        let request = NSOGetProductsRequest(query: productName)
                        NSOAPI.shared.getProducts(
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
                                                                                self.presentProductSearchView()
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
                                                                                self.presentProductSearchView()
                                                                        }
                                                                )
                                                        )
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                }
                                        } else if let apiResponse = apiResponse {
                                                DispatchQueue.main.async {
                                                        self.checkForSimilarProducts(apiResponse.products)
                                                }
                                        }
                                }
                        )
                }
        }
        
        override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
                let product = self.productSearchResults[indexPath.row]
                
                let productViewController = NSOProductViewController(product: product)
                self.navigationController?.pushViewController(productViewController,
                                                              animated: true)
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let product = self.productSearchResults[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductVariantViewController.productTableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + product.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = product.name
                
                cell.accessoryType = .detailButton
                cell.contentConfiguration = content
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let product = self.productSearchResults[indexPath.row]
                
                if self.mode == .creation {
                        self.product.brand = product.brand
                        self.product.parentProduct = product
                        self.product.parentProductID = product.id
                        
                        let productNameViewController = NSOProductNameViewController(product: self.product)
                        self.navigationController?.pushViewController(productNameViewController,
                                                                      animated: true)
                } else if mode == .search {
                        self.delegate?.variantViewController(self,
                                                             didSelect: product)
                }
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                return self.productSearchResults.count
        }
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
                self.enableFormButtons()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                if textField.tag == 1 {
                        self.searchProducts()
                }
                
                return false
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.presentProductSearchView()
                        
                        self.viewIsLoaded = true
                }
                
                if self.mode == .search {
                        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
                }
                
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.searchButton
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
                        
                        if self.searchButton == nil {
                                self.searchButton = UIBarButtonItem(
                                        title: "Search",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.searchProducts)
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
                                width: self.productSearchResultsTableHeaderView.bounds.width - 40,
                                height: self.infoLabel.bounds.height
                        )
                        
                        self.productSearchField.frame = CGRect(
                                x: 20,
                                y: self.infoLabel.frame.origin.y + self.infoLabel.bounds.height + 10,
                                width: self.productSearchResultsTableHeaderView.bounds.width - 40,
                                height: self.productSearchField.bounds.height + 10
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
