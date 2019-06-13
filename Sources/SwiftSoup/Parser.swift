//
//  Parser.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 29/09/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
* Parses HTML into a {@link org.jsoup.nodes.Document}. Generally best to use one of the  more convenient parse methods
* in {@link org.jsoup.Jsoup}.
*/
public class Parser {
	private static let DEFAULT_MAX_ERRORS: Int = 0 // by default, error tracking is disabled.

	private var _treeBuilder: TreeBuilder
	private var _maxErrors: Int = DEFAULT_MAX_ERRORS
	private var _errors: ParseErrorList = ParseErrorList(16, 16)
	private var _settings: ParseSettings

	/**
	* Create a new Parser, using the specified TreeBuilder
	* - Parameter treeBuilder: TreeBuilder to use to parse input into Documents.
	*/
	init(_ treeBuilder: TreeBuilder) {
		self._treeBuilder = treeBuilder
		_settings = treeBuilder.defaultSettings()
	}

	public func parseInput(_ html: String, _ baseUri: String)throws->Document {
		_errors = isTrackErrors() ? ParseErrorList.tracking(_maxErrors) : ParseErrorList.noTracking()
		return try _treeBuilder.parse(html, baseUri, _errors, _settings)
	}

	// gets & sets
	/**
	* Get the TreeBuilder currently in use.
	* - Returns: current TreeBuilder.
	*/
	public func getTreeBuilder() -> TreeBuilder {
		return _treeBuilder
	}

	/**
	* Update the TreeBuilder used when parsing content.
	* - Parameter treeBuilder: current TreeBuilder
	* - Returns: this, for chaining
	*/
    @discardableResult
	public func setTreeBuilder(_ treeBuilder: TreeBuilder) -> Parser {
		self._treeBuilder = treeBuilder
		return self
	}

	/**
	* Check if parse error tracking is enabled.
	* - Returns: current track error state.
	*/
	public func isTrackErrors() -> Bool {
		return _maxErrors > 0
	}

	/**
	* Enable or disable parse error tracking for the next parse.
	* - Parameter maxErrors: the maximum number of errors to track. Set to 0 to disable.
	* - Returns: this, for chaining
	*/
    @discardableResult
	public func setTrackErrors(_ maxErrors: Int) -> Parser {
		self._maxErrors = maxErrors
		return self
	}

	/**
	* Retrieve the parse errors, if any, from the last parse.
	* - Returns: list of parse errors, up to the size of the maximum errors tracked.
	*/
	public func getErrors() -> ParseErrorList {
		return _errors
	}

    @discardableResult
	public func settings(_ settings: ParseSettings) -> Parser {
		self._settings = settings
		return self
	}

	public func settings() -> ParseSettings {
		return _settings
	}

	// static parse functions below
	/**
	* Parse HTML into a Document.
	*
	* - Parameter html: HTML to parse
	* - Parameter baseUri: base URI of document (i.e. original fetch location), for resolving relative URLs.
	*
	* - Returns: parsed Document
	*/
	public static func parse(_ html: String, _ baseUri: String)throws->Document {
		let treeBuilder: TreeBuilder = HtmlTreeBuilder()
		return try treeBuilder.parse(html, baseUri, ParseErrorList.noTracking(), treeBuilder.defaultSettings())
	}
    
    public static func parseResult(_ html: String, _ baseUri: String) -> Result<Document,Swift.Error> {
        return .init(catching: { try Parser.parse(html,baseUri) })
    }
	/**
	* Parse a fragment of HTML into a list of nodes. The context element, if supplied, supplies parsing context.
	*
	* - Parameter fragmentHtml: the fragment of HTML to parse
	* - Parameter context: (optional) the element that this HTML fragment is being parsed for (i.e. for inner HTML). This
	* provides stack context (for implicit element creation).
	* - Parameter baseUri: base URI of document (i.e. original fetch location), for resolving relative URLs.
	*
	* - Returns: list of nodes parsed from the input HTML. Note that the context element, if supplied, is not modified.
	*/
	public static func parseFragment(_ fragmentHtml: String, _ context: Element?, _ baseUri: String)throws->Array<Node> {
		let treeBuilder = HtmlTreeBuilder()
		return try treeBuilder.parseFragment(fragmentHtml, context, baseUri, ParseErrorList.noTracking(), treeBuilder.defaultSettings())
	}

	/**
	* Parse a fragment of XML into a list of nodes.
	*
	* - Parameter fragmentXml: the fragment of XML to parse
	* - Parameter baseUri: base URI of document (i.e. original fetch location), for resolving relative URLs.
	* - Returns: list of nodes parsed from the input XML.
	*/
	public static func parseXmlFragment(_ fragmentXml: String, _ baseUri: String)throws->Array<Node> {
		let treeBuilder: XmlTreeBuilder = XmlTreeBuilder()
		return try treeBuilder.parseFragment(fragmentXml, baseUri, ParseErrorList.noTracking(), treeBuilder.defaultSettings())
	}

	/**
	* Parse a fragment of HTML into the {@code body} of a Document.
	*
	* - Parameter bodyHtml: fragment of HTML
	* - Parameter baseUri: base URI of document (i.e. original fetch location), for resolving relative URLs.
	*
	* - Returns: Document, with empty head, and HTML parsed into body
	*/
	public static func parseBodyFragment(_ bodyHtml: String, _ baseUri: String)throws->Document {
		let doc: Document = Document.createShell(baseUri)
		if let body: Element = doc.body() {
			let nodeList: Array<Node> = try parseFragment(bodyHtml, body, baseUri)
			//var nodes: [Node] = nodeList.toArray(Node[nodeList.count]) // the node list gets modified when re-parented
            if nodeList.count > 0 {
                for i in 1..<nodeList.count {
                    try nodeList[i].remove()
                }
            }
			for node: Node in nodeList {
				try body.appendChild(node)
			}
		}
		return doc
	}

	/**
	* Utility method to unescape HTML entities from a string
	* - Parameter string: HTML escaped string
	* - Parameter inAttribute: if the string is to be escaped in strict mode (as attributes are)
	* - Returns: an unescaped string
	*/
	public static func unescapeEntities(_ string: String, _ inAttribute: Bool)throws->String {
		let tokeniser: Tokeniser = Tokeniser(CharacterReader(string), ParseErrorList.noTracking())
		return try tokeniser.unescapeEntities(inAttribute)
	}

	/**
	* - Parameter bodyHtml: HTML to parse
	* - Parameter baseUri: baseUri base URI of document (i.e. original fetch location), for resolving relative URLs.
	*
	* - Returns: parsed Document
	* @deprecated Use {@link #parseBodyFragment} or {@link #parseFragment} instead.
	*/
	public static func parseBodyFragmentRelaxed(_ bodyHtml: String, _ baseUri: String)throws->Document {
		return try parse(bodyHtml, baseUri)
	}

	// builders

	/**
	* Create a new HTML parser. This parser treats input as HTML5, and enforces the creation of a normalised document,
	* based on a knowledge of the semantics of the incoming tags.
	* - Returns: a new HTML parser.
	*/
	public static func htmlParser() -> Parser {
		return Parser(HtmlTreeBuilder())
	}

	/**
	* Create a new XML parser. This parser assumes no knowledge of the incoming tags and does not treat it as HTML,
	* rather creates a simple tree directly from the input.
	* - Returns: a new simple XML parser.
	*/
	public static func xmlParser() -> Parser {
		return Parser(XmlTreeBuilder())
	}
}
