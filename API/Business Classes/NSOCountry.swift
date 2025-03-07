//
//  NSOCountry.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOCountry: Codable, Hashable {
        public var alpha2Code: String?
        public var alpha3Code: String?
        public var continent: NSOContinent?
        public var currency: NSOCurrency?
        public var fullName: String?
        public var name: String?
        public var numeric3Code: String?
        
        enum CodingKeys: String, CodingKey {
                case alpha2Code = "alpha_2_code"
                case alpha3Code = "alpha_3_code"
                case continent
                case currency
                case fullName = "full_name"
                case name
                case numeric3Code = "numeric_3_code"
        }
        
        
        public init(alpha2Code: String? = nil,
                    alpha3Code: String? = nil,
                    continent: NSOContinent? = nil,
                    currency: NSOCurrency? = nil,
                    fullName: String? = nil,
                    name: String? = nil,
                    numeric3Code: String? = nil) {
                self.alpha2Code = alpha2Code
                self.alpha3Code = alpha3Code
                self.continent = continent
                self.currency = currency
                self.fullName = fullName
                self.name = name
                self.numeric3Code = numeric3Code
        }
        
        public static func == (lhs: NSOCountry,
                               rhs: NSOCountry) -> Bool {
                return lhs.alpha2Code == rhs.alpha2Code
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.alpha2Code)
        }
}
