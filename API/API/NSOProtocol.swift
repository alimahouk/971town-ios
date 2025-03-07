//
//  Protocol.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import CoreLocation


public enum NSOBrandReportType: Int, Codable {
        case duplicate = 1
        case falseInfo = 2
        case managerBehavior = 3
        case nonexistent = 4
        case ownershipClaim = 5
}


public enum NSOClientDeviceType: Int, Codable {
        case undefined = 0
        case desktop = 1
        case phone = 2
        case tablet = 3
}


public enum NSOContentVisibility: Int, Codable {
        case publiclyVisible = 1
        case deleted = 2
        case removed = 4
}


public enum NSOEditAccessLevel: Int, Codable {
        case open = 1
        case archived = 2
        case locked = 3
        case publiclyAccessible = 4
}

public enum NSOFileFormat: String {
        case jpg = "jpg"
        case png = "png"
}


public enum NSOMediaMode: Int, Codable {
        case dark = 1
        case light = 2
}


public enum NSOMediaType: Int, Codable {
        case image = 1
        case video = 2
}


public enum NSOProductReportType: Int, Codable {
        case duplicate = 1
        case falseInfo = 2
        case managerBehavior = 3
        case nonexistent = 4
        case ownershipClaim = 5
}


public enum NSOProductStatus: Int, Codable {
        case available = 1
        case comingSoon = 2
        case discontinued = 3
        case preorder = 4
        case unavailable = 5
}


public enum NSOProtocolKey: String, Codable {
        case address = "address"
        case alias = "alias"
        case alpha2Code = "alpha_2_code"
        case alpha3Code = "alpha_3_code"
        case attempts = "attempts"
        case attribution = "attribution"
        case avatar = "avatar"
        case avatarDarkModeFilePath = "avatar_dark_path"
        case avatarLightModeFilePath = "avatar_light_path"
        case bio = "bio"
        case brand = "brand"
        case brands = "brands"
        case brandID = "brand_id"
        case building = "building"
        case client = "client"
        case clientID = "client_id"
        case clientVersion = "client_version"
        case code = "code"
        case comment = "comment"
        case condition = "condition"
        case continent = "continent"
        case continentCode = "continent_code"
        case coordinates = "coordinates"
        case coordinatesText = "coordinates_txt"
        case countries = "countries"
        case country = "country"
        case creationTimestamp = "creation_timestamp"
        case creator = "creator"
        case creatorID = "creator_id"
        case currency = "currency"
        case currencyCode = "currency_code"
        case dialingCode = "dialing_code"
        case dialingCodeID = "dialing_code_id"
        case dialingCodes = "dialing_codes"
        case description = "description"
        case deviceName = "device_name"
        case deviceType = "device_type"
        case editAccessLevel = "edit_access_level"
        case error = "error"
        case errorCode = "error_code"
        case errorMessage = "error_message"
        case filePath = "file_path"
        case floor = "floor"
        case hex = "hex"
        case id = "id"
        case identity = "identity"
        case identityType = "identity_type"
        case imposerID = "imposer_id"
        case index = "index"
        case ipAddress = "ip_address"
        case isAdmin = "is_admin"
        case isEnabled = "is_enabled"
        case isVerified = "is_verified"
        case lastActivity = "last_activity"
        case latitude = "latitude"
        case localities = "localities"
        case locality = "locality"
        case localityID = "locality_id"
        case location = "location"
        case longitude = "longitude"
        case macAddress = "mac_address"
        case mainColor = "main_color"
        case mainColorCode = "main_color_code"
        case material = "material"
        case materialID = "material_id"
        case media = "media"
        case mediaMode = "media_mode"
        case mediaType = "media_type"
        case mobileCarrier = "mobile_carrier"
        case name = "name"
        case nameClean = "name_clean"
        case nameLowercase = "name_lc"
        case numeric3Code = "numeric_3_code"
        case fullName = "full_name"
        case offset = "offset"
        case os = "os"
        case osID = "os_id"
        case osVersion = "os_version"
        case overridesDisplayName = "display_name_override"
        case parentProduct = "parent_product"
        case parentProductID = "parent_product_id"
        case password = "password"
        case phoneNumber = "phone_number"
        case phoneNumberID = "phone_number_id"
        case postCode = "post_code"
        case postgresSearchAlias = "ts_alias"
        case postgresSearchName = "ts_name"
        case preorderTimestamp = "preorder_timestamp"
        case price = "price"
        case product = "product"
        case productColors = "product_colors"
        case productCount = "product_count"
        case productID = "product_id"
        case productMaterials = "product_materials"
        case products = "products"
        case productVariantCount = "product_variant_count"
        case productVariants = "product_variants"
        case query = "query"
        case releaseTimestamp = "release_timestamp"
        case rep = "rep"
        case reporter = "reporter"
        case reporterID = "reporter_id"
        case screenResolution = "screen_resolution"
        case sessions = "sessions"
        case status = "status"
        case store = "store"
        case storeID = "store_id"
        case storeProduct = "store_product"
        case storeProductID = "store_product_id"
        case storeProducts = "store_products"
        case stores = "stores"
        case street = "street"
        case symbol = "symbol"
        case tags = "tags"
        case tagID = "tag_id"
        case timeZone = "time_zone"
        case type = "type"
        case unit = "unit"
        case upc = "upc"
        case user = "user"
        case users = "users"
        case userID = "user_id"
        case url = "url"
        case userAccount = "user_account"
        case userAccountID = "user_account_id"
        case userAccountSession = "user_account_session"
        case userAccountSessionID = "user_account_session_id"
        case userAccounts = "user_accounts"
        case verificationCode = "verification_code"
        case version = "version"
        case visibility = "visibility"
        case website = "website"
}


public enum NSOResponseStatus: Int, Codable {
        // Generic
        case OK = 0
        case badRequest = 1
        case forbidden = 2
        case internalServerError = 3
        case notFound = 4
        case notImplemented = 5
        case payloadTooLarge = 6
        case tooManyRequests = 7
        case unauthorized = 8
        // Specific
        case aliasExists = 9
        case aliasInvalid = 10
        case alpha2CodeInvalid = 11
        case bioInvalid = 12
        case brandNotFound = 13
        case brandTooSimilar = 14
        case descriptionInvalid = 15
        case mediaInvalid = 16
        case mediaUnsupported = 17
        case nameInvalid = 18
        case passwordIncorrect = 19
        case passwordInvalid = 20
        case phoneNumberNotFound = 21
        case phoneNumberInvalid = 22
        case phoneNumberUnverified = 23
        case productNotFound = 24
        case productTooSimilar = 25
        case sessionInvalid = 26
        case storeNotFound = 27
        case storeTooSimilar = 28
        case storeProductNotFound = 29
        case tagInvalid = 30
        case unsupportedClient = 31
        case URLInvalid = 32
        case userAccountMaxCountReached = 33
        case userAccountNotFound = 34
        case userAccountSuspended = 35
        case verificationCodeExpired = 36
        case verificationCodeIncorrect = 37
        case verificationCodeNotFound = 38
        case attributionInvalid = 39
}


public enum NSOStoreStatus: Int, Codable {
        case open = 1
        case openingSoon = 2
        case permanentlyClosed = 3
        case temporarlyClosed = 4
}


public enum NSOStoreProductStatus: Int, Codable {
        case available = 1
        case discounted = 2
        case preorder = 3
        case outOfStock = 4
}


public enum NSOStoreReportType: Int, Codable {
        case closed = 1
        case duplicate = 2
        case falseInfo = 3
        case falsePrices = 4
        case falseProducts = 5
        case managerBehavior = 6
        case nonexistent = 7
        case ownershipClaim = 8
}


public enum NSOUserAccountReportType: Int, Codable {
        case behavior = 1
        case spam = 2
        case vandalism = 3
}


public struct NSOAPIError: Codable {
        public let errorCode: NSOResponseStatus
        public let errorMessage: String
        
        enum CodingKeys: String, CodingKey {
                case errorCode = "error_code"
                case errorMessage = "error_message"
        }
}


public struct NSOAppError: LocalizedError {
        public let errorDescription: String?
}


public struct NSONetworkError: LocalizedError {
        public let errorDescription: String?
}


// MARK: - Extensions


extension CLLocationCoordinate2D: Codable {
        public func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(longitude)
                try container.encode(latitude)
        }
        
        public init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                let longitude = try container.decode(CLLocationDegrees.self)
                let latitude = try container.decode(CLLocationDegrees.self)
                
                self.init(latitude: latitude, longitude: longitude)
        }
}


public extension Notification.Name {
        static let NSOCreatedBrand = Notification.Name("NSOCreatedBrand")
        static let NSOCreatedProduct = Notification.Name("NSOCreatedProduct")
        static let NSOCurrentUserAccountFetched = Notification.Name("NSOCurrentUserAccountFetched")
        static let NSOUpdatedBrand = Notification.Name("NSOUpdatedBrand")
        static let NSOUpdatedBrandAvatar = Notification.Name("NSOUpdatedBrandAvatar")
        static let NSOUpdatedProduct = Notification.Name("NSOUpdatedProduct")
        static let NSOUpdatedProductMedia = Notification.Name("NSOUpdatedProductMedia")
        static let NSOUserAccountJoined = Notification.Name("NSOUserAccountJoined")
        static let NSOUserAccountKickedOut = Notification.Name("NSOUserAccountKickedOut")
        static let NSOUserAccountLoggedIn = Notification.Name("NSOUserAccountLoggedIn")
        static let NSOUserAccountLoggedOut = Notification.Name("NSOUserAccountLoggedOut")
}


// MARK: - Helper Functions


public func mapResponseCode(httpStatusCode: Int) -> NSOResponseStatus {
        let ret: NSOResponseStatus
        
        switch httpStatusCode {
        case 200:
                ret = NSOResponseStatus.OK
        case 400:
                ret = NSOResponseStatus.badRequest
        case 403:
                ret = NSOResponseStatus.forbidden
        case 500:
                ret = NSOResponseStatus.internalServerError
        case 404:
                ret = NSOResponseStatus.notFound
        case 501:
                ret = NSOResponseStatus.notImplemented
        case 413:
                ret = NSOResponseStatus.payloadTooLarge
        case 429:
                ret = NSOResponseStatus.tooManyRequests
        case 401:
                ret = NSOResponseStatus.unauthorized
        default:
                ret = NSOResponseStatus.OK
        }
        
        return ret
}
