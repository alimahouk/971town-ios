//
//  API.swift
//  API
//
//  Created by Ali Mahouk on 05/02/2023.
//

import Foundation
import KeychainSwift


public class NSOAPI {
        public class Configuration {
                internal enum AppMode {
                        case development
                        case testing
                        case production
                }
                
                internal static let awsS3MediaBucketName: String = "YOUR_AWS_S3_BUCKET_NAME"
                internal static let awsS3MediaBucketRegion: String = "YOUR_AWS_REGION"
                internal static let clientID: String = "YOUR_CLIENT_ID" // Replace with your client ID from the 971town API
                internal static let mode: AppMode = .development
                
                public static let productMediaFileCountLimit: Int = 6
                public static let mentionSequence: String = "@"
                public static let verificationCodeLength: Int = 6
                public static let verificationCodeResendInterval: CGFloat = 30.0 // Seconds
                public static let verificationCodeTTL: CGFloat = 1800.0 // Seconds
        }
        
        
        private static let firstRunFlag: String = "NotFirstRun"
        private let urlSessionConfiguration: URLSessionConfiguration
        
        internal static let APIHostPortDev: String = "8000"
        internal static let APIHostnameDev: String = "localhost" // Default to localhost for development
        internal static let APIHostnameProduction: String = "YOUR_PRODUCTION_HOSTNAME"
        internal static let APIPathV1: String = "/api/v1/"
        internal static var baseAPIPath: String { get { return NSOAPI.basePath + NSOAPI.APIPathV1 } }
        internal static var baseMediaPath: String {
                get {
                        var ret: String
                        
                        if Configuration.mode == .development {
                                ret = NSOAPI.basePath + "static/media/"
                        } else {
                                ret = "https://\(Configuration.awsS3MediaBucketName).s3.\(Configuration.awsS3MediaBucketRegion).amazonaws.com/"
                        }
                        
                        return ret
                }
        }
        internal static var basePath: String {
                get {
                        var ret: String
                        
                        if Configuration.mode == .development {
                                ret = "http://\(NSOAPI.APIHostnameDev):\(NSOAPI.APIHostPortDev)/"
                        } else {
                                ret = "https://\(NSOAPI.APIHostnameProduction)/"
                        }
                        
                        return ret
                }
        }
        
        public var currentSession: NSOUserAccountSession?
        public var currentUserAccount: NSOUserAccount?
        public static let shared = NSOAPI()
        
        
        // MARK: -
        
        
        private init() {
                self.urlSessionConfiguration = URLSessionConfiguration.default
                self.urlSessionConfiguration.httpAdditionalHeaders = ["User-Agent": UserAgent.UserAgentString()]
                
                self.loadCurrentSessionInfo()
        }
        
        private func deleteCurrentSessionInfo() -> Bool {
                let keychain = KeychainSwift()
                let accountIDDeleteSuccess = keychain.delete(NSOProtocolKey.userAccountID.rawValue)
                let sessionIDDeleteSuccess = keychain.delete(NSOProtocolKey.userAccountSessionID.rawValue)
                let success = (accountIDDeleteSuccess && sessionIDDeleteSuccess)
                
                if success {
                        self.currentSession = nil
                        self.currentUserAccount = nil
                }
                
                return success
        }
        
        private func getCurrentUserAccount() {
                self.me(
                        responseHandler: { apiResponse, errorResponse, networkError in
                                if let networkError = networkError {
                                        print(networkError)
                                } else if let errorResponse = errorResponse {
                                        if errorResponse.error.errorCode == .unauthorized {
                                                self.logOut(responseHandler: { _, _, _ in })
                                        }
                                } else if let apiResponse = apiResponse {
                                        self.currentUserAccount = apiResponse.userAccount
                                        
                                        DispatchQueue.main.async {
                                                NotificationCenter.default.post(name: .NSOCurrentUserAccountFetched,
                                                                                object: nil)
                                        }
                                }
                        }
                )
        }
        
        private func loadCurrentSessionInfo() {
                let keychain = KeychainSwift()
                
                if let accountID = keychain.get(NSOProtocolKey.userAccountID.rawValue) {
                        self.currentUserAccount = NSOUserAccount(id: Int(accountID))
                } else  {
                        print("No user account ID found in Keychain.")
                }
                
                if let sessionID = keychain.get(NSOProtocolKey.userAccountSessionID.rawValue) {
                        self.currentSession = NSOUserAccountSession(id: sessionID)
                        
                        // Set the session ID as a cookie for all URLSession requests.
                        let cookieProps: [HTTPCookiePropertyKey: Any]
                        
                        if Configuration.mode == .development {
                                cookieProps  = [
                                        HTTPCookiePropertyKey.domain: NSOAPI.APIHostnameDev,
                                        HTTPCookiePropertyKey.path: "/",
                                        HTTPCookiePropertyKey.name: NSOProtocolKey.userAccountSessionID.rawValue,
                                        HTTPCookiePropertyKey.value: self.currentSession!.id!
                                ]
                        } else {
                                cookieProps = [
                                        HTTPCookiePropertyKey.domain: NSOAPI.APIHostnameProduction,
                                        HTTPCookiePropertyKey.path: "/",
                                        HTTPCookiePropertyKey.name: NSOProtocolKey.userAccountSessionID.rawValue,
                                        HTTPCookiePropertyKey.value: self.currentSession!.id!,
                                        HTTPCookiePropertyKey.secure: "TRUE"
                                ]
                        }
                        
                        let cookie = HTTPCookie(properties: cookieProps)
                        self.urlSessionConfiguration.httpCookieStorage?.setCookie(cookie!)
                } else {
                        print("No session ID found in Keychain.")
                }
                
                /*
                 * Keychain values remain even after the app gets deleted and reinstalled.
                 * UserDefaults get wiped out. Set a flag to help us know whether any
                 * existing Keychain values are from the current installation or a previous
                 * one. If they're from a previous installation, delete them by logging out.
                 */
                let notFirstRun = UserDefaults.standard.bool(forKey: NSOAPI.firstRunFlag)
                
                if !notFirstRun {
                        if self.currentSession != nil {
                                self.logOut(
                                        responseHandler: { apiResponse, errorResponse, networkError in
                                                if apiResponse != nil || errorResponse != nil {
                                                        UserDefaults.standard.set(true,
                                                                                  forKey: NSOAPI.firstRunFlag)
                                                }
                                        }
                                )
                        } else {
                                UserDefaults.standard.set(true,
                                                          forKey: NSOAPI.firstRunFlag)
                        }
                } else {
                        if self.currentSession != nil {
                                self.heartbeat(
                                        responseHandler: { apiResponse, errorResponse, networkError in
                                                if let networkError = networkError {
                                                        print(networkError)
                                                } else if let errorResponse = errorResponse {
                                                        if errorResponse.error.errorCode == .unauthorized {
                                                                self.logOut(responseHandler: { _, _, _ in })
                                                        }
                                                } else if apiResponse != nil {
                                                        self.getCurrentUserAccount()
                                                }
                                        }
                                )
                        }
                }
        }
        
        private func storeCurrentSessionInfo(userAccount: NSOUserAccount,
                                             session: NSOUserAccountSession) -> Bool {
                let keychain = KeychainSwift()
                let accountIDStorageSuccess = keychain.set(String(userAccount.id!),
                                                           forKey: NSOProtocolKey.userAccountID.rawValue)
                let sessionIDStorageSuccess = keychain.set(session.id!,
                                                           forKey: NSOProtocolKey.userAccountSessionID.rawValue)
                let success = (accountIDStorageSuccess && sessionIDStorageSuccess)
                
                if success {
                        self.currentSession = session
                        self.currentUserAccount = userAccount
                }
                
                return success
        }
        
        
        // MARK: - API Calls
        
        
        public func checkAlias(request: NSOCheckAliasRequest,
                               responseHandler: @escaping (NSOCheckAliasResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.alias.rawValue: request.alias
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.checkAlias)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOCheckAliasResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func checkVerificationCode(request: NSOCheckVerificationCodeRequest,
                                          responseHandler: @escaping (NSOCheckVerificationCodeResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.code.rawValue: request.code.SHA256(),
                        NSOProtocolKey.phoneNumberID.rawValue: request.phoneNumberID
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.checkVerificationCode)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOCheckVerificationCodeResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func createBrand(request: NSOCreateBrandRequest,
                                responseHandler: @escaping (NSOCreateBrandResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [
                        NSOProtocolKey.alias.rawValue: request.alias,
                        NSOProtocolKey.name.rawValue: request.name
                ] as [String : Any]
                
                var tagBuffer = Array<String>()
                
                for tag in request.tags {
                        tagBuffer.append(tag.name!)
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: tagBuffer,
                                                          options: []) {
                        parameters[NSOProtocolKey.tags.rawValue] = String(data: data,
                                                                          encoding: .utf8)
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.createBrand)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOCreateBrandResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                                
                                                DispatchQueue.main.async {
                                                        NotificationCenter.default.post(name: .NSOCreatedBrand,
                                                                                        object: apiResponse.brand)
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func createProduct(request: NSOCreateProductRequest,
                                responseHandler: @escaping (NSOCreateProductResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [
                        NSOProtocolKey.alias.rawValue: request.alias,
                        NSOProtocolKey.brandID.rawValue: request.brandID,
                        NSOProtocolKey.name.rawValue: request.name
                ] as [String : Any]
                
                if let parentProductID = request.parentProductID {
                        parameters[NSOProtocolKey.parentProductID.rawValue] = parentProductID
                }
                
                var tagBuffer = Array<String>()
                
                for tag in request.tags {
                        tagBuffer.append(tag.name!)
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: tagBuffer,
                                                          options: []) {
                        parameters[NSOProtocolKey.tags.rawValue] = String(data: data,
                                                                          encoding: .utf8)
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.createProduct)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOCreateProductResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                                
                                                DispatchQueue.main.async {
                                                        NotificationCenter.default.post(name: .NSOCreatedProduct,
                                                                                        object: apiResponse.product)
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getBrand(request: NSOGetBrandRequest,
                             responseHandler: @escaping (NSOGetBrandResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [:] as [String : Any]
                
                if let brandID = request.brandID {
                        parameters = [
                                NSOProtocolKey.brandID.rawValue: brandID
                        ]
                } else if let alias = request.alias {
                        parameters = [
                                NSOProtocolKey.alias.rawValue: alias
                        ]
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getBrand)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetBrandResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getBrands(request: NSOGetBrandsRequest,
                              responseHandler: @escaping (NSOGetBrandsResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.query.rawValue: request.query
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getBrands)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetBrandsResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getCountryList(request: NSOGetCountryListRequest,
                                   responseHandler: @escaping (NSOGetCountryListResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.isEnabled.rawValue: request.isEnabled
                ] as [String : Any]
                
                var request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getCountryList)
                request.cachePolicy = .useProtocolCachePolicy
                
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetCountryListResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getDialingCodeList(request: NSOGetDialingCodeListRequest,
                                       responseHandler: @escaping (NSOGetDialingCodeListResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.isEnabled.rawValue: request.isEnabled
                ] as [String : Any]
                
                var request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getDialingCodeList)
                request.cachePolicy = .useProtocolCachePolicy
                
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetDialingCodeListResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getProduct(request: NSOGetProductRequest,
                               responseHandler: @escaping (NSOGetProductResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [:] as [String : Any]
                
                if let productID = request.productID {
                        parameters = [
                                NSOProtocolKey.productID.rawValue: productID
                        ]
                } else if let alias = request.alias {
                        parameters = [
                                NSOProtocolKey.alias.rawValue: alias
                        ]
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getProduct)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetProductResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getProductColorList(responseHandler: @escaping (NSOGetProductColorListResponse?, NSOErrorResponse?, Error?) -> ()) {
                var request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: nil,
                                                 url: NSOEndpoints.getProductColorList)
                request.cachePolicy = .useProtocolCachePolicy
                
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetProductColorListResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getProductMaterialList(responseHandler: @escaping (NSOGetProductMaterialListResponse?, NSOErrorResponse?, Error?) -> ()) {
                var request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: nil,
                                                 url: NSOEndpoints.getProductMaterialList)
                request.cachePolicy = .useProtocolCachePolicy
                
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetProductMaterialListResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getProductVariants(request: NSOGetProductVariantsRequest,
                                       responseHandler: @escaping (NSOGetProductVariantsResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.offset.rawValue: request.offset,
                        NSOProtocolKey.parentProductID.rawValue: request.parentProductID
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getProductVariants)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetProductVariantsResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func getProducts(request: NSOGetProductsRequest,
                                responseHandler: @escaping (NSOGetProductsResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters: [String : Any] = [:]
                
                if let brandID = request.brandID {
                        parameters[NSOProtocolKey.brandID.rawValue] = brandID
                } else if let query = request.query {
                        parameters[NSOProtocolKey.query.rawValue] = query
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.getProducts)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetProductsResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func heartbeat(responseHandler: @escaping (NSOHeartbeatResponse?, NSOErrorResponse?, Error?) -> ()) {
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: nil,
                                                 url: NSOEndpoints.heartbeat)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOHeartbeatResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func join(request: NSOJoinRequest,
                         responseHandler: @escaping (NSOJoinResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.alias.rawValue: request.alias,
                        NSOProtocolKey.code.rawValue: request.code.SHA256(),
                        NSOProtocolKey.clientID.rawValue: request.clientID,
                        NSOProtocolKey.phoneNumberID.rawValue: request.phoneNumberID
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.join)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOJoinResponse.self,
                                                                                           from: data)
                                                
                                                // Store session info.
                                                if self.storeCurrentSessionInfo(userAccount: apiResponse.userAccount,
                                                                                session: apiResponse.userAccountSession) {
                                                        responseHandler(apiResponse, nil, nil)
                                                        
                                                        DispatchQueue.main.async {
                                                                NotificationCenter.default.post(name: .NSOUserAccountJoined,
                                                                                                object: nil)
                                                        }
                                                } else {
                                                        responseHandler(nil, nil, NSOAppError(errorDescription: "Could not store session info in Keychain."))
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func logIn(request: NSOLogInRequest,
                          responseHandler: @escaping (NSOLogInResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.code.rawValue: request.code.SHA256(),
                        NSOProtocolKey.clientID.rawValue: request.clientID,
                        NSOProtocolKey.phoneNumberID.rawValue: request.phoneNumberID,
                        NSOProtocolKey.userAccountID.rawValue: request.userAccountID
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.logIn)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOLogInResponse.self,
                                                                                           from: data)
                                                
                                                // Store session info.
                                                if self.storeCurrentSessionInfo(userAccount: apiResponse.userAccount,
                                                                                session: apiResponse.userAccountSession) {
                                                        responseHandler(apiResponse, nil, nil)
                                                        
                                                        DispatchQueue.main.async {
                                                                NotificationCenter.default.post(name: .NSOUserAccountLoggedIn,
                                                                                                object: nil)
                                                        }
                                                } else {
                                                        responseHandler(nil, nil, NSOAppError(errorDescription: "Could not store session info in Keychain."))
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func logOut(responseHandler: @escaping (NSOLogOutResponse?, NSOErrorResponse?, Error?) -> ()) {
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: nil,
                                                 url: NSOEndpoints.logOut)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOLogOutResponse.self,
                                                                                           from: data)
                                                
                                                // Delete session info.
                                                if self.deleteCurrentSessionInfo() {
                                                        responseHandler(apiResponse, nil, nil)
                                                        
                                                        DispatchQueue.main.async {
                                                                NotificationCenter.default.post(name: .NSOUserAccountLoggedOut,
                                                                                                object: nil)
                                                        }
                                                } else {
                                                        responseHandler(nil, nil, NSOAppError(errorDescription: "Could not delete session info from Keychain."))
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        
                                                        /*
                                                         * In case the session was deleted on the server, the one sent by the device will
                                                         * return an error but it should still be treated as a logout.
                                                         */
                                                        if self.deleteCurrentSessionInfo() {
                                                                responseHandler(nil, errorResponse, nil)
                                                                
                                                                DispatchQueue.main.async {
                                                                        NotificationCenter.default.post(name: .NSOUserAccountKickedOut,
                                                                                                        object: nil)
                                                                }
                                                        } else {
                                                                responseHandler(nil, nil, NSOAppError(errorDescription: "Could not delete session info from Keychain."))
                                                        }
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func me(responseHandler: @escaping (NSOGetUserAccountResponse?, NSOErrorResponse?, Error?) -> ()) {
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: nil,
                                                 url: NSOEndpoints.me)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOGetUserAccountResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func sendVerificationCode(request: NSOSendVerificationCodeRequest,
                                         responseHandler: @escaping (NSOSendVerificationCodeResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.alpha2Code.rawValue: request.phoneNumber.dialingCode!.country!.alpha2Code!,
                        NSOProtocolKey.dialingCode.rawValue: request.phoneNumber.dialingCode!.code!,
                        NSOProtocolKey.phoneNumber.rawValue: request.phoneNumber.phoneNumber!
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.sendVerificationCode)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOSendVerificationCodeResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func updateBrand(request: NSOUpdateBrandRequest,
                                responseHandler: @escaping (NSOUpdateBrandResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [
                        NSOProtocolKey.brandID.rawValue: request.brandID,
                        NSOProtocolKey.name.rawValue: request.name
                ] as [String : Any]
                
                if let description = request.description {
                        parameters[NSOProtocolKey.description.rawValue] = description
                }
                
                if let website = request.website {
                        parameters[NSOProtocolKey.website.rawValue] = website.absoluteString
                }
                
                var tagBuffer = Array<String>()
                
                for tag in request.tags {
                        tagBuffer.append(tag.name!)
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: tagBuffer,
                                                          options: []) {
                        parameters[NSOProtocolKey.tags.rawValue] = String(data: data,
                                                                          encoding: .utf8)
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.updateBrand)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOUpdateBrandResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                                
                                                DispatchQueue.main.async {
                                                        NotificationCenter.default.post(name: .NSOUpdatedBrand,
                                                                                        object: apiResponse.brand)
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func updateProduct(request: NSOUpdateProductRequest,
                                  responseHandler: @escaping (NSOUpdateProductResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [
                        NSOProtocolKey.productID.rawValue: request.productID,
                        NSOProtocolKey.name.rawValue: request.name,
                        NSOProtocolKey.overridesDisplayName.rawValue: request.overridesDisplayName,
                        NSOProtocolKey.status.rawValue: request.status.rawValue
                ] as [String : Any]
                
                if let description = request.description {
                        parameters[NSOProtocolKey.description.rawValue] = description
                }
                
                if let mainColorCode = request.mainColorCode {
                        parameters[NSOProtocolKey.mainColorCode.rawValue] = mainColorCode
                }
                
                if let materialID = request.materialID {
                        parameters[NSOProtocolKey.materialID.rawValue] = materialID
                }
                
                if let parentProductID = request.parentProductID {
                        parameters[NSOProtocolKey.parentProductID.rawValue] = parentProductID
                }
                
                if let preorderTimestampString = request.preorderTimestampString {
                        parameters[NSOProtocolKey.preorderTimestamp.rawValue] = preorderTimestampString
                }
                
                if let releaseTimestampString = request.releaseTimestampString {
                        parameters[NSOProtocolKey.releaseTimestamp.rawValue] = releaseTimestampString
                }
                
                if let upc = request.upc {
                        parameters[NSOProtocolKey.upc.rawValue] = upc
                }
                
                if let url = request.url {
                        parameters[NSOProtocolKey.url.rawValue] = url.absoluteString
                }
                
                var tagBuffer = Array<String>()
                
                for tag in request.tags {
                        tagBuffer.append(tag.name!)
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: tagBuffer,
                                                          options: []) {
                        parameters[NSOProtocolKey.tags.rawValue] = String(data: data,
                                                                          encoding: .utf8)
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.updateProduct)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOUpdateProductResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                                
                                                DispatchQueue.main.async {
                                                        NotificationCenter.default.post(name: .NSOUpdatedProduct,
                                                                                        object: apiResponse.product)
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func updateProductMedia(request: NSOUpdateProductMediaRequest,
                                       responseHandler: @escaping (NSOUpdateProductMediaResponse?, NSOErrorResponse?, Error?) -> ()) {
                var parameters = [
                        NSOProtocolKey.productID.rawValue: request.productID,
                        NSOProtocolKey.mediaMode.rawValue: request.mediaMode.rawValue
                ] as [String : Any]
                
                var metadata: [String : Any] = [:]
                
                for (key, medium_metadata) in request.metadata {
                        metadata[key] = medium_metadata
                        
                        if let medium = request.media[key] {
                                let medium_file = NSOHTTPFile(image: medium as UIImage,
                                                              fileFormat: .jpg)!
                                
                                parameters[key] = medium_file
                        }
                }
                
                if let data = try? JSONSerialization.data(withJSONObject: metadata,
                                                          options: []) {
                        parameters[NSOProtocolKey.media.rawValue] = String(data: data,
                                                                           encoding: .utf8)
                }
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.updateProductMedia)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOUpdateProductMediaResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                                
                                                DispatchQueue.main.async {
                                                        NotificationCenter.default.post(name: .NSOUpdatedProductMedia,
                                                                                        object: apiResponse)
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
        
        public func updateBrandAvatar(request: NSOUpdateBrandAvatarRequest,
                                      responseHandler: @escaping (NSOUpdateBrandAvatarResponse?, NSOErrorResponse?, Error?) -> ()) {
                let parameters = [
                        NSOProtocolKey.avatar.rawValue: NSOHTTPFile(image: request.avatar,
                                                                    fileFormat: .jpg)!,
                        NSOProtocolKey.brandID.rawValue: request.brandID,
                        NSOProtocolKey.mediaMode.rawValue: request.mediaMode.rawValue
                ] as [String : Any]
                
                let request = NSOHTTPRequest.new(method: "POST",
                                                 parameters: parameters,
                                                 url: NSOEndpoints.updateBrandAvatar)
                let session = URLSession(configuration: self.urlSessionConfiguration,
                                         delegate: nil,
                                         delegateQueue: nil)
                let task = session.dataTask(
                        with: request,
                        completionHandler: { data, response, error in
                                if error != nil {
                                        responseHandler(nil, nil, NSONetworkError(errorDescription: error?.localizedDescription))
                                } else if let data = data {
                                        do {
                                                let apiResponse = try JSONDecoder().decode(NSOUpdateBrandAvatarResponse.self,
                                                                                           from: data)
                                                responseHandler(apiResponse, nil, nil)
                                                
                                                DispatchQueue.main.async {
                                                        NotificationCenter.default.post(name: .NSOUpdatedBrandAvatar,
                                                                                        object: apiResponse)
                                                }
                                        } catch {
                                                do {
                                                        let errorResponse = try JSONDecoder().decode(NSOErrorResponse.self,
                                                                                                     from: data)
                                                        responseHandler(nil, errorResponse, nil)
                                                } catch {
                                                        responseHandler(nil, nil, NSONetworkError(errorDescription: "Could not parse returned data."))
                                                }
                                        }
                                }
                        }
                )
                task.resume()
        }
}
