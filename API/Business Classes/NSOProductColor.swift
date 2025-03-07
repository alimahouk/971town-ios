//
//  NSOProductColor.swift
//  API
//
//  Created by Ali Mahouk on 26/03/2023.
//

import UIKit


public extension UIColor {
        convenience init(hex: String) {
                var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                var rgbValue: UInt64 = 0
                
                if (cString.hasPrefix("#")) {
                        cString.remove(at: cString.startIndex)
                }
                
                if (cString.count != 6) {
                        self.init(cgColor: UIColor.gray.cgColor)
                } else {
                        Scanner(string: cString).scanHexInt64(&rgbValue)
                        
                        self.init(
                                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                                alpha: CGFloat(1.0)
                        )
                }
        }
}


public class NSOProductColor: Codable, Hashable {
        public var hex: String
        public var name: String?
        
        
        public init(hex: String,
                    name: String? = nil) {
                self.hex = hex
                self.name = name
        }
        
        public static func == (lhs: NSOProductColor,
                               rhs: NSOProductColor) -> Bool {
                return lhs.hex == rhs.hex
        }
        
        public func copy(with zone: NSZone? = nil) -> Any {
                let copy = NSOProductColor(hex: self.hex,
                                           name: self.name)
                
                return copy
        }
        
        public func hash(into hasher: inout Hasher) {
                hasher.combine(self.hex)
        }
}
