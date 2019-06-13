//
//  BooleanAttribute.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 29/09/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * A boolean attribute that is written out without any value.
 */
open class BooleanAttribute: Attribute {
    /**
     * Create a new boolean attribute from unencoded (raw) key.
     * - Parameter key: attribute key
     */
    init(key: String) throws {
        try super.init(key: key, value: "")
    }
//    
//    required public init(from decoder: Decoder) throws {
//        fatalError("init(from:) has not been implemented")
//    }
    
    override public func isBooleanAttribute() -> Bool {
        return true
    }
}
