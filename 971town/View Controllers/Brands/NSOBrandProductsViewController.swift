//
//  NSOBrandProductsViewController.swift
//  971town
//
//  Created by Ali Mahouk on 20/03/2023.
//

import API
import UIKit


class NSOBrandProductsViewController: UITableViewController {
        private var addButton: UIBarButtonItem?
        private let progressIndicator: UIAlertController
        private static let tableViewCellIdentifier: String = "BrandProductTableViewCell"
        private var products: Array<NSOProduct> = []
        private var viewIsLoaded: Bool = false
        
        public var brand: NSOBrand
        
        init(brand: NSOBrand) {
                self.brand = brand
                
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
                
                self.title = "Products"
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOBrandProductsViewController.tableViewCellIdentifier)
                
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
        
        private func getProducts() {
                guard let brandID = self.brand.id else { return }
                
                self.navigationController?.present(self.progressIndicator,
                                                   animated: false)
                
                let request = NSOGetProductsRequest(brandID: brandID)
                NSOAPI.shared.getProducts(
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
                                        self.products = apiResponse.products
                                        
                                        DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                        }
                                }
                        }
                )
        }
        
        @objc
        private func presentNewProductViewController() {
                let product = NSOProduct(
                        brand: self.brand
                )
                
                let productNameViewController = NSOProductNameViewController(product: product)
                let navigationController = UINavigationController(rootViewController: productNameViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        @objc
        private dynamic func userDidCreateProduct(_ notification: Notification) {
                let product = notification.object as! NSOProduct
                
                if product.brandID == self.brand.id {
                        // User added a variant; refresh.
                        self.products.append(product)
                        self.tableView.reloadData()
                        
                        /// Scroll to the row and briefly flash it.
                        let indexPath = IndexPath(row: self.products.count - 1,
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
                                        action: #selector(self.presentNewProductViewController)
                                )
                        }
                }
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getProducts()
                }
                
                if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                        self.tableView.deselectRow(at: selectedIndexPath,
                                                   animated: animated)
                }
                
                self.navigationItem.largeTitleDisplayMode = .never
        }
}


// MARK: - UITableViewDataSource

extension NSOBrandProductsViewController {
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let product = self.products[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOBrandProductsViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + product.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = product.displayName!
                
                cell.accessoryType = .disclosureIndicator
                cell.contentConfiguration = content
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                return self.products.count
        }
}


// MARK: - UITableViewDelegate

extension NSOBrandProductsViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let product = self.products[indexPath.row]
                
                let productViewController = NSOProductViewController(product: product)
                self.navigationController?.pushViewController(productViewController,
                                                              animated: true)
        }
}
