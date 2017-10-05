//
//  Common.swift
//  Lambda
//
//  Created by Dmitry Pimenov on 7/1/17.
//  Copyright © 2017 Dmitry. All rights reserved.
//

import Foundation
import CoreLocation

let usCountryCode = "US"

func matches(for regex: String, in text: String) -> [String: NSRange] {
    
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let nsString = text as NSString
        let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        var resp = [String: NSRange]()
        for result in results {
            resp[nsString.substring(with:result.range)] = result.range
        }
        return resp
        
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return [:]
    }
}


func isValidLocation() -> Bool {
    if CLLocationManager.locationServicesEnabled() {
        let countryCode = NSLocale.current.regionCode;
        return countryCode == usCountryCode
    } else {
        return false
    }
}
