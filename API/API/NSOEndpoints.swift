//
//  NSOEndpoints.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


internal struct NSOEndpoints {
        // MARK: - API Endpoint Names
        
        
        private static let ENDPOINT_CHECK_ALIAS = "check-alias"
        private static let ENDPOINT_CHECK_VERIFICATION_CODE = "check-verification-code"
        private static let ENDPOINT_CREATE_BRAND = "create-brand"
        private static let ENDPOINT_CREATE_PRODUCT = "create-product"
        private static let ENDPOINT_CREATE_STORE = "create-store"
        private static let ENDPOINT_CREATE_STORE_PRODUCT = "create-store-product"
        private static let ENDPOINT_DELETE_BRAND = "delete-brand"
        private static let ENDPOINT_DELETE_BRAND_AVATAR = "delete-brand-avatar"
        private static let ENDPOINT_DELETE_PRODUCT = "delete-product"
        private static let ENDPOINT_DELETE_STORE = "delete-store"
        private static let ENDPOINT_DELETE_STORE_AVATAR = "delete-store-avatar"
        private static let ENDPOINT_DELETE_STORE_PRODUCT = "delete-store-product"
        private static let ENDPOINT_DELETE_USER_ACCOUNT = "delete-user-account"
        private static let ENDPOINT_DELETE_USER_AVATAR = "delete-user-avatar"
        private static let ENDPOINT_GET_BADGE = "get-badge"
        private static let ENDPOINT_GET_BRAND = "get-brand"
        private static let ENDPOINT_GET_BRANDS = "get-brands"
        private static let ENDPOINT_GET_COUNTRY_LIST = "get-country-list"
        private static let ENDPOINT_GET_DIALING_CODE_LIST = "get-dialing-code-list"
        private static let ENDPOINT_GET_LOCALITIES = "get-localities"
        private static let ENDPOINT_GET_PRODUCT = "get-product"
        private static let ENDPOINT_GET_PRODUCT_COLOR_LIST = "get-product-color-list"
        private static let ENDPOINT_GET_PRODUCT_MATERIAL_LIST = "get-product-material-list"
        private static let ENDPOINT_GET_PRODUCT_VARIANTS = "get-product-variants"
        private static let ENDPOINT_GET_PRODUCTS = "get-products"
        private static let ENDPOINT_GET_STORE = "get-store"
        private static let ENDPOINT_GET_STORE_PRODUCT = "get-store-product"
        private static let ENDPOINT_GET_STORE_PRODUCTS = "get-store-products"
        private static let ENDPOINT_GET_STORES = "get-stores"
        private static let ENDPOINT_GET_USER_ACCOUNT = "get-user-account"
        private static let ENDPOINT_GET_USER_ACCOUNTS = "get-user-accounts"
        private static let ENDPOINT_HEARTBEAT = "heartbeat"
        private static let ENDPOINT_JOIN = "join"
        private static let ENDPOINT_LOG_IN = "log-in"
        private static let ENDPOINT_LOG_OUT = "log-out"
        private static let ENDPOINT_ME = "me"
        private static let ENDPOINT_REMOVE_BRAND = "remove-brand"
        private static let ENDPOINT_REMOVE_PRODUCT = "remove-product"
        private static let ENDPOINT_REMOVE_STORE = "remove-store"
        private static let ENDPOINT_REPORT_BRAND = "report-brand"
        private static let ENDPOINT_REPORT_PRODUCT = "report-product"
        private static let ENDPOINT_REPORT_STORE = "report-store"
        private static let ENDPOINT_REPORT_USER_ACCOUNT = "report-user-account"
        private static let ENDPOINT_SEND_VERIFICATION_CODE = "send-verification-code"
        private static let ENDPOINT_UPDATE_BRAND = "update-brand"
        private static let ENDPOINT_UPDATE_BRAND_AVATAR = "update-brand-avatar"
        private static let ENDPOINT_UPDATE_PRODUCT = "update-product"
        private static let ENDPOINT_UPDATE_PRODUCT_MEDIA = "update-product-media"
        private static let ENDPOINT_UPDATE_STORE = "update-store"
        private static let ENDPOINT_UPDATE_STORE_AVATAR = "update-store-avatar"
        private static let ENDPOINT_UPDATE_STORE_PRODUCT = "update-store-product"
        private static let ENDPOINT_UPDATE_USER_ACCOUNT = "update-user-account"
        private static let ENDPOINT_UPDATE_USER_AVATAR = "update-user-avatar"
        
        
        // MARK: - API Endpoint URLs
        
        
        internal static var checkAlias: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_CHECK_ALIAS)! } }
        internal static var checkVerificationCode: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_CHECK_VERIFICATION_CODE)! } }
        internal static var createBrand: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_CREATE_BRAND)! } }
        internal static var createProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_CREATE_PRODUCT)! } }
        internal static var createStore: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_CREATE_STORE)! } }
        internal static var createStoreProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_CREATE_STORE_PRODUCT)! } }
        internal static var deleteBrand: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_BRAND)! } }
        internal static var deleteBrandAvatar: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_BRAND_AVATAR)! } }
        internal static var deleteProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_PRODUCT)! } }
        internal static var deleteStore: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_STORE)! } }
        internal static var deleteStoreAvatar: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_STORE_AVATAR)! } }
        internal static var deleteStoreProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_STORE_PRODUCT)! } }
        internal static var deleteUserAccount: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_USER_ACCOUNT)! } }
        internal static var deleteUserAvatar: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_DELETE_USER_AVATAR)! } }
        internal static var getBadge: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_BADGE)! } }
        internal static var getBrand: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_BRAND)! } }
        internal static var getBrands: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_BRANDS)! } }
        internal static var getCountryList: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_COUNTRY_LIST)! } }
        internal static var getDialingCodeList: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_DIALING_CODE_LIST)! } }
        internal static var getLocalities: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_LOCALITIES)! } }
        internal static var getProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_PRODUCT)! } }
        internal static var getProductColorList: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_PRODUCT_COLOR_LIST)! } }
        internal static var getProductMaterialList: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_PRODUCT_MATERIAL_LIST)! } }
        internal static var getProductVariants: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_PRODUCT_VARIANTS)! } }
        internal static var getProducts: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_PRODUCTS)! } }
        internal static var getStore: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_STORE)! } }
        internal static var getStoreProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_STORE_PRODUCT)! } }
        internal static var getStoreProducts: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_STORE_PRODUCTS)! } }
        internal static var getStores: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_STORES)! } }
        internal static var getUserAccount: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_USER_ACCOUNT)! } }
        internal static var getUserAccounts: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_GET_USER_ACCOUNTS)! } }
        internal static var heartbeat: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_HEARTBEAT)! } }
        internal static var join: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_JOIN)! } }
        internal static var logIn: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_LOG_IN)! } }
        internal static var logOut: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_LOG_OUT)! } }
        internal static var me: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_ME)! } }
        internal static var removeBrand: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REMOVE_BRAND)! } }
        internal static var removeProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REMOVE_PRODUCT)! } }
        internal static var removeStore: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REMOVE_STORE)! } }
        internal static var reportBrand: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REPORT_BRAND)! } }
        internal static var reportProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REPORT_PRODUCT)! } }
        internal static var reportStore: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REPORT_STORE)! } }
        internal static var reportUserAccount: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_REPORT_USER_ACCOUNT)! } }
        internal static var sendVerificationCode: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_SEND_VERIFICATION_CODE)! } }
        internal static var updateBrand: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_BRAND)! } }
        internal static var updateBrandAvatar: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_BRAND_AVATAR)! } }
        internal static var updateProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_PRODUCT)! } }
        internal static var updateProductMedia: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_PRODUCT_MEDIA)! } }
        internal static var updateStore: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_STORE)! } }
        internal static var updateStoreAvatar: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_STORE_AVATAR)! } }
        internal static var updateStoreProduct: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_PRODUCT)! } }
        internal static var updateUserAccount: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_USER_ACCOUNT)! } }
        internal static var updateUserAvatar: URL { get { return URL(string: NSOAPI.baseAPIPath + self.ENDPOINT_UPDATE_USER_AVATAR)! } }
        
        
        
}

public struct NSOWebPath {
        // MARK: - Webpage Paths
        
        
        private static let PATH_PRIVACY = "privacy"
        private static let PATH_TERMS = "tos"
        
        
        // MARK: - Webpage URLs
        
        
        public static var privacy: URL { get { return URL(string: NSOAPI.basePath + self.PATH_PRIVACY)! } }
        public static var tos: URL { get { return URL(string: NSOAPI.basePath + self.PATH_TERMS)! } }
}
