//
//  Document.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 29/09/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

open class Document: Element, Codable {
    public enum QuirksMode: String, Codable {
        case noQuirks, quirks, limitedQuirks
    }

    private var _outputSettings: OutputSettings  = OutputSettings()
    private var _quirksMode: Document.QuirksMode = QuirksMode.noQuirks
    private let _location: String
    private var updateMetaCharset: Bool = false

    /**
     Create a new, empty Document.
     - Parameter baseUri: base URI of document
     @see org.jsoup.Jsoup#parse
     @see #createShell
     */
    public init(_ baseUri: String) {
        self._location = baseUri
        super.init(try! Tag.valueOf("#root", ParseSettings.htmlDefault), baseUri)
    }
    
    public init(_ html: String, baseUri: String) throws {
        self._location = baseUri
        try super.init(html, baseUri)
    }
    
    //MARK: Codable
    enum DocumentCodingKeys: String, CodingKey {
        case location
        case html
        case outputSettings
        case quirksMode
        case updateMetaCharset
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DocumentCodingKeys.self)
        let html = try container.decode(String.self, forKey: .html)
        self._outputSettings = try container.decode(OutputSettings.self, forKey: .outputSettings)
        self._quirksMode = try container.decode(QuirksMode.self, forKey: .quirksMode)
        self._location = try container.decode(String.self, forKey: .location)
        self.updateMetaCharset = try container.decode(Bool.self, forKey: .updateMetaCharset)
        
        try super.init(html, _location)
    }
    
    public required init(original: Element, items: [Attribute]) {
        self._location = original.getBaseUri()
        super.init(original.tag(), original.getBaseUri(), Attributes(items))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DocumentCodingKeys.self)
        try container.encode(try self.outerHtml(), forKey: .html)
        try container.encode(_location, forKey: .location)
        try container.encode(updateMetaCharset, forKey: .updateMetaCharset)
        try container.encode(_quirksMode, forKey: .quirksMode)
        try container.encode(_outputSettings, forKey: .outputSettings)
    }
    
    /**
     Create a valid, empty shell of a document, suitable for adding more elements to.
     - Parameter baseUri: baseUri of document
     - Returns: document with html, head, and body elements.
     */
    static public func createShell(_ baseUri: String) -> Document {
        let doc: Document = Document(baseUri)
        let html: Element = try! doc.appendElement("html")
        try! html.appendElement("head")
        try! html.appendElement("body")

        return doc
    }

    /**
     * Get the URL this Document was parsed from. If the starting URL is a redirect,
     * this will return the final URL from which the document was served from.
     * - Returns: location
     */
    public func location() -> String {
    return _location
    }

    /**
     Accessor to the document's {@code head} element.
     - Returns: {@code head}
     */
    public func head() -> Element? {
        return findFirstElementByTagName("head", self)
    }

    /**
     Accessor to the document's {@code body} element.
     - Returns: {@code body}
     */
    public func body() -> Element? {
        return findFirstElementByTagName("body", self)
    }

    /**
     Get the string contents of the document's {@code title} element.
     - Returns: Trimmed title, or empty string if none set.
     */
    public func title()throws->String {
        // title is a preserve whitespace tag (for document output), but normalised here
        let titleEl: Element? = try getElementsByTag("title").first
        return titleEl != nil ? try StringUtil.normaliseWhitespace(titleEl!.text()).trim() : ""
    }

    /**
     Set the document's {@code title} element. Updates the existing element, or adds {@code title} to {@code head} if
     not present
     - Parameter title: string to set as title
     */
    public func title(_ title: String)throws {
        let titleEl: Element? = try getElementsByTag("title").first
        if (titleEl == nil) { // add to head
            try head()?.appendElement("title").text(title)
        } else {
            try titleEl?.text(title)
        }
    }

    /**
     Create a new Element, with this document's base uri. Does not make the new element a child of this document.
     - Parameter tagName: element tag name (e.g. {@code a})
     - Returns: new element
     */
    public func createElement(_ tagName: String)throws->Element {
        return try Element(Tag.valueOf(tagName, ParseSettings.preserveCase), self.getBaseUri())
    }

    /**
     Normalise the document. This happens after the parse phase so generally does not need to be called.
     Moves any text content that is not in the body element into the body.
     - Returns: this document after normalisation
     */
    @discardableResult
    public func normalise()throws->Document {
        var htmlE: Element? = findFirstElementByTagName("html", self)
        if (htmlE == nil) {
            htmlE = try appendElement("html")
        }
        let htmlEl: Element = htmlE!

        if (head() == nil) {
            try htmlEl.prependElement("head")
        }
        if (body() == nil) {
            try htmlEl.appendElement("body")
        }

        // pull text nodes out of root, html, and head els, and push into body. non-text nodes are already taken care
        // of. do in inverse order to maintain text order.
        try normaliseTextNodes(head()!)
        try normaliseTextNodes(htmlEl)
        try normaliseTextNodes(self)

        try normaliseStructure("head", htmlEl)
        try normaliseStructure("body", htmlEl)

        try ensureMetaCharsetElement()

        return self
    }

    // does not recurse.
    private func normaliseTextNodes(_ element: Element)throws {
        var toMove: Array<Node> =  Array<Node>()
        for node: Node in element.childNodes {
            if let tn = (node as? TextNode) {
                if (!tn.isBlank()) {
                toMove.append(tn)
                }
            }
        }

        for i in (0..<toMove.count).reversed() {
            let node: Node = toMove[i]
            try element.removeChild(node)
            try body()?.prependChild(TextNode(" ", ""))
            try body()?.prependChild(node)
        }
    }

    // merge multiple <head> or <body> contents into one, delete the remainder, and ensure they are owned by <html>
    private func normaliseStructure(_ tag: String, _ htmlEl: Element)throws {
        let elements: Elements = try self.getElementsByTag(tag)
        let master: Element? = elements.first // will always be available as created above if not existent
        if (elements.count > 1) { // dupes, move contents to master
            var toMove: Array<Node> = Array<Node>()
            for i in 1..<elements.count {
                let dupe: Node = elements.get(i)
                for node: Node in dupe.childNodes {
                    toMove.append(node)
                }
                try dupe.remove()
            }

            for dupe: Node in toMove {
                try master?.appendChild(dupe)
            }
        }
        // ensure parented by <html>
        if (!(master != nil && master!.parent != nil && master!.parent!.equals(htmlEl))) {
            try htmlEl.appendChild(master!) // includes remove()
        }
    }

    // fast method to get first by tag name, used for html, head, body finders
    private func findFirstElementByTagName(_ tag: String, _ node: Node) -> Element? {
        if (node.nodeName()==tag) {
            return node as? Element
        } else {
            for child: Node in node.childNodes {
                let found: Element? = findFirstElementByTagName(tag, child)
                if (found != nil) {
                    return found
                }
            }
        }
        return nil
    }

    open override func outerHtml()throws->String {
        return try super.html() // no outer wrapper tag
    }

    /**
     Set the text of the {@code body} of this document. Any existing nodes within the body will be cleared.
     - Parameter text: unencoded text
     - Returns: this document
     */
    @discardableResult
    public override func text(_ text: String)throws->Element {
        try body()?.text(text) // overridden to not nuke doc structure
        return self
    }

    open override func nodeName() -> String {
    return "#document"
    }

    /**
     * Sets the charset used in this document. This method is equivalent
     * to {@link OutputSettings#charset(java.nio.charset.Charset)
     * OutputSettings.charset(Charset)} but in addition it updates the
     * charset / encoding element within the document.
     *
     * <p>This enables
     * {@link #updateMetaCharsetElement(boolean) meta charset update}.</p>
     *
     * <p>If there's no element with charset / encoding information yet it will
     * be created. Obsolete charset / encoding definitions are removed!</p>
     *
     * <p><b>Elements used:</b></p>
     *
     *
     * - <b>Html:</b> <i>&lt;meta charset="CHARSET"&gt;</i>
     * - <b>Xml:</b> <i>&lt;?xml version="1.0" encoding="CHARSET"&gt;</i>
     *
     *
     * - Parameter charset: Charset
     *
     * @see #updateMetaCharsetElement(boolean)
     * @see OutputSettings#charset(java.nio.charset.Charset)
     */
    public func charset(_ charset: String.Encoding)throws {
        updateMetaCharsetElement(true)
        _outputSettings.charset(charset)
        try ensureMetaCharsetElement()
    }

    /**
     * Returns the charset used in this document. This method is equivalent
     * to {@link OutputSettings#charset()}.
     *
     * - Returns: Current Charset
     *
     * @see OutputSettings#charset()
     */
    public func charset()->String.Encoding {
        return _outputSettings.charset()
    }

    /**
     * Sets whether the element with charset information in this document is
     * updated on changes through {@link #charset(java.nio.charset.Charset)
     * Document.charset(Charset)} or not.
     *
     * <p>If set to <tt>false</tt> <i>(default)</i> there are no elements
     * modified.</p>
     *
     * - Parameter update: If <tt>true</tt> the element updated on charset
     * changes, <tt>false</tt> if not
     *
     * @see #charset(java.nio.charset.Charset)
     */
    public func updateMetaCharsetElement(_ update: Bool) {
        self.updateMetaCharset = update
    }

    /**
     * Returns whether the element with charset information in this document is
     * updated on changes through {@link #charset(java.nio.charset.Charset)
     * Document.charset(Charset)} or not.
     *
     * - Returns: <tt>true</tt> if the element is updated on charset
     * changes, <tt>false</tt> if not
     */
    public func updateMetaCharsetElement() -> Bool {
        return updateMetaCharset
    }

    /**
     * Ensures a meta charset (html) or xml declaration (xml) with the current
     * encoding used. This only applies with
     * {@link #updateMetaCharsetElement(boolean) updateMetaCharset} set to
     * <tt>true</tt>, otherwise this method does nothing.
     *
     * 
     * - An exsiting element gets updated with the current charset
     * - If there's no element yet it will be inserted
     * - Obsolete elements are removed
     *
     *
     * <p><b>Elements used:</b></p>
     *
     * <ul>
     * - <b>Html:</b> <i>&lt;meta charset="CHARSET"&gt;</i></li>
     * - <b>Xml:</b> <i>&lt;?xml version="1.0" encoding="CHARSET"&gt;</i></li>
     * </ul>
     */
    private func ensureMetaCharsetElement()throws {
        if (updateMetaCharset) {
            let syntax: OutputSettings.Syntax = outputSettings().syntax()

            if (syntax == OutputSettings.Syntax.html) {
                let metaCharset: Element? = try select("meta[charset]").first

                if (metaCharset != nil) {
                    try metaCharset?.attr("charset", charset().displayName())
                } else {
                    let head: Element? = self.head()

                    if (head != nil) {
                        try head?.appendElement("meta").attr("charset", charset().displayName())
                    }
                }

                // Remove obsolete elements
				let s = try select("meta[name=charset]")
				try s.remove()

            } else if (syntax == OutputSettings.Syntax.xml) {
                let node: Node = getChildNodes()[0]

                if let decl = (node as? XmlDeclaration) {

                    if (decl.name()=="xml") {
                        try decl.attr("encoding", charset().displayName())

                        _ = try  decl.attr("version")
                        try decl.attr("version", "1.0")
                    } else {
                        try Validate.notNull(obj: baseUri)
                        let decl = XmlDeclaration("xml", baseUri!, false)
                        try decl.attr("version", "1.0")
                        try decl.attr("encoding", charset().displayName())

                        try prependChild(decl)
                    }
                } else {
                    try Validate.notNull(obj: baseUri)
                    let decl = XmlDeclaration("xml", baseUri!, false)
                    try decl.attr("version", "1.0")
                    try decl.attr("encoding", charset().displayName())

                    try prependChild(decl)
                }
            }
        }
    }

    /**
     * Get the document's current output settings.
     * - Returns: the document's current output settings.
     */
    public func outputSettings() -> OutputSettings {
    return _outputSettings
    }

    /**
     * Set the document's output settings.
     * - Parameter outputSettings: new output settings.
     * - Returns: this document, for chaining.
     */
    @discardableResult
    public func outputSettings(_ outputSettings: OutputSettings) -> Document {
        self._outputSettings = outputSettings
        return self
    }

    public func quirksMode()->Document.QuirksMode {
        return _quirksMode
    }

    @discardableResult
    public func quirksMode(_ quirksMode: Document.QuirksMode) -> Document {
        self._quirksMode = quirksMode
        return self
    }

	public override func copy(with zone: NSZone? = nil) -> Any {
		let clone = Document(_location)
		return copy(clone: clone)
	}

	public override func copy(parent: Node?) -> Node {
		let clone = Document(_location)
		return copy(clone: clone, parent: parent)
	}

	public override func copy(clone: Node, parent: Node?) -> Node {
		let clone = clone as! Document
		clone._outputSettings = _outputSettings.copy() as! OutputSettings
		clone._quirksMode = _quirksMode
		clone.updateMetaCharset = updateMetaCharset
		return super.copy(clone: clone, parent: parent)
	}

}
extension String.Encoding: Codable {
    
}
public class OutputSettings: NSCopying, Codable {
    /**
     * The output serialization syntax.
     */
    public enum Syntax: String, Codable {
        case html, xml
    }

    private var _escapeMode: Entities.EscapeMode  = Entities.EscapeMode.base
    private var _encoder: String.Encoding = String.Encoding.utf8 // Charset.forName("UTF-8")
    private var _prettyPrint: Bool = true
    private var _outline: Bool = false
    private var _indentAmount: UInt  = 1
    private var _syntax = Syntax.html

    public init() {}
    
    enum OutputSettingsCodingKeys: String, CodingKey {
        case escapeMode
        case encoder
        case prettyPrint
        case outline
        case indentAmount
        case syntax
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OutputSettingsCodingKeys.self)
        self._escapeMode = try container.decode(Entities.EscapeMode.self, forKey: .escapeMode)
        self._encoder = try container.decode(String.Encoding.self, forKey: .encoder)
        self._prettyPrint = try container.decode(Bool.self, forKey: .prettyPrint)
        self._indentAmount = try container.decode(UInt.self, forKey: .indentAmount)
        self._outline = try container.decode(Bool.self, forKey: .outline)
        self._syntax = try container.decode(Syntax.self, forKey: .syntax)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OutputSettingsCodingKeys.self)
        try container.encode(_encoder, forKey: .encoder)
        try container.encode(_escapeMode, forKey: .escapeMode)
        try container.encode(_prettyPrint, forKey: .prettyPrint)
        try container.encode(_indentAmount, forKey: .indentAmount)
        try container.encode(_outline, forKey: .outline)
        try container.encode(_syntax, forKey: .syntax)
    }
    /**
     * Get the document's current HTML escape mode: <code>base</code>, which provides a limited set of named HTML
     * entities and escapes other characters as numbered entities for maximum compatibility; or <code>extended</code>,
     * which uses the complete set of HTML named entities.
     * <p>
     * The default escape mode is <code>base</code>.
     * - Returns: the document's current escape mode
     */
    public func escapeMode() -> Entities.EscapeMode {
        return _escapeMode
    }

    /**
     * Set the document's escape mode, which determines how characters are escaped when the output character set
     * does not support a given character:- using either a named or a numbered escape.
     * - Parameter escapeMode: the new escape mode to use
     * - Returns: the document's output settings, for chaining
     */
    @discardableResult
    public func escapeMode(_ escapeMode: Entities.EscapeMode) -> OutputSettings {
        self._escapeMode = escapeMode
        return self
    }

    /**
     * Get the document's current output charset, which is used to control which characters are escaped when
     * generating HTML (via the <code>html()</code> methods), and which are kept intact.
     * <p>
     * Where possible (when parsing from a URL or File), the document's output charset is automatically set to the
     * input charset. Otherwise, it defaults to UTF-8.
     * - Returns: the document's current charset.
     */
    public func encoder() -> String.Encoding {
        return _encoder
    }
    public func charset() -> String.Encoding {
        return _encoder
    }

    /**
     * Update the document's output charset.
     * - Parameter charset: the new charset to use.
     * - Returns: the document's output settings, for chaining
     */
    @discardableResult
    public func encoder(_ encoder: String.Encoding) -> OutputSettings {
        self._encoder = encoder
        return self
    }

    @discardableResult
    public func charset(_ e: String.Encoding) -> OutputSettings {
        return encoder(e)
    }

    /**
     * Get the document's current output syntax.
     * - Returns: current syntax
     */
    public func syntax() -> Syntax {
        return _syntax
    }

    /**
     * Set the document's output syntax. Either {@code html}, with empty tags and boolean attributes (etc), or
     * {@code xml}, with self-closing tags.
     * - Parameter syntax: serialization syntax
     * - Returns: the document's output settings, for chaining
     */
    @discardableResult
    public func syntax(syntax: Syntax) -> OutputSettings {
        _syntax = syntax
        return self
    }

    /**
     * Get if pretty printing is enabled. Default is true. If disabled, the HTML output methods will not re-format
     * the output, and the output will generally look like the input.
     * - Returns: if pretty printing is enabled.
     */
    public func prettyPrint() -> Bool {
        return _prettyPrint
    }

    /**
     * Enable or disable pretty printing.
     * - Parameter pretty: new pretty print setting
     * - Returns: this, for chaining
     */
    @discardableResult
    public func prettyPrint(pretty: Bool) -> OutputSettings {
        _prettyPrint = pretty
        return self
    }

    /**
     * Get if outline mode is enabled. Default is false. If enabled, the HTML output methods will consider
     * all tags as block.
     * - Returns: if outline mode is enabled.
     */
    public func outline() -> Bool {
        return _outline
    }

    /**
     * Enable or disable HTML outline mode.
     * - Parameter outlineMode: new outline setting
     * - Returns: this, for chaining
     */
    @discardableResult
    public func outline(outlineMode: Bool) -> OutputSettings {
        _outline = outlineMode
        return self
    }

    /**
     * Get the current tag indent amount, used when pretty printing.
     * - Returns: the current indent amount
     */
    public func indentAmount() -> UInt {
        return _indentAmount
    }

    /**
     * Set the indent amount for pretty printing
     * - Parameter indentAmount: number of spaces to use for indenting each level. Must be {@literal >=} 0.
     * - Returns: this, for chaining
     */
    @discardableResult
    public func indentAmount(indentAmount: UInt) -> OutputSettings {
        _indentAmount = indentAmount
        return self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
        let clone: OutputSettings = OutputSettings()
        clone.charset(_encoder) // new charset and charset encoder
        clone._escapeMode = _escapeMode//Entities.EscapeMode.valueOf(escapeMode.name())
        // indentAmount, prettyPrint are primitives so object.clone() will handle
        return clone
    }

}
