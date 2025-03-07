//
//  Crypto.swift
//  API
//
//  Created by Ali Mahouk on 07/02/2023.
//

import CommonCrypto
import Foundation


extension Data {
        private func digest(input : NSData) -> NSData {
                let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
                var hash = [UInt8](repeating: 0,
                                   count: digestLength)
                CC_SHA256(input.bytes, UInt32(input.length), &hash)
                
                return NSData(bytes: hash,
                              length: digestLength)
        }
        
        private  func hexStringFromData(input: NSData) -> String {
                var bytes = [UInt8](repeating: 0,
                                    count: input.length)
                input.getBytes(&bytes, length: input.length)
                
                var hexString = ""
                
                for byte in bytes {
                        hexString += String(format:"%02x", UInt8(byte))
                }
                
                return hexString
        }
        
        public func SHA256() -> String {
                return hexStringFromData(input: digest(input: self as NSData))
        }
}

public extension String {
        func SHA256() -> String {
                var ret = ""
                
                if let stringData = self.data(using: .utf8) {
                        ret = stringData.SHA256()
                }
                
                return ret
        }
}
