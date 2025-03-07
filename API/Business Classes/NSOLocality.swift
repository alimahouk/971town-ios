//
//  NSOLocality.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOLocality: Codable, Hashable {
        public var country: NSOCountry?
        public var creationTimestamp: Date?
        public var id: Int?
        public var name: String
        
        enum CodingKeys: String, CodingKey {
                case country
                case creationTimestamp = "creation_timestamp"
                case id
                case name
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.country = try container.decodeIfPresent(NSOCountry.self,
                                                             forKey: .country)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.name = try container.decode(String.self,
                                                 forKey: .name)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(country: NSOCountry? = nil,
                    creationTimestamp: Date? = nil,
                    id: Int? = nil,
                    name: String) {
                self.country = country
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.name = name
        }
        
        public static func == (lhs: NSOLocality,
                               rhs: NSOLocality) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
