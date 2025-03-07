//
//  NSOWelcomeViewController.swift
//  971town
//
//  Created by Ali Mahouk on 02/03/2023.
//

import UIKit


class NSOWelcomeViewController: UIViewController {
        private let getStartedButton: UIButton
        private var viewIsLoaded: Bool = false
        private let welcomeLabel: UILabel
        private let welcomeView: UIStackView
        
        public var scrollView: UIScrollView { return self.view as! UIScrollView }
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                var getStartedButtonConfig = UIButton.Configuration.filled()
                getStartedButtonConfig.buttonSize = .large
                getStartedButtonConfig.cornerStyle = .medium
                getStartedButtonConfig.image = UIImage(systemName: "chevron.right")
                getStartedButtonConfig.imagePadding = 5
                getStartedButtonConfig.imagePlacement = .trailing
                getStartedButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
                getStartedButtonConfig.title = "Get Started"
                getStartedButtonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                        var outgoing = incoming
                        outgoing.font = UIFont.preferredFont(forTextStyle: .headline)
                        
                        return outgoing
                }
                
                self.getStartedButton = UIButton(configuration: getStartedButtonConfig)
                self.getStartedButton.setContentHuggingPriority(.defaultHigh,
                                                                for: .vertical)
                
                let welcomeLabelParagraphStyle = NSMutableParagraphStyle()
                welcomeLabelParagraphStyle.lineSpacing = 7
                
                let welcomeString = NSMutableAttributedString(string: """
                                        Welcome to the beta of 971town, a project with the aim of cataloging every product being sold in every physical retail store in Dubai!
                                        
                                        The project will roll out over three phases. We're in Phase 2, which is to add the various retail products that can be found around Dubai. As you might expect from software that's still in beta, you may occasionally encounter bugs and glitches. When you do, we would very much appreciate you reporting it via the Send Feedback button in the app (a screenshot is always helpful to include when possible).
                                        
                                        Thank you for joining us early in our journey.
                                        """)
                welcomeString.addAttribute(.paragraphStyle,
                                           value: welcomeLabelParagraphStyle,
                                           range: NSRange(location: 0, length: welcomeString.length))
                
                self.welcomeLabel = UILabel()
                self.welcomeLabel.numberOfLines = 0
                self.welcomeLabel.attributedText = welcomeString
                
                self.welcomeView = UIStackView()
                self.welcomeView.alignment = .fill
                self.welcomeView.axis = .vertical
                
                self.welcomeView.addArrangedSubview(self.welcomeLabel)
                self.welcomeView.addArrangedSubview(self.getStartedButton)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.getStartedButton.addAction(
                        UIAction(title: "Get Started") { (action) in
                                self.presentPhoneEntryViewController()
                        },
                        for: .touchUpInside
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        override func loadView() {
                let scrollView = UIScrollView()
                scrollView.contentInsetAdjustmentBehavior = .never
                scrollView.backgroundColor = .white
                scrollView.addSubview(self.welcomeView)
                self.view = scrollView
        }
        
        private func presentPhoneEntryViewController() {
                let phoneNumberEntryViewController = NSOPhoneNumberEntryViewController()
                self.navigationController?.pushViewController(phoneNumberEntryViewController,
                                                              animated: true)
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        let welcomeLabelSize = self.welcomeLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - 80,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        
                        self.welcomeView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 40,
                                y: self.view.safeAreaInsets.top,
                                width: self.view.bounds.width - 80,
                                height: max(welcomeLabelSize.height + 100,
                                            self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom - 40)
                        )
                        self.scrollView.contentSize = CGSize(
                                width: self.view.bounds.width,
                                height: max(self.view.bounds.height - self.view.safeAreaInsets.top - self.view.safeAreaInsets.bottom,
                                            self.welcomeView.frame.origin.y + self.welcomeView.bounds.height + 40)
                        )
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
}
