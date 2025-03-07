//
//  NSOProductsNavigationController.swift
//  971town
//
//  Created by Ali Mahouk on 12/03/2023.
//

import UIKit

class NSOProductsNavigationController: UINavigationController {
        private let productsViewController: NSOProductsViewController
        
        init() {
                self.productsViewController = NSOProductsViewController(nibName: nil,
                                                                        bundle: nil)
                
                super.init(rootViewController: self.productsViewController)
                
                self.navigationBar.prefersLargeTitles = true
        }
        
        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
}
