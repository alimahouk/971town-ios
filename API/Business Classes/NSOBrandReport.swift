//
//  NSOBrandReport.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOBrandReport: Codable, Hashable {
        public var brand: NSOBrand?
        public var comment: String?
        public var creationTimestamp: Date?
        public var id: Int?
        public var reporterID: Int?
        public var type: NSOBrandReportType?
        
        enum CodingKeys: String, CodingKey {
                case brand
                case comment
                case creationTimestamp = "creation_timestamp"
                case id
                case reporterID = "reporter_id"
                case type
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.brand = try container.decodeIfPresent(NSOBrand.self,
                                                           forKey: .brand)
                self.comment = try container.decodeIfPresent(String.self,
                                                             forKey: .comment)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.reporterID = try container.decodeIfPresent(Int.self,
                                                                forKey: .reporterID)
                self.type = try container.decodeIfPresent(NSOBrandReportType.self,
                                                          forKey: .type)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(brand: NSOBrand? = nil,
                    comment: String? = nil,
                    creationTimestamp: Date? = nil,
                    id: Int? = nil,
                    reporterID: Int? = nil,
                    type: NSOBrandReportType? = nil) {
                self.brand = brand
                self.comment = comment
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.reporterID = reporterID
                self.type = type
        }
        
        public static func == (lhs: NSOBrandReport,
                               rhs: NSOBrandReport) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
