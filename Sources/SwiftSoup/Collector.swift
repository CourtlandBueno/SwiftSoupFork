//
//  Collector.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 22/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * Collects a list of elements that match the supplied criteria.
 *
 */
open class Collector {

    private init() {
    }

    /**
     Build a list of elements, by visiting root and every descendant of root, and testing it against the evaluator.
     - Parameter eval: Evaluator to test elements against
     - Parameter root: root of tree to descend
     - Returns: list of matches; empty if none
     */
    public static func collect (_ eval: Evaluator, _ root: Element)throws->Elements {
        let elements: Elements = Elements()
        try NodeTraversor(Accumulator(root, elements, eval)).traverse(root)
        return elements
    }
    
    public static func collectResult(_ eval: Evaluator, _ root: Element) -> Result<Elements, Swift.Error> {
        let elements: Elements = Elements()
        return NodeTraversor
            .init(Accumulator(root, elements, eval))
            .traverseResult(root)
            .map({_ in return elements})
        
    }
}

private final class Accumulator: NodeVisitor {
    private let root: Element
    private let elements: Elements
    private let eval: Evaluator

    init(_ root: Element, _ elements: Elements, _ eval: Evaluator) {
        self.root = root
        self.elements = elements
        self.eval = eval
    }

    public func head(_ node: Node, _ depth: Int) {
        guard let el = node as? Element else {
            return
        }
        do {
            if try eval.matches(root, el) {
                elements.add(el)
            }
        } catch {}
    }

    public func tail(_ node: Node, _ depth: Int) {
        // void
    }
}
