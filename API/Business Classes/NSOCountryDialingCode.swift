//
//  NSOCountryDialingCode.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation

public class NSOCountryDialingCode: Codable, Hashable {
        public var country: NSOCountry?
        public var code: String?
        public var id: Int?
        
        enum CodingKeys: String, CodingKey {
                case country
                case code
                case id
        }
        
        
        public init(country: NSOCountry? = nil,
                    code: String? = nil,
                    id: Int? = nil) {
                self.country = country
                self.code = code
                self.id = id
        }
        
        public static func == (lhs: NSOCountryDialingCode,
                               rhs: NSOCountryDialingCode) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
