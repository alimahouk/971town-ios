//
//  NSOProductNameViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOProductNameViewController: UIViewController,
                                    UIAdaptivePresentationControllerDelegate,
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    UITextFieldDelegate {
        private var cancelButton: UIBarButtonItem?
        private let infoLabel: UILabel
        private let isProductVariant: Bool
        private let productNameField: UITextField
        private var nextButton: UIBarButtonItem?
        private var similarProducts: Array<NSOProduct> = []
        private let similarProductsTableView: UITableView
        private static let similarProductsTableViewCellIdentifier: String = "ProductCell"
        private var viewIsLoaded: Bool = false
        
        public var product: NSOProduct
        
        init(product: NSOProduct) {
                self.product = product
                
                if product.parentProductID != nil {
                        self.isProductVariant = true
                } else {
                        self.isProductVariant = false
                }
                
                self.infoLabel = UILabel()
                self.infoLabel.textColor = .systemGray
                self.infoLabel.numberOfLines = 0
                
                let productNameFieldIcon: UIImage?
                
                if self.isProductVariant {
                        productNameFieldIcon = UIImage(systemName: "square.on.square")
                } else {
                        productNameFieldIcon = UIImage(systemName: "shippingbox")
                }
                
                let productNameFieldIconView = UIImageView(
                        image: productNameFieldIcon?.withTintColor(.systemGray,
                                                                   renderingMode: .alwaysOriginal)
                )
                productNameFieldIconView.contentMode = .center
                productNameFieldIconView.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: 35,
                        height: 18
                )
                let productNameFieldIconContainer = UIView(frame: productNameFieldIconView.bounds)
                productNameFieldIconContainer.addSubview(productNameFieldIconView)
                
                let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
                self.productNameField = UITextField()
                self.productNameField.autocapitalizationType = .words
                self.productNameField.autocorrectionType = .yes
                self.productNameField.backgroundColor = .systemGray6
                self.productNameField.clearButtonMode = .always
                self.productNameField.enablesReturnKeyAutomatically = true
                self.productNameField.font = .systemFont(ofSize: 18)
                self.productNameField.isHidden = true
                self.productNameField.layer.cornerRadius = softRoundCornerRadius
                self.productNameField.layer.masksToBounds = true
                self.productNameField.layer.opacity = 0.0
                self.productNameField.leftView = productNameFieldIconContainer
                self.productNameField.leftViewMode = .always
                self.productNameField.returnKeyType = .next
                self.productNameField.tag = 1
                self.productNameField.sizeToFit()
                
                self.similarProductsTableView = UITableView()
                self.similarProductsTableView.isHidden = true
                self.similarProductsTableView.layer.opacity = 0.0
                
                super.init(nibName: nil,
                           bundle: nil)
                
                if self.isProductVariant {
                        self.title = "Product Variant Name"
                        
                        self.infoLabel.text = "You don't need to include the main product's name before this variant's name."
                        
                        self.productNameField.placeholder = "Variant Name"
                } else {
                        self.title = "Product Name"
                        
                        self.infoLabel.text = "You don't need to include the brand's name before this product's name."
                        
                        self.productNameField.placeholder = "Product Name"
                }
                
                self.productNameField.delegate = self
                self.productNameField.addTarget(
                        self,
                        action: #selector(self.textFieldDidChange),
                        for: .editingChanged
                )
                
                self.similarProductsTableView.dataSource = self
                self.similarProductsTableView.delegate = self
                self.similarProductsTableView.register(UITableViewCell.self,
                                                       forCellReuseIdentifier: NSOProductNameViewController.similarProductsTableViewCellIdentifier)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func checkForSimilarProducts(_ products: Array<NSOProduct>) {
                self.similarProducts.removeAll()
                
                guard let enteredName = self.productNameField.text else { return }
                var aliasFormattedName = String(enteredName.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                aliasFormattedName = aliasFormattedName.lowercased()
                
                for product in products {
                        if self.isProductVariant {
                                if product.parentProductID == self.product.parentProductID {
                                        if product.name!.localizedStandardContains(enteredName)
                                                || product.alias!.localizedStandardContains(aliasFormattedName) {
                                                self.similarProducts.append(product)
                                        }
                                }
                        } else if product.name!.localizedStandardContains(enteredName)
                                        || product.alias!.localizedStandardContains(aliasFormattedName) {
                                self.similarProducts.append(product)
                        }
                }
                
                if !self.similarProducts.isEmpty {
                        self.presentSimilarProducts()
                } else {
                        self.presentProductAliasViewController()
                }
        }
        
        @objc
        private dynamic func dismissView() {
                self.navigationController?.dismiss(animated: true)
        }
        
        @objc
        private dynamic func enableFormButtons() {
                if let productName = self.productNameField.text {
                        if productName.isEmpty {
                                self.nextButton?.isEnabled = false
                        } else {
                                self.nextButton?.isEnabled = true
                        }
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
        
        private func presentProductAliasViewController() {
                guard var productName = self.productNameField.text else { return }
                
                if self.isProductVariant {
                        if let range = productName.range(of: self.product.parentProduct!.displayName!,
                                                                options: [.caseInsensitive]) {
                                productName = String(productName[range.upperBound...])
                        }
                } else if let range = productName.range(of: self.product.brand!.name!,
                                                        options: [.caseInsensitive]) {
                        productName = String(productName[range.upperBound...])
                }
                
                self.product.name = productName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                let productAliasViewController = NSOProductAliasViewController(product: self.product)
                self.navigationController?.pushViewController(productAliasViewController,
                                                              animated: true)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Reset the view.
                        self.presentProductNameEntryView(giveFocus: false)
                }
        }
        
        private func presentProductNameEntryView(giveFocus: Bool = true) {
                guard self.similarProducts.isEmpty else { return }
                
                self.infoLabel.isHidden = false
                
                self.productNameField.isEnabled = true
                self.productNameField.isHidden = false
                self.productNameField.textColor = .black
                
                let animator = UIViewPropertyAnimator(duration: 0.2,
                                                      curve: .easeOut) {
                        self.infoLabel.alpha = 1.0
                        
                        self.productNameField.frame.origin = CGPoint(x: self.view.safeAreaInsets.left + 20,
                                                                     y: (self.view.bounds.height / 2) - 200)
                        self.productNameField.layer.opacity = 1.0
                        
                        self.similarProductsTableView.frame.origin = CGPoint(x: 0,
                                                                             y: self.view.safeAreaInsets.top + 100)
                        self.similarProductsTableView.layer.opacity = 0.0
                }
                animator.addCompletion({ _ in
                        self.similarProducts = []
                        
                        self.similarProductsTableView.isHidden = true
                        self.similarProductsTableView.reloadData()
                        
                        if giveFocus {
                                self.productNameField.becomeFirstResponder()
                        }
                })
                animator.startAnimation()
                
                self.enableFormButtons()
        }
        
        private func presentSimilarProducts() {
                guard !self.similarProducts.isEmpty else { return }
                
                self.productNameField.isEnabled = true
                self.productNameField.isHidden = false
                self.productNameField.textColor = .systemYellow
                self.productNameField.resignFirstResponder()
                
                self.similarProductsTableView.reloadData()
                self.similarProductsTableView.isHidden = false
                
                let animator = UIViewPropertyAnimator(duration: 0.2,
                                                      curve: .easeOut) {
                        self.infoLabel.alpha = 0.0
                        
                        self.productNameField.frame.origin = CGPoint(x: self.view.safeAreaInsets.left + 20,
                                                                     y: self.view.safeAreaInsets.top + 20)
                        
                        self.similarProductsTableView.frame = CGRect(
                                x: 0,
                                y: self.productNameField.frame.origin.y + self.productNameField.bounds.height + 20,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,
                                height: self.view.bounds.height - self.view.safeAreaInsets.top - self.productNameField.frame.origin.y - self.productNameField.bounds.height - 20
                        )
                        self.similarProductsTableView.layer.opacity = 1.0
                }
                animator.addCompletion({ _ in
                        self.infoLabel.isHidden = true
                })
                animator.startAnimation()
                
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func searchProducts() {
                guard var productName = self.productNameField.text else { return }
                productName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
                
                self.productNameField.text = productName   // Give the user feedback of what characters are illegal.
                
                if productName == self.product.name || !self.similarProducts.isEmpty {
                        self.presentProductAliasViewController()
                } else if !productName.isEmpty {
                        self.productNameField.isEnabled = false
                        self.nextButton?.isEnabled = false
                        
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
                                                                                self.presentProductNameEntryView()
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
                                                                                self.presentProductNameEntryView()
                                                                        }
                                                                )
                                                        )
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                }
                                        } else if let apiResponse = apiResponse {
                                                DispatchQueue.main.async {
                                                        if apiResponse.products.isEmpty {
                                                                self.presentProductAliasViewController()
                                                        } else {
                                                                self.checkForSimilarProducts(apiResponse.products)
                                                        }
                                                }
                                        }
                                }
                        )
                }
        }
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
                return self.similarProducts.count
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let product = self.similarProducts[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductNameViewController.similarProductsTableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + product.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = product.displayName
                
                cell.accessoryType = .detailButton
                cell.contentConfiguration = content
                
                return cell
        }
        
        func tableView(_ tableView: UITableView,
                       didSelectRowAt indexPath: IndexPath) {
                let product = self.similarProducts[indexPath.row]
                let productViewController = NSOProductViewController(product: product)
                productViewController.allowsCreationWorkflows = false
                self.navigationController?.pushViewController(productViewController,
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
                        self.searchProducts()
                }
                
                return false
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                if self == self.navigationController?.viewControllers.first {
                        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
                }
                
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.nextButton
                self.navigationController?.presentationController?.delegate = self
                
                self.presentProductNameEntryView()
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
                                        action: #selector(self.searchProducts)
                                )
                        }
                        
                        let infoLabelSize = self.infoLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.infoLabel.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 20,
                                y: self.view.safeAreaInsets.top + 40,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: infoLabelSize.height
                        )
                        self.view.addSubview(self.infoLabel)
                        
                        self.productNameField.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 20,
                                y: (self.view.bounds.height / 2) - 200,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: self.productNameField.bounds.height + 10
                        )
                        self.view.addSubview(self.productNameField)
                        
                        let similarProductsWarningLabel = UILabel()
                        similarProductsWarningLabel.numberOfLines = 0
                        similarProductsWarningLabel.text = "Products with similar names already exist! Check the products below to make sure you're not adding a duplicate. Otherwise, tap \(self.nextButton!.title!) to go ahead."
                        
                        let similarProductsWarningLabelSize = similarProductsWarningLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        similarProductsWarningLabel.frame = CGRect(
                                x: 20,
                                y: 0,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: similarProductsWarningLabelSize.height
                        )
                        
                        let similarProductsTableHeaderView = UIView(
                                frame: CGRect(
                                        x: 0,
                                        y: 0,
                                        width: 0,
                                        height: similarProductsWarningLabelSize.height + 15
                                )
                        )
                        similarProductsTableHeaderView.addSubview(similarProductsWarningLabel)
                        
                        self.similarProductsTableView.tableHeaderView = similarProductsTableHeaderView
                        self.similarProductsTableView.contentInset = UIEdgeInsets(
                                top: 0,
                                left: self.view.safeAreaInsets.left,
                                bottom: self.view.safeAreaInsets.bottom,
                                right: self.view.safeAreaInsets.right
                        )
                        self.similarProductsTableView.frame = CGRect(
                                x: 0,
                                y: self.view.safeAreaInsets.top + 100,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right,
                                height: self.view.bounds.height - self.view.safeAreaInsets.top - self.productNameField.frame.origin.y - self.productNameField.bounds.height - 20
                        )
                        self.view.addSubview(self.similarProductsTableView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if let selectedIndexPath = self.similarProductsTableView.indexPathForSelectedRow {
                        self.similarProductsTableView.deselectRow(at: selectedIndexPath,
                                                                  animated: animated)
                }
        }
}
