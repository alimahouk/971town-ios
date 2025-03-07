//
//  UserAccountCreationViewController.swift
//  971town
//
//  Created by Ali Mahouk on 08/02/2023.
//

import API
import UIKit


class NSOUserAccountCreationViewController: UIViewController,
                                            UITextFieldDelegate {
        private let accountDetailEntryView: UIStackView
        private let aliasField: UITextField
        private let infoLabel: UILabel
        private var joinButton: UIBarButtonItem?
        private let progressIndicator: UIAlertController
        private var viewIsLoaded: Bool = false
        
        public var phoneNumber: NSOUserPhoneNumber?
        public var userID: Int?
        public var verificationCode: String?
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                self.accountDetailEntryView = UIStackView()
                self.accountDetailEntryView.alignment = .center
                self.accountDetailEntryView.distribution = .fillProportionally
                self.accountDetailEntryView.axis = .vertical
                
                self.aliasField = UITextField()
                self.aliasField.autocapitalizationType = .none
                self.aliasField.autocorrectionType = .no
                self.aliasField.enablesReturnKeyAutomatically = true
                self.aliasField.font = .systemFont(ofSize: 18)
                self.aliasField.placeholder = "Username"
                self.aliasField.returnKeyType = .join
                self.aliasField.tag = 1
                self.aliasField.textAlignment = .center
                self.aliasField.textContentType = .username
                self.aliasField.setContentHuggingPriority(.defaultHigh,
                                                          for: .vertical)
                
                self.infoLabel = UILabel()
                self.infoLabel.textColor = .systemGray
                self.infoLabel.numberOfLines = 0
                self.infoLabel.text = "You're about to create a new account.\n\nPick a username (you can't change this later)."
                self.infoLabel.setContentHuggingPriority(.defaultLow,
                                                         for: .vertical)
                
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.isUserInteractionEnabled = false
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressIndicator = UIAlertController(
                        title: "Creating Account…",
                        message: nil,
                        preferredStyle: .alert
                )
                self.progressIndicator.view.addSubview(activityIndicatorView)
                
                self.accountDetailEntryView.addArrangedSubview(self.infoLabel)
                self.accountDetailEntryView.addArrangedSubview(self.aliasField)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.aliasField.delegate = self
                self.aliasField.addTarget(
                        self,
                        action: #selector(self.enableFormButtons),
                        for: .editingChanged
                )
                
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
        private dynamic func enableFormButtons() {
                if let alias = self.aliasField.text {
                        if alias.isEmpty {
                                self.joinButton?.isEnabled = false
                        } else {
                                self.joinButton?.isEnabled = true
                        }
                }
        }
        
        @objc
        private dynamic func join() {
                guard let phoneNumber = self.phoneNumber else { return }
                guard let verificationCode = self.verificationCode else { return }
                guard let alias = self.aliasField.text else { return }
                
                let request = NSOJoinRequest(
                        alias: alias,
                        code: verificationCode,
                        phoneNumberID: phoneNumber.id!
                )
                
                self.aliasField.text = request.alias  // Give the user feedback of what characters are illegal.
                
                guard !request.alias.isEmpty else { return }
                
                self.aliasField.isEnabled = false
                self.joinButton?.isEnabled = false
                
                self.navigationController?.present(self.progressIndicator,
                                                   animated: true)
                NSOAPI.shared.join(
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
                                                                        self.presentAccountDetailEntryView()
                                                                }
                                                        )
                                                )
                                                self.progressIndicator.dismiss(animated: true, completion: {
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                })
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
                                                                        if errorResponse.error.errorCode == .verificationCodeExpired
                                                                                || errorResponse.error.errorCode == .verificationCodeNotFound
                                                                                || errorResponse.error.errorCode == .phoneNumberNotFound {
                                                                                self.navigationController?.popToRootViewController(animated: true)
                                                                        } else {
                                                                                self.presentAccountDetailEntryView()
                                                                        }
                                                                }
                                                        )
                                                )
                                                self.progressIndicator.dismiss(animated: true, completion: {
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                })
                                        }
                                } else if apiResponse != nil {
                                        DispatchQueue.main.async {
                                                // Nothing to be done. The view will be dismissed by the navigation controller.
                                                self.progressIndicator.dismiss(animated: false)
                                        }
                                }
                        }
                )
        }
        
        private func presentAccountDetailEntryView(giveFocus: Bool = true) {
                self.aliasField.isEnabled = true
                
                if giveFocus {
                        self.aliasField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
                self.enableFormButtons()
                
                return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                if textField.tag == 1 {
                        self.join()
                }
                
                return false
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        if self.phoneNumber?.userID != nil {
                                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                                self.navigationItem.hidesBackButton = false
                        } else {
                                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                                self.navigationItem.hidesBackButton = true
                        }
                        
                        self.presentAccountDetailEntryView()
                        
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.joinButton
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        self.joinButton = UIBarButtonItem(
                                title: "Join",
                                style: .done,
                                target: self,
                                action: #selector(self.join)
                        )
                        self.joinButton?.isEnabled = false
                        
                        self.accountDetailEntryView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 40,
                                y: (self.view.bounds.height / 2) - 200,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 80,
                                height: 200
                        )
                        self.view.addSubview(self.accountDetailEntryView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                // Re-enable the swipe gesture to go back.
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
}
