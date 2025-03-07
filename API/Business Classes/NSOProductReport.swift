//
//  NSOProductReport.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOProductReport: Codable, Hashable {
        public var comment: String?
        public var creationTimestamp: Date?
        public var id: Int?
        public var product: NSOProduct?
        public var reporterID: Int?
        public var type: NSOProductReportType?
        
        enum CodingKeys: String, CodingKey {
                case comment
                case creationTimestamp = "creation_timestamp"
                case id
                case product
                case reporterID = "reporter_id"
                case type
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.comment = try container.decodeIfPresent(String.self,
                                                             forKey: .comment)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.product = try container.decodeIfPresent(NSOProduct.self,
                                                             forKey: .product)
                self.reporterID = try container.decodeIfPresent(Int.self,
                                                                forKey: .reporterID)
                self.type = try container.decodeIfPresent(NSOProductReportType.self,
                                                          forKey: .type)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                
                if let creationTimestamp = try container.decodeIfPresent(String.self,
                                                                         forKey: .creationTimestamp) {
                        self.creationTimestamp = dateFormatter.date(from: creationTimestamp)
                }
        }
        
        public init(comment: String? = nil,
                    creationTimestamp: Date? = nil,
                    id: Int? = nil,
                    product: NSOProduct? = nil,
                    reporterID: Int? = nil,
                    type: NSOProductReportType? = nil) {
                self.comment = comment
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.product = product
                self.reporterID = reporterID
                self.type = type
        }
        
        public static func == (lhs: NSOProductReport,
                               rhs: NSOProductReport) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
