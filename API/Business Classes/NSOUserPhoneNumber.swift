//
//  NSOUserPhoneNumber.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOUserPhoneNumber: Codable, Hashable {
        public var creationTimestamp: Date?
        public var dialingCode: NSOCountryDialingCode?
        public var id: Int?
        public var isVerified: Bool?
        public var phoneNumber: String?
        public var userID: Int?
        
        enum CodingKeys: String, CodingKey {
                case creationTimestamp = "creation_timestamp"
                case dialingCode = "dialing_code"
                case id
                case isVerified = "is_verified"
                case phoneNumber = "phone_number"
                case userID = "user_id"
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.dialingCode = try container.decodeIfPresent(NSOCountryDialingCode.self,
                                                                 forKey: .dialingCode)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.isVerified = try container.decodeIfPresent(Bool.self,
                                                                forKey: .isVerified)
                self.phoneNumber = try container.decodeIfPresent(String.self,
                                                                 forKey: .phoneNumber)
                self.userID = try container.decodeIfPresent(Int.self,
                                                            forKey: .userID)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(creationTimestamp: Date? = nil,
                    dialingCode: NSOCountryDialingCode? = nil,
                    id: Int? = nil,
                    isVerified: Bool? = nil,
                    phoneNumber: String? = nil,
                    userID: Int? = nil) {
                self.creationTimestamp = creationTimestamp
                self.dialingCode = dialingCode
                self.id = id
                self.isVerified = isVerified
                self.phoneNumber = phoneNumber
                self.userID = userID
        }
        
        public static func == (lhs: NSOUserPhoneNumber,
                               rhs: NSOUserPhoneNumber) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
