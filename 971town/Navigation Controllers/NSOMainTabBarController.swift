//
//  NSOMainTabBarController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOMainTabBarController: UITabBarController, UITabBarControllerDelegate {
        private let brandsNavigationController: NSOBrandsNavigationController
        private let productsNavigationController: NSOProductsNavigationController
        
        init() {
                self.brandsNavigationController = NSOBrandsNavigationController()
                let brandsNavigationControllerTabBarItem = UITabBarItem(
                        title: self.brandsNavigationController.topViewController!.title,
                        image: UIImage(systemName: "tag"),
                        selectedImage: UIImage(systemName: "tag.fill")
                )
                self.brandsNavigationController.tabBarItem = brandsNavigationControllerTabBarItem
                
                self.productsNavigationController = NSOProductsNavigationController()
                let productsNavigationControllerTabBarItem = UITabBarItem(
                        title: self.productsNavigationController.topViewController!.title,
                        image: UIImage(systemName: "shippingbox"),
                        selectedImage: UIImage(systemName: "shippingbox.fill")
                )
                self.productsNavigationController.tabBarItem = productsNavigationControllerTabBarItem
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.delegate = self
                self.viewControllers = [
                        self.brandsNavigationController,
                        self.productsNavigationController
                ]
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userAccountDidGetKickedOut),
                        name: .NSOUserAccountKickedOut,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userAccountDidJoin),
                        name: .NSOUserAccountJoined,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userAccountDidLogIn),
                        name: .NSOUserAccountLoggedIn,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userAccountDidLogOut),
                        name: .NSOUserAccountLoggedOut,
                        object: nil
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        private func presentPhoneNumberEntryViewController() {
                let phoneNumberEntryViewController = NSOPhoneNumberEntryViewController()
                phoneNumberEntryViewController.isModalInPresentation = true
                
                let phoneNumberEntryNavigationController = NSOPhoneNumberEntryNavigationController(rootViewController: phoneNumberEntryViewController)
                
                // An alert was most likely presented if the user got kicked/logged out.
                // Logout is also normally done through a modal view.
                let presentedViewController =  self.presentedViewController
                // Dismiss it first.
                if presentedViewController != nil {
                        presentedViewController?.dismiss(
                                animated: true,
                                completion: {
                                        self.present(
                                                phoneNumberEntryNavigationController,
                                                animated: true,
                                                completion: {
                                                        // Try to present any previously presented alert again.
                                                        if let presentedViewController = presentedViewController as? UIAlertController {
                                                                self.present(presentedViewController,
                                                                             animated: true)
                                                        }
                                                }
                                        )
                                }
                        )
                } else {
                        self.present(phoneNumberEntryNavigationController,
                                     animated: false)
                }
        }
        
        @objc
        private dynamic func userAccountDidGetKickedOut() {
                self.presentPhoneNumberEntryViewController()
                self.brandsNavigationController.popToRootViewController(animated: false)
                self.productsNavigationController.popToRootViewController(animated: false)
        }
        
        @objc
        private dynamic func userAccountDidJoin() {
                if let presentedViewController = self.presentedViewController as? NSOPhoneNumberEntryNavigationController {
                        presentedViewController.dismiss(animated: true)
                }
        }
        
        @objc
        private dynamic func userAccountDidLogIn() {
                if let presentedViewController = self.presentedViewController as? NSOPhoneNumberEntryNavigationController {
                        presentedViewController.dismiss(animated: true)
                }
        }
        
        @objc
        private dynamic func userAccountDidLogOut() {
                self.presentPhoneNumberEntryViewController()
                self.brandsNavigationController.popToRootViewController(animated: false)
                self.productsNavigationController.popToRootViewController(animated: false)
        }
}
