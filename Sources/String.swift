//
//  String.swift
//  md-tree
//
//  Created by AtsuyaSato on 2017/05/25.
//
//

import Foundation

extension String{
    func headLineLevel() -> Int{
        do {
            let regxp = try NSRegularExpression(
                pattern: "(#*)\\s.*", options: [])
            let result = regxp.firstMatch(in: self, options: [], range: NSMakeRange(0, (self as NSString).length))
            guard let headLineRange = result?.rangeAt(1) else { return 0 }
            
            let headLine = String(NSString(string: self).substring(with: headLineRange))!
            
            return headLine.characters.count
        } catch {
            return 0
        }
    }
}
