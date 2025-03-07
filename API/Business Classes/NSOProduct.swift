//
//  NSOProduct.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOProduct: Codable,
                         Comparable,
                         Hashable {
        public var alias: String?
        public var brand: NSOBrand?
        public var brandID: Int?
        public var creationTimestamp: Date?
        public var creator: NSOUserAccount?
        public var creatorID: Int?
        public var description: String?
        public var displayDescription: String? {
                get {
                        var ret: String?
                        
                        if let description = self.description {
                                ret = description
                        } else {
                                var parent: NSOProduct? = self.parentProduct
                                
                                while parent != nil {
                                        if let description = parent!.description {
                                                ret = description
                                                break
                                        }
                                        
                                        parent = parent!.parentProduct
                                }
                        }
                        
                        return ret
                }
        }
        public var displayName: String? {
                get {
                        var ret: String?
                        
                        if let name = self.name {
                                ret = name
                                
                                if !self.overridesDisplayName {
                                        if let parentProductName = self.parentProduct?.displayName {
                                                ret = "\(parentProductName) \(name)"
                                        } else if let brandName = self.brand?.name {
                                                ret = "\(brandName) \(name)"
                                        }
                                }
                        }
                        
                        return ret
                }
        }
        public var displayURL: URL? {
                get {
                        var ret: URL?
                        
                        if let url = self.url {
                                ret = url
                        } else {
                                var parent: NSOProduct? = self.parentProduct
                                
                                while parent != nil {
                                        if let url = parent!.url {
                                                ret = url
                                                break
                                        }
                                        
                                        parent = parent!.parentProduct
                                }
                        }
                        
                        return ret
                }
        }
        public var editAccessLevel: NSOEditAccessLevel = .open
        public var id: Int?
        public var mainColor: NSOProductColor?
        public var mainColorCode: String?
        public var material: NSOProductMaterial?
        public var materialID: Int?
        public var media: [NSOProductMedium] = []
        public var name: String?
        public var overridesDisplayName: Bool
        public var parentProduct: NSOProduct?
        public var parentProductID: Int?
        public var preorderTimestamp: Date?
        public var releaseTimestamp: Date?
        public var status: NSOProductStatus = .available
        public var tags: Set<NSOTag> = []
        public var upc: String?
        public var url: URL?
        public var variantCount: Int
        public var variants: [NSOProduct] = []
        public var visibility: NSOContentVisibility = .publiclyVisible
        
        enum CodingKeys: String, CodingKey {
                case alias
                case brand
                case brandID = "brand_id"
                case creationTimestamp = "creation_timestamp"
                case creator
                case creatorID = "creator_id"
                case description
                case editAccessLevel = "edit_access_level"
                case id
                case mainColor = "main_color"
                case mainColorCode = "main_color_code"
                case material
                case materialID = "material_id"
                case media
                case name
                case overridesDisplayName = "display_name_override"
                case parentProduct = "parent_product"
                case parentProductID = "parent_product_id"
                case preorderTimestamp = "preorder_timestamp"
                case releaseTimestamp = "release_timestamp"
                case status
                case tags
                case upc
                case url
                case variants = "product_variants"
                case variantCount = "product_variant_count"
                case visibility
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.alias = try container.decodeIfPresent(String.self,
                                                           forKey: .alias)
                self.brand = try container.decodeIfPresent(NSOBrand.self,
                                                           forKey: .brand)
                self.brandID = try container.decodeIfPresent(Int.self,
                                                             forKey: .brandID)
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
                self.mainColor = try container.decodeIfPresent(NSOProductColor.self,
                                                               forKey: .mainColor)
                self.mainColorCode = try container.decodeIfPresent(String.self,
                                                               forKey: .mainColorCode)
                self.material = try container.decodeIfPresent(NSOProductMaterial.self,
                                                              forKey: .material)
                self.materialID = try container.decodeIfPresent(Int.self,
                                                                forKey: .materialID)
                self.name = try container.decodeIfPresent(String.self,
                                                          forKey: .name)
                self.overridesDisplayName = try container.decode(Bool.self,
                                                                 forKey: .overridesDisplayName)
                self.parentProduct = try container.decodeIfPresent(NSOProduct.self,
                                                                   forKey: .parentProduct)
                self.parentProductID = try container.decodeIfPresent(Int.self,
                                                                     forKey: .parentProductID)
                self.status = try container.decode(NSOProductStatus.self,
                                                   forKey: .status)
                self.upc = try container.decodeIfPresent(String.self,
                                                         forKey: .upc)
                self.url = try container.decodeIfPresent(URL.self,
                                                         forKey: .url)
                self.variantCount = try container.decode(Int.self,
                                                         forKey: .variantCount)
                self.visibility = try container.decode(NSOContentVisibility.self,
                                                       forKey: .visibility)
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                
                if let creationTimestampString = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                        self.creationTimestamp = dateFormatter.date(from: creationTimestampString)
                }
                
                if let media = try container.decodeIfPresent(Array<NSOProductMedium>.self,
                                                             forKey: .media) {
                        self.media = media
                } else {
                        self.media = []
                }
                
                if let preorderTimestampString = try container.decodeIfPresent(String.self,
                                                                         forKey: .preorderTimestamp) {
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        
                        if let preorderTimestamp = dateFormatter.date(from: preorderTimestampString) {
                                self.preorderTimestamp = preorderTimestamp
                        } else {
                                print("Pre-order Timestamp Error: could not parse \(preorderTimestampString)")
                        }
                }
                
                if let releaseTimestampString = try container.decodeIfPresent(String.self,
                                                                        forKey: .releaseTimestamp) {
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                        
                        if let releaseTimestamp = dateFormatter.date(from: releaseTimestampString) {
                                self.releaseTimestamp = releaseTimestamp
                        } else {
                                print("Release Timestamp Error: could not parse \(releaseTimestampString)")
                        }
                }
                
                if let tags = try container.decodeIfPresent(Set<NSOTag>.self,
                                                            forKey: .tags) {
                        self.tags = tags
                } else {
                        self.tags = []
                }
                
                if let variants = try container.decodeIfPresent(Array<NSOProduct>.self,
                                                                forKey: .variants) {
                        self.variants = variants
                } else {
                        self.variants = []
                }
        }
        
        public init(alias: String? = nil,
                    brand: NSOBrand? = nil,
                    brandID: Int? = nil,
                    creationTimestamp: Date? = nil,
                    creator: NSOUserAccount? = nil,
                    creatorID: Int? = nil,
                    description: String? = nil,
                    editAccessLevel: NSOEditAccessLevel = .open,
                    id: Int? = nil,
                    mainColor: NSOProductColor? = nil,
                    mainColorCode: String? = nil,
                    material: NSOProductMaterial? = nil,
                    materialID: Int? = nil,
                    media: [NSOProductMedium] = [],
                    name: String? = nil,
                    overridesDisplayName: Bool = false,
                    parentProduct: NSOProduct? = nil,
                    parentProductID: Int? = nil,
                    preorderTimestamp: Date? = nil,
                    releaseTimestamp: Date? = nil,
                    status: NSOProductStatus = .available,
                    tags: Set<NSOTag> = [],
                    upc: String? = nil,
                    url: URL? = nil,
                    variantCount: Int = 0,
                    variants: [NSOProduct] = [],
                    visibility: NSOContentVisibility = .publiclyVisible) {
                self.alias = alias
                self.brand = brand
                self.brandID = brandID
                self.creationTimestamp = creationTimestamp
                self.creator = creator
                self.creatorID = creatorID
                self.description = description
                self.editAccessLevel = editAccessLevel
                self.id = id
                self.mainColor = mainColor
                self.mainColorCode = mainColorCode
                self.material = material
                self.materialID = materialID
                self.media = media
                self.name = name
                self.overridesDisplayName = overridesDisplayName
                self.parentProduct = parentProduct
                self.parentProductID = parentProductID
                self.preorderTimestamp = preorderTimestamp
                self.releaseTimestamp = releaseTimestamp
                self.status = status
                self.tags = tags
                self.upc = upc
                self.url = url
                self.variantCount = variantCount
                self.variants = variants
                self.visibility = visibility
        }
        
        public static func == (lhs: NSOProduct,
                               rhs: NSOProduct) -> Bool {
                return lhs.id == rhs.id
        }
        
        public static func < (lhs: NSOProduct,
                              rhs: NSOProduct) -> Bool {
                guard let lhsName = lhs.displayName, let rhsName = rhs.displayName else { return false }
                return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                let copy = NSOProduct(
                        alias: self.alias,
                        brand: self.brand?.copy() as? NSOBrand,
                        brandID: self.brandID,
                        creationTimestamp: self.creationTimestamp,
                        creator: self.creator?.copy() as? NSOUserAccount,
                        creatorID: self.creatorID,
                        description: self.description,
                        editAccessLevel: self.editAccessLevel,
                        id: self.id,
                        mainColor: self.mainColor?.copy() as? NSOProductColor,
                        mainColorCode: self.mainColorCode,
                        material: self.material?.copy() as? NSOProductMaterial,
                        materialID: self.materialID,
                        media: [NSOProductMedium](self.media.map { $0.copy() } as! [NSOProductMedium]),
                        name: self.name,
                        overridesDisplayName: self.overridesDisplayName,
                        parentProduct: self.parentProduct?.copy() as? NSOProduct,
                        parentProductID: self.parentProductID,
                        preorderTimestamp: self.preorderTimestamp,
                        releaseTimestamp: self.releaseTimestamp,
                        status: self.status,
                        tags: Set<NSOTag>(self.tags.map { $0.copy() } as! [NSOTag]),
                        upc: self.upc,
                        url: self.url,
                        variantCount: self.variantCount,
                        variants: [NSOProduct](self.variants.map { $0.copy() } as! [NSOProduct]),
                        visibility: self.visibility
                )
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
