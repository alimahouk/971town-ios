//
//  NSOBrandsNavigationController.swift
//  971town
//
//  Created by Ali Mahouk on 09/02/2023.
//

import API
import UIKit


class NSOBrandsNavigationController: UINavigationController {
        private let brandsViewController: NSOBrandsViewController
        
        init() {
                self.brandsViewController = NSOBrandsViewController(nibName: nil,
                                                                    bundle: nil)
                
                super.init(rootViewController: self.brandsViewController)
                
                self.navigationBar.prefersLargeTitles = true
        }
        
        required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
}
