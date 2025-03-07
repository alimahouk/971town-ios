//
//  NSOCurrency.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOCurrency: Codable, Hashable {
        public var code: String?
        public var symbol: String?
        
        
        public init(code: String? = nil,
                    symbol: String? = nil) {
                self.code = code
                self.symbol = symbol
        }
        
        public static func == (lhs: NSOCurrency,
                               rhs: NSOCurrency) -> Bool {
                return lhs.code == rhs.code
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.code)
        }
}
