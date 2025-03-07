//
//  NSOProductMedium.swift
//  API
//
//  Created by Ali Mahouk on 26/03/2023.
//

import UIKit


public class NSOProductMedium: Codable,
                               Comparable,
                               Hashable {
        public var attribution: String?
        public var creationTimestamp: Date?
        public var creator: NSOUserAccount?
        public var creatorID: Int?
        public private(set) var fileHash: String?
        public var filePath: String?
        public var fileURL: URL? {
                get {
                        var ret: URL? = nil
                        
                        if let filePath = self.filePath {
                                ret = URL(string: NSOAPI.baseMediaPath + filePath)
                        }
                        
                        return ret
                }
        }
        public var id: Int?
        public var image: UIImage? {
                didSet {
                        var data: Data?
                        
                        if self.mediaFormat == .jpg {
                                data = self.image?.jpegData(compressionQuality: 0.8)
                        } else if self.mediaFormat == .png {
                                data = self.image?.pngData()
                        }
                        
                        if let data = data {
                                self.fileHash = data.SHA256()
                        }
                }
        }
        public var index: Int?
        public var media: AnyObject? {
                get {
                        var ret: AnyObject?
                        
                        if mediaType == .image {
                                ret = self.image
                        }
                        
                        return ret
                }
        }
        public var mediaFormat: NSOFileFormat?
        public var mediaMode: NSOMediaMode?
        public var mediaType: NSOMediaType?
        
        enum CodingKeys: String, CodingKey {
                case attribution
                case creationTimestamp = "creation_timestamp"
                case creator
                case creatorID = "creator_id"
                case filePath = "file_path"
                case id
                case index
                case mediaMode = "media_mode"
                case mediaType = "media_type"
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.attribution = try container.decodeIfPresent(String.self,
                                                             forKey: .attribution)
                self.creator = try container.decodeIfPresent(NSOUserAccount.self,
                                                             forKey: .creator)
                self.creatorID = try container.decodeIfPresent(Int.self,
                                                               forKey: .creatorID)
                self.filePath = try container.decodeIfPresent(String.self,
                                                              forKey: .filePath)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.index = try container.decode(Int.self,
                                                  forKey: .index)
                self.mediaMode = try container.decode(NSOMediaMode.self,
                                                      forKey: .mediaMode)
                self.mediaType = try container.decode(NSOMediaType.self,
                                                      forKey: .mediaType)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(attribution: String? = nil,
                    creationTimestamp: Date? = nil,
                    creator: NSOUserAccount? = nil,
                    creatorID: Int? = nil,
                    filePath: String? = nil,
                    id: Int? = nil,
                    image: UIImage? = nil,
                    index: Int? = nil,
                    mediaFormat: NSOFileFormat? = nil,
                    mediaMode: NSOMediaMode? = nil,
                    mediaType: NSOMediaType? = nil) {
                self.attribution = attribution
                self.creationTimestamp = creationTimestamp
                self.creator = creator
                self.creatorID = creatorID
                self.filePath = filePath
                self.id = id
                self.index = index
                self.mediaFormat = mediaFormat
                self.mediaMode = mediaMode
                self.mediaType = mediaType
                
                defer {
                        /// The file hash depends on other fields being set.
                        /// Set the image at the end.
                        self.image = image
                }
        }
        
        public static func == (lhs: NSOProductMedium,
                               rhs: NSOProductMedium) -> Bool {
                return lhs.id == rhs.id
        }
        
        public static func < (lhs: NSOProductMedium,
                              rhs: NSOProductMedium) -> Bool {
                return lhs.index! < rhs.index!
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                var imageCopy: UIImage? = nil
                
                if let image = self.image {
                        if let cgImage = image.cgImage?.copy() {
                                imageCopy = UIImage(cgImage: cgImage,
                                                    scale: image.scale,
                                                    orientation: image.imageOrientation)
                        }
                }
                
                let copy = NSOProductMedium(
                        attribution: self.attribution,
                        creationTimestamp: self.creationTimestamp,
                        creator: self.creator?.copy() as? NSOUserAccount,
                        creatorID: self.creatorID,
                        filePath: self.filePath,
                        id: self.id,
                        image: imageCopy,
                        index: self.index,
                        mediaFormat: self.mediaFormat,
                        mediaMode: self.mediaMode,
                        mediaType: self.mediaType
                )
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
