//
//  NSOHTTPRequest.swift
//  API
//
//  Created by Ali Mahouk on 15/02/2023.
//

import Foundation


internal struct NSOHTTPRequest {
        private init() { }
        
        private static func isMultipartForm(parameters: Dictionary<String, Any>?) -> Bool {
                var isMultipart = false
                guard let parameters = parameters else { return isMultipart }
                
                for val in parameters.values {
                        if let _ = val as? NSOHTTPFile {
                                isMultipart = true
                                
                                break
                        }
                }
                
                return isMultipart
        }
        
        private static func multipartFormPOSTBody(forParameters parameters: Dictionary<String, Any>,
                                                  usingBoundary boundary: String) -> Data? {
                var body = Data()
                
                for (key, val) in parameters {
                        if let file = val as? NSOHTTPFile {
                                guard let fileData = file.fileData else { continue }
                                
                                var bodyStr = "--\(boundary)\r\n"
                                bodyStr += "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(file.filename)\"\r\n"
                                bodyStr += "Content-Type: \(file.mimeType)\r\n\r\n"
                                guard let fieldData = bodyStr.data(using: .utf8) else { continue }
                                body.append(fieldData)
                                body.append(fileData)
                                body.append("\r\n".data(using: .utf8)!)
                        } else {
                                var bodyStr = "--\(boundary)\r\n"
                                bodyStr += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                                bodyStr += "\(val)\r\n"
                                guard let fieldData = bodyStr.data(using: .utf8) else { continue }
                                body.append(fieldData)
                        }
                }
                
                guard let endData = "--\(boundary)--\r\n".data(using: .utf8) else { return nil }
                body.append(endData)
                
                return body
        }
        
        static func new(method: String,
                        parameters: Dictionary<String, Any>?,
                        url: URL) -> URLRequest {
                let boundary = UUID().uuidString
                
                var request = URLRequest(url: url,
                                         cachePolicy: .reloadIgnoringLocalCacheData)
                request.httpBody = NSOHTTPRequest.requestBody(forParameters: parameters,
                                                              usingBoundary: boundary)
                request.httpMethod = method
                
                if NSOHTTPRequest.isMultipartForm(parameters: parameters) {
                        request.setValue("multipart/form-data; boundary=\(boundary)",
                                         forHTTPHeaderField: "Content-Type")
                }
                
                return request
        }
        
        private static func requestBody(forParameters parameters: Dictionary<String, Any>?,
                                        usingBoundary boundary: String) -> Data? {
                var body: Data? = nil
                guard let parameters = parameters else { return body }
                
                if NSOHTTPRequest.isMultipartForm(parameters: parameters) {
                        body = NSOHTTPRequest.multipartFormPOSTBody(forParameters: parameters,
                                                                    usingBoundary: boundary)
                } else {
                        body = NSOHTTPRequest.regularPOSTBody(forParameters: parameters)
                }
                
                return body
        }
        
        private static func regularPOSTBody(forParameters parameters: Dictionary<String, Any>) -> Data? {
                var bodyStr = ""
                
                for (key, val) in parameters {
                        let valString = String(describing: val)
                                .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                                .replacingOccurrences(of: "&",
                                                      with: "%26")
                        bodyStr.append("\(key)=\(valString)&")
                }
                
                return bodyStr.data(using: .utf8)
        }
}
