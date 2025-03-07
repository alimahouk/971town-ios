//
//  NSOProductViewController.swift
//  971town
//
//  Created by Ali Mahouk on 16/03/2023.
//

import API
import SDWebImage
import UIKit


class NSOProductViewController: UITableViewController {
        private enum BrandRow: Int,
                               CaseIterable {
                case brand
        }
        
        private enum HeaderRow: Int,
                                CaseIterable {
                case identification // Contains the name and alias.
                case url
                case description
        }
        
        private enum MainColorRow: Int,
                                   CaseIterable {
                case mainColor
        }
        
        private enum MaterialRow: Int,
                                  CaseIterable {
                case material
        }
        
        private enum ParentProductRow: Int,
                                       CaseIterable {
                case parentProduct
        }
        
        private enum ProduceImageRow: Int,
                                      CaseIterable {
                case images
        }
        
        private enum ReleaseTimestampRow: Int,
                                          CaseIterable {
                case releaseTimestamp
        }
        
        private enum TagsRow: Int,
                              CaseIterable {
                case tags
        }
        
        private enum UPCRow: Int,
                             CaseIterable {
                case upc
        }
        
        private enum VariantRow: Int,
                                 CaseIterable {
                case productVariant
                case allProductVariants
                case addProductVariant
        }
        
        private enum Section: Int,
                              CaseIterable {
                case brand
                case header
                case mainColor
                case material
                case parentProduct
                case productImages
                case releaseTimestamp
                case tags
                case upc
                case variants
        }
        
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
        private var editButton: UIBarButtonItem?
        private let imageCarouselHeaderView: NSOImageCarouselView
        private let productCreationLabel: UILabel
        private var productIsLoading: Bool = true
        private var productMainColorView: UIStackView
        private let productMainColorLabel: UILabel
        private let productMainColorThumbnailView: UIView
        private var productTagsFormattedString: String?
        private let progressIndicator: UIAlertController
        private let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
        private static let tableViewCellIdentifier: String = "ProductTableViewCell"
        private var viewIsLoaded: Bool = false
        
        public var allowsCreationWorkflows: Bool = true
        public var product: NSOProduct
        
        
        init(product: NSOProduct) {
                self.product = product
                
                self.imageCarouselHeaderView = NSOImageCarouselView()
                self.imageCarouselHeaderView.isUserInteractionEnabled = true
                self.imageCarouselHeaderView.translatesAutoresizingMaskIntoConstraints = false
                
                self.productCreationLabel = UILabel()
                self.productCreationLabel.font = .systemFont(ofSize: 14)
                self.productCreationLabel.numberOfLines = 0
                self.productCreationLabel.textColor = .systemGray
                
                self.productMainColorLabel = UILabel()
                self.productMainColorLabel.numberOfLines = 0
                self.productMainColorLabel.setContentHuggingPriority(.defaultLow,
                                                                     for: .horizontal)
                self.productMainColorLabel.setContentHuggingPriority(.defaultLow,
                                                                     for: .vertical)
                
                self.productMainColorThumbnailView = UIView()
                self.productMainColorThumbnailView.layer.borderColor = UIColor.systemGray4.cgColor
                self.productMainColorThumbnailView.layer.borderWidth = 0.5
                self.productMainColorThumbnailView.layer.cornerRadius = 10
                self.productMainColorThumbnailView.layer.masksToBounds = true
                self.productMainColorThumbnailView.translatesAutoresizingMaskIntoConstraints = false
                self.productMainColorThumbnailView.setContentHuggingPriority(.defaultHigh,
                                                                             for: .horizontal)
                self.productMainColorThumbnailView.setContentHuggingPriority(.defaultHigh,
                                                                             for: .vertical)
                
                self.productMainColorView = UIStackView()
                self.productMainColorView.alignment = .center
                self.productMainColorView.axis = .horizontal
                self.productMainColorView.spacing = 15
                self.productMainColorView.translatesAutoresizingMaskIntoConstraints = false
                self.productMainColorView.setContentHuggingPriority(.defaultLow,
                                                                    for: .vertical)
                
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
                
                self.productMainColorView.addArrangedSubview(self.productMainColorThumbnailView)
                self.productMainColorView.addArrangedSubview(self.productMainColorLabel)

                super.init(style: .insetGrouped)
                
                self.view.tintAdjustmentMode = .normal
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductViewController.tableViewCellIdentifier)
                
                self.imageCarouselHeaderView.editButton.addTarget(
                        self,
                        action: #selector(presentProductMediaEditingViewController),
                        for: .touchUpInside
                )
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidCreateProduct),
                        name: .NSOCreatedProduct,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidUpdateProduct),
                        name: .NSOUpdatedProduct,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidUpdateProductMedia),
                        name: .NSOUpdatedProductMedia,
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
        
        private func dismissProductInfoView() {
                self.editButton?.isEnabled = false
                self.productIsLoading = true
                self.tableView.separatorStyle = .none
                
                self.tableView.reloadData()
        }
        
        private func getProduct() {
                self.dismissProductInfoView()
                self.navigationController?.present(self.progressIndicator,
                                                   animated: false)
                
                let request = NSOGetProductRequest(productID: self.product.id)
                NSOAPI.shared.getProduct(
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
                                                let product = apiResponse.product
                                                self.presentProductInfoView(product: product)
                                                self.presentProductMedia(product.media)
                                        }
                                }
                        }
                )
        }
        
        private func presentNewVariantViewController() {
                let product = NSOProduct(
                        brand: self.product.brand,
                        parentProduct: self.product,
                        parentProductID: self.product.id
                )
                
                let productNameViewController = NSOProductNameViewController(product: product)
                let navigationController = UINavigationController(rootViewController: productNameViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        @objc
        private dynamic func presentProductEditingViewController() {
                let editingViewController = NSOProductEditingViewController(product: self.product)
                let navigationController = UINavigationController(rootViewController: editingViewController)
                navigationController.presentationController?.delegate = editingViewController
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        private func presentProductInfoView(product: NSOProduct) {
                if product.id == self.product.id {
                        self.editButton?.isEnabled = true
                        self.productIsLoading = false
                        self.tableView.separatorStyle = .singleLine
                        
                        self.progressIndicator.dismiss(animated: true)
                        
                        // Refresh.
                        self.product.alias = product.alias
                        self.product.brand = product.brand
                        self.product.brandID = product.brandID
                        self.product.creationTimestamp = product.creationTimestamp
                        self.product.creator = product.creator
                        self.product.creatorID = product.creatorID
                        self.product.description = product.description
                        self.product.editAccessLevel = product.editAccessLevel
                        self.product.name = product.name
                        self.product.mainColor = product.mainColor
                        self.product.material = product.material
                        self.product.overridesDisplayName = product.overridesDisplayName
                        self.product.parentProduct = product.parentProduct
                        self.product.parentProductID = product.parentProductID
                        self.product.preorderTimestamp = product.preorderTimestamp
                        self.product.releaseTimestamp = product.releaseTimestamp
                        self.product.status = product.status
                        self.product.tags = product.tags
                        self.product.upc = product.upc
                        self.product.url = product.url
                        self.product.variantCount = product.variantCount
                        self.product.variants = product.variants
                        self.product.visibility = product.visibility
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.calendar = Calendar.current
                        dateFormatter.dateFormat = "h:mm a 'on' MMMM d, yyyy"
                        dateFormatter.timeZone = .current
                        
                        if let mainColor = self.product.mainColor {
                                self.productMainColorLabel.text = mainColor.name
                                self.productMainColorThumbnailView.backgroundColor = UIColor(hex: mainColor.hex)
                        } else {
                                self.productMainColorLabel.text = nil
                                self.productMainColorThumbnailView.backgroundColor = .clear
                        }
                        
                        if let creatorALias = self.product.creator?.alias {
                                self.productCreationLabel.text = "Added by \(NSOAPI.Configuration.mentionSequence)\(creatorALias) at \(dateFormatter.string(from: self.product.creationTimestamp!))"
                        } else {
                                self.productCreationLabel.text = "Added at \(dateFormatter.string(from: self.product.creationTimestamp!))"
                        }
                        
                        if !self.product.tags.isEmpty {
                                self.productTagsFormattedString = self.product.tags.map({$0.name!}).joined(separator: ", ")
                        } else {
                                self.productTagsFormattedString = nil
                        }
                        
                        let productCreationLabelSize = self.productCreationLabel.sizeThatFits(
                                CGSize(
                                        width: self.tableView.bounds.width - 80,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.productCreationLabel.frame = CGRect(
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
                                        height: self.productCreationLabel.bounds.height + 10
                                )
                        )
                        tableFooterView.addSubview(self.productCreationLabel)
                        self.tableView.tableFooterView = tableFooterView
                        
                        self.tableView.reloadData()
                }
        }
        
        private func presentProductMedia(_ media: [NSOProductMedium]) {
                for medium in media {
                        medium.mediaFormat = .jpg
                }
                        
                self.product.media = media
                
                // Sort in ascending order of index.
                self.product.media.sort()
                
                // Set up the header view.
                self.imageCarouselHeaderView.urls = self.product.media.map({ $0.fileURL! })
        }
        
        @objc
        private dynamic func presentProductMediaEditingViewController() {
                let productImageViewController = NSORearrangeableImageCarouselViewController(product: self.product)
                let navigationController = UINavigationController(rootViewController: productImageViewController)
                navigationController.presentationController?.delegate = productImageViewController
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        private func rowFor(tableRow: Int,
                            inSection section: Section) -> Any? {
                var row: Any? = nil
                
                switch section {
                case .brand:
                        row = BrandRow.brand
                case .header:
                        switch tableRow {
                        case 0:
                                row = HeaderRow.identification
                        case 1:
                                if self.product.displayURL != nil {
                                        row = HeaderRow.url
                                } else if self.product.displayDescription != nil {
                                        row = HeaderRow.description
                                }
                        case 2:
                                row = HeaderRow.description
                        default:
                                break
                        }
                case .mainColor:
                        row = MainColorRow.mainColor
                case .material:
                        row = MaterialRow.material
                case .parentProduct:
                        row = ParentProductRow.parentProduct
                case .productImages:
                        row = ProduceImageRow.images
                case .releaseTimestamp:
                        row = ReleaseTimestampRow.releaseTimestamp
                case .tags:
                        row = TagsRow.tags
                case .upc:
                        row = UPCRow.upc
                case .variants:
                        if self.product.variantCount > self.product.variants.count {
                                if tableRow == self.product.variants.count {
                                        row = VariantRow.allProductVariants
                                } else if tableRow == self.product.variants.count + 1 {
                                        row = VariantRow.addProductVariant
                                } else {
                                        row = VariantRow.productVariant
                                }
                        } else {
                                if tableRow == self.product.variants.count {
                                        row = VariantRow.addProductVariant
                                } else {
                                        row = VariantRow.productVariant
                                }
                        }
                }
                
                return row
        }
        
        private func sectionFor(tableSection: Int) -> Section {
                var visibleSections: Array<Section> = [
                        .productImages,
                        .header,
                        .brand
                ]
                
                if self.product.mainColor != nil {
                        visibleSections.append(.mainColor)
                }
                
                if self.product.material != nil {
                        visibleSections.append(.material)
                }
                
                if self.product.parentProduct != nil {
                        visibleSections.append(.parentProduct)
                }
                
                visibleSections.append(.variants)
                
                if self.product.releaseTimestamp != nil {
                        visibleSections.append(.releaseTimestamp)
                }
                
                if self.product.upc != nil {
                        visibleSections.append(.upc)
                }
                
                if !self.product.tags.isEmpty {
                        visibleSections.append(.tags)
                }
                
                return visibleSections[tableSection]
        }
        
        @objc
        private dynamic func userDidCreateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                if product.parentProductID == self.product.id {
                        // User added a variant; refresh.
                        self.product.variantCount += 1
                        
                        if self.product.variants.count < 3 {
                                self.product.variants.append(product)
                        }
                        
                        self.presentProductInfoView(product: self.product)
                }
        }
        
        @objc
        private dynamic func userDidUpdateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                if product.id == self.product.id {
                        // Refresh.
                        self.presentProductInfoView(product: product)
                }
        }
        
        @objc
        private dynamic func userDidUpdateProductMedia(_ notification: Notification) {
                let response = notification.object as! NSOUpdateProductMediaResponse
                
                if response.productID == self.product.id {
                        // Refresh.
                        self.presentProductMedia(response.media)
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
                                        action: #selector(self.presentProductEditingViewController)
                                )
                        }
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getProduct()
                }
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
                
                self.navigationItem.largeTitleDisplayMode = .never
        }
}


// MARK: - UITableViewDataSource

extension NSOProductViewController {
        override func numberOfSections(in tableView: UITableView) -> Int {
                var count = Section.allCases.count
                
                if self.product.mainColor == nil {
                        count -= 1
                }
                
                if self.product.material == nil {
                        count -= 1
                }
                
                if self.product.parentProduct == nil {
                        count -= 1
                }
                
                if self.product.releaseTimestamp == nil {
                        count -= 1
                }
                
                if self.product.tags.isEmpty {
                        count -= 1
                }
                
                if self.product.upc == nil {
                        count -= 1
                }
                
                return count
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let section = self.sectionFor(tableSection: indexPath.section)
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                // Reset the cell in prep for each type of row.
                cell.accessoryType = .none
                cell.contentConfiguration = nil
                cell.selectionStyle = .none
                
                for subview in cell.contentView.subviews {
                        subview.removeFromSuperview()
                }
                
                switch section {
                case .brand:
                        if let brand = self.product.brand {
                                var content = cell.defaultContentConfiguration()
                                content.imageProperties.cornerRadius = self.softRoundCornerRadius
                                content.secondaryText = NSOAPI.Configuration.mentionSequence + brand.alias!
                                content.secondaryTextProperties.color = .systemGray
                                content.text = brand.name
                                
                                if brand.avatarLightPath != nil {
                                        SDWebImageManager.shared.loadImage(
                                                with: brand.avatarLightURL,
                                                options: .continueInBackground,
                                                progress: nil,
                                                completed: { [weak self] (image, data, error, cacheType, finished, url) in
                                                        guard self != nil else { return }
                                                        
                                                        if let error = error {
                                                                print(error)
                                                                
                                                                return
                                                        }
                                                        
                                                        guard let image = image else { return }
                                                        self?.product.brand?.avatar = image
                                                        content.image = image
                                                        cell.contentConfiguration = content
                                                }
                                        )
                                } else {
                                        self.product.brand?.avatar = nil
                                        content.image = nil
                                }
                                
                                cell.accessoryType = .disclosureIndicator
                                cell.contentConfiguration = content
                                cell.selectionStyle = .default
                        }
                case .header:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! HeaderRow
                        
                        switch row {
                        case .identification:
                                var content = cell.defaultContentConfiguration()
                                content.image = nil
                                content.secondaryText = NSOAPI.Configuration.mentionSequence + self.product.alias!
                                content.secondaryTextProperties.color = .systemGray
                                content.text = self.product.displayName
                                content.textProperties.font = .boldSystemFont(ofSize: 18)
                                
                                cell.contentConfiguration = content
                        case .description:
                                let paragraphStyle = NSMutableParagraphStyle()
                                paragraphStyle.lineSpacing = 5
                                
                                let attributes = [
                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                        .paragraphStyle: paragraphStyle
                                ]
                                
                                let attributedString = NSMutableAttributedString(string: self.product.displayDescription!)
                                attributedString.setAttributes(attributes,
                                                               range: NSMakeRange(0, attributedString.length))
                                
                                var content = cell.defaultContentConfiguration()
                                content.attributedText = attributedString
                                
                                cell.contentConfiguration = content
                        case .url:
                                if let url = self.product.displayURL {
                                        var urlString = url.host!
                                        
                                        if !url.path.isEmpty && url.path != "/" {
                                                urlString += url.path
                                        }
                                        
                                        var content = cell.defaultContentConfiguration()
                                        content.image = UIImage(systemName: "link")
                                        content.text = urlString
                                        content.textProperties.color = self.view.tintColor
                                        
                                        cell.contentConfiguration = content
                                        cell.selectionStyle = .default
                                }
                        }
                case .mainColor:
                        cell.contentView.addSubview(self.productMainColorView)
                        
                        let cellViews = [
                                "productMainColorLabel": self.productMainColorLabel,
                                "productMainColorThumbnailView": self.productMainColorThumbnailView,
                                "productMainColorView": self.productMainColorView
                        ] as [String : Any]
                        
                        var productMainColorThumbnailViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:[productMainColorThumbnailView(==20)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        productMainColorThumbnailViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:[productMainColorThumbnailView(==20)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        self.productMainColorView.addConstraints(productMainColorThumbnailViewConstraints)
                        
                        var productMainColorViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[productMainColorView]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        productMainColorViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[productMainColorView]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(productMainColorViewConstraints)
                case .material:
                        var content = cell.defaultContentConfiguration()
                        content.text = self.product.material?.name
                        
                        cell.contentConfiguration = content
                case .parentProduct:
                        var content = cell.defaultContentConfiguration()
                        content.secondaryText = NSOAPI.Configuration.mentionSequence + self.product.parentProduct!.alias!
                        content.secondaryTextProperties.color = .systemGray
                        content.text = self.product.parentProduct!.displayName
                        
                        cell.accessoryType = .disclosureIndicator
                        cell.contentConfiguration = content
                        cell.selectionStyle = .default
                case .productImages:
                        cell.contentView.addSubview(self.imageCarouselHeaderView)
                        
                        let cellViews = [
                                "imageCarouselHeaderView": self.imageCarouselHeaderView
                        ] as [String : Any]
                        
                        var cellConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|[imageCarouselHeaderView]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cellConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|[imageCarouselHeaderView]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(cellConstraints)
                        
                        self.imageCarouselHeaderView.layoutIfNeeded()
                case .releaseTimestamp:
                        var content = cell.defaultContentConfiguration()
                        
                        let calendar = Calendar.current
                        let dateFormatter = DateFormatter()
                        dateFormatter.calendar = calendar
                        
                        let dateComponents = calendar.dateComponents(in: TimeZone(abbreviation: "UTC")!,
                                                                     from: self.product.releaseTimestamp!)
                        
                        if dateComponents.hour != 0 || dateComponents.minute != 0 {
                                dateFormatter.dateFormat = "h:mm a 'on' MMMM d, yyyy"
                                content.image = UIImage(systemName: "calendar.badge.clock")
                        } else {
                                dateFormatter.dateFormat = "MMMM d, yyyy"
                                content.image = UIImage(systemName: "calendar")
                        }
                        
                        content.text = dateFormatter.string(from: self.product.releaseTimestamp!)
                        
                        cell.contentConfiguration = content
                case .tags:
                        let paragraphStyle = NSMutableParagraphStyle()
                        paragraphStyle.lineSpacing = 5
                        
                        let attributes = [
                                NSAttributedString.Key.font: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                .paragraphStyle: paragraphStyle
                        ]
                        
                        let attributedString = NSMutableAttributedString(string: self.productTagsFormattedString!)
                        attributedString.setAttributes(attributes,
                                                       range: NSMakeRange(0, attributedString.length))
                        
                        var content = cell.defaultContentConfiguration()
                        content.attributedText = attributedString
                        
                        cell.contentConfiguration = content
                case .upc:
                        var content = cell.defaultContentConfiguration()
                        content.image = UIImage(systemName: "barcode.viewfinder")
                        content.text = self.product.upc
                        content.textProperties.font = .monospacedSystemFont(ofSize: 18,
                                                                            weight: .regular)
                        
                        cell.contentConfiguration = content
                case .variants:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! VariantRow
                        var content = cell.defaultContentConfiguration()
                        
                        switch row {
                        case .addProductVariant:
                                content.image = UIImage(systemName: "plus.square.on.square")
                                content.text = "Add Variant"
                                content.textProperties.color = self.view.tintColor
                                
                                cell.selectionStyle = .default
                        case .allProductVariants:
                                content.image = UIImage(systemName: "square.on.square")
                                content.text = "All Variants"
                                
                                let numberFormatter = NumberFormatter()
                                numberFormatter.numberStyle = .decimal
                                
                                if let formattedCount = numberFormatter.string(from: NSNumber(value: self.product.variantCount)) {
                                        content.prefersSideBySideTextAndSecondaryText = true
                                        content.secondaryText = formattedCount
                                        content.secondaryTextProperties.color = .systemGray
                                        content.secondaryTextProperties.font = .systemFont(ofSize: UIFont.labelFontSize)
                                }
                                
                                cell.accessoryType = .disclosureIndicator
                                cell.selectionStyle = .default
                        case .productVariant:
                                let variant = self.product.variants[indexPath.row]
                                
                                content.secondaryText = NSOAPI.Configuration.mentionSequence + variant.alias!
                                content.secondaryTextProperties.color = .systemGray
                                content.text = variant.displayName
                                
                                cell.accessoryType = .disclosureIndicator
                                cell.selectionStyle = .default
                        }
                        
                        cell.contentConfiguration = content
                }
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                heightForRowAt indexPath: IndexPath) -> CGFloat {
                var height: CGFloat = 0
                let section = self.sectionFor(tableSection: indexPath.section)
                
                switch section {
                case .brand:
                        height = 80
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
                                let boundingBox = self.product.displayDescription!.boundingRect(
                                        with: constraintRect,
                                        options: .usesLineFragmentOrigin,
                                        attributes: attributes,
                                        context: nil
                                )
                                
                                height = ceil(boundingBox.height) + 24
                        case .identification:
                                height = 80
                        case .url:
                                height = 44
                        }
                case .mainColor:
                        height = 44
                case .material:
                        height = 44
                case .parentProduct:
                        height = 80
                case .productImages:
                        height = tableView.bounds.width - 40 // Make it a square.
                case .releaseTimestamp:
                        height = 44
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
                        let boundingBox = self.productTagsFormattedString!.boundingRect(
                                with: constraintRect,
                                options: .usesLineFragmentOrigin,
                                attributes: attributes,
                                context: nil
                        )
                        
                        height = ceil(boundingBox.height) + 24
                case .upc:
                        height = 44
                case .variants:
                        let row = self.rowFor(tableRow: indexPath.row,
                                              inSection: section) as! VariantRow
                        
                        if row == .productVariant {
                                height = 64
                        } else {
                                height = 44
                        }
                }
                
                return height
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                var count = 0
                
                if !self.productIsLoading {
                        let section = self.sectionFor(tableSection: section)
                        
                        switch section {
                        case .brand:
                                count = BrandRow.allCases.count
                        case .header:
                                count = HeaderRow.allCases.count
                                
                                if self.product.displayDescription == nil || self.product.displayDescription!.isEmpty {
                                        count -= 1
                                }
                                
                                if self.product.displayURL == nil {
                                        count -= 1
                                }
                        case .mainColor:
                                count = MainColorRow.allCases.count
                        case .material:
                                count = MaterialRow.allCases.count
                        case .parentProduct:
                                count = ParentProductRow.allCases.count
                        case .productImages:
                                count = ProduceImageRow.allCases.count
                        case .releaseTimestamp:
                                count = ReleaseTimestampRow.allCases.count
                        case .tags:
                                count = TagsRow.allCases.count
                        case .upc:
                                count = UPCRow.allCases.count
                        case .variants:
                                count = (VariantRow.allCases.count - 1) + self.product.variants.count
                                
                                if self.product.variantCount == self.product.variants.count {
                                        count -= 1 // Don't need the row for seeing all variants.
                                }
                                
                                if !self.allowsCreationWorkflows {
                                        count -= 1
                                }
                        }
                }
                
                return count
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
                var title: String? = nil
                
                if !self.productIsLoading {
                        let section = self.sectionFor(tableSection: section)
                        
                        switch section {
                        case .brand:
                                title = "Brand"
                        case .header:
                                break
                        case .mainColor:
                                title = "Main Color"
                        case .material:
                                title = "Material"
                        case .upc:
                                title = "Universal Product Code (UPC)"
                        case .parentProduct:
                                title = "Variant Of"
                        case .productImages:
                                break
                        case .releaseTimestamp:
                                title = "Release Date"
                        case .variants:
                                title = "Variants"
                        case .tags:
                                title = "Tags"
                        }
                }
                
                return title
        }
}


// MARK: - UITableViewDelegate

extension NSOProductViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let section = self.sectionFor(tableSection: indexPath.section)
                
                switch section {
                case .brand:
                        if let brand = self.product.brand {
                                let brandViewController = NSOBrandViewController(brand: brand)
                                self.navigationController?.pushViewController(brandViewController,
                                                                              animated: true)
                        }
                case .header:
                        let row = rowFor(tableRow: indexPath.row,
                                         inSection: section) as! HeaderRow
                        
                        if row == .url {
                                if UIApplication.shared.canOpenURL(self.product.url!) {
                                        UIApplication.shared.open(self.product.url!,
                                                                  options: [:],
                                                                  completionHandler: nil)
                                }
                                
                                self.tableView.deselectRow(at: indexPath,
                                                           animated: true)
                        }
                case .mainColor:
                        break
                case .material:
                        break
                case .parentProduct:
                        if let parentProduct = self.product.parentProduct {
                                let productViewController = NSOProductViewController(product: parentProduct)
                                self.navigationController?.pushViewController(productViewController,
                                                                              animated: true)
                        }
                case .productImages:
                        break
                case .releaseTimestamp:
                        break
                case .tags:
                        break
                case .upc:
                        break
                case .variants:
                        let row = rowFor(tableRow: indexPath.row,
                                         inSection: section) as! VariantRow
                        
                        switch row {
                        case .addProductVariant:
                                self.presentNewVariantViewController()
                                self.tableView.deselectRow(at: indexPath,
                                                           animated: false)
                        case .allProductVariants:
                                let variantsViewController = NSOProductVariantsViewController(product: self.product)
                                self.navigationController?.pushViewController(variantsViewController,
                                                                              animated: true)
                        case .productVariant:
                                let variant = self.product.variants[indexPath.row]
                                let productViewController = NSOProductViewController(product: variant)
                                self.navigationController?.pushViewController(productViewController,
                                                                              animated: true)
                        }
                }
        }
}
