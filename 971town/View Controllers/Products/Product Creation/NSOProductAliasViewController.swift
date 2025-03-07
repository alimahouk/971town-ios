//
//  NSOProductAliasViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOProductAliasViewController: UIViewController,
                                     UIAdaptivePresentationControllerDelegate,
                                     UITextFieldDelegate {
        private let infoLabel: UILabel
        private let isProductVariant: Bool
        private let productDetailEntryView: UIStackView
        private let productAliasField: UITextField
        private var nextButton: UIBarButtonItem?
        private var viewIsLoaded: Bool = false
        
        public let product: NSOProduct
        
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
                self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
                
                self.productDetailEntryView = UIStackView()
                self.productDetailEntryView.alignment = .center
                self.productDetailEntryView.distribution = .fillProportionally
                self.productDetailEntryView.axis = .vertical
                
                let aliasIconView = UIImageView(
                        image: UIImage(systemName: "at.badge.plus")?.withTintColor(.systemGray,
                                                                                   renderingMode: .alwaysOriginal)
                )
                aliasIconView.contentMode = .center
                aliasIconView.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: 35,
                        height: 18
                )
                let aliasIconContainer = UIView(frame: aliasIconView.bounds)
                aliasIconContainer.addSubview(aliasIconView)
                
                let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
                self.productAliasField = UITextField()
                self.productAliasField.autocapitalizationType = .none
                self.productAliasField.autocorrectionType = .no
                self.productAliasField.backgroundColor = .systemGray6
                self.productAliasField.clearButtonMode = .always
                self.productAliasField.enablesReturnKeyAutomatically = true
                self.productAliasField.font = .systemFont(ofSize: 18)
                self.productAliasField.layer.cornerRadius = softRoundCornerRadius
                self.productAliasField.layer.masksToBounds = true
                self.productAliasField.leftView = aliasIconContainer
                self.productAliasField.leftViewMode = .always
                self.productAliasField.placeholder = "Product Alias"
                self.productAliasField.returnKeyType = .next
                self.productAliasField.tag = 1
                self.productAliasField.textContentType = .username
                self.productAliasField.translatesAutoresizingMaskIntoConstraints = false
                self.productAliasField.setContentHuggingPriority(.defaultHigh,
                                                                 for: .vertical)
                
                self.productDetailEntryView.addArrangedSubview(self.infoLabel)
                self.productDetailEntryView.addArrangedSubview(self.productAliasField)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                if product.parentProductID != nil {
                        self.title = "Product Variant Alias"
                        
                        self.infoLabel.text = "You're about to add a new product variant.\n\nPick an alias for it (an alias is like a username, i.e. the same rules apply to it)."
                } else {
                        self.title = "Product Alias"
                        
                        self.infoLabel.text = "You're about to add a new product.\n\nPick an alias for it (an alias is like a username, i.e. the same rules apply to it)."
                }
                
                self.productAliasField.delegate = self
                self.productAliasField.addTarget(
                        self,
                        action: #selector(self.textFieldDidChange),
                        for: .editingChanged
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        private dynamic func checkAlias() {
                guard let alias = self.productAliasField.text else { return }
                let request = NSOCheckAliasRequest(alias: alias)
                
                self.productAliasField.text = request.alias  // Give the user feedback of what characters are illegal.
                
                guard !request.alias.isEmpty else { return }
                
                self.productAliasField.isEnabled = false
                self.nextButton?.isEnabled = false
                
                NSOAPI.shared.checkAlias(
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
                                                                        self.presentProductAliasEntryView()
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
                                                                        self.presentProductAliasEntryView()
                                                                }
                                                        )
                                                )
                                                self.navigationController?.present(alert,
                                                                                   animated: true)
                                        }
                                } else if apiResponse != nil {
                                        DispatchQueue.main.async {
                                                self.product.alias = alias
                                                
                                                let tagsViewController = NSOProductTagsViewController(product: self.product)
                                                self.navigationController?.pushViewController(tagsViewController,
                                                                                              animated: true)
                                                self.presentProductAliasEntryView(giveFocus: false)
                                        }
                                }
                        }
                )
        }
        
        @objc
        private dynamic func enableFormButtons() {
                var alias: String? = nil
                
                if var aliasFieldString = self.productAliasField.text {
                        aliasFieldString = aliasFieldString.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !aliasFieldString.isEmpty {
                                alias = aliasFieldString
                        }
                }
                
                if alias != nil {
                        self.nextButton?.isEnabled = true
                } else {
                        self.nextButton?.isEnabled = false
                }
        }
        
        private func presentProductAliasEntryView(giveFocus: Bool = true) {
                self.productAliasField.isEnabled = true
                self.productAliasField.isHidden = false
                
                if giveFocus {
                        self.productAliasField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if !self.product.tags.isEmpty {
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
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
                self.enableFormButtons()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                if textField.tag == 1 {
                        self.checkAlias()
                }
                
                return false
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                self.presentProductAliasEntryView()
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.nextButton
                self.navigationController?.presentationController?.delegate = self
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.nextButton == nil {
                                self.nextButton = UIBarButtonItem(
                                        title: "Next",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.checkAlias)
                                )
                        }
                        
                        self.productDetailEntryView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 20,
                                y: (self.view.bounds.height / 2) - 200,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: 200
                        )
                        self.view.addSubview(self.productDetailEntryView)
                        
                        let views = [
                                "infoLabel": self.infoLabel,
                                "productAliasField": self.productAliasField
                        ] as [String : Any]
                        
                        var productDetailEntryViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[infoLabel]-(20)-[productAliasField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        productDetailEntryViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|[productAliasField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        self.productDetailEntryView.addConstraints(productDetailEntryViewConstraints)
                        
                        if !self.isProductVariant {
                                let name: String
                                
                                if let brand = self.product.brand {
                                        name = "\(brand.name!) \(self.product.name!)"
                                } else {
                                        name = self.product.name!
                                }
                                
                                var prefilledAlias = String(name.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                                prefilledAlias = String(prefilledAlias.unicodeScalars.filter(CharacterSet.punctuationCharacters.inverted.contains))
                                prefilledAlias = prefilledAlias.lowercased()
                                
                                self.productAliasField.text = prefilledAlias
                        } else if let name = self.product.displayName {
                                var prefilledAlias = String(name.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                                prefilledAlias = String(prefilledAlias.unicodeScalars.filter(CharacterSet.punctuationCharacters.inverted.contains))
                                prefilledAlias = prefilledAlias.lowercased()
                                
                                self.productAliasField.text = prefilledAlias
                        }
                        
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
}
