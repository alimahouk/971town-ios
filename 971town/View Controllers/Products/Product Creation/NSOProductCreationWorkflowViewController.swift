//
//  NSOProductCreationWorkflowViewController.swift
//  971town
//
//  Created by Ali Mahouk on 13/03/2023.
//

import API
import UIKit

class NSOProductCreationWorkflowViewController: UIViewController {
        private var cancelButton: UIBarButtonItem?
        private let optionsView: UIStackView
        private let productOptionButton: UIButton
        private let productVariantOptionButton: UIButton
        private var viewIsLoaded: Bool = false
        
        init() {
                self.optionsView = UIStackView()
                self.optionsView.axis = .vertical
                self.optionsView.distribution = .fillEqually
                self.optionsView.spacing = 5
                
                var productOptionButtonConfig = UIButton.Configuration.gray()
                productOptionButtonConfig.baseForegroundColor = .black
                productOptionButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 25)
                productOptionButtonConfig.image = UIImage(systemName: "shippingbox",
                                                          withConfiguration: UIImage.SymbolConfiguration(scale: .large))
                productOptionButtonConfig.imagePadding = 10.0
                productOptionButtonConfig.imagePlacement = .leading
                productOptionButtonConfig.title = "Product"
                productOptionButtonConfig.titlePadding = 5
                
                var productOptionContainer = AttributeContainer()
                productOptionContainer.foregroundColor = .systemGray
                productOptionButtonConfig.attributedSubtitle = AttributedString("If you're adding a product line, e.g. Apples.",
                                                                                attributes: productOptionContainer)
                
                self.productOptionButton = UIButton(type: .system)
                self.productOptionButton.configuration = productOptionButtonConfig
                self.productOptionButton.configurationUpdateHandler = { button in
                        var config = button.configuration!
                        
                        if button.isHighlighted {
                                config.baseForegroundColor = .systemGray
                                config.image = UIImage(systemName: "shippingbox.fill")
                        } else {
                                config.baseForegroundColor = .black
                                config.image = UIImage(systemName: "shippingbox")
                        }
                        
                        button.configuration = config
                }
                
                var productVariantOptionButtonConfig = UIButton.Configuration.gray()
                productVariantOptionButtonConfig.baseForegroundColor = .black
                productVariantOptionButtonConfig.contentInsets = NSDirectionalEdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 25)
                productVariantOptionButtonConfig.image = UIImage(systemName: "square.on.square",
                                                                 withConfiguration: UIImage.SymbolConfiguration(scale: .large))
                productVariantOptionButtonConfig.imagePadding = 10.0
                productVariantOptionButtonConfig.imagePlacement = .leading
                productVariantOptionButtonConfig.title = "Product Variant"
                productVariantOptionButtonConfig.titlePadding = 5
                
                var productVariantOptionContainer = AttributeContainer()
                productVariantOptionContainer.foregroundColor = .systemGray
                productVariantOptionButtonConfig.attributedSubtitle = AttributedString("If you're adding a product with specific variations, e.g. Apples, Red. A variant is linked to the product it describes.",
                                                                                       attributes: productVariantOptionContainer)
                
                self.productVariantOptionButton = UIButton(type: .system)
                self.productVariantOptionButton.configuration = productVariantOptionButtonConfig
                self.productVariantOptionButton.configurationUpdateHandler = { button in
                        var config = button.configuration!
                        
                        if button.isHighlighted {
                                config.baseForegroundColor = .systemGray
                                config.image = UIImage(systemName: "square.fill.on.square.fill")
                        } else {
                                config.baseForegroundColor = .black
                                config.image = UIImage(systemName: "square.on.square")
                        }
                        
                        button.configuration = config
                }
                
                self.optionsView.addArrangedSubview(self.productOptionButton)
                self.optionsView.addArrangedSubview(self.productVariantOptionButton)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.title = "Add a Product"
                
                self.productOptionButton.addAction(
                        UIAction(title: "Add Product") { (action) in
                                let productBrandViewController = NSOProductBrandViewController()
                                self.navigationController?.pushViewController(productBrandViewController,
                                                                              animated: true)
                        },
                        for: .touchUpInside
                )
                self.productVariantOptionButton.addAction(
                        UIAction(title: "Add Product Variant") { (action) in
                                let productVariantViewController = NSOProductVariantViewController()
                                self.navigationController?.pushViewController(productVariantViewController,
                                                                              animated: true)
                        },
                        for: .touchUpInside
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        @objc
        private dynamic func dismissView() {
                self.navigationController?.dismiss(animated: true)
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
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
                        }
                        
                        self.optionsView.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 30,
                                y: (self.view.bounds.height / 2) - (self.view.safeAreaInsets.top / 2) - (self.view.bounds.height / 3 * 0.5),
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 60,
                                height: self.view.bounds.height / 3
                        )
                        
                        self.view.addSubview(self.optionsView)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
}
