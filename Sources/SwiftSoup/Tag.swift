//
//  Tag.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 15/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

public struct TagOptions: OptionSet, Hashable, Codable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    // block or inline
    public static let isBlock = TagOptions(rawValue: 1 << 0)
    
    // should be formatted as a block
    public static let formatAsBlock = TagOptions(rawValue: 1 << 1)
    
    // Can this tag hold block level tags?
    public static let canContainBlock = TagOptions(rawValue: 1 << 2)
    
    // only pcdata if not
    public static let canContainInline = TagOptions(rawValue: 1 << 3)
    
    // can hold nothing e.g. img
    public static let empty = TagOptions(rawValue: 1 << 4)
    
    // can self close (<foo />). used for unknown tags that self close, without forcing them as empty.
    public static let selfClosing = TagOptions(rawValue: 1 << 5)
    
    // for pre, textarea, script etc
    public static let preserveWhitespace = TagOptions(rawValue: 1 << 6)
    
    // a control that appears in forms: input, textarea, output etc
    public static let formList = TagOptions(rawValue: 1 << 7)
    
    // a control that can be submitted in a form: input etc
    public static let formSubmit = TagOptions(rawValue: 1 << 8)
    
    fileprivate static let `default`: TagOptions = [.isBlock, .formatAsBlock, .canContainBlock, .canContainInline]
    
    public static let form: TagOptions = [.formList, .formSubmit]
    
    public var isInline: Bool {
        return !contains(.isBlock)
    }
    
    public var isData: Bool {
        return isDisjoint(with: [.canContainInline, .empty])
    }
    
    public var isSelfClosing: Bool {
        return contains(.empty) || contains(.selfClosing)
    }
    
}

open class Tag: Hashable, Codable {
    // map of known tags
    static var tags: Dictionary<String, Tag> = {
        do {
            return try Tag.initializeMaps()
        } catch {
            preconditionFailure("This method must be overridden")
        }
        return Dictionary<String, Tag>()
    }()
    
    
    
    fileprivate var _tagName: String
    fileprivate var _tagNameNormal: String
    
    public fileprivate(set) var options: TagOptions = .default
    
    fileprivate var _isBlock: Bool {
        get { return options.contains(.isBlock) }
        set { newValue ? options.formUnion(.isBlock) : options.subtract(.isBlock) }
    }
    
    fileprivate var _formatAsBlock: Bool {
        get { return options.contains(.formatAsBlock) }
        set { newValue ? options.formUnion(.formatAsBlock) : options.subtract(.formatAsBlock) }
    }
    
    fileprivate var _canContainBlock: Bool {
        get { return options.contains(.canContainBlock) }
        set { newValue ? options.formUnion(.canContainBlock) : options.subtract(.canContainBlock) }
    }
    
    fileprivate var _canContainInline: Bool {
        get { return options.contains(.canContainInline) }
        set { newValue ? options.formUnion(.canContainInline) : options.subtract(.canContainInline) }
    }
    
    fileprivate var _empty: Bool {
        get { return options.contains(.empty) }
        set { newValue ? options.formUnion(.empty) : options.subtract(.empty) }
    }
    
    fileprivate var _selfClosing: Bool {
        get { return options.contains(.selfClosing) }
        set { newValue ? options.formUnion(.selfClosing) : options.subtract(.selfClosing) }
    }
    
    fileprivate var _preserveWhitespace: Bool {
        get { return options.contains(.preserveWhitespace) }
        set { newValue ? options.formUnion(.preserveWhitespace) : options.subtract(.preserveWhitespace) }
    }
    
    fileprivate var _formList: Bool {
        get { return options.contains(.formList) }
        set { newValue ? options.formUnion(.formList) : options.subtract(.formList) }
    }
    
    fileprivate var _formSubmit: Bool {
        get { return options.contains(.formSubmit) }
        set { newValue ? options.formUnion(.formSubmit) : options.subtract(.formSubmit) }
    }

    public init(_ tagName: String) {
        self._tagName = tagName
        self._tagNameNormal = tagName.lowercased()
    }
    
    enum CodingKeys: String, CodingKey {
        case tagName
        case tagNameNormal
        case options
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._tagName = try container.decode(String.self, forKey: .tagName)
        self._tagNameNormal = try container.decode(String.self, forKey: .tagNameNormal)
        self.options = try container.decode(TagOptions.self, forKey: .options)
        
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_tagName, forKey: .tagName)
        try container.encode(_tagNameNormal, forKey: .tagNameNormal)
        try container.encode(options, forKey: .options)
        
    }
    /**
     * Get this tag's name.
     *
     * - Returns: the tag's name
     */
    open func getName() -> String {
        return self._tagName
    }
    open func getNameNormal() -> String {
        return self._tagNameNormal
    }

    /**
     * Get a Tag by name. If not previously defined (unknown), returns a new generic tag, that can do anything.
     * <p>
     * Pre-defined tags (P, DIV etc) will be ==, but unknown tags are not registered and will only .equals().
     * </p>
     *
     * - Parameter tagName: Name of tag, e.g. "p". Case insensitive.
     * - Parameter settings: used to control tag name sensitivity
     * - Returns: The tag, either defined or new generic.
     */
    public static func valueOf(_ tagName: String, _ settings: ParseSettings)throws->Tag {
        var tagName = tagName
        var tag: Tag? = Tag.tags[tagName]

        if (tag == nil) {
            tagName = settings.normalizeTag(tagName)
            try Validate.notEmpty(string: tagName)
            tag = Tag.tags[tagName]

            if (tag == nil) {
                // not defined: create default; go anywhere, do anything! (incl be inside a <p>)
                tag = Tag(tagName)
                tag!._isBlock = false
                tag!._canContainBlock = true
            }
        }
        return tag!
    }

    /**
     * Get a Tag by name. If not previously defined (unknown), returns a new generic tag, that can do anything.
     * <p>
     * Pre-defined tags (P, DIV etc) will be ==, but unknown tags are not registered and will only .equals().
     * </p>
     *
     * - Parameter tagName: Name of tag, e.g. "p". <b>Case sensitive</b>.
     * - Returns: The tag, either defined or new generic.
     */
    public static func valueOf(_ tagName: String)throws->Tag {
        return try valueOf(tagName, ParseSettings.preserveCase)
    }

    /**
     * Gets if this is a block tag.
     *
     * - Returns: if block tag
     */
    open func isBlock() -> Bool {
        return _isBlock
    }

    /**
     * Gets if this tag should be formatted as a block (or as inline)
     *
     * - Returns: if should be formatted as block or inline
     */
    open func formatAsBlock() -> Bool {
        return _formatAsBlock
    }

    /**
     * Gets if this tag can contain block tags.
     *
     * - Returns: if tag can contain block tags
     */
    open func canContainBlock() -> Bool {
        return _canContainBlock
    }

    /**
     * Gets if this tag is an inline tag.
     *
     * - Returns: if this tag is an inline tag.
     */
    open func isInline() -> Bool {
        return !_isBlock
    }

    /**
     * Gets if this tag is a data only tag.
     *
     * - Returns: if this tag is a data only tag
     */
    open func isData() -> Bool {
        return !_canContainInline && !isEmpty()
    }

    /**
     * Get if this is an empty tag
     *
     * - Returns: if this is an empty tag
     */
    open func isEmpty() -> Bool {
        return _empty
    }

    /**
     * Get if this tag is self closing.
     *
     * - Returns: if this tag should be output as self closing.
     */
    open func isSelfClosing() -> Bool {
        return _empty || _selfClosing
    }

    /**
     * Get if this is a pre-defined tag, or was auto created on parsing.
     *
     * - Returns: if a known tag
     */
    open func isKnownTag() -> Bool {
        return Tag.tags[_tagName] != nil
    }

    /**
     * Check if this tagname is a known tag.
     *
     * - Parameter tagName: name of tag
     * - Returns: if known HTML tag
     */
    public static func isKnownTag(_ tagName: String) -> Bool {
        return Tag.tags[tagName] != nil
    }

    /**
     * Get if this tag should preserve whitespace within child text nodes.
     *
     * - Returns: if preserve whitepace
     */
    public func preserveWhitespace() -> Bool {
        return _preserveWhitespace
    }

    /**
     * Get if this tag represents a control associated with a form. E.g. input, textarea, output
     * - Returns: if associated with a form
     */
    public func isFormListed() -> Bool {
        return _formList
    }

    /**
     * Get if this tag represents an element that should be submitted with a form. E.g. input, option
     * - Returns: if submittable with a form
     */
    public func isFormSubmittable() -> Bool {
        return _formSubmit
    }

    @discardableResult
    func setSelfClosing() -> Tag {
        _selfClosing = true
        return self
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static public func ==(lhs: Tag, rhs: Tag) -> Bool {
        if (lhs === rhs) {return true}
        if (type(of: lhs) != type(of: rhs)) {return false}
        return lhs._tagName == rhs._tagName && lhs.options == rhs.options
    }

    public func equals(_ tag: Tag) -> Bool {
        return self == tag
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_tagName)
        hasher.combine(_tagNameNormal)
        hasher.combine(options)
    }
    
    open func toString() -> String {
        return _tagName
    }

    // internal static initialisers:
    // prepped from http://www.w3.org/TR/REC-html40/sgml/dtd.html and other sources
    private static let blockTags: [String] = [
        "html", "head", "body", "frameset", "script", "noscript", "style", "meta", "link", "title", "frame",
        "noframes", "section", "nav", "aside", "hgroup", "header", "footer", "p", "h1", "h2", "h3", "h4", "h5", "h6",
        "ul", "ol", "pre", "div", "blockquote", "hr", "address", "figure", "figcaption", "form", "fieldset", "ins",
        "del", "s", "dl", "dt", "dd", "li", "table", "caption", "thead", "tfoot", "tbody", "colgroup", "col", "tr", "th",
        "td", "video", "audio", "canvas", "details", "menu", "plaintext", "template", "article", "main",
        "svg", "math"
    ]
    private static let inlineTags: [String] = [
        "object", "base", "font", "tt", "i", "b", "u", "big", "small", "em", "strong", "dfn", "code", "samp", "kbd",
        "var", "cite", "abbr", "time", "acronym", "mark", "ruby", "rt", "rp", "a", "img", "br", "wbr", "map", "q",
        "sub", "sup", "bdo", "iframe", "embed", "span", "input", "select", "textarea", "label", "button", "optgroup",
        "option", "legend", "datalist", "keygen", "output", "progress", "meter", "area", "param", "source", "track",
        "summary", "command", "device", "area", "basefont", "bgsound", "menuitem", "param", "source", "track",
        "data", "bdi"
    ]
    private static let emptyTags: [String] = [
        "meta", "link", "base", "frame", "img", "br", "wbr", "embed", "hr", "input", "keygen", "col", "command",
        "device", "area", "basefont", "bgsound", "menuitem", "param", "source", "track"
    ]
    private static let formatAsInlineTags: [String] = [
        "title", "a", "p", "h1", "h2", "h3", "h4", "h5", "h6", "pre", "address", "li", "th", "td", "script", "style",
        "ins", "del", "s"
    ]
    private static let preserveWhitespaceTags: [String] = [
        "pre", "plaintext", "title", "textarea"
        // script is not here as it is a data node, which always preserve whitespace
    ]
    // todo: I think we just need submit tags, and can scrub listed
    private static let formListedTags: [String] = [
        "button", "fieldset", "input", "keygen", "object", "output", "select", "textarea"
    ]
    private static let formSubmitTags: [String] = [
        "input", "keygen", "object", "select", "textarea"
    ]

    static private func initializeMaps()throws->Dictionary<String, Tag> {
        var dict = Dictionary<String, Tag>()

        // creates
        for tagName in blockTags {
            let tag = Tag(tagName)
            dict[tag._tagName] = tag
        }
        for tagName in inlineTags {
            let tag = Tag(tagName)
            tag._isBlock = false
            tag._canContainBlock = false
            tag._formatAsBlock = false
            dict[tag._tagName] = tag
        }

        // mods:
        for tagName in emptyTags {
            let tag = dict[tagName]
            try Validate.notNull(obj: tag)
            tag?._canContainBlock = false
            tag?._canContainInline = false
            tag?._empty = true
        }

        for tagName in formatAsInlineTags {
            let tag = dict[tagName]
            try Validate.notNull(obj: tag)
            tag?._formatAsBlock = false
        }

        for tagName in preserveWhitespaceTags {
            let tag = dict[tagName]
            try Validate.notNull(obj: tag)
            tag?._preserveWhitespace = true
        }

        for tagName in formListedTags {
            let tag = dict[tagName]
            try Validate.notNull(obj: tag)
            tag?._formList = true
        }

        for tagName in formSubmitTags {
            let tag = dict[tagName]
            try Validate.notNull(obj: tag)
            tag?._formSubmit = true
        }
        return dict
    }
}
