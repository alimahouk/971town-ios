//
//  NSOAboutViewController.swift
//  971town
//
//  Created by Ali Mahouk on 27/02/2023.
//

import API
import UIKit


class NSOAboutViewController: UIViewController {
        private let appInfoView: UIStackView
        private let appNameLabel: UILabel
        private var cancelButton: UIBarButtonItem?
        private let copyrightLabel: UILabel
        private let currentAccountInfoLabel: UILabel
        private let externalLinkView: UIStackView
        private let instagramButton: UIButton
        private let logoutButton: UIButton
        private let sendFeedbackButton: UIButton
        private let versionLabel: UILabel
        private var viewIsLoaded: Bool = false
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                self.appInfoView = UIStackView()
                self.appInfoView.axis = .vertical
                
                let appName = Bundle.main.infoDictionary?["CFBundleName"] as! String
                
                self.appNameLabel = UILabel()
                self.appNameLabel.font = .boldSystemFont(ofSize: 18)
                self.appNameLabel.text = appName
                self.appNameLabel.textAlignment = .center
                self.appNameLabel.sizeToFit()
                
                self.copyrightLabel = UILabel()
                self.copyrightLabel.numberOfLines = 0
                self.copyrightLabel.text = "Copyright © 2023 971town. All rights reserved."
                self.copyrightLabel.textAlignment = .center
                self.copyrightLabel.textColor = .systemGray
                
                self.currentAccountInfoLabel = UILabel()
                self.currentAccountInfoLabel.text = "Logged in as \(NSOAPI.Configuration.mentionSequence)\(NSOAPI.shared.currentUserAccount!.alias!)"
                
                self.externalLinkView = UIStackView()
                self.externalLinkView.axis = .vertical
                
                let instagramButtonIconSize = CGSize(width: 24,
                                                     height: 24)
                UIGraphicsBeginImageContextWithOptions(instagramButtonIconSize, false, 0)
                var instagramButtonIcon = UIImage(named: "InstagramIcon")
                instagramButtonIcon!.draw(in: CGRect(origin: .zero, size: instagramButtonIconSize))
                instagramButtonIcon = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysTemplate)
                
                var instagramButtonConfig = UIButton.Configuration.plain()
                instagramButtonConfig.image = instagramButtonIcon
                instagramButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 14, bottom: 8, trailing: 14)
                instagramButtonConfig.imagePadding = 14
                instagramButtonConfig.imagePlacement = .leading
                instagramButtonConfig.title = "Instagram"
                instagramButtonConfig.titleAlignment = .leading
                
                self.instagramButton = UIButton(configuration: instagramButtonConfig)
                self.instagramButton.contentHorizontalAlignment = .left
                self.instagramButton.imageView?.contentMode = .scaleAspectFit
                self.instagramButton.sizeToFit()
                
                var logoutButtonConfig = UIButton.Configuration.plain()
                logoutButtonConfig.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
                logoutButtonConfig.imagePadding = 10
                logoutButtonConfig.imagePlacement = .leading
                logoutButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(weight: .medium)
                logoutButtonConfig.title = "Log Out"
                logoutButtonConfig.titleAlignment = .leading
                
                self.logoutButton = UIButton(configuration: logoutButtonConfig)
                self.logoutButton.configurationUpdateHandler = { button in
                        var config = button.configuration!
                        config.image = button.isHighlighted ?
                        UIImage(systemName: "rectangle.portrait.and.arrow.right.fill") :
                        UIImage(systemName: "rectangle.portrait.and.arrow.right")
                        button.configuration = config
                }
                self.logoutButton.contentHorizontalAlignment = .left
                self.logoutButton.sizeToFit()
                
                var sendFeedbackButtonConfig = UIButton.Configuration.plain()
                sendFeedbackButtonConfig.image = UIImage(systemName: "bubble.right")
                sendFeedbackButtonConfig.imagePadding = 10
                sendFeedbackButtonConfig.imagePlacement = .leading
                sendFeedbackButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(weight: .medium)
                sendFeedbackButtonConfig.title = "Send Feedback"
                sendFeedbackButtonConfig.titleAlignment = .leading
                
                self.sendFeedbackButton = UIButton(configuration: sendFeedbackButtonConfig)
                self.sendFeedbackButton.configurationUpdateHandler = { button in
                        var config = button.configuration!
                        config.image = button.isHighlighted ?
                        UIImage(systemName: "bubble.right.fill") :
                        UIImage(systemName: "bubble.right")
                        button.configuration = config
                }
                self.sendFeedbackButton.contentHorizontalAlignment = .left
                self.sendFeedbackButton.sizeToFit()
                
                let appBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
                let appVersionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                
                self.versionLabel = UILabel()
                self.versionLabel.text = "Version \(appVersionNumber) (\(appBuildNumber))"
                self.versionLabel.textAlignment = .center
                self.versionLabel.textColor = .systemGray
                self.versionLabel.sizeToFit()
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.appInfoView.addArrangedSubview(self.appNameLabel)
                self.appInfoView.addArrangedSubview(self.versionLabel)
                
                self.externalLinkView.addArrangedSubview(self.sendFeedbackButton)
                self.externalLinkView.addArrangedSubview(self.instagramButton)
                self.externalLinkView.addArrangedSubview(self.logoutButton)
                
                self.instagramButton.addAction(
                        UIAction(title: "Open URL") { (action) in
                                guard let url = URL(string: "https://instagram.com/971town") else { return }
                                
                                if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url,
                                                                  options: [:],
                                                                  completionHandler: nil)
                                }
                        },
                        for: .touchUpInside
                )
                self.logoutButton.addAction(
                        UIAction(title: "Log Out") { (action) in
                                self.confirmLogout()
                        },
                        for: .touchUpInside
                )
                self.sendFeedbackButton.addAction(
                        UIAction(title: "Open URL") { (action) in
                                guard let url = URL(string: "https://reddit.com/r/971town") else { return }
                                
                                if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url,
                                                                  options: [:],
                                                                  completionHandler: nil)
                                }
                        },
                        for: .touchUpInside
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func confirmLogout() {
                let confirmationAlert = UIAlertController(
                        title: "",
                        message: "Are you sure you want to log out?",
                        preferredStyle: .alert
                )
                confirmationAlert.addAction(
                        UIAlertAction(
                                title: "Log Out",
                                style: .destructive,
                                handler: { action in
                                        self.logOut()
                                }
                        )
                )
                confirmationAlert.addAction(
                        UIAlertAction(title: "Cancel",
                                      style: .cancel)
                )
                self.navigationController?.present(confirmationAlert,
                                                   animated: true)
        }
        
        @objc
        private dynamic func dismissView() {
                self.navigationController?.dismiss(animated: true)
        }
        
        private func logOut() {
                NSOAPI.shared.logOut(responseHandler: { _, _, _ in })
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
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
                        
                        self.appInfoView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 30,
                                y: self.view.safeAreaInsets.top + 40,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                height: 80
                        )
                        self.view.addSubview(self.appInfoView)
                        
                        let currentAccountInfoLabelSize = self.currentAccountInfoLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.currentAccountInfoLabel.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 30,
                                y: (self.view.bounds.height / 2) - currentAccountInfoLabelSize.height - 10,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                height: currentAccountInfoLabelSize.height
                        )
                        self.view.addSubview(self.currentAccountInfoLabel)
                        
                        let copyrightLabelSize = self.copyrightLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.copyrightLabel.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 30,
                                y: self.currentAccountInfoLabel.frame.origin.y + self.currentAccountInfoLabel.bounds.height + 20,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                height: copyrightLabelSize.height
                        )
                        self.view.addSubview(self.copyrightLabel)
                        
                        self.externalLinkView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 30,
                                y: self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 120,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                height: 105
                        )
                        self.view.addSubview(self.externalLinkView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.title = "About"
                self.view.backgroundColor = .white
        }
}
