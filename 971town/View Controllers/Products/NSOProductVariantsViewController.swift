//
//  NSOProductVariantsViewController.swift
//  971town
//
//  Created by Ali Mahouk on 18/03/2023.
//

import API
import UIKit


class NSOProductVariantsViewController: UITableViewController {
        private var addButton: UIBarButtonItem?
        private let progressIndicator: UIAlertController
        private static let tableViewCellIdentifier: String = "ProductVariantTableViewCell"
        private var variants: Array<NSOProduct> = []
        private var viewIsLoaded: Bool = false
        
        public var product: NSOProduct
        
        init(product: NSOProduct) {
                self.product = product
                
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
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.title = "Variants"
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductVariantsViewController.tableViewCellIdentifier)
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidCreateProduct),
                        name: .NSOCreatedProduct,
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
        
        private func getVariants() {
                guard let parentProductID = self.product.id else { return }
                
                self.navigationController?.present(self.progressIndicator,
                                                   animated: false)
                
                let request = NSOGetProductVariantsRequest(parentProductID: parentProductID)
                NSOAPI.shared.getProductVariants(
                        request: request,
                        responseHandler: { apiResponse, errorResponse, networkError in
                                DispatchQueue.main.async {
                                        self.progressIndicator.dismiss(animated: true)
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
                                        self.variants = apiResponse.productVariants
                                        
                                        DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                        }
                                }
                        }
                )
        }
        
        @objc
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
        private dynamic func userDidCreateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                if product.parentProductID == self.product.id {
                        // Refresh.
                        self.variants.append(product)
                        self.tableView.reloadData()
                        
                        /// Scroll to the row and briefly flash it.
                        let indexPath = IndexPath(row: self.variants.count - 1,
                                                  section: 0)
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
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
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
                                        action: #selector(self.presentNewVariantViewController)
                                )
                        }
                }
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getVariants()
                }
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
                
                self.navigationItem.largeTitleDisplayMode = .never
        }
}


// MARK: - UITableViewDataSource

extension NSOProductVariantsViewController {
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let variant = self.variants[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductVariantsViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + variant.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = variant.displayName
                
                cell.accessoryType = .disclosureIndicator
                cell.contentConfiguration = content
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                return self.variants.count
        }
}


// MARK: - UITableViewDelegate

extension NSOProductVariantsViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let variant = self.variants[indexPath.row]
                
                let productViewController = NSOProductViewController(product: variant)
                self.navigationController?.pushViewController(productViewController,
                                                              animated: true)
        }
}
