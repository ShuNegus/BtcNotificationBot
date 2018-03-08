//
//  String+Ext.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 08.03.2018.
//

import Foundation

extension String {
    var toDouble: Double? {
        return Double(self)
    }
    
    var toJSON: Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
