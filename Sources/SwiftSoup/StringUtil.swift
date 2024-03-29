//
//  StringUtil.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 20/04/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

/**
 * A minimal String utility class. Designed for internal jsoup use only.
 */
open class StringUtil {
    enum StringError: Error {
        case empty
        case short
        case error(String)
    }

    // memoised padding up to 10
    fileprivate static var padding: [String] = ["", " ", "  ", "   ", "    ", "     ", "      ", "       ", "        ", "         ", "          "]

    /**
     * Join a collection of strings by a seperator
     * - Parameter strings: collection of string objects
     * - Parameter sep: string to place between strings
     * - Returns: joined string
     */
    public static func join(_ strings: [String], sep: String) -> String {
        return strings.joined(separator: sep)
    }
    public static func join(_ strings: Set<String>, sep: String) -> String {
        return strings.joined(separator: sep)
    }

    public static func join(_ strings: OrderedSet<String>, sep: String) -> String {
		return strings.joined(separator: sep)
	}

//    /**
//     * Join a collection of strings by a seperator
//     * - Parameter strings: iterator of string objects
//     * - Parameter sep: string to place between strings
//     * - Returns: joined string
//     */
//    public static String join(Iterator strings, String sep) {
//    if (!strings.hasNext())
//    return ""
//    
//    String start = strings.next().toString()
//    if (!strings.hasNext()) // only one, avoid builder
//    return start
//    
//    StringBuilder sb = new StringBuilder(64).append(start)
//    while (strings.hasNext()) {
//    sb.append(sep)
//    sb.append(strings.next())
//    }
//    return sb.toString()
//    }
    /**
     * Returns space padding
     * - Parameter width: amount of padding desired
     * - Returns: string of spaces * width
     */
    public static func padding(_ width: Int) -> String {

        if(width <= 0) {
            return ""
        }

        if (width < padding.count) {
            return padding[width]
        }

        var out: [Character] = [Character]()

        for _ in 0..<width {
            out.append(" ")
        }
        return String(out)
    }

    /**
     * Tests if a string is blank: null, emtpy, or only whitespace (" ", \r\n, \t, etc)
     * - Parameter string: string to test
     * - Returns: if string is blank
     */
    public static func isBlank(_ string: String) -> Bool {
        if (string.count == 0) {
            return true
        }

        for chr in string {
            if (!StringUtil.isWhitespace(chr)) {
                return false
            }
        }
        return true
    }

    /**
     * Tests if a string is numeric, i.e. contains only digit characters
     * - Parameter string: string to test
     * - Returns: true if only digit chars, false if empty or null or contains non-digit chrs
     */
    public static func isNumeric(_ string: String) -> Bool {
        if (string.count == 0) {
            return false
        }

        for chr in string {
            if !("0"..."9" ~= chr) {
                return false
            }
        }
        return true
    }

    /**
     * Tests if a code point is "whitespace" as defined in the HTML spec.
     * - Parameter c: code point to test
     * - Returns: true if code point is whitespace, false otherwise
     */
    public static func isWhitespace(_ c: Character) -> Bool {
        //(c == " " || c == UnicodeScalar.BackslashT || c == "\n" || (c == "\f" ) || c == "\r")
        return c.isWhitespace
    }

    /**
     * Normalise the whitespace within this string; multiple spaces collapse to a single, and all whitespace characters
     * (e.g. newline, tab) convert to a simple space
     * - Parameter string: content to normalise
     * - Returns: normalised string
     */
    public static func normaliseWhitespace(_ string: String) -> String {
        let sb: StringBuilder  = StringBuilder.init()
        appendNormalisedWhitespace(sb, string: string, stripLeading: false)
        return sb.toString()
    }

    /**
     * After normalizing the whitespace within a string, appends it to a string builder.
     * - Parameter accum: builder to append to
     * - Parameter string: string to normalize whitespace within
     * - Parameter stripLeading: set to true if you wish to remove any leading whitespace
     */
    public static func appendNormalisedWhitespace(_ accum: StringBuilder, string: String, stripLeading: Bool ) {
        var lastWasWhite: Bool = false
        var reachedNonWhite: Bool  = false

        for c in string {
            if (isWhitespace(c)) {
                if ((stripLeading && !reachedNonWhite) || lastWasWhite) {
                    continue
                }
                accum.append(" ")
                lastWasWhite = true
            } else {
                accum.appendCodePoint(c)
                lastWasWhite = false
                reachedNonWhite = true
            }
        }
    }

    public static func inString(_ needle: String?, haystack: String...) -> Bool {
        return inString(needle, haystack)
    }
    public static func inString(_ needle: String?, _ haystack: [String?]) -> Bool {
        if(needle == nil) {return false}
        for hay in haystack {
            if(hay != nil  && hay! == needle!) {
                return true
            }
        }
        return false
    }

//    open static func inSorted(_ needle: String, haystack: [String]) -> Bool {
//        return binarySearch(haystack, searchItem: needle) >= 0
//    }
//
//    open static func binarySearch<T: Comparable>(_ inputArr: Array<T>, searchItem: T) -> Int {
//        var lowerIndex = 0
//        var upperIndex = inputArr.count - 1
//
//        while (true) {
//            let currentIndex = (lowerIndex + upperIndex)/2
//            if(inputArr[currentIndex] == searchItem) {
//                return currentIndex
//            } else if (lowerIndex > upperIndex) {
//                return -1
//            } else {
//                if (inputArr[currentIndex] > searchItem) {
//                    upperIndex = currentIndex - 1
//                } else {
//                    lowerIndex = currentIndex + 1
//                }
//            }
//        }
//    }

    /**
     * Create a new absolute URL, from a provided existing absolute URL and a relative URL component.
     * - Parameter base: the existing absolulte base URL
     * - Parameter relUrl: the relative URL to resolve. (If it's already absolute, it will be returned)
     * - Returns: the resolved absolute URL
     * @throws MalformedURLException if an error occurred generating the URL
     */
    //NOTE: Not sure it work
    public static func resolve(_ base: URL, relUrl: String ) -> URL? {
        var base = base
        if(base.pathComponents.count == 0 && base.absoluteString.last != "/" && !base.isFileURL) {
            base = base.appendingPathComponent("/", isDirectory: false)
        }
        let u =  URL(string: relUrl, relativeTo: base)
        return u
    }

    /**
     * Create a new absolute URL, from a provided existing absolute URL and a relative URL component.
     * - Parameter baseUrl: the existing absolute base URL
     * - Parameter relUrl: the relative URL to resolve. (If it's already absolute, it will be returned)
     * - Returns: an absolute URL if one was able to be generated, or the empty string if not
     */
    public static func resolve(_ baseUrl: String, relUrl: String ) -> String {

        let base = URL(string: baseUrl)

        if(base == nil || base?.scheme == nil) {
            let abs = URL(string: relUrl)
			return abs != nil && abs?.scheme != nil ? abs!.absoluteURL.absoluteString : ""
        } else {
            let url = resolve(base!, relUrl: relUrl)
            if(url != nil) {
                let ext = url!.absoluteURL.absoluteString
                return ext
            }

            if(base != nil && base?.scheme != nil) {
                let ext = base!.absoluteString
                return ext
            }

            return ""
        }

//        try {
//            try {
//                    base = new URL(baseUrl)
//                } catch (MalformedURLException e) {
//                        // the base is unsuitable, but the attribute/rel may be abs on its own, so try that
//                        URL abs = new URL(relUrl)
//                        return abs.toExternalForm()
//                }
//            return resolve(base, relUrl).toExternalForm()
//        } catch (MalformedURLException e) {
//            return ""
//        }

    }

}
