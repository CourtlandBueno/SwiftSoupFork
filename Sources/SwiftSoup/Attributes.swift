//
//  Attributes.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 29/09/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * The attributes of an Element.
 * <p>
 * Attributes are treated as a map: there can be only one value associated with an attribute key/name.
 * </p>
 * <p>
 * Attribute name and value comparisons are  <b>case sensitive</b>. By default for HTML, attribute names are
 * normalized to lower-case on parsing. That means you should use lower-case strings when referring to attributes by
 * name.
 * </p>
 *
 * 
 */
open class Attributes: NSCopying {
    
    
    public static var dataPrefix: String = "data-"

    var attributes: OrderedDictionary<String, Attribute>  = OrderedDictionary<String, Attribute>()
    // linked hash map to preserve insertion order.
    // null be default as so many elements have no attributes -- saves a good chunk of memory

	public init() {}
    
    internal convenience init(_ list: [Attribute]) {
        self.init()
        for attrib in list {
            put(attribute: attrib)
        }
    }
    /**
     Get an attribute value by key.
     - Parameter key: the (case-sensitive) attribute key
     - Returns: the attribute value if set; or empty string if not set.
     @see #hasKey(String)
     */
    open func  get(key: String) -> String {
        let attr: Attribute? = attributes.get(key: key)
		return attr != nil ? attr!.getValue() : ""
    }

    /**
     * Get an attribute's value by case-insensitive key
     * - Parameter key: the attribute name
     * - Returns: the first matching attribute value if set; or empty string if not set.
     */
    open func getIgnoreCase(key: String )throws -> String {
        try Validate.notEmpty(string: key)

        for attrKey in (attributes.keySet()) {
            if attrKey.equalsIgnoreCase(string: key) {
                return attributes.get(key: attrKey)!.getValue()
            }
        }
        return ""
    }

    /**
     Set a new attribute, or replace an existing one by key.
     - Parameter key: attribute key
     - Parameter value: attribute value
     */
    open func put(_ key: String, _ value: String) throws {
        let attr = try Attribute(key: key, value: value)
        put(attribute: attr)
    }

    /**
     Set a new boolean attribute, remove attribute if value is false.
     - Parameter key: attribute key
     - Parameter value: attribute value
     */
    open func put(_ key: String, _ value: Bool) throws {
        if (value) {
            try put(attribute: BooleanAttribute(key: key))
        } else {
            try remove(key: key)
        }
    }

    /**
     Set a new attribute, or replace an existing one by key.
     - Parameter attribute: attribute
     */
    open func put(attribute: Attribute) {
        attributes.put(value: attribute, forKey: attribute.getKey())
    }

    /**
     Remove an attribute by key. <b>Case sensitive.</b>
     - Parameter key: attribute key to remove
     */
    open func remove(key: String)throws {
        try Validate.notEmpty(string: key)
		attributes.remove(key: key)
    }

    /**
     Remove an attribute by key. <b>Case insensitive.</b>
     - Parameter key: attribute key to remove
     */
    open func removeIgnoreCase(key: String ) throws {
        try Validate.notEmpty(string: key)
        for attrKey in attributes.keySet() {
            if (attrKey.equalsIgnoreCase(string: key)) {
                attributes.remove(key: attrKey)
            }
        }
    }

    /**
     Tests if these attributes contain an attribute with this key.
     - Parameter key: case-sensitive key to check for
     - Returns: true if key exists, false otherwise
     */
    open func hasKey(key: String) -> Bool {
        return attributes.containsKey(key: key)
    }

    /**
     Tests if these attributes contain an attribute with this key.
     - Parameter key: key to check for
     - Returns: true if key exists, false otherwise
     */
    open func hasKeyIgnoreCase(key: String) -> Bool {
        for attrKey in attributes.keySet() {
            if (attrKey.equalsIgnoreCase(string: key)) {
                return true
            }
        }
        return false
    }

    /**
     Get the number of attributes in this set.
     - Returns: size
     */
    private func size() -> Int {
        return attributes.count//TODO: check retyrn right size
    }
    
    /**
     Get the number of attributes in this set.
     - Returns: size
     */
    open var count: Int {
        return size()
    }
    
    /**
     Add all the attributes from the incoming set to this set.
     - Parameter incoming: attributes to add to these attributes.
     */
    open func addAll(incoming: Attributes?) {
        guard let incoming = incoming else {
            return
        }

        if (incoming.count == 0) {
            return
        }
        attributes.putAll(all: incoming.attributes)
    }

//    open func iterator() -> IndexingIterator<Array<Attribute>> {
//        if (attributes.isEmpty) {
//            let args: [Attribute] = []
//            return args.makeIterator()
//        }
//        return attributes.orderedValues.makeIterator()
//    }

    /**
     Get the attributes as a List, for iteration. Do not modify the keys of the attributes via this view, as changes
     to keys will not be recognised in the containing set.
     - Returns: an view of the attributes as a List.
     */
    open func asList() -> Array<Attribute> {
        var list: Array<Attribute> = Array(/*attributes.count*/)
        for entry in attributes.orderedValues {
            list.append(entry)
        }
        return list
    }

    /**
     * Retrieves a filtered view of attributes that are HTML5 custom data attributes; that is, attributes with keys
     * starting with {@code data-}.
     * - Returns: map of custom data attributes.
     */
    //Map<String, String>
    open func dataset() -> Dictionary<String, String> {
		var dataset = Dictionary<String, String>()
        attributes.lazy.forEach { (attribute) in
            let attr = attribute.1
            if(attr.isDataAttribute()) {
                let key = attr.getKey().substring(Attributes.dataPrefix.count)
                dataset[key] = attribute.1.getValue()
            }
        }
        return dataset
    }

    /**
     Get the HTML representation of these attributes.
     - Returns: HTML
     @throws SerializationException if the HTML representation of the attributes cannot be constructed.
     */
    open func html()throws -> String {
        let accum = StringBuilder()
        try html(accum: accum, out: Document("").outputSettings()) // output settings a bit funky, but this html() seldom used
        return accum.toString()
    }

    public func html(accum: StringBuilder, out: OutputSettings ) throws {
        for attribute in attributes.orderedValues {
            accum.append(" ")
            attribute.html(accum: accum, out: out)
        }
    }

    open func toString()throws -> String {
        return try html()
    }

    /**
     * Checks if these attributes are equal to another set of attributes, by comparing the two sets
     * - Parameter o: attributes to compare with
     * - Returns: if both sets of attributes have the same content
     */
    open func equals(o: AnyObject?) -> Bool {
        if(o == nil) {return false}
        if (self === o.self) {return true}
        guard let that: Attributes = o as? Attributes else {return false}
		return (attributes == that.attributes)
    }

    /**
     * Calculates the hashcode of these attributes, by iterating all attributes and summing their hashcodes.
     * - Returns: calculated hashcode
     */
    open func hashCode() -> Int {
        return attributes.hashCode()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let clone = Attributes()
        clone.attributes = attributes.clone()
        return clone
    }

    open func clone() -> Attributes {
        return self.copy() as! Attributes
    }

    fileprivate static func dataKey(key: String) -> String {
        return dataPrefix + key
    }

}

extension Attributes: Sequence {
    public __consuming func makeIterator() -> AttributesIterator {
        return AttributesIterator(self)
    }
}

public struct AttributesIterator: IteratorProtocol {
    
    public typealias Element = Attribute
    
    private var _internalIterator: IndexingIterator<OrderedDictionary<String, Attribute>>
    
    init(_ attributes: Attributes) {
        self._internalIterator = attributes.attributes.makeIterator()
    }
    
    mutating public func next() -> Attribute? {
        return _internalIterator.next()?.1
    }
}

extension Attributes: Collection {
    public subscript(i: Int) -> Attribute {
        get { return  attributes.orderedValues[i] }
    }
    
    public var startIndex: Int {
        return attributes.startIndex
    }
    
    public var endIndex: Int {
        return attributes.endIndex
    }
    
    public func index(after i: Int) -> Int {
        return attributes.index(after: i)
    }
}
