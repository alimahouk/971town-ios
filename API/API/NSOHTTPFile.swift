//
//  NSOHTTPFile.swift
//  API
//
//  Created by Ali Mahouk on 15/02/2023.
//

import UIKit


internal class NSOHTTPFile {
        internal let fileData: Data?
        internal let fileHash: String
        internal let filename: String
        internal let mimeType: String
        
        init?(image: UIImage,
              filename: String? = nil,
              fileFormat: NSOFileFormat) {
                var data: Data?
                
                if fileFormat == .jpg {
                        data = image.jpegData(compressionQuality: 0.8)
                } else if fileFormat == .png {
                        data = image.pngData()
                }
                
                if let data = data {
                        self.fileData = data
                        self.fileHash = data.SHA256()
                        self.mimeType = NSOHTTPFile.mimeType(forImageData: data)!
                        
                        if let filename = filename {
                                self.filename = filename
                        } else {
                                self.filename = UUID().uuidString + "." + NSOHTTPFile.fileExtension(forImageData: data)!
                        }
                } else {
                        return nil
                }
        }
        
        private static func fileExtension(forImageData data: Data) -> String? {
                var ret: String? = nil
                var values = [UInt8](repeating: 0,
                                     count: 1)
                data.copyBytes(to: &values,
                               count: 1)
                
                switch values[0] {
                case 0xff:
                        ret = "jpg"
                case 0x89:
                        ret = "png"
                case 0x47:
                        ret = "gif"
                case 0x49, 0x4d:
                        ret = "tiff"
                default:
                        break
                }
                
                return ret
        }
        
        private static func mimeType(forImageData data: Data) -> String? {
                var ret: String? = nil
                var values = [UInt8](repeating: 0,
                                     count: 1)
                data.copyBytes(to: &values,
                               count: 1)
                
                switch values[0] {
                case 0xff:
                        ret = "image/jpeg"
                case 0x89:
                        ret = "image/png"
                case 0x47:
                        ret = "image/gif"
                case 0x49, 0x4d:
                        ret = "image/tiff"
                default:
                        break
                }
                
                return ret
        }
}
