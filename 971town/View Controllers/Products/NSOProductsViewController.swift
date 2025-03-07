//
//  NSOProductsViewController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import API
import UIKit


class NSOProductsViewController: UITableViewController {
        private var addButton: UIBarButtonItem?
        private var products: Dictionary<String, Array<NSOProduct>> = [:]
        private let productCountLabel: UILabel
        private let emptyListMessageLabel: UILabel
        private var sections: Array<String> = []
        private let tableFooterView: UIView
        private static let tableViewCellIdentifier: String = "ProductCell"
        private var viewIsLoaded: Bool = false
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                self.productCountLabel = UILabel()
                self.productCountLabel.textAlignment = .center
                self.productCountLabel.textColor = .systemGray
                self.productCountLabel.translatesAutoresizingMaskIntoConstraints = false
                
                self.emptyListMessageLabel = UILabel()
                self.emptyListMessageLabel.font = .systemFont(ofSize: 18)
                self.emptyListMessageLabel.isHidden = true
                self.emptyListMessageLabel.text = "No Products Yet"
                self.emptyListMessageLabel.textAlignment = .center
                self.emptyListMessageLabel.textColor = .systemGray
                self.emptyListMessageLabel.sizeToFit()
                
                self.tableFooterView = UIView(
                        frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 0,
                                height: 50
                        )
                )
                self.tableFooterView.addSubview(self.productCountLabel)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.tableView.refreshControl = UIRefreshControl()
                self.tableView.tableFooterView = self.tableFooterView
                self.title = "Products"
                
                self.tableView.addSubview(self.emptyListMessageLabel)
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductsViewController.tableViewCellIdentifier)
                
                self.tableView.refreshControl?.addTarget(
                        self,
                        action: #selector(self.handleRefresh),
                        for: .valueChanged
                )
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidCreateProduct),
                        name: .NSOCreatedProduct,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.didFetchCurrentUserAccount),
                        name: .NSOCurrentUserAccountFetched,
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
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.didFetchCurrentUserAccount),
                        name: .NSOUserAccountJoined,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.resetView),
                        name: .NSOUserAccountKickedOut,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.didFetchCurrentUserAccount),
                        name: .NSOUserAccountLoggedIn,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.resetView),
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
        
        @objc
        private dynamic func didFetchCurrentUserAccount() {
                self.addButton?.isEnabled = true
                
                if self.products.isEmpty {
                        self.getProducts()
                }
        }
        
        @objc
        private dynamic func getProducts(completion: (() -> Void)? = nil) {
                if self.viewIfLoaded?.window != nil {
                        /*
                         * Only animate the refresh control when the view is visible
                         * otherwise the navigation bar vanishes.
                         */
                        self.tableView.refreshControl?.beginRefreshing()
                }
                
                let request = NSOGetProductsRequest(query: "")
                NSOAPI.shared.getProducts(
                        request: request,
                        responseHandler: { apiResponse, errorResponse, networkError in
                                DispatchQueue.main.async {
                                        if self.tableView.refreshControl!.isRefreshing {
                                                self.tableView.refreshControl?.endRefreshing()
                                        }
                                }
                                
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
                                                                style: .default
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
                                                                style: .default
                                                        )
                                                )
                                                self.navigationController?.present(alert,
                                                                                   animated: true)
                                        }
                                } else if let apiResponse = apiResponse {
                                        DispatchQueue.main.async {
                                                self.rebuildProductList(apiResponse.products)
                                                self.tableView.reloadData()
                                                
                                                completion?()
                                        }
                                }
                        }
                )
        }
        
        @objc
        private dynamic func handleRefresh() {
                self.getProducts()
        }

        
        private func indexPath(forProduct product: NSOProduct) -> IndexPath? {
                var ret: IndexPath?
                
                if let name = product.displayName {
                        let section: String
                        let firstChar = String(name[name.index(name.startIndex, offsetBy: 0)]).uppercased()
                        
                        if firstChar.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
                                section = "#"
                        } else if firstChar.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil {
                                section = firstChar
                        } else {
                                section = "?"
                        }
                        
                        if let products = self.products[section],
                           let rowIndex = products.firstIndex(of: product),
                           let sectionIndex = self.sections.firstIndex(of: section) {
                                ret = IndexPath(row: rowIndex,
                                                section: sectionIndex)
                        }
                }
                
                return ret
        }
        
        private func indexPath(forProduct productID: Int) -> IndexPath? {
                var ret: IndexPath?
                
                for (i, section) in self.sections.enumerated() {
                        if let products = self.products[section] {
                                for (j, product) in products.enumerated() {
                                        if product.id == productID {
                                                ret = IndexPath(row: j,
                                                                section: i)
                                                
                                                break
                                        }
                                }
                        }
                        
                        if ret != nil {
                                break
                        }
                }
                
                return ret
        }
        
        @objc
        private dynamic func presentNewProductViewController() {
                let productCreationViewController = NSOProductCreationWorkflowViewController()
                let navigationController = UINavigationController(rootViewController: productCreationViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        private func rebuildProductList(_ products: Array<NSOProduct>) {
                self.products.removeAll()
                self.sections.removeAll()
                
                if products.isEmpty {
                        self.productCountLabel.isHidden = true
                        self.emptyListMessageLabel.isHidden = false
                        self.tableView.isScrollEnabled = false
                } else {
                        self.emptyListMessageLabel.isHidden = true
                        self.tableView.isScrollEnabled = true
                        
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        
                        if let formattedCount = numberFormatter.string(from: NSNumber(value: products.count)) {
                                self.productCountLabel.isHidden = false
                                self.productCountLabel.text = "\(formattedCount) product" + (products.count == 1 ? "" : "s") + " (so far)"
                        } else {
                                self.productCountLabel.isHidden = true
                                self.productCountLabel.text = nil
                        }
                        
                        for product in products {
                                guard let name = product.displayName else { continue }
                                guard !name.isEmpty else { continue }
                                
                                let firstChar = String(name[name.index(name.startIndex, offsetBy: 0)]).uppercased()
                                let section: String
                                
                                if firstChar.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
                                        section = "#"
                                } else if firstChar.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil {
                                        section = firstChar
                                } else {
                                        section = "?"
                                }
                                
                                if !self.sections.contains(section) {
                                        self.sections.append(section)
                                }
                                
                                if self.products[section] == nil {
                                        self.products[section] = [product]
                                } else {
                                        self.products[section]?.append(product)
                                }
                        }
                        
                        for section in self.products.keys {
                                self.products[section]?.sort()
                        }
                        
                        self.sections.sort()
                }
        }
        
        @objc
        private dynamic func resetView() {
                self.productCountLabel.text = nil
                
                self.products.removeAll()
                self.sections.removeAll()
                self.tableView.reloadData()
        }
        
        @objc
        private dynamic func userDidCreateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                // Refresh.
                self.getProducts(completion: {
                        if self.viewIfLoaded?.window != nil {
                                /// Only scroll to the row when the view is visible.
                                if let indexPath = self.indexPath(forProduct: product) {
                                        /// Scroll to the row and briefly flash it.
                                        self.tableView.selectRow(
                                                at: indexPath,
                                                animated: true,
                                                scrollPosition: .middle
                                        )
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                self.tableView.deselectRow(at: indexPath,
                                                                           animated: true)
                                        }
                                }
                        }
                })
        }
        
        @objc
        private dynamic func userDidUpdateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                // Refresh.
                self.getProducts(completion: {
                        if self.viewIfLoaded?.window != nil {
                                /// Only scroll to the row when the view is visible.
                                if let indexPath = self.indexPath(forProduct: product) {
                                        /// Scroll to the row and briefly flash it.
                                        self.tableView.selectRow(
                                                at: indexPath,
                                                animated: true,
                                                scrollPosition: .middle
                                        )
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                                self.tableView.deselectRow(at: indexPath,
                                                                           animated: true)
                                        }
                                }
                        }
                })
        }
        
        @objc
        private dynamic func userDidUpdateProductMedia(_ notification: Notification) {
                let response = notification.object as! NSOUpdateProductMediaResponse
                
                if let indexPath = self.indexPath(forProduct: response.productID) {
                        let sectionName = self.sections[indexPath.section]
                        let products = self.products[sectionName]
                        let product = products![indexPath.row]
                        product.media = response.media
                }
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.productCountLabel.isHidden = true
                        
                        if self.products.isEmpty {
                                self.getProducts()
                        }
                        
                        self.viewIsLoaded = true
                }
                
                self.navigationItem.rightBarButtonItem = self.addButton
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.addButton == nil {
                                self.addButton = UIBarButtonItem(
                                        barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(self.presentNewProductViewController)
                                )
                                
                                if NSOAPI.shared.currentUserAccount?.alias == nil {
                                        self.addButton?.isEnabled = false
                                }
                        }
                        
                        self.emptyListMessageLabel.frame.origin = CGPoint(
                                x: (self.view.bounds.width / 2) - (self.emptyListMessageLabel.bounds.width / 2),
                                y: (self.view.bounds.height / 2) - (self.emptyListMessageLabel.bounds.height / 2) - (self.view.safeAreaInsets.top / 2)
                        )
                        
                        let views = [
                                "productCountLabel": self.productCountLabel
                        ] as [String : Any]
                        
                        var tableFooterViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|-(12)-[productCountLabel]-(12)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        tableFooterViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[productCountLabel]-(20)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        
                        self.tableFooterView.addConstraints(tableFooterViewConstraints)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
        }
}


// MARK: - UITableViewDataSource

extension NSOProductsViewController {
        override func numberOfSections(in tableView: UITableView) -> Int {
                return self.sections.count
        }
        
        override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
                return self.sections
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let sectionName = self.sections[indexPath.section]
                let products = self.products[sectionName]
                let product = products![indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductsViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + product.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = product.displayName
                
                cell.accessoryType = .disclosureIndicator
                cell.contentConfiguration = content
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                let sectionName = self.sections[section]
                let products = self.products[sectionName]
                
                return products!.count
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
                return self.sections[section]
        }
}


// MARK: - UITableViewDelegate

extension NSOProductsViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let sectionName = self.sections[indexPath.section]
                let products = self.products[sectionName]
                let product = products![indexPath.row]
                
                let productViewController = NSOProductViewController(product: product)
                self.navigationController?.pushViewController(productViewController,
                                                              animated: true)
        }
}
