//
//  NSOUserAccount.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOUserAccount: Codable,
                             Comparable,
                             Hashable,
                             NSCopying {
        public var alias: String?
        public var bio: String?
        public var creationTimestamp: Date?
        public var id: Int?
        public var isAdmin: Bool?
        public var rep: Int?
        public var sessions: Array<NSOUserAccountSession> = []
        public var userID: Int?
        public var website: URL?
        
        enum CodingKeys: String, CodingKey {
                case alias
                case bio
                case creationTimestamp = "creation_timestamp"
                case id
                case isAdmin = "is_admin"
                case rep
                case sessions
                case userID = "user_id"
                case website
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.alias = try container.decodeIfPresent(String.self,
                                                           forKey: .alias)
                self.bio = try container.decodeIfPresent(String.self,
                                                         forKey: .bio)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.isAdmin = try container.decodeIfPresent(Bool.self,
                                                             forKey: .isAdmin)
                self.rep = try container.decodeIfPresent(Int.self,
                                                         forKey: .rep)
                self.userID = try container.decodeIfPresent(Int.self,
                                                            forKey: .userID)
                self.website = try container.decodeIfPresent(URL.self,
                                                             forKey: .website)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
                
                if let sessions = try container.decodeIfPresent([NSOUserAccountSession].self,
                                                                forKey: .sessions) {
                        self.sessions = sessions
                } else {
                        self.sessions = []
                }
        }
        
        init(alias: String? = nil,
             bio: String? = nil,
             creationTimestamp: Date? = nil,
             id: Int? = nil,
             isAdmin: Bool? = nil,
             rep: Int? = nil,
             sessions: Array<NSOUserAccountSession> = [],
             userID: Int? = nil,
             website: URL? = nil) {
                self.alias = alias
                self.bio = bio
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.isAdmin = isAdmin
                self.rep = rep
                self.sessions = sessions
                self.userID = userID
                self.website = website
        }
        
        public static func == (lhs: NSOUserAccount,
                               rhs: NSOUserAccount) -> Bool {
                return lhs.id == rhs.id
        }
        
        public static func < (lhs: NSOUserAccount,
                              rhs: NSOUserAccount) -> Bool {
                guard let lhsName = lhs.alias, let rhsName = rhs.alias else { return false }
                return lhsName.localizedCaseInsensitiveCompare(rhsName) == .orderedAscending
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                let copy = NSOUserAccount(
                        alias: self.alias,
                        bio: self.bio,
                        creationTimestamp: self.creationTimestamp,
                        id: self.id,
                        isAdmin: self.isAdmin,
                        rep: self.rep,
                        sessions: self.sessions.map { $0.copy() } as! [NSOUserAccountSession],
                        userID: self.userID,
                        website: self.website
                )
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
