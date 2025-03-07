//
//  NSOVerificationCodeEntryViewController.swift
//  971town
//
//  Created by Ali Mahouk on 08/02/2023.
//

import API
import UIKit


class NSOVerificationCodeEntryViewController: UIViewController,
                                              UITextFieldDelegate {
        private let progressIndicator: UIAlertController
        private let verificationCodeEntryView: UIStackView
        private let verificationCodeField: UITextField
        private var viewIsLoaded: Bool = false
        
        public var codeDispatchTime: Date?
        public var phoneNumber: NSOUserPhoneNumber?
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.isUserInteractionEnabled = false
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressIndicator = UIAlertController(
                        title: "Checking…",
                        message: nil,
                        preferredStyle: .alert
                )
                self.progressIndicator.view.addSubview(activityIndicatorView)
                
                self.verificationCodeEntryView = UIStackView()
                self.verificationCodeEntryView.axis = .vertical
                self.verificationCodeEntryView.spacing = 5
                
                self.verificationCodeField = UITextField()
                self.verificationCodeField.autocapitalizationType = .none
                self.verificationCodeField.autocorrectionType = .no
                self.verificationCodeField.enablesReturnKeyAutomatically = true
                self.verificationCodeField.font = .systemFont(ofSize: 18)
                self.verificationCodeField.keyboardType = .numberPad
                self.verificationCodeField.placeholder = "Verification code?"
                self.verificationCodeField.returnKeyType = .go
                self.verificationCodeField.tag = 1
                self.verificationCodeField.textAlignment = .center
                self.verificationCodeField.textContentType = .oneTimeCode
                self.verificationCodeField.setContentHuggingPriority(.defaultHigh,
                                                                     for: .vertical)
                self.verificationCodeEntryView.addArrangedSubview(self.verificationCodeField)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
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
                
                self.verificationCodeField.delegate = self
                self.verificationCodeField.addTarget(
                        self,
                        action: #selector(self.verificationCodeChanged),
                        for: .editingChanged
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        func checkVerificationCode() {
                guard var verificationCode = self.verificationCodeField.text else { return }
                verificationCode = String(verificationCode.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if !verificationCode.isEmpty {
                        verificationCode = verificationCode.filter("0123456789".contains)
                        self.verificationCodeField.text = verificationCode // Give the user feedback of what characters are illegal.
                        
                        self.navigationController?.present(self.progressIndicator,
                                                           animated: true)
                        
                        let request = NSOCheckVerificationCodeRequest(code: verificationCode,
                                                                      phoneNumberID: self.phoneNumber!.id!)
                        NSOAPI.shared.checkVerificationCode(
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
                                                                                self.presentVerificationCodeEntryView()
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
                                                                                        self.presentVerificationCodeEntryView()
                                                                                }
                                                                        }
                                                                )
                                                        )
                                                        self.progressIndicator.dismiss(animated: true, completion: {
                                                                self.navigationController?.present(alert,
                                                                                                   animated: true)
                                                        })
                                                }
                                        } else if let apiResponse = apiResponse {
                                                DispatchQueue.main.async {
                                                        self.progressIndicator.dismiss(animated: true, completion: {
                                                                if let userAccounts = apiResponse.userAccounts {
                                                                        // Existing user.
                                                                        self.phoneNumber!.userID = apiResponse.userID
                                                                        
                                                                        let accountSelector = NSOUserAccountSelectionViewController(nibName: nil,
                                                                                                                                    bundle: nil)
                                                                        accountSelector.phoneNumber = self.phoneNumber
                                                                        accountSelector.userAccounts = userAccounts
                                                                        accountSelector.verificationCode = verificationCode
                                                                        
                                                                        self.navigationController?.pushViewController(accountSelector,
                                                                                                                      animated: true)
                                                                } else {
                                                                        // New user.
                                                                        let accountCreationViewController = NSOUserAccountCreationViewController(nibName: nil,
                                                                                                                                                 bundle: nil)
                                                                        accountCreationViewController.phoneNumber = self.phoneNumber
                                                                        accountCreationViewController.verificationCode = verificationCode
                                                                        
                                                                        self.navigationController?.pushViewController(accountCreationViewController,
                                                                                                                      animated: true)
                                                                }
                                                        })
                                                }
                                        }
                                }
                        )
                }
        }
        
        func presentVerificationCodeEntryView(giveFocus: Bool = true) {
                self.verificationCodeEntryView.isHidden = false
                
                self.verificationCodeField.isEnabled = true
                self.verificationCodeField.text = ""
                
                if giveFocus {
                        self.verificationCodeField.becomeFirstResponder()
                }
        }
        
        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
                let allowedCharacters = CharacterSet.decimalDigits
                let characterSet = CharacterSet(charactersIn: string)
                let willChange = allowedCharacters.isSuperset(of: characterSet)
                
                if willChange {
                        self.verificationCodeChanged()
                }
                
                return willChange
        }
        
        @objc
        dynamic func verificationCodeChanged() {
                guard let verificationCode = self.verificationCodeField.text else { return }
                
                if verificationCode.count == NSOAPI.Configuration.verificationCodeLength {
                        self.verificationCodeField.isEnabled = false
                        
                        self.checkVerificationCode()
                }
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.presentVerificationCodeEntryView()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + NSOAPI.Configuration.verificationCodeResendInterval) {
                                self.navigationItem.hidesBackButton = false
                                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                        }
                }
                
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        self.verificationCodeEntryView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 40,
                                y: (self.view.bounds.height / 2) - 200,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 80,
                                height: 200
                        )
                        self.view.addSubview(self.verificationCodeEntryView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
                self.navigationItem.hidesBackButton = true
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                // Re-enable the swipe gesture to go back.
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
}
