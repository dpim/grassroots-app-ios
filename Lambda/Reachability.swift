//
//  Reachability.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 5/21/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import SystemConfiguration

public class Reachability {
    //from: http://stackoverflow.com/questions/25623272/how-to-use-scnetworkreachability-in-swift/25623647#25623647
    class func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        isValidLocation()
        return (isReachable && !needsConnection)
    }
}
