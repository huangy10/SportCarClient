//
//  frameworkextensions.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation


extension String {
    func insert(string: String, atIndex ind: Int) -> String {
        return String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters
            .count - ind))
    }
}


