//
//  Attribute.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 29/09/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

open class Attribute {
    /// The element type of a dictionary: a tuple containing an individual
    /// key-value pair.
//    enum CodingKeys: String, CodingKey {
//        case key, value
//    }
    static let booleanAttributes: [String] = [
        "allowfullscreen", "async", "autofocus", "checked", "compact", "declare", "default", "defer", "disabled",
        "formnovalidate", "hidden", "inert", "ismap", "itemscope", "multiple", "muted", "nohref", "noresize",
        "noshade", "novalidate", "nowrap", "open", "readonly", "required", "reversed", "seamless", "selected",
        "sortable", "truespeed", "typemustmatch"
    ]
    
    var key: String
    var value: String

    public init(key: String, value: String) throws {
        try Validate.notEmpty(string: key)
        self.key = key.trim()
        self.value = value
    }
//    
//    required public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.key = try container.decode(String.self, forKey: .key)
//        self.value = try container.decode(String.self, forKey: .value)
//    }
    /**
     Get the attribute key.
     - Returns: the attribute key
     */
    open func getKey() -> String {
        return key
    }

    /**
     Set the attribute key; case is preserved.
     - Parameter key: the new key; must not be null
     */
    open func setKey(key: String) throws {
        try Validate.notEmpty(string: key)
        self.key = key.trim()
    }

    /**
     Get the attribute value.
     - Returns: the attribute value
     */
    open func getValue() -> String {
        return value
    }

    /**
     Set the attribute value.
     - Parameter value: the new attribute value; must not be null
     */
    @discardableResult
    open func setValue(value: String) -> String {
        let old = self.value
        self.value = value
        return old
    }

    /**
     Get the HTML representation of this attribute; e.g. {@code href="index.html"}.
     - Returns: HTML
     */
    public func html() -> String {
        let accum =  StringBuilder()
		html(accum: accum, out: (Document("")).outputSettings())
        return accum.toString()
    }

    public func html(accum: StringBuilder, out: OutputSettings ) {
        accum.append(key)
        if (!shouldCollapseAttribute(out: out)) {
            accum.append("=\"")
            Entities.escape(accum, value, out, true, false, false)
            accum.append("\"")
        }
    }

    /**
     Get the string representation of this attribute, implemented as {@link #html()}.
     - Returns: string
     */
    open func toString() -> String {
        return html()
    }

    /**
     * Create a new Attribute from an unencoded key and a HTML attribute encoded value.
     * - Parameter unencodedKey: assumes the key is not encoded, as can be only run of simple \w chars.
     * - Parameter encodedValue: HTML attribute encoded value
     * - Returns: attribute
     */
    public static func createFromEncoded(unencodedKey: String, encodedValue: String) throws ->Attribute {
        let value = try Entities.unescape(string: encodedValue, strict: true)
        return try Attribute(key: unencodedKey, value: value)
    }

    public func isDataAttribute() -> Bool {
        return key.startsWith(Attributes.dataPrefix) && key.count > Attributes.dataPrefix.count
    }

    /**
     * Collapsible if it's a boolean attribute and value is empty or same as name
     *
     * - Parameter out: Outputsettings
     * - Returns:  Returns whether collapsible or not
     */
    public final func shouldCollapseAttribute(out: OutputSettings) -> Bool {
        return ("" == value  || value.equalsIgnoreCase(string: key))
            && out.syntax() == OutputSettings.Syntax.html
            && isBooleanAttribute()
    }

    public func isBooleanAttribute() -> Bool {
        return Attribute.booleanAttributes.contains(key)
    }

    public func hashCode() -> Int {
        var result = key.hashValue
        result = 31 * result + value.hashValue
        return result
    }

    public func clone() -> Attribute {
        do {
            return try Attribute(key: key, value: value)
        } catch Exception.Error( _, let  msg) {
            print(msg)
        } catch {

        }
        return try! Attribute(key: "", value: "")
    }
}

extension Attribute: Equatable {
	static public func == (lhs: Attribute, rhs: Attribute) -> Bool {
		return lhs.value == rhs.value && lhs.key == rhs.key
	}

}
