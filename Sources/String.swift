//
//  String.swift
//  md-tree
//
//  Created by AtsuyaSato on 2017/05/25.
//
//

import Foundation

extension String {
    var headLineLevel: Int {
        do {
            let regxp = try NSRegularExpression(
                pattern: "(#*)\\s.*", options: [])
            let result = regxp.firstMatch(in: self, options: [], range: NSMakeRange(0, (self as NSString).length))
            guard let headLineRange = result?.rangeAt(1) else { return 0 }

            let headLine = String(NSString(string: self).substring(with: headLineRange))!
            return headLine.characters.count
        } catch {
            exit(EXIT_FAILURE)
        }
    }
    var planeText: String {
        do {
            let regxp = try NSRegularExpression(
                pattern: "\\s(.*)", options: [])
            let result = regxp.firstMatch(in: self, options: [], range: NSMakeRange(0, (self as NSString).length))
            guard let textRange = result?.rangeAt(1) else { return self }

            let text = String(NSString(string: self).substring(with: textRange))!
            return text
        } catch {
            exit(EXIT_FAILURE)
        }
    }
}
