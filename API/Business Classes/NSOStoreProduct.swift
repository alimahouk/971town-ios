//
//  NSOStoreProduct.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOStoreProduct: Codable, Hashable {
        public var condition: String?
        public var creationTimestamp: Date?
        public var creatorID: Int?
        public var description: String?
        public var id: Int?
        public var price: Decimal?
        public var product: NSOProduct?
        public var status: NSOStoreProductStatus = .available
        public var storeID: Int?
        public var url: URL?
        
        enum CodingKeys: String, CodingKey {
                case condition
                case creationTimestamp = "creation_timestamp"
                case creatorID = "creator_id"
                case description
                case id
                case price
                case product
                case status
                case storeID = "store_id"
                case url
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.condition = try container.decodeIfPresent(String.self,
                                                               forKey: .condition)
                self.creatorID = try container.decodeIfPresent(Int.self,
                                                               forKey: .creatorID)
                self.description = try container.decodeIfPresent(String.self,
                                                                 forKey: .description)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.price = try container.decodeIfPresent(Decimal.self,
                                                           forKey: .price)
                self.product = try container.decodeIfPresent(NSOProduct.self,
                                                             forKey: .product)
                self.status = try container.decode(NSOStoreProductStatus.self,
                                                   forKey: .status)
                self.storeID = try container.decodeIfPresent(Int.self,
                                                             forKey: .storeID)
                self.url = try container.decodeIfPresent(URL.self,
                                                         forKey: .url)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(condition: String? = nil,
                    creationTimestamp: Date? = nil,
                    creatorID: Int? = nil,
                    description: String? = nil,
                    id: Int? = nil,
                    price: Decimal? = nil,
                    product: NSOProduct? = nil,
                    status: NSOStoreProductStatus = .available,
                    storeID: Int? = nil,
                    url: URL? = nil) {
                self.condition = condition
                self.creationTimestamp = creationTimestamp
                self.creatorID = creatorID
                self.description = description
                self.id = id
                self.price = price
                self.product = product
                self.status = status
                self.storeID = storeID
                self.url = url
        }
        
        public static func == (lhs: NSOStoreProduct,
                               rhs: NSOStoreProduct) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
