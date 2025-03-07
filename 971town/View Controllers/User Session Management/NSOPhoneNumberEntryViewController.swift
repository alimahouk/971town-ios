//
//  NSOPhoneNumberEntryViewController.swift
//  971town
//
//  Created by Ali Mahouk on 11/01/2023.
//

import API
import SafariServices
import UIKit


class NSOPhoneNumberEntryViewController: UIViewController,
                                         UITextFieldDelegate {
        private let dialingCodeLabel: UILabel
        private var dialingCodes: Array<NSOCountryDialingCode> = []
        private let phoneNumberEntryView: UIStackView
        private let phoneNumberFieldView: UIStackView
        private let phoneNumberField: UITextField
        private let progressIndicator: UIAlertController
        private var selectedDialingCode: NSOCountryDialingCode?
        private var sendVerificationCodeButton: UIBarButtonItem?
        private var submitAccessPasswordButton: UIBarButtonItem?
        private let usageInfo: NSMutableAttributedString
        private let usageInfoLabel: UILabel
        private var viewIsLoaded: Bool = false
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                self.dialingCodeLabel = UILabel()
                self.dialingCodeLabel.font = .systemFont(ofSize: 18)
                self.dialingCodeLabel.textAlignment = .right
                self.dialingCodeLabel.textColor = .black
                self.dialingCodeLabel.setContentHuggingPriority(.defaultHigh,
                                                                for: .horizontal)
                
                self.phoneNumberEntryView = UIStackView()
                self.phoneNumberEntryView.axis = .vertical
                self.phoneNumberEntryView.isHidden = true
                
                self.phoneNumberFieldView = UIStackView()
                self.phoneNumberFieldView.alignment = .center
                self.phoneNumberFieldView.axis = .horizontal
                self.phoneNumberFieldView.distribution = .fillProportionally
                self.phoneNumberFieldView.spacing = 5
                
                self.phoneNumberField = UITextField()
                self.phoneNumberField.font = .systemFont(ofSize: 18)
                self.phoneNumberField.keyboardType = .phonePad
                self.phoneNumberField.placeholder = "Mobile Number"
                self.phoneNumberField.tag = 2
                self.phoneNumberField.textContentType = .telephoneNumber
                self.phoneNumberField.setContentHuggingPriority(.defaultLow,
                                                                for: .horizontal)
                
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
                
                self.usageInfo = NSMutableAttributedString(string: "By continuing, you agree to the Terms of Use.")
                let tosLinkRange = self.usageInfo.mutableString.range(of: "Terms of Use")
                
                if tosLinkRange.location != NSNotFound {
                        let linkAttributes = [
                                NSAttributedString.Key.foregroundColor: UIColor(
                                        red: 102/255.0,
                                        green: 161/255.0,
                                        blue: 255/255.0,
                                        alpha: 1.0
                                ),
                                NSAttributedString.Key.link: NSOWebPath.tos
                        ] as [NSAttributedString.Key : Any]
                        
                        self.usageInfo.setAttributes(linkAttributes,
                                                     range: tosLinkRange)
                }
                
                self.usageInfoLabel = UILabel()
                self.usageInfoLabel.attributedText = self.usageInfo
                self.usageInfoLabel.font = .systemFont(ofSize: 12)
                self.usageInfoLabel.isUserInteractionEnabled = true
                self.usageInfoLabel.numberOfLines = 0
                self.usageInfoLabel.textAlignment = .center
                self.usageInfoLabel.textColor = .systemGray
                
                self.phoneNumberFieldView.addArrangedSubview(self.dialingCodeLabel)
                self.phoneNumberFieldView.addArrangedSubview(self.phoneNumberField)
                
                self.phoneNumberEntryView.addArrangedSubview(self.phoneNumberFieldView)
                self.phoneNumberEntryView.addArrangedSubview(self.usageInfoLabel)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.phoneNumberField.delegate = self
                self.phoneNumberField.addTarget(
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
                
                let usageInfoLabelTapRecognizer = UITapGestureRecognizer(target: self,
                                                                         action: #selector(self.didTapUsageInfoLabel))
                self.usageInfoLabel.addGestureRecognizer(usageInfoLabelTapRecognizer)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        private func gestureRecognizer(gestureRecognizer: UITapGestureRecognizer,
                                       didTapAttributedTextInLabel label: UILabel,
                                       inRange targetRange: NSRange) -> Bool {
                // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage.
                let layoutManager = NSLayoutManager()
                let textContainer = NSTextContainer(size: CGSize.zero)
                let textStorage = NSTextStorage(attributedString: label.attributedText!)
                
                // Configure layoutManager and textStorage.
                layoutManager.addTextContainer(textContainer)
                textStorage.addLayoutManager(layoutManager)
                
                // Configure textContainer.
                textContainer.lineFragmentPadding = 0.0
                textContainer.lineBreakMode = label.lineBreakMode
                textContainer.maximumNumberOfLines = label.numberOfLines
                let labelSize = label.bounds.size
                textContainer.size = labelSize
                
                // Find the tapped character location and compare it to the specified range.
                let locationOfTouchInLabel = gestureRecognizer.location(in: label)
                let textBoundingBox = layoutManager.usedRect(for: textContainer)
                let textContainerOffset = CGPoint(
                        x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                        y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
                )
                let locationOfTouchInTextContainer = CGPoint(
                        x: locationOfTouchInLabel.x - textContainerOffset.x,
                        y: locationOfTouchInLabel.y - textContainerOffset.y
                )
                let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer,
                                                                    in: textContainer,
                                                                    fractionOfDistanceBetweenInsertionPoints: nil)
                
                return NSLocationInRange(indexOfCharacter, targetRange)
        }
        
        @objc
        private dynamic func didTapUsageInfoLabel(gestureRecognizer: UITapGestureRecognizer) {
                let tosLinkRange = self.usageInfo.mutableString.range(of: "Terms of Use")
                
                if self.gestureRecognizer(gestureRecognizer: gestureRecognizer,
                                          didTapAttributedTextInLabel: self.usageInfoLabel,
                                          inRange: tosLinkRange) {
                        self.usageInfo.enumerateAttribute(
                                .link,
                                in: tosLinkRange,
                                using: { value, range, stop in
                                        let config = SFSafariViewController.Configuration()
                                        
                                        let webViewController = SFSafariViewController(url: value as! URL,
                                                                                       configuration: config)
                                        present(webViewController,
                                                animated: true)
                                }
                        )
                }
        }
        
        @objc
        private dynamic func enableFormButtons() {
                if let phoneNumber = self.phoneNumberField.text {
                        if phoneNumber.isEmpty {
                                self.sendVerificationCodeButton?.isEnabled = false
                        } else {
                                self.sendVerificationCodeButton?.isEnabled = true
                        }
                }
        }
        
        func getDialingCodes() {
                self.navigationController?.present(self.progressIndicator,
                                                   animated: true)
                
                let request = NSOGetDialingCodeListRequest(isEnabled: true)
                NSOAPI.shared.getDialingCodeList(
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
                                                                title: "Retry",
                                                                style: .default,
                                                                handler: { action in
                                                                        self.getDialingCodes()
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
                                                                        if !self.dialingCodes.isEmpty {
                                                                                self.presentPhoneNumberEntryView()
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
                                        self.dialingCodes = apiResponse.dialingCodes
                                        
                                        DispatchQueue.main.async {
                                                self.progressIndicator.dismiss(animated: true)
                                                
                                                if !self.dialingCodes.isEmpty {
                                                        self.updateDialingCodeSelector()
                                                        self.presentPhoneNumberEntryView()
                                                } else {
                                                        let alert = UIAlertController(
                                                                title: "Network Issues",
                                                                message: "An error occurred. Try again later?",
                                                                preferredStyle: .alert
                                                        )
                                                        alert.addAction(
                                                                UIAlertAction(
                                                                        title: "Retry",
                                                                        style: .default,
                                                                        handler: { action in
                                                                                self.getDialingCodes()
                                                                        }
                                                                )
                                                        )
                                                        self.progressIndicator.dismiss(animated: true, completion: {
                                                                self.navigationController?.present(alert,
                                                                                                   animated: true)
                                                        })
                                                }
                                        }
                                }
                        }
                )
        }
        
        /// Keep the keyboard methods for future reference.
        @objc
        private dynamic func keyboardWillHide(_ notification: Notification) {
                let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                let duration = notification.userInfo![durationKey] as! Double
                
                // Extract the curve of the iOS keyboard animation.
                let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
                let curveValue = notification.userInfo![curveKey] as! Int
                let curve = UIView.AnimationCurve(rawValue: curveValue)!
                
                let animator = UIViewPropertyAnimator(duration: duration,
                                                      curve: curve) {
                        self.phoneNumberEntryView.frame = CGRect(
                                x: self.phoneNumberEntryView.frame.origin.x,
                                y: self.phoneNumberEntryView.frame.origin.y,
                                width: self.phoneNumberEntryView.bounds.width,
                                height: self.view.bounds.height - self.view.safeAreaInsets.bottom - self.view.safeAreaInsets.top
                        )
                }
                animator.startAnimation()
        }
        
        @objc
        private dynamic func keyboardWillShow(_ notification: Notification) {
                let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
                let duration = notification.userInfo![durationKey] as! Double
                
                // Extract the final frame of the keyboard.
                let frameKey = UIResponder.keyboardFrameEndUserInfoKey
                let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
                let keyboardHeight = keyboardFrameValue.cgRectValue.height
                
                // Extract the curve of the iOS keyboard animation.
                let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
                let curveValue = notification.userInfo![curveKey] as! Int
                let curve = UIView.AnimationCurve(rawValue: curveValue)!
                
                let animator = UIViewPropertyAnimator(duration: duration,
                                                      curve: curve) {
                        self.phoneNumberEntryView.frame = CGRect(
                                x: self.phoneNumberEntryView.frame.origin.x,
                                y: self.phoneNumberEntryView.frame.origin.y,
                                width: self.phoneNumberEntryView.bounds.width,
                                height: self.view.bounds.height - self.phoneNumberEntryView.frame.origin.y - keyboardHeight - 20
                        )
                }
                animator.startAnimation()
        }
        
        func presentPhoneNumberEntryView(giveFocus: Bool = true) {
                self.phoneNumberEntryView.isHidden = false
                
                self.phoneNumberField.isEnabled = true
                self.phoneNumberField.text = ""
                
                if giveFocus {
                        self.phoneNumberField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func sendVerificationCode() {
                guard var phoneNumberStr = self.phoneNumberField.text else { return }
                phoneNumberStr = String(phoneNumberStr.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                phoneNumberStr = phoneNumberStr.filter("0123456789".contains)
                self.phoneNumberField.text = phoneNumberStr // Give the user feedback of what characters are illegal.
                
                if !phoneNumberStr.isEmpty {
                        self.phoneNumberField.isEnabled = false
                        self.sendVerificationCodeButton?.isEnabled = false
                        
                        if phoneNumberStr.hasPrefix("0") {
                                // Trim leading zero.
                                phoneNumberStr.remove(at: phoneNumberStr.startIndex)
                        }
                        
                        let phoneNumber = NSOUserPhoneNumber(dialingCode: self.selectedDialingCode,
                                                             phoneNumber: phoneNumberStr)
                        
                        self.navigationController?.present(self.progressIndicator,
                                                           animated: true)
                        
                        let request = NSOSendVerificationCodeRequest(phoneNumber: phoneNumber)
                        NSOAPI.shared.sendVerificationCode(
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
                                                                                self.presentPhoneNumberEntryView()
                                                                        }
                                                                )
                                                        )
                                                        self.progressIndicator.dismiss(animated: true,
                                                                                       completion: {
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
                                                                                self.phoneNumberField.text = ""
                                                                                self.presentPhoneNumberEntryView()
                                                                        }
                                                                )
                                                        )
                                                        self.progressIndicator.dismiss(animated: true,
                                                                                       completion: {
                                                                self.navigationController?.present(alert,
                                                                                                   animated: true)
                                                        })
                                                }
                                        } else if let apiResponse = apiResponse {
                                                DispatchQueue.main.async {
                                                        let codeEntryViewController = NSOVerificationCodeEntryViewController(nibName: nil,
                                                                                                                             bundle: nil)
                                                        codeEntryViewController.codeDispatchTime = apiResponse.creationTimestamp
                                                        codeEntryViewController.phoneNumber = apiResponse.phoneNumber
                                                        
                                                        self.enableFormButtons()
                                                        self.progressIndicator.dismiss(animated: false,
                                                                                       completion: {
                                                                self.navigationController?.pushViewController(codeEntryViewController,
                                                                                                              animated: true)
                                                        })
                                                }
                                        }
                                }
                        )
                }
        }
        
        func textField(_ textField: UITextField,
                       shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool {
                self.enableFormButtons()
                
                return true
        }
        
        func updateDialingCodeSelector() {
                if self.dialingCodes.count > 0 {
                        self.selectedDialingCode = self.dialingCodes.first
                        self.dialingCodeLabel.text = "+\(self.selectedDialingCode!.code!)"
                }
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getDialingCodes()
                        
                        self.viewIsLoaded = true
                }
                
                if !self.dialingCodes.isEmpty {
                        self.presentPhoneNumberEntryView()
                }
                
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.sendVerificationCodeButton
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        self.sendVerificationCodeButton = UIBarButtonItem(
                                title: "Send Code",
                                style: .done,
                                target: self,
                                action: #selector(self.sendVerificationCode)
                        )
                        self.sendVerificationCodeButton?.isEnabled = false
                        
                        let usageInfoLabelSize = self.usageInfoLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        
                        self.phoneNumberEntryView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 20,
                                y: (self.view.bounds.height / 2) - max(200, 100 + usageInfoLabelSize.height),
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 40,
                                height: max(200, 100 + usageInfoLabelSize.height)
                        )
                        self.view.addSubview(self.phoneNumberEntryView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.navigationItem.hidesBackButton = true
                self.view.backgroundColor = .white
        }
}
