//
//  NSOContinent.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOContinent: Codable, Hashable {
        public var code: String?
        public var name: String?
        
        
        public init(code: String? = nil,
                    name: String? = nil) {
                self.code = code
                self.name = name
        }
        
        public static func == (lhs: NSOContinent,
                               rhs: NSOContinent) -> Bool {
                return lhs.code == rhs.code
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.code)
        }
}
