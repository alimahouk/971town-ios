//
//  NSOBrandEditingViewController.swift
//  971town
//
//  Created by Ali Mahouk on 25/02/2023.
//

import API
import UIKit


class NSOBrandEditingViewController: UITableViewController,
                                     UIAdaptivePresentationControllerDelegate,
                                     UIImagePickerControllerDelegate,
                                     UINavigationControllerDelegate,
                                     UITextFieldDelegate,
                                     UITextViewDelegate {
        private enum Sections: Int,
                               CaseIterable {
                case name = 0
                case description
                case website
                case tags
        }
        
        private let brandAvatarEditButton: UIButton
        private let brandAvatarView: UIImageView
        private var cancelButton: UIBarButtonItem?
        private let descriptionField: UITextView
        private var doneButton: UIBarButtonItem?
        private let nameField: UITextField
        private let newTagField: UITextField
        private let progressIndicator: UIAlertController
        private var shouldUpdateBrandAvatar: Bool = false
        private var shouldUpdateBrandInfo: Bool = false
        private let tableHeaderView: UIView
        private static let tableViewCellIdentifier: String = "BrandEditingTableViewCell"
        private var tags: Array<NSOTag>
        private let websiteField: UITextField
        
        public var brand: NSOBrand
        public var editedBrand: NSOBrand
        
        init(brand: NSOBrand) {
                self.brand = brand
                self.editedBrand = brand.copy() as! NSOBrand
                self.tags = Array(self.editedBrand.tags)
                
                let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
                self.brandAvatarEditButton = UIButton(type: .custom)
                self.brandAvatarEditButton.clipsToBounds = true
                self.brandAvatarEditButton.frame.size = CGSize(width: 100,
                                                               height: 100)
                self.brandAvatarEditButton.layer.cornerRadius = softRoundCornerRadius
                self.brandAvatarEditButton.layer.masksToBounds = true
                
                let brandAvatarLabel = UILabel()
                brandAvatarLabel.backgroundColor = UIColor(white: 0.2,
                                                           alpha: 0.5)
                brandAvatarLabel.font = .boldSystemFont(ofSize: 9)
                brandAvatarLabel.text = "Edit"
                brandAvatarLabel.textAlignment = .center
                brandAvatarLabel.textColor = .white
                brandAvatarLabel.translatesAutoresizingMaskIntoConstraints = false
                brandAvatarLabel.sizeToFit()
                
                self.brandAvatarView = UIImageView(image: self.editedBrand.avatar)
                self.brandAvatarView.backgroundColor = .white
                self.brandAvatarView.contentMode = .scaleAspectFill
                self.brandAvatarView.frame = brandAvatarEditButton.bounds
                
                self.descriptionField = UITextView()
                self.descriptionField.autocorrectionType = .default
                self.descriptionField.autocapitalizationType = .sentences
                self.descriptionField.font = .systemFont(ofSize: 18)
                self.descriptionField.isScrollEnabled = false
                self.descriptionField.scrollsToTop = false
                self.descriptionField.textContainer.lineFragmentPadding = 0
                self.descriptionField.translatesAutoresizingMaskIntoConstraints = false
                
                self.nameField = UITextField()
                self.nameField.autocapitalizationType = .words
                self.nameField.autocorrectionType = .yes
                self.nameField.enablesReturnKeyAutomatically = true
                self.nameField.font = .systemFont(ofSize: 18)
                self.nameField.returnKeyType = .done
                self.nameField.textContentType = .organizationName
                self.nameField.translatesAutoresizingMaskIntoConstraints = false
                
                self.newTagField = UITextField()
                self.newTagField.autocapitalizationType = .none
                self.newTagField.autocorrectionType = .no
                self.newTagField.clearButtonMode = .always
                self.newTagField.enablesReturnKeyAutomatically = true
                self.newTagField.font = .systemFont(ofSize: 18)
                self.newTagField.placeholder = "New Tag"
                self.newTagField.returnKeyType = .done
                self.newTagField.sizeToFit()
                
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.isUserInteractionEnabled = false
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressIndicator = UIAlertController(
                        title: "Saving…",
                        message: nil,
                        preferredStyle: .alert
                )
                self.progressIndicator.view.addSubview(activityIndicatorView)
                
                self.tableHeaderView = UIView(
                        frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 0,
                                height: 120
                        )
                )
                self.tableHeaderView.addSubview(brandAvatarEditButton)
                
                self.websiteField = UITextField()
                self.websiteField.autocapitalizationType = .none
                self.websiteField.autocorrectionType = .no
                self.websiteField.clearButtonMode = .always
                self.websiteField.font = .systemFont(ofSize: 18)
                self.websiteField.returnKeyType = .done
                self.websiteField.textContentType = .URL
                self.websiteField.translatesAutoresizingMaskIntoConstraints = false
                
                super.init(style: .grouped)
                
                self.tableView.allowsSelection = false
                self.tableView.keyboardDismissMode = .interactive
                self.tableView.tableHeaderView = self.tableHeaderView
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOBrandEditingViewController.tableViewCellIdentifier)
                
                self.brandAvatarEditButton.addSubview(self.brandAvatarView)
                self.brandAvatarEditButton.addSubview(brandAvatarLabel)
                self.brandAvatarEditButton.addTarget(
                        self,
                        action: #selector(self.presentMediaLibrary),
                        for: .touchUpInside
                )
                
                self.descriptionField.delegate = self
                
                self.nameField.addTarget(
                        self,
                        action: #selector(textFieldDidChange),
                        for: .editingChanged
                )
                self.nameField.delegate = self
                
                self.newTagField.addTarget(
                        self,
                        action: #selector(textFieldDidChange),
                        for: .editingChanged
                )
                self.newTagField.delegate = self
                
                let brandAvatarButtonViews = [
                        "brandAvatarEditButton": brandAvatarEditButton,
                        "brandAvatarLabel": brandAvatarLabel
                ] as [String : Any]
                var brandAvatarButtonConstraints = NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-(80)-[brandAvatarLabel]|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: brandAvatarButtonViews
                )
                brandAvatarButtonConstraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|[brandAvatarLabel]|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: brandAvatarButtonViews
                )
                self.brandAvatarEditButton.addConstraints(brandAvatarButtonConstraints)
                
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
                
                self.websiteField.addTarget(
                        self,
                        action: #selector(textFieldDidChange),
                        for: .editingChanged
                )
                self.websiteField.delegate = self
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func addTag(_ tagString: String?) {
                let tag = NSOTag(name: tagString)
                guard tag.name != nil else { return }
                
                if !self.tags.contains(tag) {
                        self.tags.append(tag)
                        self.editedBrand.tags = Set(self.tags)
                        self.tableView.insertRows(
                                at: [IndexPath(row: self.tags.count - 1, section: Sections.tags.rawValue)],
                                with: .automatic
                        )
                        self.enableFormButtons()
                }
        }
        
        @objc
        private dynamic func dismissView() {
                if self.shouldUpdateBrandInfo || self.shouldUpdateBrandAvatar {
                        let confirmationAlert = UIAlertController(
                                title: "Discard Changes?",
                                message: "Any edits you made will be lost.",
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
                } else {
                        self.navigationController?.dismiss(animated: true)
                }
        }
        
        @objc
        private dynamic func editBrand() {
                self.doneButton?.isEnabled = false
                
                // Sometimes people enter a tag but forget to hit the done key.
                let newTagFieldCell = self.tableView.cellForRow(at: IndexPath(row: self.tags.count, section: Sections.tags.rawValue))
                if let newTagField = newTagFieldCell?.contentView.viewWithTag(Sections.tags.rawValue) as? UITextField {
                        self.addTag(newTagField.text)
                        newTagField.text = nil
                }
                
                self.navigationController?.present(
                        self.progressIndicator,
                        animated: true,
                        completion: {
                        if self.shouldUpdateBrandInfo {
                                let request = NSOUpdateBrandRequest(
                                        brandID: self.brand.id!,
                                        description: self.editedBrand.description,
                                        name: self.editedBrand.name!,
                                        tags: self.tags,
                                        website: self.editedBrand.website
                                )
                                NSOAPI.shared.updateBrand(
                                        request: request,
                                        responseHandler: { apiResponse, errorResponse, networkError in
                                                if let networkError = networkError {
                                                        print(networkError)
                                                        
                                                        DispatchQueue.main.async {
                                                                self.progressIndicator.dismiss(animated: true,
                                                                                               completion: {
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
                                                                                                self.presentBrandEditingView()
                                                                                        }
                                                                                )
                                                                        )
                                                                        self.navigationController?.present(alert,
                                                                                                           animated: true)
                                                                })
                                                        }
                                                } else if let errorResponse = errorResponse {
                                                        DispatchQueue.main.async {
                                                                self.progressIndicator.dismiss(animated: true,
                                                                                               completion: {
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
                                                                                                self.presentBrandEditingView()
                                                                                        }
                                                                                )
                                                                        )
                                                                        self.navigationController?.present(alert,
                                                                                                           animated: true)
                                                                })
                                                        }
                                                } else if apiResponse != nil {
                                                        if self.shouldUpdateBrandAvatar {
                                                                self.updateBrandAvatar()
                                                        } else {
                                                                DispatchQueue.main.async {
                                                                        self.progressIndicator.dismiss(animated: false)
                                                                        self.navigationController?.dismiss(animated: true)
                                                                }
                                                        }
                                                }
                                        }
                                )
                        } else if self.shouldUpdateBrandAvatar {
                                self.updateBrandAvatar()
                        }
                })
        }
        
        private func enableFormButtons() {
                if self.editedBrand.name != self.brand.name ||
                        self.editedBrand.description != self.brand.description ||
                        self.editedBrand.website != self.brand.website ||
                        self.editedBrand.tags != self.brand.tags {
                        self.shouldUpdateBrandInfo = true
                } else {
                        self.shouldUpdateBrandInfo = false
                }
                
                var buttonIsEnabled = (self.shouldUpdateBrandInfo || self.shouldUpdateBrandAvatar)
                
                if self.editedBrand.name == nil ||
                        self.editedBrand.tags.isEmpty {
                        buttonIsEnabled = false
                }
                
                self.doneButton?.isEnabled = buttonIsEnabled
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                var image: UIImage?
                
                if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                        image = img
                } else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                        image = img
                }
                
                self.editedBrand.avatar = image
                self.brandAvatarView.image = image
                
                if image?.pngData() != self.brand.avatar?.pngData() {
                        self.shouldUpdateBrandAvatar = true
                } else {
                        self.shouldUpdateBrandAvatar = false
                }
                
                self.enableFormButtons()
                picker.dismiss(animated: true)
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
                return Sections.allCases.count
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if self.shouldUpdateBrandInfo || self.shouldUpdateBrandAvatar {
                        ret = false
                }
                
                return ret
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                
                let confirmationAlert = UIAlertController(
                        title: "Discard Changes?",
                        message: "Any edits you made will be lost.",
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
        
        private func presentBrandEditingView() {
                self.tableView.isUserInteractionEnabled = true
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func presentMediaLibrary() {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        let pickerController = UIImagePickerController()
                        pickerController.allowsEditing = true
                        pickerController.delegate = self
                        pickerController.sourceType = .photoLibrary
                        self.navigationController?.present(pickerController,
                                                           animated: true)
                }
        }
        
        override func tableView(_ tableView: UITableView,
                                canEditRowAt indexPath: IndexPath) -> Bool {
                var ret = false
                let section = Sections(rawValue: indexPath.section)
                
                if section == .tags {
                        ret = true
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let section = Sections(rawValue: indexPath.section)
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOBrandEditingViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                // Reset the cell in prep for each type of row.
                cell.accessoryType = .none
                cell.contentConfiguration = nil
                cell.selectionStyle = .none
                
                for subview in cell.contentView.subviews {
                        subview.removeFromSuperview()
                }
                
                switch section {
                case .description:
                        self.descriptionField.tag = indexPath.section
                        self.descriptionField.text = self.editedBrand.description
                        
                        cell.contentView.addSubview(self.descriptionField)
                        
                        let cellViews = [
                                "descriptionField": self.descriptionField
                        ] as [String : Any]
                        
                        var descriptionFieldConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|-(3)-[descriptionField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        descriptionFieldConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[descriptionField]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(descriptionFieldConstraints)
                case .name:
                        self.nameField.tag = indexPath.section
                        self.nameField.text = self.editedBrand.name
                        
                        cell.contentView.addSubview(self.nameField)
                        
                        let cellViews = [
                                "nameField": self.nameField
                        ] as [String : Any]
                        
                        var nameFieldConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[nameField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        nameFieldConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[nameField]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(nameFieldConstraints)
                case .tags:
                        if indexPath.row < self.tags.count {
                                let tag = self.tags[indexPath.row]
                                
                                var content = cell.defaultContentConfiguration()
                                content.text = tag.name
                                cell.contentConfiguration = content
                        } else {
                                self.newTagField.frame = CGRect(
                                        x: 17,
                                        y: 12,
                                        width: tableView.bounds.width - 80,
                                        height: self.newTagField.bounds.height
                                )
                                self.newTagField.tag = indexPath.section
                                cell.contentView.addSubview(self.newTagField)
                        }
                case .website:
                        self.websiteField.tag = indexPath.section
                        self.websiteField.text = self.editedBrand.website?.absoluteString
                        
                        cell.contentView.addSubview(self.websiteField)
                        
                        let cellViews = [
                                "websiteField": self.websiteField
                        ] as [String : Any]
                        
                        var websiteFieldConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[websiteField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        websiteFieldConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[websiteField]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(websiteFieldConstraints)
                default:
                        break
                }
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                commit editingStyle: UITableViewCell.EditingStyle,
                                forRowAt indexPath: IndexPath) {
                if editingStyle == .delete {
                        self.tags.remove(at: indexPath.row)
                        self.editedBrand.tags = Set(self.tags)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.enableFormButtons()
                }
        }
        
        override func tableView(_ tableView: UITableView,
                                editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
                var ret = UITableViewCell.EditingStyle.none
                let section = Sections(rawValue: indexPath.section)
                
                if section == .tags {
                        if indexPath.row < self.tags.count {
                                ret = .delete
                        } else {
                                ret = .insert
                        }
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                heightForRowAt indexPath: IndexPath) -> CGFloat {
                var ret: CGFloat = 44
                let section = Sections(rawValue: indexPath.section)
                
                switch section {
                case .description:
                        if let brandDescription = self.editedBrand.description {
                                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
                                let descriptionString = NSAttributedString(string: brandDescription,
                                                                           attributes: attributes)
                                let descriptionFieldSize = descriptionString.boundingRect(
                                        with: CGSize(width: tableView.bounds.width - 40, height: .greatestFiniteMagnitude),
                                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                                        context: nil
                                )
                                
                                ret = max(descriptionFieldSize.height + 22, ret)
                        }
                default:
                        break
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                var ret: Int = 1
                let section = Sections(rawValue: section)
                
                switch section {
                case .tags:
                        ret = self.tags.count + 1
                default:
                        break
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
                var ret: String?
                let section = Sections(rawValue: section)
                
                switch section {
                case .name:
                        ret = "Name"
                case .description:
                        ret = "Description"
                case .website:
                        ret = "Website"
                case .tags:
                        ret = "Tags"
                default:
                        break
                }
                
                return ret
        }
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
                let section = Sections(rawValue: textField.tag)
                
                switch section {
                case .name:
                        var brandName: String? = nil
                        
                        if var textFieldString = textField.text {
                                textFieldString = textFieldString.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                if !textFieldString.isEmpty {
                                        brandName = textFieldString
                                }
                        }
                        
                        self.editedBrand.name = brandName
                case .website:
                        var website: URL? = nil
                        
                        if let textFieldString = textField.text {
                                let websiteString = String(textFieldString.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                                
                                if !websiteString.isEmpty {
                                        website = URL(string: websiteString)
                                }
                        }
                        
                        self.editedBrand.website = website
                default:
                        break
                }
                
                self.enableFormButtons()
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                let section = Sections(rawValue: textField.tag)
                
                switch section {
                case .tags:
                        if let tag = textField.text {
                                self.addTag(tag)
                                self.tableView.scrollToRow(
                                        at: IndexPath(row: self.tags.count,
                                                      section: textField.tag),
                                        at: .bottom,
                                        animated: true
                                )
                                textField.text = nil
                        }
                default:
                        textField.resignFirstResponder()
                }
                
                return false
        }
        
        func textViewDidChange(_ textView: UITextView) {
                let section = Sections(rawValue: textView.tag)
                
                switch section {
                case .description:
                        var description: String? = textView.text
                        
                        let fixedWidth = textView.bounds.size.width
                        let newSize = textView.sizeThatFits(
                                CGSize(
                                        width: fixedWidth,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        textView.frame.size = CGSize(
                                width: max(newSize.width, fixedWidth),
                                height: newSize.height
                        )
                        
                        if description!.isEmpty {
                                description = nil
                        }
                        
                        self.editedBrand.description = description
                        self.tableView.beginUpdates()
                        self.tableView.endUpdates()
                default:
                        break
                }
                
                self.enableFormButtons()
        }
        
        private func updateBrandAvatar() {
                let request = NSOUpdateBrandAvatarRequest(
                        avatar: self.editedBrand.avatar!,
                        brandID: self.brand.id!,
                        mediaMode: .light
                )
                NSOAPI.shared.updateBrandAvatar(
                        request: request,
                        responseHandler: { apiResponse, errorResponse, networkError in
                                if let networkError = networkError {
                                        print(networkError)
                                        
                                        DispatchQueue.main.async {
                                                self.progressIndicator.dismiss(animated: true, completion: {
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
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                })
                                        }
                                } else if let errorResponse = errorResponse {
                                        DispatchQueue.main.async {
                                                self.progressIndicator.dismiss(animated: true, completion: {
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
                self.presentBrandEditingView()
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if self.cancelButton == nil {
                        self.cancelButton = UIBarButtonItem(
                                barButtonSystemItem: .close,
                                target: self,
                                action: #selector(self.dismissView)
                        )
                        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
                }
                
                if self.doneButton == nil {
                        self.doneButton = UIBarButtonItem(
                                title: "Done",
                                style: .done,
                                target: self,
                                action: #selector(self.editBrand)
                        )
                        self.doneButton?.isEnabled = false
                        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.doneButton
                }
                
                self.brandAvatarEditButton.frame.origin = CGPoint(x: (self.tableView.bounds.width / 2) - 50,
                                                                  y: 10)
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                self.tableView.setEditing(true, animated: false)
        }
}
