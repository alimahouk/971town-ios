//
//  NSOLoginViewController.swift
//  971town
//
//  Created by Ali Mahouk on 08/02/2023.
//

import API
import UIKit


class NSOLoginViewController: UIViewController {
        private let progressIndicator: UIActivityIndicatorView
        private var viewIsLoaded: Bool = false
        
        public var phoneNumber: NSOUserPhoneNumber?
        public var userAccount: NSOUserAccount?
        public var verificationCode: String?
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                self.progressIndicator = UIActivityIndicatorView(style: .large)
                self.progressIndicator.hidesWhenStopped = true
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func logIn() {
                self.progressIndicator.startAnimating()
                
                guard let phoneNumberID = self.phoneNumber?.id else { return }
                guard let userAccountID = self.userAccount?.id else { return }
                guard let verificationCode = self.verificationCode else { return }
                
                let request = NSOLogInRequest(
                        code: verificationCode,
                        phoneNumberID: phoneNumberID,
                        userAccountID: userAccountID
                )
                NSOAPI.shared.logIn(
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
                                                                        self.navigationController?.popToRootViewController(animated: true)
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
                                                                        self.navigationController?.popToRootViewController(animated: true)
                                                                }
                                                        )
                                                )
                                                self.navigationController?.present(alert,
                                                                                   animated: true)
                                        }
                                } else if apiResponse != nil {
                                        // Nothing to be done. The view will be dismissed by the navigation controller.
                                }
                        }
                )
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        self.progressIndicator.frame = CGRect(
                                x: (self.view.bounds.width / 2) - 35,
                                y: (self.view.bounds.height / 2) - 35,
                                width: 70,
                                height: 70
                        )
                        self.view.addSubview(self.progressIndicator)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
                self.navigationItem.hidesBackButton = true
                
                self.logIn()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                // Re-enable the swipe gesture to go back.
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
}
