//
//  NSOBrandAliasViewController.swift
//  971town
//
//  Created by Ali Mahouk on 14/02/2023.
//

import API
import UIKit


class NSOBrandAliasViewController: UIViewController,
                                   UIAdaptivePresentationControllerDelegate,
                                   UITextFieldDelegate {
        private let brandDetailEntryView: UIStackView
        private let brandAliasField: UITextField
        private let infoLabel: UILabel
        private var nextButton: UIBarButtonItem?
        private var viewIsLoaded: Bool = false
        
        public let brand: NSOBrand
        
        init(brand: NSOBrand) {
                self.brand = brand
                
                self.brandDetailEntryView = UIStackView()
                self.brandDetailEntryView.alignment = .center
                self.brandDetailEntryView.distribution = .fillProportionally
                self.brandDetailEntryView.axis = .vertical
                
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
                self.brandAliasField = UITextField()
                self.brandAliasField.autocapitalizationType = .none
                self.brandAliasField.autocorrectionType = .no
                self.brandAliasField.backgroundColor = .systemGray6
                self.brandAliasField.clearButtonMode = .always
                self.brandAliasField.enablesReturnKeyAutomatically = true
                self.brandAliasField.font = .systemFont(ofSize: 18)
                self.brandAliasField.layer.cornerRadius = softRoundCornerRadius
                self.brandAliasField.layer.masksToBounds = true
                self.brandAliasField.leftView = aliasIconContainer
                self.brandAliasField.leftViewMode = .always
                self.brandAliasField.placeholder = "Brand Alias"
                self.brandAliasField.returnKeyType = .next
                self.brandAliasField.tag = 1
                self.brandAliasField.textContentType = .username
                self.brandAliasField.translatesAutoresizingMaskIntoConstraints = false
                self.brandAliasField.setContentHuggingPriority(.defaultHigh,
                                                               for: .vertical)
                
                self.infoLabel = UILabel()
                self.infoLabel.textColor = .systemGray
                self.infoLabel.numberOfLines = 0
                self.infoLabel.text = "You're about to add a new brand.\n\nPick an alias for it (an alias is like a username, i.e. the same rules apply to it)."
                self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
                
                self.brandDetailEntryView.addArrangedSubview(self.infoLabel)
                self.brandDetailEntryView.addArrangedSubview(self.brandAliasField)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.title = "Brand Alias"
                
                self.brandAliasField.delegate = self
                self.brandAliasField.addTarget(
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
                guard let alias = self.brandAliasField.text else { return }
                let request = NSOCheckAliasRequest(alias: alias)
                
                self.brandAliasField.text = request.alias  // Give the user feedback of what characters are illegal.
                
                guard !request.alias.isEmpty else { return }
                
                self.brandAliasField.isEnabled = false
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
                                                                        self.presentBrandAliasEntryView()
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
                                                                        self.presentBrandAliasEntryView()
                                                                }
                                                        )
                                                )
                                                self.navigationController?.present(alert,
                                                                                   animated: true)
                                        }
                                } else if apiResponse != nil {
                                        DispatchQueue.main.async {
                                                self.brand.alias = alias
                                                
                                                let brandAvatarViewController = NSOBrandAvatarViewController(brand: self.brand)
                                                self.navigationController?.pushViewController(brandAvatarViewController,
                                                                                              animated: true)
                                                
                                                self.presentBrandAliasEntryView(giveFocus: false)
                                        }
                                }
                        }
                )
        }
        
        @objc
        private dynamic func enableFormButtons() {
                var alias: String? = nil
                
                if var aliasFieldString = self.brandAliasField.text {
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
        
        private func presentBrandAliasEntryView(giveFocus: Bool = true) {
                self.brandAliasField.isEnabled = true
                self.brandAliasField.isHidden = false
                
                if giveFocus {
                        self.brandAliasField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if !self.brand.tags.isEmpty {
                        ret = false
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
                
                self.presentBrandAliasEntryView()
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
                        
                        self.brandDetailEntryView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 20,
                                y: (self.view.bounds.height / 2) - 200,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: 200
                        )
                        self.view.addSubview(self.brandDetailEntryView)
                        
                        let views = [
                                "brandAliasField": self.brandAliasField,
                                "infoLabel": self.infoLabel
                        ] as [String : Any]
                        
                        var brandDetailEntryViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[infoLabel]-(20)-[brandAliasField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        brandDetailEntryViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|[brandAliasField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        self.brandDetailEntryView.addConstraints(brandDetailEntryViewConstraints)
                        
                        if let name = self.brand.name {
                                var alias = String(name.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                                alias = String(alias.unicodeScalars.filter(CharacterSet.punctuationCharacters.inverted.contains))
                                alias = alias.lowercased()
                                
                                self.brandAliasField.text = alias
                        }
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
}
