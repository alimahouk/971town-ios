//
//  NSOProductEditingViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOProductEditingViewController: UITableViewController {
        private enum DatePicker: Int {
                case releaseDate
                case releaseTime
        }
        
        private enum InfoSection: Int,
                                  CaseIterable {
                case name = 0
                case description
                case mainColor
                case material
                case parentProduct
                case releaseTimestamp
                case upc
                case url
                case tags
        }
        
        private enum InfoSwitch: Int {
                case releaseDate
                case releaseTime
        }
        
        private enum SettingsSection: Int,
                                      CaseIterable {
                case displayNameOverride = 0
        }
        
        private enum SettingSwitch: Int {
                case displayNameOverride
        }
        
        private enum Tab: String,
                          CaseIterable{
                case info = "Info"
                case settings = "Settings"
        }
        
        private var activeTab: Tab = Tab.allCases.first!
        private var cancelButton: UIBarButtonItem?
        private let descriptionField: UITextView
        private var doneButton: UIBarButtonItem?
        private var infoSectionSwitchStates: Array<Bool> = [false, false]
        private var isProductVariant: Bool
        private var mainColorView: UIStackView
        private let mainColorLabel: UILabel
        private let mainColorThumbnailView: UIView
        private let nameField: UITextField
        private let newTagField: UITextField
        private let progressIndicator: UIAlertController
        private let releaseTimestampDatePicker: UIDatePicker
        private let releaseTimestampTimePicker: UIDatePicker
        private var settingsSectionSwitchStates: Array<Bool> = [false]
        private var shouldUpdateProductInfo: Bool = false
        private static let tableViewCellIdentifier: String = "ProductEditingTableViewCell"
        private var tags: Array<NSOTag>
        private let upcField: UITextField
        private let urlField: UITextField
        
        public var product: NSOProduct
        public var editedProduct: NSOProduct
        
        init(product: NSOProduct) {
                self.product = product
                self.editedProduct = product.copy() as! NSOProduct
                self.tags = Array(self.editedProduct.tags)
                
                if product.parentProductID != nil {
                        self.isProductVariant = true
                } else {
                        self.isProductVariant = false
                }
                
                let calendar = Calendar.current
                
                self.releaseTimestampDatePicker = UIDatePicker()
                self.releaseTimestampDatePicker.datePickerMode = .date
                self.releaseTimestampDatePicker.preferredDatePickerStyle = .compact
                self.releaseTimestampDatePicker.tag = DatePicker.releaseDate.rawValue
                self.releaseTimestampDatePicker.translatesAutoresizingMaskIntoConstraints = false
                
                self.descriptionField = UITextView()
                self.descriptionField.autocorrectionType = .default
                self.descriptionField.autocapitalizationType = .sentences
                self.descriptionField.font = .systemFont(ofSize: UIFont.labelFontSize)
                self.descriptionField.isScrollEnabled = false
                self.descriptionField.scrollsToTop = false
                self.descriptionField.textContainer.lineFragmentPadding = 0
                self.descriptionField.translatesAutoresizingMaskIntoConstraints = false
                
                self.mainColorLabel = UILabel()
                self.mainColorLabel.font = .systemFont(ofSize: UIFont.labelFontSize)
                self.mainColorLabel.numberOfLines = 0
                self.mainColorLabel.setContentHuggingPriority(.defaultLow,
                                                              for: .horizontal)
                self.mainColorLabel.setContentHuggingPriority(.defaultLow,
                                                              for: .vertical)
                
                self.mainColorThumbnailView = UIView()
                self.mainColorThumbnailView.layer.borderColor = UIColor.systemGray4.cgColor
                self.mainColorThumbnailView.layer.borderWidth = 0.5
                self.mainColorThumbnailView.layer.cornerRadius = 10
                self.mainColorThumbnailView.layer.masksToBounds = true
                self.mainColorThumbnailView.translatesAutoresizingMaskIntoConstraints = false
                self.mainColorThumbnailView.setContentHuggingPriority(.defaultHigh,
                                                                      for: .horizontal)
                self.mainColorThumbnailView.setContentHuggingPriority(.defaultHigh,
                                                                      for: .vertical)
                
                self.mainColorView = UIStackView()
                self.mainColorView.alignment = .center
                self.mainColorView.axis = .horizontal
                self.mainColorView.spacing = 15
                self.mainColorView.translatesAutoresizingMaskIntoConstraints = false
                self.mainColorView.setContentHuggingPriority(.defaultLow,
                                                             for: .vertical)

                self.nameField = UITextField()
                self.nameField.autocapitalizationType = .words
                self.nameField.autocorrectionType = .yes
                self.nameField.enablesReturnKeyAutomatically = true
                self.nameField.font = .systemFont(ofSize: UIFont.labelFontSize)
                self.nameField.returnKeyType = .done
                self.nameField.translatesAutoresizingMaskIntoConstraints = false
                
                self.newTagField = UITextField()
                self.newTagField.autocapitalizationType = .none
                self.newTagField.autocorrectionType = .no
                self.newTagField.clearButtonMode = .always
                self.newTagField.enablesReturnKeyAutomatically = true
                self.newTagField.font = .systemFont(ofSize: UIFont.labelFontSize)
                self.newTagField.placeholder = "New Tag"
                self.newTagField.returnKeyType = .done
                self.newTagField.translatesAutoresizingMaskIntoConstraints = false
                
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
                
                self.releaseTimestampTimePicker = UIDatePicker()
                self.releaseTimestampTimePicker.datePickerMode = .time
                self.releaseTimestampTimePicker.preferredDatePickerStyle = .compact
                self.releaseTimestampTimePicker.tag = DatePicker.releaseTime.rawValue
                self.releaseTimestampTimePicker.translatesAutoresizingMaskIntoConstraints = false
                
                self.upcField = UITextField()
                self.upcField.autocapitalizationType = .none
                self.upcField.autocorrectionType = .no
                self.upcField.clearButtonMode = .always
                self.upcField.font = .systemFont(ofSize: 18)
                self.upcField.returnKeyType = .done
                self.upcField.translatesAutoresizingMaskIntoConstraints = false
                
                self.urlField = UITextField()
                self.urlField.autocapitalizationType = .none
                self.urlField.autocorrectionType = .no
                self.urlField.clearButtonMode = .always
                self.urlField.font = .systemFont(ofSize: 18)
                self.urlField.returnKeyType = .done
                self.urlField.textContentType = .URL
                self.urlField.translatesAutoresizingMaskIntoConstraints = false
                
                self.mainColorView.addArrangedSubview(self.mainColorLabel)
                
                super.init(style: .grouped)
                
                self.tableView.allowsSelectionDuringEditing = true
                self.tableView.keyboardDismissMode = .interactive
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductEditingViewController.tableViewCellIdentifier)
                
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
                
                self.releaseTimestampDatePicker.addTarget(self,
                                                          action: #selector(self.datePickerDidChange),
                                                          for: .valueChanged)
                
                self.releaseTimestampTimePicker.addTarget(self,
                                                          action: #selector(self.datePickerDidChange),
                                                          for: .valueChanged)
                
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
                
                self.upcField.addTarget(
                        self,
                        action: #selector(textFieldDidChange),
                        for: .editingChanged
                )
                self.upcField.delegate = self
                
                self.urlField.addTarget(
                        self,
                        action: #selector(textFieldDidChange),
                        for: .editingChanged
                )
                self.urlField.delegate = self
                
                if let releaseTimestamp = product.releaseTimestamp {
                        self.releaseTimestampDatePicker.date = releaseTimestamp
                        self.releaseTimestampTimePicker.date = releaseTimestamp
                        
                        self.infoSectionSwitchStates[InfoSwitch.releaseDate.rawValue] = true
                        
                        let dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                     from: releaseTimestamp)
                        
                        if dateComponents.hour != 0 || dateComponents.minute != 0 {
                                self.infoSectionSwitchStates[InfoSwitch.releaseTime.rawValue] = true
                        }
                } else {
                        var dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                     from: Date())
                        dateComponents.hour = 0
                        dateComponents.minute = 0
                        dateComponents.second = 0
                        
                        self.releaseTimestampDatePicker.date = calendar.date(from: dateComponents)!
                        self.releaseTimestampTimePicker.date = calendar.date(bySettingHour: 9,
                                                                             minute: 0,
                                                                             second: 0,
                                                                             of: Date())!
                }
                
                self.settingsSectionSwitchStates[SettingSwitch.displayNameOverride.rawValue] = product.overridesDisplayName
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func addTag(_ tagString: String?) {
                let tag = NSOTag(name: tagString)
                guard tag.name != nil else { return }
                
                if !self.tags.contains(tag) {
                        self.tags.append(tag)
                        self.editedProduct.tags = Set(self.tags)
                        self.tableView.insertRows(
                                at: [IndexPath(row: self.tags.count - 1, section: InfoSection.tags.rawValue)],
                                with: .automatic
                        )
                        self.enableFormButtons()
                }
        }
        
        @objc
        private dynamic func datePickerDidChange(datePicker: UIDatePicker) {
                let calendar = Calendar.current
                let pickerType = DatePicker(rawValue: datePicker.tag)
                
                switch pickerType {
                case .releaseDate:
                        let dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                     from: self.editedProduct.releaseTimestamp!)
                        
                        if dateComponents.hour != 0 || dateComponents.minute != 0 {
                                self.editedProduct.releaseTimestamp = calendar.date(bySettingHour: dateComponents.hour!,
                                                                                    minute: dateComponents.minute!,
                                                                                    second: 0,
                                                                                    of: datePicker.date)
                        } else {
                                var dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                             from: datePicker.date)
                                dateComponents.hour = 0
                                dateComponents.minute = 0
                                dateComponents.second = 0
                                
                                self.editedProduct.releaseTimestamp = calendar.date(from: dateComponents)
                        }
                        
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: InfoSection.releaseTimestamp.rawValue)],
                                                  with: .none)
                case .releaseTime:
                        let dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                     from: datePicker.date)
                        self.editedProduct.releaseTimestamp = calendar.date(bySettingHour: dateComponents.hour!,
                                                                            minute: dateComponents.minute!,
                                                                            second: 0,
                                                                            of: self.releaseTimestampDatePicker.date)
                        
                        self.tableView.reloadRows(at: [IndexPath(row: 2, section: InfoSection.releaseTimestamp.rawValue)],
                                                  with: .none)
                default:
                        break
                }
                
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func dismissView() {
                if self.shouldUpdateProductInfo {
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
        private dynamic func editProduct() {
                self.doneButton?.isEnabled = false
                
                // Sometimes people enter a tag but forget to hit the done key.
                let newTagFieldCell = self.tableView.cellForRow(at: IndexPath(row: self.tags.count, section: InfoSection.tags.rawValue))
                
                if let newTagField = newTagFieldCell?.contentView.viewWithTag(InfoSection.tags.rawValue) as? UITextField {
                        self.addTag(newTagField.text)
                        newTagField.text = nil
                }
                
                self.navigationController?.present(
                        self.progressIndicator,
                        animated: true,
                        completion: {
                                if self.shouldUpdateProductInfo {
                                        let request = NSOUpdateProductRequest(
                                                description: self.editedProduct.description,
                                                mainColorCode: self.editedProduct.mainColor?.hex,
                                                materialID: self.editedProduct.material?.id,
                                                name: self.editedProduct.name!,
                                                overridesDisplayName: self.editedProduct.overridesDisplayName,
                                                parentProductID: self.editedProduct.parentProduct?.id,
                                                preorderTimestamp: self.editedProduct.preorderTimestamp,
                                                productID: self.product.id!,
                                                releaseTimestamp: self.editedProduct.releaseTimestamp,
                                                status: self.editedProduct.status,
                                                tags: self.tags,
                                                upc: self.editedProduct.upc,
                                                url: self.editedProduct.url
                                        )
                                        NSOAPI.shared.updateProduct(
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
                                                                DispatchQueue.main.async {
                                                                        self.progressIndicator.dismiss(animated: false)
                                                                        self.navigationController?.dismiss(animated: true)
                                                                }
                                                        }
                                                }
                                        )
                                } else {
                                        self.progressIndicator.dismiss(animated: false)
                                        self.navigationController?.dismiss(animated: true)
                                }
                        })
        }
        
        private func enableFormButtons() {
                if self.editedProduct.description != self.product.description ||
                        self.editedProduct.overridesDisplayName != self.product.overridesDisplayName ||
                        self.editedProduct.mainColor != self.product.mainColor ||
                        self.editedProduct.material != self.product.material ||
                        self.editedProduct.name != self.product.name ||
                        self.editedProduct.parentProduct != self.product.parentProduct ||
                        self.editedProduct.releaseTimestamp != self.product.releaseTimestamp ||
                        self.editedProduct.tags != self.product.tags ||
                        self.editedProduct.upc != self.product.upc ||
                        self.editedProduct.url != self.product.url {
                        self.shouldUpdateProductInfo = true
                } else {
                        self.shouldUpdateProductInfo = false
                }
                
                var buttonIsEnabled = self.shouldUpdateProductInfo
                
                if self.editedProduct.name == nil {
                        buttonIsEnabled = false
                }
                
                self.doneButton?.isEnabled = buttonIsEnabled
        }
        
        private func furnish(tableViewCell cell: UITableViewCell,
                             forInfoAt indexPath: IndexPath) {
                let section = InfoSection(rawValue: indexPath.section)
                
                switch section {
                case .description:
                        self.descriptionField.tag = indexPath.section
                        self.descriptionField.text = self.editedProduct.description
                        
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
                        self.nameField.text = self.editedProduct.name
                        
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
                case .mainColor:
                        if let color = self.editedProduct.mainColor {
                                self.mainColorLabel.text = color.name
                                self.mainColorThumbnailView.backgroundColor = UIColor(hex: color.hex)
                                
                                self.mainColorView.insertArrangedSubview(self.mainColorThumbnailView,
                                                                         at: 0)
                        } else {
                                self.mainColorLabel.text = "No Color"
                                self.mainColorThumbnailView.backgroundColor = .clear
                                
                                self.mainColorThumbnailView.removeFromSuperview()
                        }
                        
                        cell.selectionStyle = .default
                        
                        cell.contentView.addSubview(self.mainColorView)
                        
                        let cellViews = [
                                "mainColorLabel": self.mainColorLabel,
                                "mainColorThumbnailView": self.mainColorThumbnailView,
                                "mainColorView": self.mainColorView
                        ] as [String : Any]
                        
                        if self.editedProduct.mainColor != nil {
                                var mainColorThumbnailViewConstraints = NSLayoutConstraint.constraints(
                                        withVisualFormat: "V:[mainColorThumbnailView(==20)]",
                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                        metrics: nil,
                                        views: cellViews
                                )
                                mainColorThumbnailViewConstraints += NSLayoutConstraint.constraints(
                                        withVisualFormat: "H:[mainColorThumbnailView(==20)]",
                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                        metrics: nil,
                                        views: cellViews
                                )
                                self.mainColorView.addConstraints(mainColorThumbnailViewConstraints)
                        }
                        
                        var mainColorViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[mainColorView]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        mainColorViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[mainColorView]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(mainColorViewConstraints)
                case .material:
                        var content = cell.defaultContentConfiguration()
                        
                        if let material = self.editedProduct.material {
                                content.text = material.name
                        } else {
                                content.text = "No Material"
                        }
                        
                        cell.contentConfiguration = content
                        cell.selectionStyle = .default
                case .parentProduct:
                        var content = cell.defaultContentConfiguration()
                        
                        if let parentProduct = self.editedProduct.parentProduct {
                                content.text = parentProduct.displayName
                        }
                        
                        cell.contentConfiguration = content
                        cell.selectionStyle = .default
                case .releaseTimestamp:
                        if let releaseTimestamp = self.editedProduct.releaseTimestamp {
                                if indexPath.row == 0 {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.calendar = Calendar.current
                                        dateFormatter.dateFormat = "MMMM d, yyyy"
                                        
                                        var content = cell.defaultContentConfiguration()
                                        content.image = UIImage(systemName: "calendar")
                                        content.secondaryText = dateFormatter.string(from: releaseTimestamp)
                                        content.secondaryTextProperties.color = .systemGray
                                        content.text = "Date"
                                        
                                        let dateSwitch = UISwitch()
                                        dateSwitch.tag = InfoSwitch.releaseDate.rawValue
                                        dateSwitch.isOn = self.infoSectionSwitchStates[dateSwitch.tag]
                                        dateSwitch.addTarget(self,
                                                             action: #selector(self.switchDidFlip),
                                                             for: .valueChanged)
                                        
                                        cell.accessoryView = dateSwitch
                                        cell.contentConfiguration = content
                                        cell.separatorInset = UIEdgeInsets(top: 0,
                                                                           left: .greatestFiniteMagnitude,
                                                                           bottom: 0,
                                                                           right: 0)
                                } else if indexPath.row == 1 {
                                        cell.contentView.addSubview(self.releaseTimestampDatePicker)
                                        
                                        let cellViews = [
                                                "releaseTimestampDatePicker": self.releaseTimestampDatePicker
                                        ] as [String : Any]
                                        
                                        var datePickerConstraints = NSLayoutConstraint.constraints(
                                                withVisualFormat: "V:|[releaseTimestampDatePicker]|",
                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                metrics: nil,
                                                views: cellViews
                                        )
                                        datePickerConstraints += NSLayoutConstraint.constraints(
                                                withVisualFormat: "H:|-(20)-[releaseTimestampDatePicker]-(20)-|",
                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                metrics: nil,
                                                views: cellViews
                                        )
                                        cell.contentView.addConstraints(datePickerConstraints)
                                } else {
                                        let calendar = Calendar.current
                                        let dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                                     from: releaseTimestamp)
                                        
                                        if dateComponents.hour != 0 || dateComponents.minute != 0 {
                                                if indexPath.row == 2 {
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.calendar = Calendar.current
                                                        dateFormatter.dateFormat = "h:mm a"
                                                        
                                                        var content = cell.defaultContentConfiguration()
                                                        content.image = UIImage(systemName: "calendar.badge.clock")
                                                        content.secondaryText = dateFormatter.string(from: releaseTimestamp)
                                                        content.secondaryTextProperties.color = .systemGray
                                                        content.text = "Time"
                                                        
                                                        let timeSwitch = UISwitch()
                                                        timeSwitch.tag = InfoSwitch.releaseTime.rawValue
                                                        timeSwitch.isOn = self.infoSectionSwitchStates[timeSwitch.tag]
                                                        timeSwitch.addTarget(self,
                                                                             action: #selector(self.switchDidFlip),
                                                                             for: .valueChanged)
                                                        
                                                        cell.accessoryView = timeSwitch
                                                        cell.contentConfiguration = content
                                                        cell.separatorInset = UIEdgeInsets(top: 0,
                                                                                           left: .greatestFiniteMagnitude,
                                                                                           bottom: 0,
                                                                                           right: 0)
                                                } else {
                                                        cell.contentView.addSubview(self.releaseTimestampTimePicker)
                                                        
                                                        let cellViews = [
                                                                "releaseTimestampTimePicker": self.releaseTimestampTimePicker
                                                        ] as [String : Any]
                                                        
                                                        var timePickerConstraints = NSLayoutConstraint.constraints(
                                                                withVisualFormat: "V:|[releaseTimestampTimePicker]|",
                                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: cellViews
                                                        )
                                                        timePickerConstraints += NSLayoutConstraint.constraints(
                                                                withVisualFormat: "H:|-(20)-[releaseTimestampTimePicker]-(20)-|",
                                                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                metrics: nil,
                                                                views: cellViews
                                                        )
                                                        cell.contentView.addConstraints(timePickerConstraints)
                                                }
                                        } else {
                                                var content = cell.defaultContentConfiguration()
                                                content.image = UIImage(systemName: "calendar.badge.clock")
                                                content.text = "Time"
                                                
                                                let timeSwitch = UISwitch()
                                                timeSwitch.tag = InfoSwitch.releaseTime.rawValue
                                                timeSwitch.isOn = self.infoSectionSwitchStates[timeSwitch.tag]
                                                timeSwitch.addTarget(self,
                                                                     action: #selector(self.switchDidFlip),
                                                                     for: .valueChanged)
                                                
                                                cell.accessoryView = timeSwitch
                                                cell.contentConfiguration = content
                                        }
                                }
                        } else {
                                var content = cell.defaultContentConfiguration()
                                
                                if indexPath.row == 0 {
                                        content.image = UIImage(systemName: "calendar")
                                        content.text = "Date"
                                        
                                        let dateSwitch = UISwitch()
                                        dateSwitch.tag = InfoSwitch.releaseDate.rawValue
                                        dateSwitch.isOn = self.infoSectionSwitchStates[dateSwitch.tag]
                                        dateSwitch.addTarget(self,
                                                             action: #selector(self.switchDidFlip),
                                                             for: .valueChanged)
                                        
                                        cell.accessoryView = dateSwitch
                                } else {
                                        content.image = UIImage(systemName: "calendar.badge.clock")
                                        content.text = "Time"
                                        
                                        let timeSwitch = UISwitch()
                                        timeSwitch.tag = InfoSwitch.releaseTime.rawValue
                                        timeSwitch.isOn = self.infoSectionSwitchStates[timeSwitch.tag]
                                        timeSwitch.addTarget(self,
                                                             action: #selector(self.switchDidFlip),
                                                             for: .valueChanged)
                                        
                                        cell.accessoryView = timeSwitch
                                }
                                
                                cell.contentConfiguration = content
                        }
                case .tags:
                        if indexPath.row < self.tags.count {
                                let tag = self.tags[indexPath.row]
                                
                                var content = cell.defaultContentConfiguration()
                                content.text = tag.name
                                content.textProperties.font = .systemFont(ofSize: UIFont.labelFontSize)
                                cell.contentConfiguration = content
                        } else {
                                self.newTagField.tag = indexPath.section
                                cell.contentView.addSubview(self.newTagField)
                                
                                let cellViews = [
                                        "newTagField": self.newTagField
                                ]
                                
                                var newTagFieldConstraints = NSLayoutConstraint.constraints(
                                        withVisualFormat: "V:|[newTagField]|",
                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                        metrics: nil,
                                        views: cellViews
                                )
                                newTagFieldConstraints += NSLayoutConstraint.constraints(
                                        withVisualFormat: "H:|-(17)-[newTagField]-(17)-|",
                                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                        metrics: nil,
                                        views: cellViews
                                )
                                cell.contentView.addConstraints(newTagFieldConstraints)
                        }
                case .upc:
                        self.upcField.tag = indexPath.section
                        self.upcField.text = self.editedProduct.upc
                        
                        cell.contentView.addSubview(self.upcField)
                        
                        let cellViews = [
                                "upcField": self.upcField
                        ] as [String : Any]
                        
                        var upcFieldConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[upcField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        upcFieldConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[upcField]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(upcFieldConstraints)
                case .url:
                        self.urlField.tag = indexPath.section
                        self.urlField.text = self.editedProduct.url?.absoluteString
                        
                        cell.contentView.addSubview(self.urlField)
                        
                        let cellViews = [
                                "urlField": self.urlField
                        ] as [String : Any]
                        
                        var urlFieldConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[urlField]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        urlFieldConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[urlField]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(urlFieldConstraints)
                default:
                        break
                }
        }
        
        private func furnish(tableViewCell cell: UITableViewCell,
                             forSettingsAt indexPath: IndexPath) {
                let section = SettingsSection(rawValue: indexPath.section)
                
                switch section {
                case .displayNameOverride:
                        var content = cell.defaultContentConfiguration()
                        content.text = "Override Name Display"
                        
                        let settingSwitch = UISwitch()
                        settingSwitch.tag = SettingSwitch.displayNameOverride.rawValue
                        settingSwitch.isOn = self.settingsSectionSwitchStates[settingSwitch.tag]
                        settingSwitch.addTarget(self,
                                             action: #selector(self.switchDidFlip),
                                             for: .valueChanged)
                        
                        cell.accessoryView = settingSwitch
                        cell.contentConfiguration = content
                default:
                        break
                }
        }
        
        private func presentBrandEditingView() {
                self.tableView.isUserInteractionEnabled = true
                self.enableFormButtons()
        }
        
        private func presentParentProductViewController() {
                let productNameViewController = NSOProductVariantViewController()
                productNameViewController.delegate = self
                productNameViewController.mode = .search
                
                let navigationController = UINavigationController(rootViewController: productNameViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        @objc
        private dynamic func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
                let selectedTab = Tab.allCases[segmentedControl.selectedSegmentIndex]
                
                if selectedTab != self.activeTab {
                        self.activeTab = selectedTab
                        self.tableView.reloadData()
                }
        }
        
        @objc
        private dynamic func switchDidFlip(theSwitch: UISwitch) {
                switch self.activeTab {
                case .info:
                        let calendar = Calendar.current
                        let switchType = InfoSwitch(rawValue: theSwitch.tag)
                        
                        switch switchType {
                        case .releaseDate:
                                if theSwitch.isOn {
                                        self.editedProduct.releaseTimestamp = self.releaseTimestampDatePicker.date
                                } else {
                                        var dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                                     from: Date())
                                        dateComponents.hour = 0
                                        dateComponents.minute = 0
                                        dateComponents.second = 0
                                        
                                        self.editedProduct.releaseTimestamp = nil
                                        self.releaseTimestampDatePicker.date = calendar.date(from: dateComponents)!
                                        self.infoSectionSwitchStates[InfoSwitch.releaseTime.rawValue] = false
                                }
                                
                                self.infoSectionSwitchStates[theSwitch.tag] = theSwitch.isOn
                        case .releaseTime:
                                if theSwitch.isOn {
                                        self.editedProduct.releaseTimestamp = calendar.date(bySettingHour: 9,
                                                                                            minute: 0,
                                                                                            second: 0,
                                                                                            of: self.releaseTimestampDatePicker.date)
                                        self.infoSectionSwitchStates[InfoSwitch.releaseDate.rawValue] = true
                                } else {
                                        var dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                                     from: self.releaseTimestampDatePicker.date)
                                        dateComponents.hour = 0
                                        dateComponents.minute = 0
                                        dateComponents.second = 0
                                        
                                        self.editedProduct.releaseTimestamp = calendar.date(from: dateComponents)
                                }
                                
                                self.releaseTimestampDatePicker.date = self.editedProduct.releaseTimestamp!
                                self.releaseTimestampTimePicker.date = self.editedProduct.releaseTimestamp!
                                self.infoSectionSwitchStates[theSwitch.tag] = theSwitch.isOn
                        default:
                                break
                        }
                        
                        self.tableView.reloadSections([InfoSection.releaseTimestamp.rawValue],
                                                      with: .automatic)
                case .settings:
                        let switchType = SettingSwitch(rawValue: theSwitch.tag)
                        
                        switch switchType {
                        case .displayNameOverride:
                                self.editedProduct.overridesDisplayName = theSwitch.isOn
                                self.settingsSectionSwitchStates[theSwitch.tag] = theSwitch.isOn
                        default:
                                break
                        }
                        
                        self.tableView.reloadSections([SettingsSection.displayNameOverride.rawValue],
                                                      with: .automatic)
                }
                
                self.enableFormButtons()
        }
        
        @objc
        private dynamic func textFieldDidChange(textField: UITextField) {
                let section = InfoSection(rawValue: textField.tag)
                
                switch section {
                case .name:
                        var productName: String? = nil
                        
                        if var textFieldString = textField.text {
                                textFieldString = textFieldString.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                if !textFieldString.isEmpty {
                                        productName = textFieldString
                                }
                        }
                        
                        if productName != nil {
                                if self.isProductVariant {
                                        if let range = productName!.range(of: self.product.parentProduct!.name!,
                                                                          options: [.caseInsensitive]) {
                                                productName = String(productName![range.upperBound...])
                                        }
                                } else if let range = productName!.range(of: self.product.brand!.name!,
                                                                         options: [.caseInsensitive]) {
                                        productName = String(productName![range.upperBound...])
                                }
                        }
                        
                        self.editedProduct.name = productName
                case .upc:
                        var upc: String? = nil
                        
                        if var textFieldString = textField.text {
                                textFieldString = textFieldString.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                if !textFieldString.isEmpty {
                                        upc = textFieldString
                                }
                        }
                        
                        self.editedProduct.upc = upc
                case .url:
                        var url: URL? = nil
                        
                        if let textFieldString = textField.text {
                                let urlString = String(textFieldString.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                                
                                if !urlString.isEmpty {
                                        url = URL(string: urlString)
                                }
                        }
                        
                        self.editedProduct.url = url
                default:
                        break
                }
                
                self.enableFormButtons()
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
                                action: #selector(self.editProduct)
                        )
                        self.doneButton?.isEnabled = false
                        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.doneButton
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                let segmentedControl = UISegmentedControl(items: Tab.allCases.map({$0.rawValue}))
                segmentedControl.selectedSegmentIndex = 0
                segmentedControl.sizeToFit()
                segmentedControl.addTarget(
                        self,
                        action: #selector(segmentedControlValueChanged),
                        for: .valueChanged
                )
                segmentedControl.addTarget(
                        self,
                        action: #selector(segmentedControlValueChanged),
                        for: .touchUpInside
                )
                
                self.navigationItem.titleView = segmentedControl
                
                self.presentBrandEditingView()
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                self.tableView.setEditing(true, animated: false)
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
        }
}


// MARK: - NSOProductColorPickerViewControllerDelegate

extension NSOProductEditingViewController: NSOProductColorPickerViewControllerDelegate {
        func colorPickerViewControllerDidFinish(_ viewController: NSOProductColorPickerViewController) {
                self.editedProduct.mainColor = viewController.selectedColor
                self.editedProduct.mainColorCode = viewController.selectedColor?.hex
                
                if let color = viewController.selectedColor {
                        self.mainColorLabel.text = color.name
                        self.mainColorThumbnailView.backgroundColor = UIColor(hex: color.hex)
                        
                        self.mainColorView.insertArrangedSubview(self.mainColorThumbnailView,
                                                                 at: 0)
                        
                        let views = [
                                "mainColorThumbnailView": self.mainColorThumbnailView
                        ] as [String : Any]
                        
                        var mainColorThumbnailViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:[mainColorThumbnailView(==20)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        mainColorThumbnailViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:[mainColorThumbnailView(==20)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                } else {
                        self.mainColorLabel.text = "No Color"
                        self.mainColorThumbnailView.backgroundColor = .clear
                        
                        self.mainColorThumbnailView.removeFromSuperview()
                }
                
                self.enableFormButtons()
        }
        
        func colorPickerViewControllerDidSelectColor(_ viewController: NSOProductColorPickerViewController) {
                self.editedProduct.mainColor = viewController.selectedColor
                self.editedProduct.mainColorCode = viewController.selectedColor?.hex
                
                if let color = viewController.selectedColor {
                        self.mainColorLabel.text = color.name
                        self.mainColorThumbnailView.backgroundColor = UIColor(hex: color.hex)
                        
                        self.mainColorView.insertArrangedSubview(self.mainColorThumbnailView,
                                                                 at: 0)
                        
                        let views = [
                                "mainColorThumbnailView": self.mainColorThumbnailView
                        ] as [String : Any]
                        
                        var mainColorThumbnailViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:[mainColorThumbnailView(==20)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        mainColorThumbnailViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:[mainColorThumbnailView(==20)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        self.mainColorView.addConstraints(mainColorThumbnailViewConstraints)
                } else {
                        self.mainColorLabel.text = "No Color"
                        self.mainColorThumbnailView.backgroundColor = .clear
                        
                        self.mainColorThumbnailView.removeFromSuperview()
                }
                
                self.enableFormButtons()
        }
}


// MARK: - NSOProductMaterialPickerViewControllerDelegate

extension NSOProductEditingViewController: NSOProductMaterialPickerViewControllerDelegate {
        func materialPickerViewControllerDidFinish(_ viewController: NSOProductMaterialPickerViewController) {
                self.editedProduct.material = viewController.selectedMaterial
                self.editedProduct.materialID = viewController.selectedMaterial?.id
                self.tableView.reloadData()
                self.enableFormButtons()
        }
        
        func materialPickerViewControllerDidSelectMaterial(_ viewController: NSOProductMaterialPickerViewController) {
                self.editedProduct.material = viewController.selectedMaterial
                self.editedProduct.materialID = viewController.selectedMaterial?.id
                self.tableView.reloadData()
                self.enableFormButtons()
        }
}


// MARK: - NSOProductVariantViewControllerDelegate

extension NSOProductEditingViewController: NSOProductVariantViewControllerDelegate {
        func variantViewControllerDidCancel(_ viewController: NSOProductVariantViewController) {
                if self.navigationController?.presentedViewController != nil {
                        viewController.dismiss(animated: true,
                                               completion: {
                                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                                        self.tableView.deselectRow(at: selectedIndexPath,
                                                                   animated: true)
                                }
                        })
                } else {
                        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                                self.tableView.deselectRow(at: selectedIndexPath,
                                                           animated: true)
                        }
                }
        }
        
        func variantViewController(_ viewController: NSOProductVariantViewController,
                                   didSelect parentProduct: NSOProduct) {
                self.isProductVariant = true
                self.editedProduct.parentProduct = parentProduct
                self.editedProduct.parentProductID = parentProduct.id
                self.enableFormButtons()
                
                viewController.dismiss(animated: true,
                                       completion: {
                        if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                                self.tableView.reloadRows(at: [selectedIndexPath],
                                                          with: .automatic)
                                self.tableView.deselectRow(at: selectedIndexPath,
                                                           animated: true)
                        }
                })
        }
}


// MARK: - UIAdaptivePresentationControllerDelegate

extension NSOProductEditingViewController: UIAdaptivePresentationControllerDelegate {
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if self.shouldUpdateProductInfo {
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
}


// MARK: - UITableViewDataSource

extension NSOProductEditingViewController {
        override func numberOfSections(in tableView: UITableView) -> Int {
                var count: Int = 0
                
                switch self.activeTab {
                case .info:
                        count = InfoSection.allCases.count
                case .settings:
                        count = SettingsSection.allCases.count
                }
                
                return count
        }
        
        override func tableView(_ tableView: UITableView,
                                canEditRowAt indexPath: IndexPath) -> Bool {
                var ret = false
                
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: indexPath.section)
                        
                        switch section {
                        case .material:
                                if self.editedProduct.material != nil {
                                        ret = true
                                }
                        case .parentProduct:
                                if self.editedProduct.parentProduct != nil {
                                        ret = true
                                }
                        case .tags:
                                ret = true
                        default:
                                break
                        }
                case .settings:
                        break
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductEditingViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                // Reset the cell in prep for each type of row.
                cell.accessoryType = .none
                cell.accessoryView = nil
                cell.contentConfiguration = nil
                cell.selectionStyle = .none
                cell.separatorInset = UIEdgeInsets(top: 0,
                                                   left: cell.layoutMargins.left,
                                                   bottom: 0,
                                                   right: 0)
                
                for subview in cell.contentView.subviews {
                        subview.removeFromSuperview()
                }
                
                switch self.activeTab {
                case .info:
                        self.furnish(tableViewCell: cell, forInfoAt: indexPath)
                case .settings:
                        self.furnish(tableViewCell: cell, forSettingsAt: indexPath)
                }
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                commit editingStyle: UITableViewCell.EditingStyle,
                                forRowAt indexPath: IndexPath) {
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: indexPath.section)
                        
                        switch section {
                        case .material:
                                if editingStyle == .delete {
                                        self.editedProduct.material = nil
                                        self.editedProduct.materialID = nil
                                        tableView.reloadRows(at: [indexPath],
                                                             with: .automatic)
                                        self.enableFormButtons()
                                }
                        case .parentProduct:
                                if editingStyle == .delete {
                                        self.isProductVariant = false
                                        self.editedProduct.parentProduct = nil
                                        self.editedProduct.parentProductID = nil
                                        tableView.reloadRows(at: [indexPath],
                                                             with: .automatic)
                                        self.enableFormButtons()
                                }
                        case .tags:
                                if editingStyle == .delete {
                                        self.tags.remove(at: indexPath.row)
                                        self.editedProduct.tags = Set(self.tags)
                                        tableView.deleteRows(at: [indexPath], with: .fade)
                                        self.enableFormButtons()
                                }
                        default:
                                break
                        }
                case .settings:
                        break
                }
        }
        
        override func tableView(_ tableView: UITableView,
                                editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
                var ret = UITableViewCell.EditingStyle.none
                
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: indexPath.section)
                        
                        switch section {
                        case .material:
                                if self.editedProduct.material != nil {
                                        ret = .delete
                                }
                        case .parentProduct:
                                if self.editedProduct.parentProduct != nil {
                                        ret = .delete
                                }
                        case .tags:
                                if indexPath.row < self.tags.count {
                                        ret = .delete
                                } else {
                                        ret = .insert
                                }
                        default:
                                break
                        }
                case .settings:
                        break
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                heightForRowAt indexPath: IndexPath) -> CGFloat {
                var ret: CGFloat = 44
                
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: indexPath.section)
                        
                        switch section {
                        case .description:
                                if let productDescription = self.editedProduct.description {
                                        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]
                                        let descriptionString = NSAttributedString(string: productDescription,
                                                                                   attributes: attributes)
                                        let descriptionFieldSize = descriptionString.boundingRect(
                                                with: CGSize(width: tableView.bounds.width - 40, height: .greatestFiniteMagnitude),
                                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                context: nil
                                        )
                                        
                                        ret = max(descriptionFieldSize.height + 22, 44)
                                }
                        case .releaseTimestamp:
                                ret = 64
                        default:
                                break
                        }
                case .settings:
                        break
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                var ret: Int = 1
                
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: section)
                        
                        switch section {
                        case .releaseTimestamp:
                                ret = 2
                                
                                if let releaseTimestamp = self.editedProduct.releaseTimestamp {
                                        ret += 1
                                        
                                        let calendar = Calendar.current
                                        let dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                                     from: releaseTimestamp)
                                        
                                        if dateComponents.hour != 0 || dateComponents.minute != 0 {
                                                ret += 1
                                        }
                                }
                        case .tags:
                                ret = self.tags.count + 1
                        default:
                                break
                        }
                case .settings:
                        break
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForFooterInSection section: Int) -> String? {
                var ret: String? = nil
                
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: section)
                        
                        switch section {
                        case .releaseTimestamp:
                                ret = "This date is in your local time zone. Adjust accordingly when adding a release date from another time zone."
                        case .upc:
                                ret = "The UPC is the number on the barcode of the product."
                        default:
                                break
                        }
                case .settings:
                        let section = SettingsSection(rawValue: section)
                        
                        switch section {
                        case .displayNameOverride:
                                if self.isProductVariant {
                                        ret = "By default, the name of the main product is always shown before the variant's name. Enabling this option will instead show the varian't name exactly as it is entered here."
                                } else {
                                        ret = "By default, the product's brand name is always shown before its name. Enabling this option will instead show the product name exactly as it is entered here."
                                }
                        default:
                                break
                        }
                }
                
                return ret
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
                var ret: String? = nil
                
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: section)
                        
                        switch section {
                        case .name:
                                ret = "Name"
                        case .description:
                                ret = "Description"
                        case .mainColor:
                                ret = "Main Color"
                        case .material:
                                ret = "Material"
                        case .parentProduct:
                                ret = "Variant of"
                        case .releaseTimestamp:
                                ret = "Release Date"
                        case .tags:
                                ret = "Tags"
                        case .upc:
                                ret = "Universal Product Code (UPC)"
                        case .url:
                                ret = "URL"
                        default:
                                break
                        }
                case .settings:
                        break
                }
                
                return ret
        }
}


// MARK: - UITableViewDelegate

extension NSOProductEditingViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: indexPath.section)
                        
                        switch section {
                        case .mainColor:
                                let picker = NSOProductColorPickerViewController()
                                picker.delegate = self
                                picker.selectedColor = self.editedProduct.mainColor
                                
                                let navigationController = UINavigationController(rootViewController: picker)
                                self.navigationController?.present(navigationController,
                                                                   animated: true)
                                tableView.deselectRow(at: indexPath,
                                                      animated: true)
                        case .material:
                                let picker = NSOProductMaterialPickerViewController()
                                picker.delegate = self
                                picker.selectedMaterial = self.editedProduct.material
                                
                                let navigationController = UINavigationController(rootViewController: picker)
                                self.navigationController?.present(navigationController,
                                                                   animated: true)
                                tableView.deselectRow(at: indexPath,
                                                      animated: true)
                        case .parentProduct:
                                self.presentParentProductViewController()
                                /// Don't deselect the row! We rely on it being selected to fetch its index path once
                                /// the user selects a parent product.
                        default:
                                break
                        }
                case .settings:
                        break
                }
        }
}


// MARK: - UITextFieldDelegate

extension NSOProductEditingViewController: UITextFieldDelegate  {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: textField.tag)
                        
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
                case .settings:
                        break
                }
                
                return false
        }
}


// MARK: - UITextViewDelegate

extension NSOProductEditingViewController: UITextViewDelegate {
        func textViewDidChange(_ textView: UITextView) {
                switch self.activeTab {
                case .info:
                        let section = InfoSection(rawValue: textView.tag)
                        
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
                                
                                self.editedProduct.description = description
                                self.tableView.beginUpdates()
                                self.tableView.endUpdates()
                        default:
                                break
                        }
                case .settings:
                        break
                }
                
                self.enableFormButtons()
        }
}
