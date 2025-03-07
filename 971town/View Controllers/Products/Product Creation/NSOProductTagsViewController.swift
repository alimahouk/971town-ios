//
//  NSOProductTagsViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOProductTagsViewController: UITableViewController,
                                    UIAdaptivePresentationControllerDelegate,
                                    UITextFieldDelegate {
        private var createButton: UIBarButtonItem?
        private let infoLabel: UILabel
        private let isProductVariant: Bool
        private let newTagField: UITextField
        private let progressIndicator: UIAlertController
        private var tags: Array<NSOTag>
        private let tagTableHeaderView: UIView
        private static let tagTableViewCellIdentifier: String = "TagCell"
        private var viewIsLoaded: Bool = false
        
        public var product: NSOProduct
        
        init(product: NSOProduct) {
                self.product = product
                self.tags = Array(self.product.tags)
                
                if product.parentProductID != nil {
                        self.isProductVariant = true
                } else {
                        self.isProductVariant = false
                }
                
                self.infoLabel = UILabel()
                self.infoLabel.textColor = .systemGray
                self.infoLabel.numberOfLines = 0
                
                self.tagTableHeaderView = UIView(
                        frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 0,
                                height: 50
                        )
                )
                self.tagTableHeaderView.addSubview(self.infoLabel)
                
                self.newTagField = UITextField()
                self.newTagField.autocapitalizationType = .none
                self.newTagField.autocorrectionType = .no
                self.newTagField.clearButtonMode = .always
                self.newTagField.enablesReturnKeyAutomatically = true
                self.newTagField.font = .systemFont(ofSize: 18)
                self.newTagField.placeholder = "New Tag"
                self.newTagField.returnKeyType = .done
                self.newTagField.tag = 1
                self.newTagField.sizeToFit()
                
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.isUserInteractionEnabled = false
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressIndicator = UIAlertController(
                        title: "Adding…",
                        message: nil,
                        preferredStyle: .alert
                )
                self.progressIndicator.view.addSubview(activityIndicatorView)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                if product.parentProductID != nil {
                        self.title = "Product Variant Tags"
                } else {
                        self.title = "Product Tags"
                }
                
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
                
                self.tableView.allowsSelection = false
                self.tableView.keyboardDismissMode = .interactive
                self.tableView.tableHeaderView = self.tagTableHeaderView
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductTagsViewController.tagTableViewCellIdentifier)
                
                self.newTagField.delegate = self
                self.newTagField.addTarget(
                        self,
                        action: #selector(self.textFieldDidChange),
                        for: .editingChanged
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        private dynamic func addTag() {
                guard let tagString = self.newTagField.text else { return }
                let tag = NSOTag(name: tagString)
                guard tag.name != nil else { return }
                
                if !self.tags.contains(tag) {
                        self.tags.append(tag)
                        self.product.tags = Set(self.tags)
                        self.tableView.insertRows(
                                at: [IndexPath(row: self.tags.count - 1, section: 0)],
                                with: .automatic
                        )
                        self.enableFormButtons()
                }
                
                self.newTagField.text = nil
        }
        
        @objc
        private dynamic func createProduct() {
                // Sometimes people enter a tag but forget to hit the done key.
                self.addTag()
                
                if self.isProductVariant || !self.tags.isEmpty {
                        self.newTagField.isEnabled = false
                        self.createButton?.isEnabled = false
                        
                        self.navigationController?.present(self.progressIndicator,
                                                           animated: true)
                        
                        let request = NSOCreateProductRequest(
                                alias: self.product.alias!,
                                brandID: self.product.brand!.id!,
                                name: self.product.name!,
                                parentProductID: self.product.parentProductID,
                                tags: self.tags
                        )
                        NSOAPI.shared.createProduct(
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
                                                                                self.presentTagEntryView()
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
                                                                                self.presentTagEntryView()
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
                                                        self.progressIndicator.dismiss(animated: false)
                                                        self.navigationController?.dismiss(animated: true)
                                                }
                                        }
                                }
                        )
                }
        }
        
        @objc
        private dynamic func enableFormButtons() {
                var newTagFieldText: String? = nil
                
                if var newTagString = self.newTagField.text {
                        newTagString = newTagString.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !newTagString.isEmpty {
                                newTagFieldText = newTagString
                        }
                }
                
                /// Tags are optional for product variants.
                if (!self.tags.isEmpty && !self.isProductVariant)
                        || self.isProductVariant
                        || newTagFieldText != nil {
                        self.createButton?.isEnabled = true
                } else {
                        self.createButton?.isEnabled = false
                }
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
        
        private func presentTagEntryView(giveFocus: Bool = true) {
                self.newTagField.isEnabled = true
                
                if giveFocus {
                        self.newTagField.becomeFirstResponder()
                }
                
                self.enableFormButtons()
        }
        
        override func tableView(_ tableView: UITableView,
                                canEditRowAt indexPath: IndexPath) -> Bool {
                return true
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductTagsViewController.tagTableViewCellIdentifier,
                                                         for: indexPath)
                
                if indexPath.row < self.tags.count {
                        let tag = self.tags[indexPath.row]
                        cell.textLabel!.text = tag.name
                } else {
                        self.newTagField.frame = CGRect(
                                x: 17,
                                y: 12,
                                width: tableView.bounds.width - 80,
                                height: self.newTagField.bounds.height
                        )
                        cell.contentView.addSubview(self.newTagField)
                }
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                commit editingStyle: UITableViewCell.EditingStyle,
                                forRowAt indexPath: IndexPath) {
                if editingStyle == .delete {
                        self.tags.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.enableFormButtons()
                }
        }
        
        override func tableView(_ tableView: UITableView,
                                editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
                var ret = UITableViewCell.EditingStyle.delete
                
                if indexPath.row == self.tags.count {
                        ret = .insert
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                heightForRowAt indexPath: IndexPath) -> CGFloat {
                return 44
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                return self.tags.count + 1
        }
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
                self.enableFormButtons()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                if textField.tag == 1 {
                        self.addTag()
                        self.tableView.scrollToRow(
                                at: IndexPath(row: self.tags.count,
                                              section: 0),
                                at: .bottom,
                                animated: true
                        )
                        textField.text = nil
                }
                
                return false
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.presentTagEntryView()
                        
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.createButton
                self.navigationController?.presentationController?.delegate = self
        }
        
        override func viewDidLayoutSubviews() {
                if !self.viewIsLoaded {
                        if self.createButton == nil {
                                let createButtonTitle: String
                                
                                if self.product.parentProductID != nil {
                                        createButtonTitle = "Add Variant"
                                } else {
                                        createButtonTitle = "Add Product"
                                }
                                
                                self.createButton = UIBarButtonItem(
                                        title: createButtonTitle,
                                        style: .done,
                                        target: self,
                                        action: #selector(self.createProduct)
                                )
                        }
                        
                        self.infoLabel.frame = CGRect(
                                x: 20,
                                y: 0,
                                width: self.tagTableHeaderView.bounds.width - 40,
                                height: self.tagTableHeaderView.bounds.height
                        )
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if product.parentProductID != nil {
                        self.infoLabel.text = "Optionally add some keywords describing this variant."
                } else {
                        self.infoLabel.text = "Add some keywords describing \(self.product.name ?? "this product")."
                }
                
                self.tableView.setEditing(true, animated: false)
        }
}
