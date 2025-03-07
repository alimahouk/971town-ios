//
//  NSOBrandViewController.swift
//  971town
//
//  Created by Ali Mahouk on 20/03/2023.
//

import API
import SDWebImage
import UIKit


class NSOBrandViewController: UITableViewController {
        private enum HeaderRow: Int,
                                CaseIterable {
                case identification = 0 // Contains the name and alias.
                case website
                case description
        }
        
        private enum ProductRow: Int,
                                 CaseIterable {
                case product = 0
                case allProducts
                case addProduct
        }
        
        private enum Section: Int,
                              CaseIterable {
                case header = 0
                case products
                case tags
        }
        
        private enum TagsRow: Int,
                              CaseIterable {
                case tags = 0
        }
        
        private let brandCreationLabel: UILabel
        private var brandIsLoading: Bool = true
        private var brandTagsFormattedString: String?
        private var editButton: UIBarButtonItem?
        private var groupedCellMargin: CGFloat
        {
                get {
                        let marginWidth: CGFloat
                        
                        if self.tableView.bounds.width > 20
                        {
                                if self.tableView.bounds.width < 400
                                {
                                        marginWidth = 10
                                }
                                else
                                {
                                        marginWidth = max(31, min(45, self.tableView.bounds.width * 0.06))
                                }
                        }
                        else
                        {
                                marginWidth = self.tableView.bounds.width - 10
                        }
                        
                        return marginWidth
                }
        }
        private let progressIndicator: UIAlertController
        private let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
        private static let tableViewCellIdentifier: String = "BrandTableViewCell"
        private var viewIsLoaded: Bool = false
        
        public var allowsCreationWorkflows: Bool = true
        public var brand: NSOBrand
        
        init(brand: NSOBrand) {
                self.brand = brand
                
                self.brandCreationLabel = UILabel()
                self.brandCreationLabel.font = .systemFont(ofSize: 14)
                self.brandCreationLabel.numberOfLines = 0
                self.brandCreationLabel.textColor = .systemGray
                
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
                
                super.init(style: .insetGrouped)
                
                self.view.tintAdjustmentMode = .normal
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOBrandViewController.tableViewCellIdentifier)
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidCreateProduct),
                        name: .NSOCreatedProduct,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(userDidUpdateBrand),
                        name: .NSOUpdatedBrand,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(userDidUpdateBrandAvatar),
                        name: .NSOUpdatedBrandAvatar,
                        object: nil
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
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        private func dismissBrandInfoView() {
                self.editButton?.isEnabled = false
                self.brandIsLoading = true
                self.tableView.separatorStyle = .none
                
                self.tableView.reloadData()
        }
        
        private func getBrand() {
                self.dismissBrandInfoView()
                self.navigationController?.present(self.progressIndicator,
                                                   animated: false)
                
                let request = NSOGetBrandRequest(brandID: self.brand.id)
                NSOAPI.shared.getBrand(
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
                                                                        style: .default
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
                                                                        style: .default
                                                                )
                                                        )
                                                        self.navigationController?.present(alert,
                                                                                           animated: true)
                                                })
                                        }
                                } else if let apiResponse = apiResponse {
                                        DispatchQueue.main.async {
                                                self.presentBrandInfoView(brand: apiResponse.brand)
                                        }
                                }
                        }
                )
        }
        
        override func numberOfSections(in tableView: UITableView) -> Int {
                var count = Section.allCases.count

                if self.brand.tags.isEmpty {
                        count -= 1
                }
                
                return count
        }
        
        @objc
        private dynamic func presentBrandEditingViewController() {
                let editingViewController = NSOBrandEditingViewController(brand: self.brand)
                let navigationController = UINavigationController(rootViewController: editingViewController)
                navigationController.presentationController?.delegate = editingViewController
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        private dynamic func presentNewProductViewController() {
                let product = NSOProduct(
                        brand: self.brand
                )
                
                let productNameViewController = NSOProductNameViewController(product: product)
                let navigationController = UINavigationController(rootViewController: productNameViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        private func presentBrandInfoView(brand: NSOBrand) {
                if brand.id == self.brand.id {
                        self.editButton?.isEnabled = true
                        self.brandIsLoading = false
                        self.tableView.separatorStyle = .singleLine
                        
                        self.progressIndicator.dismiss(animated: true)
                        
                        // Refresh.
                        self.brand.alias = brand.alias
                        self.brand.avatarLightPath = brand.avatarLightPath
                        self.brand.creationTimestamp = brand.creationTimestamp
                        self.brand.creator = brand.creator
                        self.brand.creatorID = brand.creatorID
                        self.brand.description = brand.description
                        self.brand.editAccessLevel = brand.editAccessLevel
                        self.brand.name = brand.name
                        self.brand.products = brand.products
                        self.brand.productCount = brand.productCount
                        self.brand.rep = brand.rep
                        self.brand.tags = brand.tags
                        self.brand.visibility = brand.visibility
                        self.brand.website = brand.website
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.calendar = Calendar.current
                        dateFormatter.dateFormat = "h:mm a 'on' MMMM d, yyyy"
                        dateFormatter.timeZone = TimeZone.current
                        
                        if let creatorALias = self.brand.creator?.alias {
                                self.brandCreationLabel.text = "Added by \(NSOAPI.Configuration.mentionSequence)\(creatorALias) at \(dateFormatter.string(from: self.brand.creationTimestamp!))"
                        } else {
                                self.brandCreationLabel.text = "Added at \(dateFormatter.string(from: self.brand.creationTimestamp!))"
                        }
                        
                        if !self.brand.tags.isEmpty {
                                self.brandTagsFormattedString = self.brand.tags.map({$0.name!}).joined(separator: ", ")
                        } else {
                                self.brandTagsFormattedString = nil
                        }
                        
                        let productCreationLabelSize = self.brandCreationLabel.sizeThatFits(
                                CGSize(
                                        width: self.tableView.bounds.width - 80,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.brandCreationLabel.frame = CGRect(
                                x: 40,
                                y: 0,
                                width: self.tableView.bounds.width - 80,
                                height: productCreationLabelSize.height
                        )
                        let tableFooterView = UIView(
                                frame: CGRect(
                                        x: 0,
                                        y: 0,
                                        width: 0,
                                        height: self.brandCreationLabel.bounds.height + 10
                                )
                        )
                        tableFooterView.addSubview(self.brandCreationLabel)
                        self.tableView.tableFooterView = tableFooterView
                        
                        self.tableView.reloadData()
                }
        }
        
        private func rowFor(tableRow: Int,
                            inSection section: Section) -> Any? {
                var row: Any? = nil
                
                switch section {
                case .header:
                        switch tableRow {
                        case 0:
                                row = HeaderRow.identification
                        case 1:
                                if self.brand.website != nil {
                                        row = HeaderRow.website
                                } else if self.brand.description != nil {
                                        row = HeaderRow.description
                                }
                        case 2:
                                row = HeaderRow.description
                        default:
                                break
                        }
                case .products:
                        if self.brand.productCount > self.brand.products.count {
                                if tableRow == self.brand.products.count {
                                        row = ProductRow.allProducts
                                } else if tableRow == self.brand.products.count + 1 {
                                        row = ProductRow.addProduct
                                } else {
                                        row = ProductRow.product
                                }
                        } else {
                                if tableRow == self.brand.products.count {
                                        row = ProductRow.addProduct
                                } else {
                                        row = ProductRow.product
                                }
                        }
                case .tags:
                        row = TagsRow.tags
                }
                
                return row
        }
        
        private func sectionFor(tableSection: Int) -> Section {
                var visibleSections: Array<Section> = [
                        .header,
                        .products
                ]
                
                if !self.brand.tags.isEmpty {
                        visibleSections.append(.tags)
                }
                
                return visibleSections[tableSection]
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let section = self.sectionFor(tableSection: indexPath.section)
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOBrandViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                // Reset the cell in prep for each type of row.
                cell.accessoryType = .none
                cell.contentConfiguration = nil
                cell.selectionStyle = .none
                
                for subview in cell.contentView.subviews {
                        subview.removeFromSuperview()
                }
                
                switch section {
                case .header:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! HeaderRow
                        
                        switch row {
                        case .description:
                                let paragraphStyle = NSMutableParagraphStyle()
                                paragraphStyle.lineSpacing = 5
                                
                                let attributes = [
                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                        .paragraphStyle: paragraphStyle
                                ]
                                
                                let attributedString = NSMutableAttributedString(string: self.brand.description!)
                                attributedString.setAttributes(attributes,
                                                               range: NSMakeRange(0, attributedString.length))
                                
                                var content = cell.defaultContentConfiguration()
                                content.attributedText = attributedString
                                
                                cell.contentConfiguration = content
                        case .identification:
                                var content = cell.defaultContentConfiguration()
                                content.imageProperties.cornerRadius = self.softRoundCornerRadius
                                content.secondaryText = NSOAPI.Configuration.mentionSequence + self.brand.alias!
                                content.secondaryTextProperties.color = .systemGray
                                content.text = self.brand.name
                                content.textProperties.font = .boldSystemFont(ofSize: 18)
                                
                                if self.brand.avatarLightPath != nil {
                                        SDWebImageManager.shared.loadImage(
                                                with: self.brand.avatarLightURL,
                                                options: .continueInBackground,
                                                progress: nil,
                                                completed: { [weak self] (image, data, error, cacheType, finished, url) in
                                                        guard self != nil else { return }
                                                        
                                                        if let error = error {
                                                                print(error)
                                                                
                                                                return
                                                        }
                                                        
                                                        guard let image = image else { return }
                                                        self?.brand.avatar = image
                                                        content.image = image
                                                        cell.contentConfiguration = content
                                                }
                                        )
                                } else {
                                        self.brand.avatar = nil
                                        content.image = nil
                                }
                                
                                cell.contentConfiguration = content
                        case .website:
                                if let website = self.brand.website {
                                        var websiteString = website.host!
                                        
                                        if !website.path.isEmpty && website.path != "/" {
                                                websiteString += website.path
                                        }
                                        
                                        var content = cell.defaultContentConfiguration()
                                        content.image = UIImage(systemName: "link")
                                        content.text = websiteString
                                        content.textProperties.color = self.view.tintColor
                                        
                                        cell.contentConfiguration = content
                                        cell.selectionStyle = .default
                                }
                        }
                case .products:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! ProductRow
                        var content = cell.defaultContentConfiguration()
                        
                        switch row {
                        case .addProduct:
                                content.image = UIImage(systemName: "plus")
                                content.text = "Add Product"
                                content.textProperties.color = self.view.tintColor
                                
                                cell.selectionStyle = .default
                        case .allProducts:
                                content.image = UIImage(systemName: "shippingbox")
                                content.text = "All Products"
                                
                                let numberFormatter = NumberFormatter()
                                numberFormatter.numberStyle = .decimal
                                
                                if let formattedCount = numberFormatter.string(from: NSNumber(value: self.brand.productCount)) {
                                        content.prefersSideBySideTextAndSecondaryText = true
                                        content.secondaryText = formattedCount
                                        content.secondaryTextProperties.color = .systemGray
                                        content.secondaryTextProperties.font = .systemFont(ofSize: UIFont.labelFontSize)
                                }
                                
                                cell.accessoryType = .disclosureIndicator
                                cell.selectionStyle = .default
                        case .product:
                                let product = self.brand.products[indexPath.row]
                                
                                content.secondaryText = NSOAPI.Configuration.mentionSequence + product.alias!
                                content.secondaryTextProperties.color = .systemGray
                                content.text = product.name
                                
                                cell.accessoryType = .disclosureIndicator
                                cell.selectionStyle = .default
                        }
                        
                        cell.contentConfiguration = content
                case .tags:
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 5
                        
                        let attributes = [
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                .paragraphStyle: paragraphStyle
                        ]
                        
                        let attributedString = NSMutableAttributedString(string: self.brandTagsFormattedString!)
                        attributedString.setAttributes(attributes,
                                                       range: NSMakeRange(0, attributedString.length))
                        
                        var content = cell.defaultContentConfiguration()
                        content.attributedText = attributedString
                        
                        cell.contentConfiguration = content
                }
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let section = self.sectionFor(tableSection: indexPath.section)
                
                switch section {
                case .header:
                        let row = rowFor(tableRow: indexPath.row,
                                         inSection: section) as! HeaderRow
                        
                        if row == .website {
                                if UIApplication.shared.canOpenURL(self.brand.website!) {
                                        UIApplication.shared.open(self.brand.website!,
                                                                  options: [:],
                                                                  completionHandler: nil)
                                }
                                
                                self.tableView.deselectRow(at: indexPath,
                                                           animated: true)
                        }
                case .products:
                        let row = rowFor(tableRow: indexPath.row,
                                         inSection: section) as! ProductRow
                        
                        switch row {
                        case .addProduct:
                                self.presentNewProductViewController()
                                self.tableView.deselectRow(at: indexPath,
                                                           animated: false)
                        case .allProducts:
                                let brandProductsViewController = NSOBrandProductsViewController(brand: self.brand)
                                self.navigationController?.pushViewController(brandProductsViewController,
                                                                              animated: true)
                        case .product:
                                let product = self.brand.products[indexPath.row]
                                let productViewController = NSOProductViewController(product: product)
                                self.navigationController?.pushViewController(productViewController,
                                                                              animated: true)
                        }
                case .tags:
                        break
                }
        }
        
        override func tableView(_ tableView: UITableView,
                                heightForRowAt indexPath: IndexPath) -> CGFloat {
                var height: CGFloat = 0
                let section = self.sectionFor(tableSection: indexPath.section)
                
                switch section {
                case .header:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! HeaderRow
                        
                        switch row {
                        case .description:
                                let paragraphStyle = NSMutableParagraphStyle()
                                paragraphStyle.lineSpacing = 5
                                
                                let attributes = [
                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                        .paragraphStyle: paragraphStyle
                                ]
                                let constraintRect = CGSize(
                                        width: tableView.bounds.width - (self.groupedCellMargin * 2) - 40,
                                        height: .greatestFiniteMagnitude
                                )
                                let boundingBox = self.brand.description!.boundingRect(
                                        with: constraintRect,
                                        options: .usesLineFragmentOrigin,
                                        attributes: attributes,
                                        context: nil
                                )
                                
                                height = ceil(boundingBox.height) + 24
                        case .identification:
                                height = 80
                        case .website:
                                height = 44
                        }
                case .products:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! ProductRow
                        
                        if row == .product {
                                height = 64
                        } else {
                                height = 44
                        }
                case .tags:
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 5
                        
                        let attributes = [
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                .paragraphStyle: paragraphStyle
                        ]
                        let constraintRect = CGSize(
                                width: tableView.bounds.width - (self.groupedCellMargin * 2) - 40,
                                height: .greatestFiniteMagnitude
                        )
                        let boundingBox = self.brandTagsFormattedString!.boundingRect(
                                with: constraintRect,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes,
                                context: nil
                        )
                        
                        height = ceil(boundingBox.height) + 24
                }
                
                return height
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                var count = 0
                
                if !self.brandIsLoading {
                        let section = self.sectionFor(tableSection: section)
                        
                        switch section {
                        case .header:
                                count = HeaderRow.allCases.count
                                
                                if self.brand.description == nil || self.brand.description!.isEmpty {
                                        count -= 1
                                }
                                
                                if self.brand.website == nil {
                                        count -= 1
                                }
                        case .products:
                                count = (ProductRow.allCases.count - 1) + self.brand.products.count
                                
                                if self.brand.productCount == self.brand.products.count {
                                        count -= 1 // Don't need the row for seeing all products.
                                }
                                
                                if !self.allowsCreationWorkflows {
                                        count -= 1
                                }
                        case .tags:
                                count = TagsRow.allCases.count
                        }
                }
                
                return count
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
                var title: String? = nil
                
                if !self.brandIsLoading {
                        let section = self.sectionFor(tableSection: section)
                        
                        switch section {
                        case .header:
                                break
                        case .products:
                                title = "Products"
                        case .tags:
                                title = "Tags"
                        }
                }
                
                return title
        }
        
        @objc
        private dynamic func userDidCreateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                if product.brandID == self.brand.id {
                        // Refresh.
                        self.brand.productCount += 1
                        
                        if self.brand.products.count < 3 {
                                self.brand.products.append(product)
                        }
                        
                        self.presentBrandInfoView(brand: self.brand)
                }
        }
        
        @objc
        private dynamic func userDidUpdateBrand(_ notification: Notification) {
                let brand = notification.object as! NSOBrand
                
                if brand.id == self.brand.id {
                        // Refresh.
                        self.presentBrandInfoView(brand: brand)
                }
        }
        
        @objc
        private dynamic func userDidUpdateBrandAvatar(_ notification: Notification) {
                let updateResponse = notification.object as! NSOUpdateBrandAvatarResponse
                
                if updateResponse.brandID == self.brand.id {
                        // Refresh.
                        self.brand.avatarLightPath = updateResponse.avatarLightPath
                        self.tableView.reloadData()
                }
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                if self.allowsCreationWorkflows {
                        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.editButton
                }
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.allowsCreationWorkflows
                                && self.editButton == nil {
                                self.editButton = UIBarButtonItem(
                                        title: "Edit",
                                        style: .plain,
                                        target: self,
                                        action: #selector(self.presentBrandEditingViewController)
                                )
                        }
                }
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getBrand()
                }
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
                
                self.navigationItem.largeTitleDisplayMode = .never
        }
}
