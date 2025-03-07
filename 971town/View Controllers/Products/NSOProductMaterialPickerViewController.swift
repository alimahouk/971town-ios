//
//  NSOProductMaterialPickerViewController.swift
//  971town
//
//  Created by Ali Mahouk on 20/03/2023.
//

import API
import UIKit


protocol NSOProductMaterialPickerViewControllerDelegate {
        func materialPickerViewControllerDidFinish(_ viewController: NSOProductMaterialPickerViewController)
        func materialPickerViewControllerDidSelectMaterial(_ viewController: NSOProductMaterialPickerViewController)
}


class NSOProductMaterialPickerViewController: UITableViewController {
        private var cancelButton: UIBarButtonItem?
        private static let tableViewCellIdentifier: String = "ProductMaterialPickerViewControllerCell"
        private var materials: Array<NSOProductMaterial> = []
        private var doneButton: UIBarButtonItem?
        private var lastSelectedIndexPath: IndexPath?
        private var listIsLoading: Bool = true
        private let progressIndicator: UIAlertController
        private var searchController: UISearchController!
        private var searchResultsTableController: ResultsTableController!
        private var viewIsLoaded: Bool = false
        
        public var delegate: NSOProductMaterialPickerViewControllerDelegate?
        public var selectedMaterial: NSOProductMaterial?
        
        init() {
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
                
                self.title = "Materials"
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: NSOProductMaterialPickerViewController.tableViewCellIdentifier)
                
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
        
        @objc
        private dynamic func dismissView() {
                self.navigationController?.dismiss(animated: true)
        }
        
        private func enableFormButtons() {
                self.doneButton?.isEnabled = true
        }
        
        private func getMaterials() {
                self.listIsLoading = true
                self.tableView.reloadData()
                self.navigationController?.present(self.progressIndicator,
                                                   animated: true)
                
                NSOAPI.shared.getProductMaterialList(
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
                                        self.materials = apiResponse.productMaterials
                                        
                                        DispatchQueue.main.async {
                                                self.presentMaterials()
                                        }
                                }
                        }
                )
        }
        
        private func presentMaterials() {
                self.listIsLoading = false
                self.tableView.reloadData()
                self.progressIndicator.dismiss(animated: true)
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.getMaterials()
                        
                        self.viewIsLoaded = true
                }
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
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
                                        action: #selector(self.dismissView)
                                )
                                self.doneButton?.isEnabled = false
                                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.doneButton
                        }
                        
                        self.searchResultsTableController = ResultsTableController(nibName: nil,
                                                                                   bundle: nil)
                        self.searchResultsTableController.tableView.delegate = self
                        
                        self.searchController = UISearchController(searchResultsController: self.searchResultsTableController)
                        self.searchController.delegate = self
                        self.searchController.searchBar.delegate = self
                        self.searchController.searchResultsUpdater = self
                        
                        self.navigationItem.searchController = self.searchController
                        self.navigationItem.hidesSearchBarWhenScrolling = false
                        self.definesPresentationContext = true
                }
        }
        
        override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                
                if self.selectedMaterial != nil {
                        self.delegate?.materialPickerViewControllerDidFinish(self)
                }
        }
}


// MARK: - UITableViewDataSource

extension NSOProductMaterialPickerViewController {
        override func tableView(_ tableView: UITableView,
                                cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: NSOProductMaterialPickerViewController.tableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                let material = self.materials[indexPath.row]
                content.text = material.name
                
                if material == self.selectedMaterial {
                        cell.accessoryType = .checkmark
                } else {
                        cell.accessoryType = .none
                }
                
                cell.contentConfiguration = content
                
                return cell
        }
        
        
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                let count: Int
                
                if self.listIsLoading {
                        count = 0
                } else {
                        count = self.materials.count
                }
                
                return count
        }
}


// MARK: - UITableViewDelegate

extension NSOProductMaterialPickerViewController {
        override func tableView(_ tableView: UITableView,
                                didSelectRowAt indexPath: IndexPath) {
                if tableView === self.tableView {
                        self.selectedMaterial = self.materials[indexPath.row]
                        self.searchResultsTableController.selectedMaterial = self.selectedMaterial
                        
                        tableView.reloadRows(at: [indexPath],
                                             with: .automatic)
                } else {
                        self.selectedMaterial = self.searchResultsTableController.filteredMaterials[indexPath.row]
                        self.searchController.searchBar.text = nil
                        self.searchController.dismiss(animated: true)
                        
                        if let index = self.materials.firstIndex(of: self.selectedMaterial!) {
                                let indexPath = IndexPath(row: index,
                                                          section: 0)
                                self.tableView.reloadRows(at: [indexPath],
                                                          with: .automatic)
                                self.tableView.scrollToRow(
                                        at: indexPath,
                                        at: .middle,
                                        animated: true
                                )
                        }
                }
                
                if let lastIndexPath = self.lastSelectedIndexPath {
                        self.tableView.reloadRows(at: [lastIndexPath],
                                                  with: .automatic)
                }
                
                self.delegate?.materialPickerViewControllerDidSelectMaterial(self)
                self.enableFormButtons()
                tableView.deselectRow(at: indexPath,
                                      animated: true)
                
                if tableView === self.tableView {
                        self.lastSelectedIndexPath = indexPath
                }
        }
}


// MARK: - UISearchBarDelegate

extension NSOProductMaterialPickerViewController: UISearchBarDelegate {
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                searchBar.resignFirstResponder()
        }
        
        func searchBar(_ searchBar: UISearchBar,
                       selectedScopeButtonIndexDidChange selectedScope: Int) {
                updateSearchResults(for: self.searchController)
        }
}


// MARK: - UISearchControllerDelegate

extension NSOProductMaterialPickerViewController: UISearchControllerDelegate {
        func presentSearchController(_ searchController: UISearchController) {
                //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        }
        
        func willPresentSearchController(_ searchController: UISearchController) {
                //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        }
        
        func didPresentSearchController(_ searchController: UISearchController) {
                //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        }
        
        func willDismissSearchController(_ searchController: UISearchController) {
                //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        }
        
        func didDismissSearchController(_ searchController: UISearchController) {
                //Swift.debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        }
}


extension NSOProductMaterialPickerViewController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
                // Update the filtered array based on the search text.
                let searchResults = self.materials
                
                // Strip out all the leading and trailing spaces.
                let strippedString = searchController.searchBar.text!.trimmingCharacters(in: .whitespaces)
                
                let filteredResults = searchResults.filter {
                        $0.name!.localizedStandardContains(strippedString)
                }
                
                // Apply the filtered results to the search results table.
                if let resultsController = searchController.searchResultsController as? ResultsTableController {
                        resultsController.filteredMaterials = filteredResults
                        resultsController.tableView.reloadData()
                }
        }
        
}


class ResultsTableController: UITableViewController {
        private static let tableViewCellIdentifier = "ResultsTableControllerCell"
        
        public var filteredMaterials = [NSOProductMaterial]()
        public var selectedMaterial: NSOProductMaterial?
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.tableView.register(UITableViewCell.self,
                                        forCellReuseIdentifier: ResultsTableController.tableViewCellIdentifier)
        }
        
        // MARK: - UITableViewDataSource
        
        override func tableView(_ tableView: UITableView,
                                numberOfRowsInSection section: Int) -> Int {
                return filteredMaterials.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let material = filteredMaterials[indexPath.row]
                
                let cell = tableView.dequeueReusableCell(withIdentifier: ResultsTableController.tableViewCellIdentifier,
                                                         for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = material.name
                cell.contentConfiguration = content
                
                if material == self.selectedMaterial {
                        cell.accessoryType = .checkmark
                } else {
                        cell.accessoryType = .none
                }
                
                return cell
        }
}
