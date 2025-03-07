//
//  NSOUserAccountSession.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOUserAccountSession: Codable,
                                    Hashable,
                                    NSCopying {
        public var creationTimestamp: Date?
        public var id: String?
        public var userAccountID: Int?
        
        enum CodingKeys: String, CodingKey {
                case creationTimestamp = "creation_timestamp"
                case id
                case userAccountID = "user_account_id"
        }
        
        
        public required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decodeIfPresent(String.self,
                                                        forKey: .id)
                self.userAccountID = try container.decodeIfPresent(Int.self,
                                                                   forKey: .userAccountID)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(creationTimestamp: Date? = nil,
                    id: String? = nil,
                    userAccountID: Int? = nil) {
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.userAccountID = userAccountID
        }
        
        public static func == (lhs: NSOUserAccountSession,
                               rhs: NSOUserAccountSession) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                let copy = NSOUserAccountSession(creationTimestamp: self.creationTimestamp,
                                                 id: self.id,
                                                 userAccountID: self.userAccountID)
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
