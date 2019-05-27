//
//  Validate.swift
//  SwifSoup
//
//  Created by Nabil Chatbi on 02/10/16.
//  Copyright © 2016 Nabil Chatbi.. All rights reserved.
//

import Foundation

struct Validate {
    public typealias ValidationSuccess = Void
    public typealias Result = Swift.Result<ValidationSuccess,Exception>
    /**
     * Validates that the object is not null
     * @param obj object to test
     */
    public static func notNull(obj: Any?) throws {
        if (obj == nil) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "Object must not be null")
        }
    }
    
    public static func notNullResult(obj: Any?) -> Validate.Result {
        if obj == nil {
            return .failure(Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "Object must not be null"))
        } else {
            return .success(())
        }
    }

    /**
     * Validates that the object is not null
     * @param obj object to test
     * @param msg message to output if validation fails
     */
    public static func notNull(obj: AnyObject?, msg: String) throws {
        if (obj == nil) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
        }
    }
    public static func notNullResult(obj: AnyObject?, msg: String = "Object must not be null") -> Validate.Result {
        if obj == nil {
            return .failure(Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg))
        } else {
            return .success(())
        }
    }
    /**
     * Validates that the value is true
     * @param val object to test
     */
    public static func isTrue(val: Bool) throws {
        if (!val) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "Must be true")
        }
    }
    
    /**
     * Validates that the value is true
     * @param val object to test
     * @param msg message to output if validation fails
     */
    public static func isTrue(val: Bool, msg: String) throws {
        if (!val) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
        }
    }

    public static func isTrueResult(val: Bool, msg: String = "Must be true") -> Validate.Result {
        if (!val) {
            return .failure(Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg))
        } else {
            return .success(())
        }
    }
    
    /**
     * Validates that the value is false
     * @param val object to test
     */
    public static func isFalse(val: Bool) throws {
        if (val) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "Must be false")
        }
    }

    /**
     * Validates that the value is false
     * @param val object to test
     * @param msg message to output if validation fails
     */
    public static func isFalse(val: Bool, msg: String) throws {
        if (val) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
        }
    }
    
    public static func isFalseResult(val: Bool, msg: String = "Must be false") -> Validate.Result {
        if val {
            return .failure(Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg))
        } else { return .success(()) }
    }
    /**
     * Validates that the array contains no null elements
     * @param objects the array to test
     */
    public static func noNullElements(objects: [AnyObject?]) throws {
        try noNullElements(objects: objects, msg: "Array must not contain any null objects")
    }

    /**
     * Validates that the array contains no null elements
     * @param objects the array to test
     * @param msg message to output if validation fails
     */
    public static func noNullElements(objects: [AnyObject?], msg: String) throws {
        for obj in objects {
            if (obj == nil) {
                throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
            }
        }
    }
    
    public static func noNillElementsResult(objects: [AnyObject?], msg: String = "Array must not contain any null objects") -> Result {
        for obj in objects {
            if (obj == nil) {
                return .failure(Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg))
            }
        }
        return .success(())
    }
    /**
     * Validates that the string is not empty
     * @param string the string to test
     */
    public static func notEmpty(string: String?) throws {
        if (string == nil || string?.count == 0) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: "String must not be empty")
        }

    }

    /**
     * Validates that the string is not empty
     * @param string the string to test
     * @param msg message to output if validation fails
     */
   public static func notEmpty(string: String?, msg: String ) throws {
        if (string == nil || string?.count == 0) {
            throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
        }
    }
    public static func notEmptyResult(string: String?, msg: String = "String must not be empty") -> Validate.Result {
        if (string == nil || string?.count == 0) {
            return .failure( Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg))
        } else {
            return .success(())
        }
    }
    /**
     Cause a failure.
     @param msg message to output.
     */
    public static func fail(msg: String) throws {
        throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
    }

    /**
     Helper
     */
    public static func exception(msg: String) throws {
        throw Exception.Error(type: ExceptionType.IllegalArgumentException, Message: msg)
    }
}


