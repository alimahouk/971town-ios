//
//  NSOBrandTagsViewController.swift
//  971town
//
//  Created by Ali Mahouk on 15/02/2023.
//

import API
import UIKit


class NSOBrandTagsViewController: UITableViewController,
                                  UIAdaptivePresentationControllerDelegate,
                                  UITextFieldDelegate {
        private var createButton: UIBarButtonItem?
        private let infoLabel: UILabel
        private let newTagField: UITextField
        private let progressIndicator: UIAlertController
        private var tags: Array<NSOTag>
        private let tagTableHeaderView: UIView
        private static let tagTableViewCellIdentifier: String = "TagCell"
        private var viewIsLoaded: Bool = false
        
        public var brand: NSOBrand
        
        init(brand: NSOBrand) {
                self.brand = brand
                self.tags = Array(self.brand.tags)
                
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
                
                self.title = "Brand Tags"
                
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
                                        forCellReuseIdentifier: NSOBrandTagsViewController.tagTableViewCellIdentifier)
                
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
                        self.brand.tags = Set(self.tags)
                        self.tableView.insertRows(
                                at: [IndexPath(row: self.tags.count - 1, section: 0)],
                                with: .automatic
                        )
                        self.enableFormButtons()
                }
                
                self.newTagField.text = nil
        }
        
        @objc
        private dynamic func createBrand() {
                // Sometimes people enter a tag but forget to hit the done key.
                self.addTag()
                
                if !self.tags.isEmpty {
                        self.newTagField.isEnabled = false
                        self.createButton?.isEnabled = false
                        
                        self.navigationController?.present(self.progressIndicator,
                                                           animated: true)
                        
                        let request = NSOCreateBrandRequest(
                                alias: self.brand.alias!,
                                name: self.brand.name!,
                                tags: self.tags
                        )
                        NSOAPI.shared.createBrand(
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
                                        } else if let apiResponse = apiResponse {
                                                self.brand.id = apiResponse.brand.id
                                                self.updateBrandAvatar()
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
                
                if !self.tags.isEmpty || newTagFieldText != nil {
                        self.createButton?.isEnabled = true
                } else {
                        self.createButton?.isEnabled = false
                }
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
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOBrandTagsViewController.tagTableViewCellIdentifier,
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
        
        private func updateBrandAvatar() {
                guard self.brand.avatar != nil else {
                        self.progressIndicator.dismiss(animated: false)
                        self.navigationController?.dismiss(animated: true)
                        
                        return
                }
                
                let request = NSOUpdateBrandAvatarRequest(
                        avatar: self.brand.avatar!,
                        brandID: self.brand.id!,
                        mediaMode: .light
                )
                NSOAPI.shared.updateBrandAvatar(
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
                                                                        self.navigationController?.dismiss(animated: true)
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
                                                                        self.navigationController?.dismiss(animated: true)
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
                                self.createButton = UIBarButtonItem(
                                        title: "Add Brand",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.createBrand)
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
                
                self.infoLabel.text = "Add some keywords describing \(self.brand.name ?? "this brand")."
                
                self.tableView.setEditing(true, animated: false)
        }
}
