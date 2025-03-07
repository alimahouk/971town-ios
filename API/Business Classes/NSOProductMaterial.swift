//
//  NSOProductMaterial.swift
//  API
//
//  Created by Ali Mahouk on 26/03/2023.
//

import Foundation


public class NSOProductMaterial: Codable, Hashable {
        public var id: Int
        public var name: String?
        
        
        public init(id: Int,
                    name: String? = nil) {
                self.id = id
                self.name = name
        }
        
        public static func == (lhs: NSOProductMaterial,
                               rhs: NSOProductMaterial) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                let copy = NSOProductMaterial(id: self.id,
                                              name: self.name)
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
