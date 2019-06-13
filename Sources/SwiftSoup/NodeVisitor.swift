//
//  NodeVisitor.swift
//  SwiftSoup
//
//  Created by Nabil Chatbi on 16/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * Node visitor interface. Provide an implementing class to {@link NodeTraversor} to iterate through nodes.
 * <p>
 * This interface provides two methods, {@code head} and {@code tail}. The head method is called when the node is first
 * seen, and the tail method when all of the node's children have been visited. As an example, head can be used to
 * create a start tag for a node, and tail to create the end tag.
 * </p>
 */
public protocol NodeVisitor {
    /**
     * Callback for when a node is first visited.
     *
     * - Parameter node: the node being visited.
     * - Parameter depth: the depth of the node, relative to the root node. E.g., the root node has depth 0, and a child node
     * of that will have depth 1.
     */
    func head(_ node: Node, _ depth: Int)throws

    /**
     * Callback for when a node is last visited, after all of its descendants have been visited.
     *
     * - Parameter node: the node being visited.
     * - Parameter depth: the depth of the node, relative to the root node. E.g., the root node has depth 0, and a child node
     * of that will have depth 1.
     */
    func tail(_ node: Node, _ depth: Int)throws
}