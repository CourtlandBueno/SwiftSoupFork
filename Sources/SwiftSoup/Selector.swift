//
//  Selector.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 21/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation
/**
CSS-like element selector, that finds elements matching a query.
 # Selector syntax
 
 A selector is a chain of simple selectors, separated by combinators. Selectors are **case insensitive** (including against
 elements, attributes, and attribute values).
 
 
 The universal selector (*) is implicit when no element selector is supplied (i.e. {@code *.header} and {@code .header}
 is equivalent).
 
 
 # Pattern
   - ## Matches
        - ### Example

 - `*`
    - any element
        - `*`
 - `tag`
    - elements with the given tag name
        - `div`
 - `*|E`
    - elements of type E in any namespace *ns*
        - `*|name` finds `<fb:name>` elements
 - `ns|E`
    - elements of type E in the namespace *ns*
        - `fb|name` finds `<fb:name>` elements
 - `#id`
    - elements with attribute ID of "id"
        - `div#wrap`, `#logo`
 - `.class`
    - elements with a class name of "class"
        - `div.left`, `.result`
 - `[attr]`
    - elements with an attribute named "attr" (with any value)
        - `a[href]`, `[title]`
 - `[^attrPrefix]`
    - elements with an attribute name starting with "attrPrefix". Use to find elements with HTML5 datasets
        - `[^data-]`, `div[^data-]`
 - `[attr=val]`
    - elements with an attribute named "attr", and value equal to "val"
        - `img[width=500]`, `a[rel=nofollow]`
 - `[attr="val"]`
    - elements with an attribute named "attr", and value equal to "val"
        - `span[hello="Cleveland"][goodbye="Columbus"]`, `a[rel="nofollow"]`
 - `[attr^=valPrefix]`
    - elements with an attribute named "attr", and value starting with "valPrefix"
        - `a[href^=http:]`
 - `[attr$=valSuffix]`
    - elements with an attribute named "attr", and value ending with "valSuffix"
        - `img[src$=.png]`
 - `[attr*=valContaining]`
    - elements with an attribute named "attr", and value containing "valContaining"
        - `a[href*=/search/]`
 - `[attr~=regex]`
    - elements with an attribute named "attr", and value matching the regular expression
        - `img[src~=(?i)\\.(png|jpe?g)]`
 -
    - The above may be combined in any order
        - `div.header[title]`

## Combinators
 - `E F`
    - an F element descended from an E element
        - `div a`, `.logo h1`
 - `E {@literal >} F`
    - an F direct child of E
        - `ol {@literal >} li`
 - `E + F`
    - an F element immediately preceded by sibling E
        - `li + li`, `div.head + div`
 - `E ~ F`
    - an F element preceded by sibling E
        - `h1 ~ p`
 - `E, F, G`
    - all matching elements E, F, or G
        - `a[href], div, h3`

## Pseudo selectors
 - `:lt(n)`
    - elements whose sibling index is less than n
        - `td:lt(3)` finds the first 3 cells of each row
 - `:gt(n)`
    - elements whose sibling index is greater than n
        - `td:gt(1)` finds cells after skipping the first two
 - `:eq(n)`
    - elements whose sibling index is equal to n
        - `td:eq(0)` finds the first cell of each row
 - `:has(selector)`
    - elements that contains at least one element matching the selector
        - `div:has(p)` finds divs that contain p elements
 - `:not(selector)`
    - elements that do not match the selector. See also {@link Elements#not(String)}
        - `div:not(.logo)` finds all divs that do not have the "logo" class.`div:not(:has(div))` finds divs that do not contain divs.
 - `:contains(text)`
    - elements that contains the specified text. The search is case insensitive. The text may appear in the found element, or any of its descendants.
        - `p:contains(jsoup)` finds p elements containing the text "jsoup".
 - `:matches(regex)`
    - elements whose text matches the specified regular expression. The text may appear in the found element, or any of its descendants.
        - `td:matches(\\d+)` finds table cells containing digits. `div:matches((?i)login)` finds divs containing the text, case insensitively.
 - `:containsOwn(text)`
    - elements that directly contain the specified text. The search is case insensitive. The text must appear in the found element, not any of its descendants.
        - `p:containsOwn(jsoup)` finds p elements with own text "jsoup".
 - `:matchesOwn(regex)`
    - elements whose own text matches the specified regular expression. The text must appear in the found element, not any of its descendants.
        - `td:matchesOwn(\\d+)` finds table cells directly containing digits. `div:matchesOwn((?i)login)` finds divs containing the text, case insensitively.
 -
    - The above may be combined in any order and with other selectors
        - `.light:contains(name):eq(0)`

## Structural pseudo selectors
 - `:root`
    - The element that is the root of the document. In HTML, this is the `html` element
        - `:root`
 - `:nth-child(an+b)`
    - elements that have `an+b-1` siblings **before** it in the document tree, for any positive integer or zero value of `n`, and has a parent element. For values of `a` and `b` greater than zero, this effectively divides the element's children into groups of a elements (the last group taking the remainder), and selecting the bth element of each group. For example, this allows the selectors to address every other row in a table, and could be used to alternate the color of paragraph text in a cycle of four. The `a` and `b` values must be integers (positive, negative, or zero). The index of the first child of an element is 1.
 In addition to this, `:nth-child()` can take `odd` and `even` as arguments instead. `odd` has the same signification as `2n+1`, and `even` has the same signification as `2n`.
    - `tr:nth-child(2n+1)` finds every odd row of a table. `:nth-child(10n-1)` the 9th, 19th, 29th, etc, element. `li:nth-child(5)` the 5h li
 - `:nth-last-child(an+b)`
    - elements that have `an+b-1` siblings **after** it in the document tree. Otherwise like `:nth-child()`
        - `tr:nth-last-child(-n+2)` the last two rows of a table
 - `:nth-of-type(an+b)`
    - pseudo-class notation represents an element that has `an+b-1` siblings with the same expanded element name before it in the document tree, for any zero or positive integer value of n, and has a parent element
        - `img:nth-of-type(2n+1)`
 - `:nth-last-of-type(an+b)`
    - pseudo-class notation represents an element that has `an+b-1` siblings with the same expanded element name after it in the document tree, for any zero or positive integer value of n, and has a parent element
        - `img:nth-last-of-type(2n+1)`
 - `:first-child`
    - elements that are the first child of some other element.
        - `div {@literal >} p:first-child`
 - `:last-child`
    - elements that are the last child of some other element.
        - `ol {@literal >} li:last-child`
 - `:first-of-type`
    - elements that are the first sibling of its type in the list of children of its parent element
        - `dl dt:first-of-type`
 - `:last-of-type`
    - elements that are the last sibling of its type in the list of children of its parent element
        - `tr {@literal >} td:last-of-type`
 - `:only-child`
    - elements that have a parent element and whose parent element hasve no other element children
 - `:only-of-type`
    -  an element that has a parent element and whose parent element has no other element children with the same expanded element name
 - `:empty`
    - elements that have no children at all

 */

open class Selector {
    private let evaluator: Evaluator
    private let root: Element

    private init(_ query: String, _ root: Element)throws {
        let query = query.trim()
        try Validate.notEmpty(string: query)

        self.evaluator = try QueryParser.parse(query)

        self.root = root
    }

    private init(_ evaluator: Evaluator, _ root: Element) {
        self.evaluator = evaluator
        self.root = root
    }
    
    static func initResult(_ query: String, _ root: Element) -> Result<Selector, Swift.Error> {
        return .init {
            try Selector.init(query, root)
        }
        
    }
    
    
    /**
     * Find elements matching selector.
     *
     * - Parameter query: CSS selector
     * - Parameter root:  root element to descend into
     * - Returns: matching elements, empty if none
     * @throws Selector.SelectorParseException (unchecked) on an invalid CSS query.
     */
    public static func select(_ query: String, _ root: Element)throws->Elements {
        return try Selector(query, root).select()
    }
    
    public static func selectResult(_ query: String, _ root: Element) -> Result<Elements,Swift.Error> {
        let _initResult = initResult(query, root)
        return _initResult.flatMap { (selector) in
            return .init(catching: {try selector.select()})
        }
        
    }

    /**
     * Find elements matching selector.
     *
     * - Parameter evaluator: CSS selector
     * - Parameter root: root element to descend into
     * - Returns: matching elements, empty if none
     */
    public static func select(_ evaluator: Evaluator, _ root: Element)throws->Elements {
        return try Selector(evaluator, root).select()
    }
    
    public static func selectResult(_ evaluator: Evaluator, _ root: Element) -> Result<Elements, Swift.Error> {
        return .init(catching: {try Selector(evaluator, root).select() })
}
    /**
     * Find elements matching selector.
     *
     * - Parameter query: CSS selector
     * - Parameter roots: root elements to descend into
     * - Returns: matching elements, empty if none
     */
    public static func select(_ query: String, _ roots: Array<Element>)throws->Elements {
        try Validate.notEmpty(string: query)
        let evaluator: Evaluator = try QueryParser.parse(query)
        var elements: Array<Element> = Array<Element>()
        var seenElements: Array<Element> = Array<Element>()
        // dedupe elements by identity, not equality

        for root: Element in roots {
            let found: Elements = try select(evaluator, root)
            for  el: Element in found.array() {
                if (!seenElements.contains(el)) {
                    elements.append(el)
                    seenElements.append(el)
                }
            }
        }
        return Elements(elements)
    }

    private func select()throws->Elements {
        return try Collector.collect(evaluator, root)
    }
    
    private var selectResult: Result<Elements,Swift.Error> {
        return .init(catching: Selector.select(self))
    }

    // exclude set. package open so that Elements can implement .not() selector.
    static func filterOut(_ elements: Array<Element>, _ outs: Array<Element>) -> Elements {
        let output: Elements = Elements()
        for el: Element in elements {
            var found: Bool = false
            for out: Element in outs {
                if (el.equals(out)) {
                    found = true
                    break
                }
            }
            if (!found) {
                output.add(el)
            }
        }
        return output
    }
}
