//
//  NSOBrandsViewController.swift
//  971town
//
//  Created by Ali Mahouk on 09/02/2023.
//

import API
import UIKit


class NSOBrandsViewController: UITableViewController {
        private var aboutButton: UIBarButtonItem?
        private var addButton: UIBarButtonItem?
        private var brands: Dictionary<String, Array<NSOBrand>> = [:]
        private let brandCountLabel: UILabel
        private let emptyListMessageLabel: UILabel
        private var sections: Array<String> = []
        private let tableFooterView: UIView
        private static let tableViewCellIdentifier: String = "BrandCell"
        private var viewIsLoaded: Bool = false
        
        override init(nibName nibNameOrNil: String?,
                      bundle nibBundleOrNil: Bundle?) {
                self.brandCountLabel = UILabel()
                self.brandCountLabel.textAlignment = .center
                self.brandCountLabel.textColor = .systemGray
                self.brandCountLabel.translatesAutoresizingMaskIntoConstraints = false
                
                self.emptyListMessageLabel = UILabel()
                self.emptyListMessageLabel.font = .systemFont(ofSize: 18)
                self.emptyListMessageLabel.isHidden = true
                self.emptyListMessageLabel.text = "No Brands Yet"
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
                self.tableFooterView.addSubview(self.brandCountLabel)
                
                super.init(nibName: nibNameOrNil,
                           bundle: nibBundleOrNil)
                
                self.tableView.refreshControl = UIRefreshControl()
                self.tableView.tableFooterView = self.tableFooterView
                self.title = "Brands"
                
                self.tableView.addSubview(self.emptyListMessageLabel)
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOBrandsViewController.tableViewCellIdentifier)
                
                self.tableView.refreshControl?.addTarget(
                        self,
                        action: #selector(self.handleRefresh),
                        for: .valueChanged
                )
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.userDidCreateBrand),
                        name: .NSOCreatedBrand,
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
                        selector: #selector(self.userDidUpdateBrand),
                        name: .NSOUpdatedBrand,
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
                self.aboutButton?.isEnabled = true
                self.addButton?.isEnabled = true
                
                self.getBrands()
        }
        
        @objc
        private dynamic func getBrands(completion: (() -> Void)? = nil) {
                if self.viewIfLoaded?.window != nil {
                        /*
                         * Only animate the refresh control when the view is visible
                         * otherwise the navigation bar vanishes.
                         */
                        self.tableView.refreshControl?.beginRefreshing()
                }
                
                let request = NSOGetBrandsRequest(query: "")
                NSOAPI.shared.getBrands(
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
                                                self.rebuildBrandList(apiResponse.brands)
                                                self.tableView.reloadData()
                                                
                                                completion?()
                                        }
                                }
                        }
                )
        }
        
        @objc
        private dynamic func handleRefresh() {
                self.getBrands()
        }
        
        private func indexPath(forBrand brand: NSOBrand) -> IndexPath? {
                var ret: IndexPath?
                
                if let name = brand.name {
                        let section: String
                        let firstChar = String(name[name.index(name.startIndex, offsetBy: 0)]).uppercased()
                        
                        if firstChar.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
                                section = "#"
                        } else if firstChar.rangeOfCharacter(from: CharacterSet.uppercaseLetters.inverted) == nil {
                                section = firstChar
                        } else {
                                section = "?"
                        }
                        
                        if let brands = self.brands[section],
                           let rowIndex = brands.firstIndex(of: brand),
                           let sectionIndex = self.sections.firstIndex(of: section){
                                ret = IndexPath(row: rowIndex,
                                                section: sectionIndex)
                        }
                }
                
                return ret
        }
        
        @objc
        private dynamic func presentAboutViewController() {
                let aboutViewController = NSOAboutViewController()
                let navigationController = UINavigationController(rootViewController: aboutViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        @objc
        private dynamic func presentNewBrandViewController() {
                let brandNameViewController = NSOBrandNameViewController()
                let navigationController = UINavigationController(rootViewController: brandNameViewController)
                self.navigationController?.present(navigationController,
                                                   animated: true)
        }
        
        private func rebuildBrandList(_ brands: Array<NSOBrand>) {
                self.brands.removeAll()
                self.sections.removeAll()
                
                if brands.isEmpty {
                        self.brandCountLabel.isHidden = true
                        self.emptyListMessageLabel.isHidden = false
                        self.tableView.isScrollEnabled = false
                } else {
                        self.emptyListMessageLabel.isHidden = true
                        self.tableView.isScrollEnabled = true
                        
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        
                        if let formattedCount = numberFormatter.string(from: NSNumber(value: brands.count)) {
                                self.brandCountLabel.isHidden = false
                                self.brandCountLabel.text = "\(formattedCount) brand" + (brands.count == 1 ? "" : "s") + " (so far)"
                        } else {
                                self.brandCountLabel.isHidden = true
                                self.brandCountLabel.text = nil
                        }
                        
                        for brand in brands {
                                guard let name = brand.name else { continue }
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
                                
                                if self.brands[section] == nil {
                                        self.brands[section] = [brand]
                                } else {
                                        self.brands[section]?.append(brand)
                                }
                        }
                        
                        for section in self.brands.keys {
                                self.brands[section]?.sort()
                        }
                        
                        self.sections.sort()
                }
        }
        
        @objc
        private dynamic func resetView() {
                self.brandCountLabel.text = nil
                
                self.brands.removeAll()
                self.sections.removeAll()
                self.tableView.reloadData()
        }
        
        @objc
        private dynamic func userDidCreateBrand(_ notification: Notification) {
                let brand = notification.object as! NSOBrand
                
                // Refresh.
                self.getBrands(completion: {
                        if self.viewIfLoaded?.window != nil {
                                /// Only scroll to the row when the view is visible.
                                if let indexPath = self.indexPath(forBrand: brand) {
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
        private dynamic func userDidUpdateBrand(_ notification: Notification) {
                let brand = notification.object as! NSOBrand
                
                // Refresh.
                self.getBrands(completion: {
                        if self.viewIfLoaded?.window != nil {
                                /// Only scroll to the row when the view is visible.
                                if let indexPath = self.indexPath(forBrand: brand) {
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
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                self.navigationItem.leftBarButtonItem = self.aboutButton
                self.navigationItem.rightBarButtonItem = self.addButton
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.aboutButton == nil {
                                let infoButton = UIButton(type: .infoLight)
                                infoButton.addTarget(
                                        self,
                                        action: #selector(self.presentAboutViewController),
                                        for: .touchUpInside
                                )
                                self.aboutButton = UIBarButtonItem(customView: infoButton)
                                
                                if NSOAPI.shared.currentUserAccount?.alias == nil {
                                        self.aboutButton?.isEnabled = false
                                }
                        }
                        
                        if self.addButton == nil {
                                self.addButton = UIBarButtonItem(
                                        barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(self.presentNewBrandViewController)
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
                                "brandCountLabel": self.brandCountLabel
                        ] as [String : Any]
                        
                        var tableFooterViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|-(12)-[brandCountLabel]-(12)-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: views
                        )
                        tableFooterViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(20)-[brandCountLabel]-(20)-|",
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
                
                if NSOAPI.shared.currentSession != nil {
                        self.getBrands()
                }
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

extension NSOBrandsViewController {
        override func numberOfSections(in tableView: UITableView) -> Int {
                return self.sections.count
        }
        
        override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
                return self.sections
        }
        
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let sectionName = self.sections[indexPath.section]
                let brands = self.brands[sectionName]
                let brand = brands![indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOBrandsViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.secondaryText = NSOAPI.Configuration.mentionSequence + brand.alias!
                content.secondaryTextProperties.color = .systemGray
                content.text = brand.name
                
                cell.accessoryType = .disclosureIndicator
                cell.contentConfiguration = content
                
                return cell
        }
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                let sectionName = self.sections[section]
                let brands = self.brands[sectionName]
                
                return brands!.count
        }
        
        override func tableView(_ tableView: UITableView,
                                titleForHeaderInSection section: Int) -> String? {
                return self.sections[section]
        }
}


// MARK: - UITableViewDelegate

extension NSOBrandsViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                let sectionName = self.sections[indexPath.section]
                let brands = self.brands[sectionName]
                let brand = brands![indexPath.row]
                
                let brandViewController = NSOBrandViewController(brand: brand)
                self.navigationController?.pushViewController(brandViewController,
                                                              animated: true)
        }
}
