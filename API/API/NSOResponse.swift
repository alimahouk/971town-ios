//
//  Responses.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public struct NSOErrorResponse: Error, Decodable {
        public let error: NSOAPIError
}


public struct NSOCheckAliasResponse: Decodable {
        let alias: String
}


public struct NSOCheckVerificationCodeResponse: Decodable {
        public let phoneNumberID: Int
        public let userID: Int?
        public let userAccounts: Array<NSOUserAccount>?
        
        enum CodingKeys: String, CodingKey {
                case phoneNumberID = "phone_number_id"
                case userID = "user_id"
                case userAccounts = "user_accounts"
        }
}


public struct NSOCreateBrandResponse: Decodable {
        public let brand: NSOBrand
}


public struct NSOCreateProductResponse: Decodable {
        public let product: NSOProduct
}


public struct NSOCreateStoreResponse: Decodable {
        public let store: NSOStore
}


public struct NSOCreateStoreProductResponse: Decodable {
        public let storeProduct: NSOStoreProduct
        
        enum CodingKeys: String, CodingKey {
                case storeProduct = "store_product"
        }
}


public struct NSODeleteBrandResponse: Decodable {
        let brandID: Int
        
        enum CodingKeys: String, CodingKey {
                case brandID = "brand_id"
        }
}


public struct NSODeleteProductResponse: Decodable {
        let productID: Int
        
        enum CodingKeys: String, CodingKey {
                case productID = "product_id"
        }
}


public struct NSODeleteStoreResponse: Decodable {
        let storeID: Int
        
        enum CodingKeys: String, CodingKey {
                case storeID = "store_id"
        }
}


public struct NSODeleteStoreProductResponse: Decodable {
        let storeProductID: Int
        
        enum CodingKeys: String, CodingKey {
                case storeProductID = "store_product_id"
        }
}


public struct NSODeleteUserAccountResponse: Decodable {
        let userAccountID: Int
        
        enum CodingKeys: String, CodingKey {
                case userAccountID = "user_account_id"
        }
}


public struct NSOGetBrandResponse: Decodable {
        public let brand: NSOBrand
}


public struct NSOGetBrandsResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.brands.description }
        public let brands: Array<NSOBrand>
}


public struct NSOGetCountryListResponse: CustomStringConvertible, Decodable {
        public let countries: Array<NSOCountry>
        public var description: String { return self.countries.description }
}


public struct NSOGetDialingCodeListResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.dialingCodes.description }
        public let dialingCodes: Array<NSOCountryDialingCode>
        
        enum CodingKeys: String, CodingKey {
                case dialingCodes = "dialing_codes"
        }
}


public struct NSOGetLocalitiesResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.localities.description }
        public let localities: Array<NSOLocality>
}


public struct NSOGetProductResponse: Decodable {
        public let product: NSOProduct
}


public struct NSOGetProductColorListResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.productColors.description }
        public let productColors: Array<NSOProductColor>
        
        enum CodingKeys: String, CodingKey {
                case productColors = "product_colors"
        }
}


public struct NSOGetProductMaterialListResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.productMaterials.description }
        public let productMaterials: Array<NSOProductMaterial>
        
        enum CodingKeys: String, CodingKey {
                case productMaterials = "product_materials"
        }
}


public struct NSOGetProductVariantsResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.productVariants.description }
        public let productVariants: Array<NSOProduct>
        
        enum CodingKeys: String, CodingKey {
                case productVariants = "product_variants"
        }
}


public struct NSOGetProductsResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.products.description }
        public let products: Array<NSOProduct>
}


public struct NSOGetStoreResponse: Decodable {
        public let store: NSOStore
}


public struct NSOGetStoreProductResponse: Decodable {
        public let storeProduct: NSOStoreProduct
        
        enum CodingKeys: String, CodingKey {
                case storeProduct = "store_product"
        }
}


public struct NSOGetStoreProductsResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.storeProducts.description }
        public let storeProducts: Array<NSOStoreProduct>
        
        enum CodingKeys: String, CodingKey {
                case storeProducts = "store_products"
        }
}


public struct NSOGetStoresResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.stores.description }
        public let stores: Array<NSOStore>
}


public struct NSOGetUserAccountResponse: Decodable {
        public let userAccount: NSOUserAccount
        
        enum CodingKeys: String, CodingKey {
                case userAccount = "user_account"
        }
}


public struct NSOGetUserAccountsResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.userAccounts.description }
        public let userAccounts: Array<NSOUserAccount>
        
        enum CodingKeys: String, CodingKey {
                case userAccounts = "user_accounts"
        }
}


public struct NSOHeartbeatResponse: Decodable {
        let userAccountID: Int
        
        enum CodingKeys: String, CodingKey {
                case userAccountID = "user_account_id"
        }
}


public struct NSOJoinResponse: Decodable {
        public let userAccount: NSOUserAccount
        public let userAccountSession: NSOUserAccountSession
        
        enum CodingKeys: String, CodingKey {
                case userAccount = "user_account"
                case userAccountSession = "user_account_session"
        }
}


public struct NSOLogInResponse: Decodable {
        public let userAccount: NSOUserAccount
        public let userAccountSession: NSOUserAccountSession
        
        enum CodingKeys: String, CodingKey {
                case userAccount = "user_account"
                case userAccountSession = "user_account_session"
        }
}


public struct NSOLogOutResponse: Decodable {
        let userAccountID: Int
        
        enum CodingKeys: String, CodingKey {
                case userAccountID = "user_account_id"
        }
}


public struct NSORemoveBrandResponse: Decodable {
        public let visibility: NSOContentVisibility
}


public struct NSORemoveProductResponse: Decodable {
        public let visibility: NSOContentVisibility
}


public struct NSORemoveStoreResponse: Decodable {
        public let visibility: NSOContentVisibility
}


public struct NSOReportBrandResponse: Decodable {
        public let report: NSOBrandReport
}


public struct NSOReportProductResponse: Decodable {
        public let report: NSOProductReport
}


public struct NSOReportStoreResponse: Decodable {
        public let report: NSOStoreReport
}


public struct NSOReportUserAccountResponse: Decodable {
        public let report: NSOUserAccountReport
}


public struct NSOSendVerificationCodeResponse: Decodable {
        public let creationTimestamp: Date
        public let phoneNumber: NSOUserPhoneNumber
        
        enum CodingKeys: String, CodingKey {
                case creationTimestamp = "creation_timestamp"
                case phoneNumber = "phone_number"
        }
        
        public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                let creationTimestamp = try container.decode(String.self, forKey: .creationTimestamp)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                self.creationTimestamp = dateFormatter.date(from: creationTimestamp)!
                self.phoneNumber = try container.decode(NSOUserPhoneNumber.self, forKey: .phoneNumber)
        }
}


public struct NSOUpdateBrandResponse: Decodable {
        public let brand: NSOBrand
}


public struct NSOUpdateBrandAvatarResponse: Decodable {
        public let avatarLightPath: String
        public let brandID: Int
        
        enum CodingKeys: String, CodingKey {
                case brandID = "brand_id"
                case avatarLightPath = "avatar_light_path"
        }
}


public struct NSOUpdateProductResponse: Decodable {
        public let product: NSOProduct
}


public struct NSOUpdateProductMediaResponse: CustomStringConvertible, Decodable {
        public var description: String { return self.media.description }
        public let media: [NSOProductMedium]
        public let productID: Int
        
        enum CodingKeys: String, CodingKey {
                case media
                case productID = "product_id"
        }
}


public struct NSOUpdateStoreResponse: Decodable {
        public let store: NSOStore
}


public struct NSOUpdateStoreProductResponse: Decodable {
        public let storeProduct: NSOStoreProduct
        
        enum CodingKeys: String, CodingKey {
                case storeProduct = "store_product"
        }
}


public struct NSOUpdateUserAccountResponse: Decodable {
        public let userAccount: NSOUserAccount
        
        enum CodingKeys: String, CodingKey {
                case userAccount = "user_account"
        }
}


internal func debugJSONResponse(_ data: Data) {
        do {
                let _ = try JSONDecoder().decode(NSOUpdateProductMediaResponse.self,
                                                           from: data)
                print("JSON response is okay.")
        } catch let DecodingError.dataCorrupted(context) {
                print(context)
        } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
        } catch {
                print("error: ", error)
        }
}
