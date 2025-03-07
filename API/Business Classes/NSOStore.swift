//
//  NSOStore.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import CoreLocation
import Foundation


public class NSOPhysicalAddress: Codable {
        public var building: String?
        public var coordinates: CLLocationCoordinate2D?
        public var floor: String?
        public var locality: NSOLocality
        public var postCode: String?
        public var street: String?
        public var unit: String?
        
        enum CodingKeys: String, CodingKey {
                case building
                case coordinates
                case floor
                case locality
                case postCode = "post_code"
                case street
                case unit
        }
        
        
        public init(building: String? = nil,
                    coordinates: CLLocationCoordinate2D? = nil,
                    floor: String? = nil,
                    locality: NSOLocality,
                    postCode: String? = nil,
                    street: String? = nil,
                    unit: String? = nil) {
                self.building = building
                self.coordinates = coordinates
                self.floor = floor
                self.locality = locality
                self.postCode = postCode
                self.street = street
                self.unit = unit
        }
}


public class NSOStore: Codable,
                       Comparable,
                       Hashable {
        public var address: NSOPhysicalAddress?
        public var alias: String?
        public var brand: NSOBrand?
        public var creationTimestamp: Date?
        public var creatorID: Int?
        public var description: String?
        public var editAccessLevel: NSOEditAccessLevel = .open
        public var id: Int?
        public var name: String?
        public var status: NSOStoreStatus = .open
        public var tags: Set<NSOTag> = []
        public var visibility: NSOContentVisibility = .publiclyVisible
        public var website: URL?
        
        enum CodingKeys: String, CodingKey {
                case address
                case alias
                case brand
                case creationTimestamp = "creation_timestamp"
                case creatorID = "creator_id"
                case description
                case editAccessLevel = "edit_access_level"
                case id
                case name
                case status
                case tags
                case visibility
                case website
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.address = try container.decodeIfPresent(NSOPhysicalAddress.self,
                                                             forKey: .address)
                self.alias = try container.decodeIfPresent(String.self,
                                                           forKey: .alias)
                self.brand = try container.decodeIfPresent(NSOBrand.self,
                                                           forKey: .brand)
                self.creatorID = try container.decodeIfPresent(Int.self,
                                                               forKey: .creatorID)
                self.description = try container.decodeIfPresent(String.self,
                                                                 forKey: .description)
                self.editAccessLevel = try container.decode(NSOEditAccessLevel.self,
                                                            forKey: .editAccessLevel)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.name = try container.decodeIfPresent(String.self,
                                                          forKey: .name)
                self.status = try container.decode(NSOStoreStatus.self,
                                                   forKey: .status)
                self.visibility = try container.decode(NSOContentVisibility.self,
                                                       forKey: .visibility)
                self.website = try container.decodeIfPresent(URL.self,
                                                             forKey: .website)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
                
                if let tags = try container.decodeIfPresent(Set<NSOTag>.self,
                                                            forKey: .tags) {
                        self.tags = tags
                } else {
                        self.tags = []
                }
        }
        
        public init(address: NSOPhysicalAddress? = nil,
                    alias: String? = nil,
                    brand: NSOBrand? = nil,
                    creationTimestamp: Date? = nil,
                    creatorID: Int? = nil,
                    description: String? = nil,
                    editAccessLevel: NSOEditAccessLevel = .open,
                    id: Int? = nil,
                    name: String? = nil,
                    status: NSOStoreStatus = .open,
                    tags: Set<NSOTag> = [],
                    visibility: NSOContentVisibility = .publiclyVisible,
                    website: URL? = nil) {
                self.address = address
                self.alias = alias
                self.brand = brand
                self.creationTimestamp = creationTimestamp
                self.creatorID = creatorID
                self.description = description
                self.editAccessLevel = editAccessLevel
                self.id = id
                self.name = name
                self.status = status
                self.tags = tags
                self.visibility = visibility
                self.website = website
        }
        
        public static func == (lhs: NSOStore,
                               rhs: NSOStore) -> Bool {
                return lhs.id == rhs.id
        }
        
        public static func < (lhs: NSOStore,
                              rhs: NSOStore) -> Bool {
                guard let lhsName = lhs.name, let rhsName = rhs.name else { return false }
                return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
