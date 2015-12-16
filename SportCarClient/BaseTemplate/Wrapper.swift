//
//  Wrapper.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/16.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

enum ManagerResult<Value, Error: ErrorType> {
    case Success(Value)
    case Failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    var value: Value? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
    
    
}

enum ManagerError: ErrorType {
    case NoContext
    case NotFound
    case TimeOut
    case KeyError
    case CantSave
    case Integrity
}
