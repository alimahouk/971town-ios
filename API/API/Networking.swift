//
//  Networking.swift
//  API
//
//  Created by Ali Mahouk on 08/02/2023.
//

import UIKit


class UserAgent {
        // e.g. Darwin/16.3.0
        static func DarwinVersion() -> String {
                var sysinfo = utsname()
                uname(&sysinfo)
                let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)),
                                encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
                
                return "Darwin/\(dv)"
        }
        
        // e.g. CFNetwork/808.3
        static func CFNetworkVersion() -> String {
                let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
                let version = dictionary?["CFBundleShortVersionString"] as! String
                
                return "CFNetwork/\(version)"
        }
        
        // e.g. iOS/10.1
        static func deviceVersion() -> String {
                let currentDevice = UIDevice.current
                
                return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
        }
        
        // e.g. iPhone5,2
        static func deviceName() -> String {
                var sysinfo = utsname()
                uname(&sysinfo)
                
                return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        }
        
        // e.g. MyApp/1.0
        static func appNameAndVersion() -> String {
                guard let dictionary = Bundle.main.infoDictionary else {
                        return ""
                }
                
                let version = dictionary["CFBundleShortVersionString"] as! String
                let name = dictionary["CFBundleName"] as! String
                
                return "\(name)/\(version)"
        }
        
        static func UserAgentString() -> String {
                return "\(appNameAndVersion()) \(deviceName()) \(deviceVersion()) \(CFNetworkVersion()) \(DarwinVersion())"
        }
}

func getPrivateIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
                var ptr = ifaddr
                
                while ptr != nil {
                        defer { ptr = ptr?.pointee.ifa_next }
                        guard let interface = ptr?.pointee else { return "" }
                        let addrFamily = interface.ifa_addr.pointee.sa_family
                        
                        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                                /*
                                 * wifi = ["en0"]
                                 * wired = ["en2", "en3", "en4"]
                                 * cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]
                                 */
                                let name: String = String(cString: (interface.ifa_name))
                                let interfaceNames: Set<String> = [
                                        "en0",
                                        "en2",
                                        "en3",
                                        "en4",
                                        "pdp_ip0",
                                        "pdp_ip1",
                                        "pdp_ip2",
                                        "pdp_ip3"
                                ]
                                
                                if interfaceNames.contains(name) {
                                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                                        getnameinfo(interface.ifa_addr,
                                                    socklen_t((interface.ifa_addr.pointee.sa_len)),
                                                    &hostname,
                                                    socklen_t(hostname.count),
                                                    nil,
                                                    socklen_t(0),
                                                    NI_NUMERICHOST)
                                        address = String(cString: hostname)
                                }
                        }
                }
                
                freeifaddrs(ifaddr)
        }
        
        return address ?? ""
}
