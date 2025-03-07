//
//  NSOBrand.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import UIKit


public class NSOBrand: Codable,
                       Comparable,
                       Hashable,
                       NSCopying {
        public var alias: String?
        public var avatar: UIImage?
        public var avatarLightPath: String?
        public var avatarLightURL: URL? {
                get {
                        var ret: URL? = nil
                        
                        if let avatarLightPath = self.avatarLightPath {
                                ret = URL(string: NSOAPI.baseMediaPath + avatarLightPath)
                        }
                        
                        return ret
                }
        }
        public var creationTimestamp: Date?
        public var creatorID: Int?
        public var creator: NSOUserAccount?
        public var description: String?
        public var editAccessLevel: NSOEditAccessLevel = .open
        public var id: Int?
        public var name: String?
        public var productCount: Int
        public var products: Array<NSOProduct> = []
        public var rep: Int?
        public var tags: Set<NSOTag> = []
        public var visibility: NSOContentVisibility = .publiclyVisible
        public var website: URL?
        
        enum CodingKeys: String, CodingKey {
                case alias
                case avatarLightPath = "avatar_light_path"
                case creationTimestamp = "creation_timestamp"
                case creator
                case creatorID = "creator_id"
                case description
                case editAccessLevel = "edit_access_level"
                case id
                case name
                case productCount = "product_count"
                case products
                case rep
                case tags
                case visibility
                case website
        }
        
        
        public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.alias = try container.decodeIfPresent(String.self,
                                                           forKey: .alias)
                self.avatarLightPath = try container.decodeIfPresent(String.self,
                                                                     forKey: .avatarLightPath)
                self.creator = try container.decodeIfPresent(NSOUserAccount.self,
                                                             forKey: .creator)
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
                self.productCount = try container.decode(Int.self,
                                                         forKey: .productCount)
                self.rep = try container.decodeIfPresent(Int.self,
                                                         forKey: .rep)
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
                
                if let products = try container.decodeIfPresent(Array<NSOProduct>.self,
                                                                forKey: .products) {
                        self.products = products
                } else {
                        self.products = []
                }
                
                if let tags = try container.decodeIfPresent(Set<NSOTag>.self,
                                                            forKey: .tags) {
                        self.tags = tags
                } else {
                        self.tags = []
                }
        }
        
        public init(alias: String? = nil,
                    avatar: UIImage? = nil,
                    avatarLightPath: String? = nil,
                    creationTimestamp: Date? = nil,
                    creator: NSOUserAccount? = nil,
                    creatorID: Int? = nil,
                    description: String? = nil,
                    editAccessLevel: NSOEditAccessLevel = .open,
                    id: Int? = nil,
                    name: String? = nil,
                    productCount: Int = 0,
                    products: Array<NSOProduct> = [],
                    rep: Int? = nil,
                    tags: Set<NSOTag> = [],
                    visibility: NSOContentVisibility = .publiclyVisible,
                    website: URL? = nil) {
                self.alias = alias
                self.avatar = avatar
                self.avatarLightPath = avatarLightPath
                self.creationTimestamp = creationTimestamp
                self.creator = creator
                self.creatorID = creatorID
                self.description = description
                self.editAccessLevel = editAccessLevel
                self.id = id
                self.name = name
                self.productCount = productCount
                self.products = products
                self.rep = rep
                self.tags = tags
                self.visibility = visibility
                self.website = website
        }
        
        public static func == (lhs: NSOBrand,
                               rhs: NSOBrand) -> Bool {
                return lhs.id == rhs.id
        }
        
        public static func < (lhs: NSOBrand,
                              rhs: NSOBrand) -> Bool {
                guard let lhsName = lhs.name, let rhsName = rhs.name else { return false }
                return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                var avatarCopy: UIImage? = nil
                
                if let avatar = self.avatar {
                        if let cgImage = avatar.cgImage?.copy() {
                                avatarCopy = UIImage(cgImage: cgImage,
                                                     scale: avatar.scale,
                                                     orientation: avatar.imageOrientation)
                        }
                }
                
                let copy = NSOBrand(alias: self.alias,
                                    avatar: avatarCopy,
                                    avatarLightPath: self.avatarLightPath,
                                    creationTimestamp: self.creationTimestamp,
                                    creator: self.creator?.copy() as? NSOUserAccount,
                                    creatorID: self.creatorID,
                                    description: self.description,
                                    editAccessLevel: self.editAccessLevel,
                                    id: self.id,
                                    name: self.name,
                                    productCount: self.productCount,
                                    products: Array<NSOProduct>(self.products.map { $0.copy() } as! [NSOProduct]),
                                    rep: self.rep,
                                    tags: Set<NSOTag>(self.tags.map { $0.copy() } as! [NSOTag]),
                                    visibility: self.visibility,
                                    website: self.website)
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
