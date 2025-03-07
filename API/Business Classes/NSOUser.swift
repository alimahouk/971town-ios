//
//  NSOUser.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOUser: Codable, Hashable {
        public var creationTimestamp: Date?
        public var id: Int?
        public var phoneNumber: NSOUserPhoneNumber?
        
        enum CodingKeys: String, CodingKey {
                case creationTimestamp = "creation_timestamp"
                case id
                case phoneNumber = "phone_number"
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.phoneNumber = try container.decodeIfPresent(NSOUserPhoneNumber.self,
                                                                 forKey: .phoneNumber)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(creationTimestamp: Date? = nil,
                    id: Int? = nil,
                    phoneNumber: NSOUserPhoneNumber? = nil) {
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.phoneNumber = phoneNumber
        }
        
        public static func == (lhs: NSOUser,
                               rhs: NSOUser) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
