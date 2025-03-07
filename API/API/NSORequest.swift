//
//  Requests.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import CoreLocation
import UIKit


private extension String {
        func sanitized() -> String {
                var ret = ""
                
                ret = self.replacingOccurrences(of: "’", with: "\'")
                ret = ret.replacingOccurrences(of: "“", with: "\"")
                ret = ret.replacingOccurrences(of: "”", with: "\"")
                ret = ret.replacingOccurrences(of: "‟", with: "\"")
                ret = ret.replacingOccurrences(of: "‘", with: "\'")
                ret = ret.replacingOccurrences(of: "‛", with: "\'")
                ret = ret.replacingOccurrences(of: "`", with: "\'")
                
                return ret
        }
}


private extension URL {
        func sanitized() -> URL? {
                var urlString = String(self.absoluteString.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if self.scheme == nil {
                        urlString = "http://" + urlString
                }
                
                if !urlString.hasSuffix("/") {
                        urlString.append("/")
                }
                
                return URL(string: urlString.lowercased())
        }
}


public struct NSOCheckAliasRequest {
        public private(set) var alias: String
        
        public init(alias: String) {
                var alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                        alias.remove(at: alias.startIndex)
                }
                
                self.alias = alias.lowercased().sanitized()
        }
}


public struct NSOCheckVerificationCodeRequest {
        public private(set) var code: String
        public private(set) var phoneNumberID: Int
        
        public init(code: String,
                    phoneNumberID: Int) {
                self.code = code
                self.phoneNumberID = phoneNumberID
        }
}


public struct NSOCreateBrandRequest {
        public private(set) var alias: String
        public private(set) var name: String
        public private(set) var tags: Array<NSOTag>
        
        public init(alias: String,
                    name: String,
                    tags: Array<NSOTag>) {
                var alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                        alias.remove(at: alias.startIndex)
                }
                
                self.alias = alias.lowercased().sanitized()
                self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.tags = tags
        }
}


public struct NSOCreateProductRequest {
        public private(set) var alias: String
        public private(set) var brandID: Int
        public private(set) var name: String
        public private(set) var parentProductID: Int?
        public private(set) var tags: Array<NSOTag>
        
        public init(alias: String,
                    brandID: Int,
                    name: String,
                    parentProductID: Int?,
                    tags: Array<NSOTag>) {
                var alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                        alias.remove(at: alias.startIndex)
                }
                
                self.alias = alias.lowercased().sanitized()
                self.brandID = brandID
                self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.parentProductID = parentProductID
                self.tags = tags
        }
}


public struct NSOCreateStoreRequest {
        public private(set) var alias: String
        public private(set) var brandID: Int
        public private(set) var coordinates: CLLocationCoordinate2D
        public private(set) var locality: NSOLocality
        public private(set) var name: String
        
        public init(alias: String,
                    brandID: Int,
                    coordinates: CLLocationCoordinate2D,
                    locality: NSOLocality, name: String) {
                var alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                        alias.remove(at: alias.startIndex)
                }
                
                self.alias = alias.lowercased().sanitized()
                self.brandID = brandID
                self.coordinates = coordinates
                self.locality = locality
                self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
        }
}


public struct NSOCreateStoreProductRequest {
        public private(set) var price: Decimal
        public private(set) var productID: Int
        public private(set) var storeID: Int
        
        public init(price: Decimal,
                    productID: Int,
                    storeID: Int) {
                self.price = price
                self.productID = productID
                self.storeID = storeID
        }
}


public struct NSODeleteBrandRequest {
        public private(set) var brandID: Int
        
        public init(brandID: Int) {
                self.brandID = brandID
        }
}


public struct NSODeleteProductRequest {
        public private(set) var productID: Int
        
        public init(productID: Int) {
                self.productID = productID
        }
}


public struct NSODeleteStoreRequest {
        public private(set) var storeID: Int
        
        public init(storeID: Int) {
                self.storeID = storeID
        }
}


public struct NSODeleteStoreProductRequest {
        public private(set) var storeProductID: Int
        
        public init(storeProductID: Int) {
                self.storeProductID = storeProductID
        }
}


public struct NSODeleteUserAccountRequest {
        public private(set) var userAccountID: Int
        
        public init(userAccountID: Int) {
                self.userAccountID = userAccountID
        }
}


public struct NSOGetBrandRequest {
        public private(set) var alias: String?
        public private(set) var brandID: Int?
        
        public init(alias: String? = nil,
                    brandID: Int? = nil) {
                if var alias = alias {
                        alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                        
                        if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                                alias.remove(at: alias.startIndex)
                        }
                        
                        self.alias = alias.lowercased().sanitized()
                }
                
                self.brandID = brandID
        }
}


public struct NSOGetBrandsRequest {
        public private(set) var query: String
        
        public init(query: String) {
                self.query = query.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
        }
}


public struct NSOGetCountryListRequest {
        public private(set) var isEnabled: Bool
        
        public init(isEnabled: Bool = true) {
                self.isEnabled = isEnabled
        }
}


public struct NSOGetDialingCodeListRequest {
        public private(set) var isEnabled: Bool
        
        public init(isEnabled: Bool = true) {
                self.isEnabled = isEnabled
        }
}


public struct NSOGetLocalitiesRequest {
        public private(set) var query: String
        
        public init(query: String) {
                self.query = query.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
        }
}


public struct NSOGetProductRequest {
        public private(set) var alias: String?
        public private(set) var productID: Int?
        
        public init(alias: String? = nil,
                    productID: Int? = nil) {
                if var alias = alias {
                        alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                        
                        if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                                alias.remove(at: alias.startIndex)
                        }
                        
                        self.alias = alias.lowercased().sanitized()
                }
                
                self.productID = productID
        }
}


public struct NSOGetProductVariantsRequest {
        public private(set) var offset: Int
        public private(set) var parentProductID: Int
        
        public init(parentProductID: Int,
                    offset: Int = 0) {
                self.offset = offset
                self.parentProductID = parentProductID
        }
}


public struct NSOGetProductsRequest {
        public private(set) var brandID: Int?
        public private(set) var query: String?
        
        public init(brandID: Int? = nil,
                    query: String? = nil) {
                self.brandID = brandID
                self.query = query?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
        }
}


public struct NSOGetStoreRequest {
        public private(set) var alias: String?
        public private(set) var storeID: Int?
        
        public init(alias: String? = nil,
                    storeID: Int? = nil) {
                if var alias = alias {
                        alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                        
                        if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                                alias.remove(at: alias.startIndex)
                        }
                        
                        self.alias = alias.lowercased().sanitized()
                }
                
                self.storeID = storeID
        }
}


public struct NSOGetStoreProductRequest {
        public private(set) var storeProductID: Int
        
        public init(storeProductID: Int) {
                self.storeProductID = storeProductID
        }
}


public struct NSOGetStoreProductsRequest {
        public private(set) var storeID: Int
        
        public init(storeID: Int) {
                self.storeID = storeID
        }
}


public struct NSOGetStoresRequest {
        public private(set) var query: String?
        public private(set) var coordinates: CLLocationCoordinate2D?
        
        public init(query: String? = nil,
                    coordinates: CLLocationCoordinate2D? = nil) {
                self.query = query?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.coordinates = coordinates
        }
}


public struct NSOGetUserAccountRequest {
        public private(set) var alias: String?
        public private(set) var userAccountID: Int?
        
        public init(alias: String? = nil,
                    userAccountID: Int? = nil) {
                if var alias = alias {
                        alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                        
                        if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                                alias.remove(at: alias.startIndex)
                        }
                        
                        self.alias = alias.lowercased().sanitized()
                }
                
                self.userAccountID = userAccountID
        }
}


public struct NSOGetUserAccountsRequest {
        public private(set) var query: String
        
        public init(query: String) {
                self.query = query.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
        }
}


public struct NSOJoinRequest {
        public private(set) var alias: String
        /// The verification code in plain text.
        public private(set) var code: String
        public private(set) var clientID: String = NSOAPI.Configuration.clientID
        public private(set) var phoneNumberID: Int
        
        public init(alias: String,
                    code: String,
                    phoneNumberID: Int) {
                var alias = String(alias.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                
                if alias.hasPrefix(NSOAPI.Configuration.mentionSequence) {
                        alias.remove(at: alias.startIndex)
                }
                
                self.alias = alias.lowercased().sanitized()
                self.code = code
                self.phoneNumberID = phoneNumberID
        }
}


public struct NSOLogInRequest {
        /// The verification code in plain text.
        public private(set) var code: String
        public private(set) var clientID: String = NSOAPI.Configuration.clientID
        public private(set) var phoneNumberID: Int
        public private(set) var userAccountID: Int
        
        public init(code: String,
                    phoneNumberID: Int,
                    userAccountID: Int) {
                self.code = code
                self.phoneNumberID = phoneNumberID
                self.userAccountID = userAccountID
        }
}


public struct NSORemoveBrandRequest {
        public private(set) var brandID: Int?
        
        public init(brandID: Int?) {
                self.brandID = brandID
        }
}


public struct NSORemoveProductRequest {
        public private(set) var productID: Int?
        
        public init(productID: Int?) {
                self.productID = productID
        }
}


public struct NSORemoveStoreRequest {
        public private(set) var storeID: Int?
        
        public init(storeID: Int?) {
                self.storeID = storeID
        }
}


public struct NSOReportBrandRequest {
        public private(set) var brandtID: Int
        public private(set) var comment: String?
        public private(set) var reportType: NSOProductReportType
        
        public init(brandtID: Int,
                    comment: String?,
                    reportType: NSOProductReportType) {
                self.brandtID = brandtID
                self.comment = comment?.sanitized()
                self.reportType = reportType
        }
}


public struct NSOReportProductRequest {
        public private(set) var comment: String?
        public private(set) var productID: Int
        public private(set) var reportType: NSOProductReportType
        
        public init(comment: String?,
                    productID: Int,
                    reportType: NSOProductReportType) {
                self.comment = comment?.sanitized()
                self.productID = productID
                self.reportType = reportType
        }
}


public struct NSOReportStoreRequest {
        public private(set) var comment: String?
        public private(set) var reportType: NSOProductReportType
        public private(set) var storeID: Int
        
        public init(comment: String?,
                    reportType: NSOProductReportType,
                    storeID: Int) {
                self.comment = comment?.sanitized()
                self.reportType = reportType
                self.storeID = storeID
        }
}


public struct NSOReportUserAccountRequest {
        public private(set) var comment: String?
        public private(set) var reportType: NSOProductReportType
        public private(set) var accountID: Int
        
        public init(comment: String?,
                    reportType: NSOProductReportType,
                    accountID: Int) {
                self.comment = comment?.sanitized()
                self.reportType = reportType
                self.accountID = accountID
        }
}


public struct NSOSendVerificationCodeRequest {
        public private(set) var phoneNumber: NSOUserPhoneNumber
        
        public init(phoneNumber: NSOUserPhoneNumber) {
                self.phoneNumber = phoneNumber
        }
}


public struct NSOUpdateBrandRequest {
        public private(set) var brandID: Int
        public private(set) var description: String?
        public private(set) var name: String
        public private(set) var tags: Array<NSOTag>
        public private(set) var website: URL?
        
        public init(brandID: Int,
                    description: String?,
                    name: String,
                    tags: Array<NSOTag>,
                    website: URL?) {
                self.brandID = brandID
                self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.tags = tags
                self.website = website?.sanitized()
        }
}


public struct NSOUpdateBrandAvatarRequest {
        public private(set) var avatar: UIImage
        public private(set) var brandID: Int
        public private(set) var mediaMode: NSOMediaMode
        
        public init(avatar: UIImage,
                    brandID: Int,
                    mediaMode: NSOMediaMode) {
                self.avatar = avatar
                self.brandID = brandID
                self.mediaMode = mediaMode
        }
}


public struct NSOUpdateProductRequest {
        public private(set) var description: String?
        public private(set) var mainColorCode: String?
        public private(set) var materialID: Int?
        public private(set) var name: String
        public private(set) var overridesDisplayName: Bool
        public private(set) var parentProductID: Int?
        public private(set) var preorderTimestamp: Date?
        public private(set) var preorderTimestampString: String?
        public private(set) var productID: Int
        public private(set) var releaseTimestamp: Date?
        public private(set) var releaseTimestampString: String?
        public private(set) var status: NSOProductStatus
        public private(set) var tags: Array<NSOTag>
        public private(set) var upc: String?
        public private(set) var url: URL?
        
        public init(description: String?,
                    mainColorCode: String?,
                    materialID: Int?,
                    name: String,
                    overridesDisplayName: Bool,
                    parentProductID: Int?,
                    preorderTimestamp: Date?,
                    productID: Int,
                    releaseTimestamp: Date?,
                    status: NSOProductStatus,
                    tags: Array<NSOTag>,
                    upc: String?,
                    url: URL?) {
                self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.mainColorCode = mainColorCode?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.materialID = materialID
                self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.overridesDisplayName = overridesDisplayName
                self.parentProductID = parentProductID
                self.preorderTimestamp = preorderTimestamp
                self.productID = productID
                self.releaseTimestamp = releaseTimestamp
                self.status = status
                self.tags = tags
                self.upc = upc?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.url = url?.sanitized()
                
                let calendar = Calendar.current
                let dateFormatter = DateFormatter()
                dateFormatter.calendar = calendar
                
                if let preorderTimestamp = preorderTimestamp {
                        let hour = calendar.component(.hour,
                                                      from: preorderTimestamp)
                        let minute = calendar.component(.minute,
                                                        from: preorderTimestamp)
                        
                        if hour != 0 || minute != 0 {
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        } else {
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                /// A date without the time set will have the time part set to midnight in local time.
                                /// Use the local time zone to get midnight as UTC.
                                dateFormatter.timeZone = .current
                        }
                        
                        self.preorderTimestampString = dateFormatter.string(from: preorderTimestamp)
                }
                
                if let releaseTimestamp = releaseTimestamp {
                        let hour = calendar.component(.hour,
                                                      from: releaseTimestamp)
                        let minute = calendar.component(.minute,
                                                        from: releaseTimestamp)
                        
                        if hour != 0 || minute != 0 {
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                        } else {
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                /// A date without the time set will have the time part set to midnight in local time.
                                /// Use the local time zone to get midnight as UTC.
                                dateFormatter.timeZone = .current
                        }
                        
                        self.releaseTimestampString = dateFormatter.string(from: releaseTimestamp)
                }
        }
}


public struct NSOUpdateProductMediaRequest {
        public private(set) var media: [String : UIImage]
        public private(set) var metadata: [String : Any]
        public private(set) var mediaMode: NSOMediaMode
        public private(set) var productID: Int
        
        public init(media: [String : UIImage],
                    metadata: [String : Any],
                    mediaMode: NSOMediaMode,
                    productID: Int) {
                self.media = media
                self.metadata = metadata
                self.mediaMode = mediaMode
                self.productID = productID
        }
}


public struct NSOUpdateStoreRequest {
        public private(set) var address: NSOPhysicalAddress?
        public private(set) var description: String?
        public private(set) var name: String
        public private(set) var status: NSOStoreStatus
        public private(set) var storeID: Int
        public private(set) var website: URL?
        
        public init(address: NSOPhysicalAddress?,
                    description: String?,
                    name: String,
                    status: NSOStoreStatus,
                    storeID: Int,
                    website: URL?) {
                if let address = address {
                        address.building = address.building?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                        address.floor = address.floor?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                        address.locality.name = address.locality.name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                        address.postCode = address.postCode?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                        address.street = address.street?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                        address.unit = address.unit?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                        self.address = address
                }
                
                self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.name = name.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.status = status
                self.storeID = storeID
                self.website = website?.sanitized()
        }
}


public struct NSOUpdateStoreAvatarRequest {
        public private(set) var avatar: UIImage
        public private(set) var storeID: Int
        
        public init(avatar: UIImage,
                    storeID: Int) {
                self.avatar = avatar
                self.storeID = storeID
        }
}


public struct NSOUpdateStoreProductRequest {
        public private(set) var condition: String?
        public private(set) var description: String?
        public private(set) var price: Decimal
        public private(set) var status: NSOProductStatus
        public private(set) var storeProductID: Int
        public private(set) var url: URL?
        
        public init(condition: String?,
                    description: String?,
                    price: Decimal,
                    status: NSOProductStatus,
                    storeProductID: Int,
                    url: URL?) {
                self.condition = condition?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.description = description?.trimmingCharacters(in: .whitespacesAndNewlines).sanitized()
                self.price = price
                self.status = status
                self.storeProductID = storeProductID
                self.url = url?.sanitized()
        }
}
