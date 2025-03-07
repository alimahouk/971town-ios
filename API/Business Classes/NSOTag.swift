//
//  NSOTag.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOTag: Codable,
                     Hashable,
                     NSCopying {
        public var creationTimestamp: Date?
        public var creatorID: Int?
        public var id: Int?
        public var name: String?
        
        enum CodingKeys: String, CodingKey {
                case creationTimestamp = "creation_timestamp"
                case creatorID = "creator_id"
                case id
                case name
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.creatorID = try container.decodeIfPresent(Int.self,
                                                               forKey: .creatorID)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.name = try container.decodeIfPresent(String.self,
                                                          forKey: .name)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(creationTimestamp: Date? = nil,
                    creatorID: Int? = nil,
                    id: Int? = nil,
                    name: String? = nil) {
                self.creationTimestamp = creationTimestamp
                self.creatorID = creatorID
                self.id = id
                
                if var name = name {
                        // Tags cannot contain punctuation or whitespace.
                        name = String(name.unicodeScalars.filter(CharacterSet.whitespacesAndNewlines.inverted.contains))
                        name = String(name.unicodeScalars.filter(CharacterSet.punctuationCharacters.inverted.contains))
                        
                        if !name.isEmpty {
                                // Tags are always lowercase.
                                name = name.lowercased()
                                self.name = name
                        }
                }
        }
        
        public static func == (lhs: NSOTag,
                               rhs: NSOTag) -> Bool {
                var ret = false
                
                if lhs.id != nil && rhs.id != nil {
                        if lhs.id == rhs.id {
                                ret = true
                        }
                } else if lhs.name == rhs.name {
                        ret = true
                }
                
                return ret
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                let copy = NSOTag(
                        creationTimestamp: self.creationTimestamp,
                        creatorID: self.creatorID,
                        id: self.id,
                        name: self.name
                )
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                if self.id != nil {
                        hasher.combine(self.id)
                } else {
                        hasher.combine(self.name)
                }
        }
}
