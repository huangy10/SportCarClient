//
//  MyOrderedDict.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation

class MyOrderedDict<Key: Hashable, Value> {
    var _keys: [Key] = []
    var _dict: [Key: Value] = [:]
    
    var keys: [Key] {
        return _keys
    }
    
    var count: Int {
        return _keys.count
    }
    
    subscript(key: Key) -> Value? {
        get {
            if let index = key as? Int {
                return self.valueForIndex(index)
            }
            return _dict[key]
        }
        
        set {
            
            if newValue == nil {
                _dict.removeValue(forKey: key)
                _ = _keys.remove(value: key)
                return
            }
            
            let oldVal = _dict.updateValue(newValue!, forKey: key)
            if oldVal == nil {
                _keys.append(key)
            }
        }
    }
    
    /**
     清除所有的内容
     */
    func removeAll() {
        _keys.removeAll()
        _dict.removeAll()
    }
    
    func remove(at: Int) {
        let key = _keys[at]
        _keys.remove(at: at)
        _dict.removeValue(forKey: key)
    }
    
    func resort(_ isOrderredBefore: (Value, Value)-> Bool) {
        _keys.sort { (key1, key2) -> Bool in
            let v1 = _dict[key1]
            let v2 = _dict[key2]
            return isOrderredBefore(v1!, v2!)
        }
    }
    
    /**
     一种快速排序的方法，将给定的index处的值移动到前端，前端的位置可以用frontPos来制定
     
     - parameter index:    目标index
     - parameter frontPos: 前端位置
     */
    @available(*, deprecated: 1)
    func bringIndexToFront(_ index: Int, frontPos: Int = 0) {
        let count = self.count
        if index >= count || frontPos >= count || index < frontPos {
            assertionFailure()
            return
        }
        let a = _keys[index]
        _keys.remove(at: index)
        _keys.insert(a, at: frontPos)
    }
    
    @available(*, deprecated: 1)
    func bringKeyToFront(_ key: Key, frontPos: Int = 0) {
        if let index = _keys.index(of: key) {
            bringIndexToFront(index, frontPos: frontPos)
        }
    }
    
    func valueForIndex(_ index: Int) -> Value? {
        let key = _keys[index]
        return _dict[key]
    }
}
