//
//  NSOUserAccountSelectionViewController.swift
//  971town
//
//  Created by Ali Mahouk on 08/02/2023.
//

import API
import UIKit


class NSOUserAccountSelectionViewController: UIViewController,
                                             UITableViewDataSource,
                                             UITableViewDelegate {
        private let createNewAccountButton: UIButton
        private let infoLabel: UILabel
        private let userAccountSelectionView: UIView
        private let userAccountTableFooterView: UIView
        private let userAccountTableView: UITableView
        private static let userAccountTableViewCellIdentifier: String = "UserAccountCell"
        private var viewIsLoaded: Bool = false
        
        public var phoneNumber: NSOUserPhoneNumber?
        public var userAccounts: Array<NSOUserAccount> = []
        public var verificationCode: String?
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                var createNewAccountButtonConfig = UIButton.Configuration.plain()
                createNewAccountButtonConfig.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 20,
                        bottom: 0,
                        trailing: 20
                )
                createNewAccountButtonConfig.image = UIImage(systemName: "plus.app")
                createNewAccountButtonConfig.imagePadding = 15
                createNewAccountButtonConfig.imagePlacement = .leading
                createNewAccountButtonConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
                createNewAccountButtonConfig.title = "New Account"
                createNewAccountButtonConfig.titleAlignment = .leading
                
                self.createNewAccountButton = UIButton(configuration: createNewAccountButtonConfig)
                self.createNewAccountButton.configurationUpdateHandler = { button in
                        var config = button.configuration!
                        config.image = button.isHighlighted ? UIImage(systemName: "plus.app.fill") : UIImage(systemName: "plus.app")
                        button.configuration = config
                }
                self.createNewAccountButton.contentHorizontalAlignment = .left
                
                self.infoLabel = UILabel()
                self.infoLabel.numberOfLines = 0
                self.infoLabel.text = "The following accounts exist under this phone number. Select the one you'd like to log into."
                self.infoLabel.textColor = .systemGray
                
                self.userAccountSelectionView = UIView()
                
                self.userAccountTableFooterView = UIView(frame: CGRect(
                        x: 0,
                        y: 0,
                        width: 0,
                        height: 50
                ))
                
                let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
                self.userAccountTableView =  UITableView()
                self.userAccountTableView.layer.cornerRadius = softRoundCornerRadius
                self.userAccountTableView.layer.borderColor = UIColor.systemGray.cgColor
                self.userAccountTableView.layer.borderWidth = 0.5
                self.userAccountTableView.layer.masksToBounds = true
                self.userAccountTableView.tableFooterView = self.userAccountTableFooterView
                self.userAccountTableView.register(UITableViewCell.self,
                                                   forCellReuseIdentifier: NSOUserAccountSelectionViewController.userAccountTableViewCellIdentifier)
                
                self.userAccountSelectionView.addSubview(self.infoLabel)
                self.userAccountSelectionView.addSubview(self.userAccountTableView)
                
                self.userAccountTableFooterView.addSubview(self.createNewAccountButton)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.createNewAccountButton.addAction(
                        UIAction(title: "New Account") { (action) in
                                let accountCreationViewController = NSOUserAccountCreationViewController(nibName: nil, bundle: nil)
                                accountCreationViewController.phoneNumber = self.phoneNumber
                                accountCreationViewController.verificationCode = self.verificationCode
                                
                                self.navigationController?.pushViewController(accountCreationViewController, animated: true)
                        },
                        for: .touchUpInside
                )
                
                self.userAccountTableView.dataSource = self
                self.userAccountTableView.delegate = self
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func createNewAccount() {
                let accountCreationViewController = NSOUserAccountCreationViewController(nibName: nil,
                                                                                         bundle: nil)
                accountCreationViewController.phoneNumber = self.phoneNumber
                accountCreationViewController.verificationCode = self.verificationCode
                
                self.navigationController?.pushViewController(accountCreationViewController,
                                                              animated: true)
        }
        
        private func logIn(userAccount: NSOUserAccount) {
                let loginViewController = NSOLoginViewController(nibName: nil,
                                                                 bundle: nil)
                loginViewController.phoneNumber = self.phoneNumber
                loginViewController.userAccount = userAccount
                loginViewController.verificationCode = self.verificationCode
                
                self.navigationController?.pushViewController(loginViewController,
                                                              animated: true)
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let account = self.userAccounts[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOUserAccountSelectionViewController.userAccountTableViewCellIdentifier,
                                                         for: indexPath)
                cell.textLabel!.text = account.alias
                
                return cell
        }
        
        func tableView(_ tableView: UITableView,
                       didSelectRowAt indexPath: IndexPath) {
                let account = self.userAccounts[indexPath.row]
                self.logIn(userAccount: account)
        }
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
                return userAccounts.count
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
                        self.userAccountSelectionView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 40,
                                y: 80,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 80,
                                height: self.view.bounds.height - self.view.safeAreaInsets.bottom - 200
                        )
                        self.view.addSubview(self.userAccountSelectionView)
                        
                        let infoLabelSize = self.infoLabel.sizeThatFits(
                                CGSize(
                                        width: self.userAccountSelectionView.bounds.width,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.infoLabel.frame = CGRect(
                                x: 0,
                                y: 0,
                                width: self.userAccountSelectionView.bounds.width,
                                height: infoLabelSize.height
                        )
                        
                        self.userAccountTableView.frame = CGRect(
                                x: 0,
                                y: infoLabelSize.height + 15,
                                width: self.userAccountSelectionView.bounds.width,
                                height: self.userAccountSelectionView.bounds.height - self.infoLabel.frame.origin.y - self.infoLabel.bounds.height - 15
                        )
                        
                        self.createNewAccountButton.frame = self.userAccountTableFooterView.bounds
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
                self.navigationItem.hidesBackButton = true
                self.navigationItem.title = "Account Options"
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if let selectedIndexPath = self.userAccountTableView.indexPathForSelectedRow {
                        self.userAccountTableView.deselectRow(at: selectedIndexPath,
                                                              animated: animated)
                }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                // Re-enable the swipe gesture to go back.
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
}
