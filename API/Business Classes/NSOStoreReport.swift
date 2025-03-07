//
//  NSOStoreReport.swift
//  API
//
//  Created by Ali Mahouk on 06/02/2023.
//

import Foundation


public class NSOStoreReport: Codable, Hashable {
        public var comment: String?
        public var creationTimestamp: Date?
        public var id: Int?
        public var reporterID: Int?
        public var store: NSOStore?
        public var type: NSOStoreReportType?
        
        enum CodingKeys: String, CodingKey {
                case comment
                case creationTimestamp = "creation_timestamp"
                case id
                case reporterID = "reporter_id"
                case store
                case type
        }
        
        
        required public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.comment = try container.decodeIfPresent(String.self,
                                                             forKey: .comment)
                self.id = try container.decodeIfPresent(Int.self,
                                                        forKey: .id)
                self.reporterID = try container.decodeIfPresent(Int.self,
                                                                forKey: .reporterID)
                self.store = try container.decodeIfPresent(NSOStore.self,
                                                           forKey: .store)
                self.type = try container.decodeIfPresent(NSOStoreReportType.self,
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
                    reporterID: Int? = nil,
                    store: NSOStore? = nil,
                    type: NSOStoreReportType? = nil) {
                self.comment = comment
                self.creationTimestamp = creationTimestamp
                self.id = id
                self.reporterID = reporterID
                self.store = store
                self.type = type
        }
        
        public static func == (lhs: NSOStoreReport,
                               rhs: NSOStoreReport) -> Bool {
                return lhs.id == rhs.id
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.id)
        }
}
