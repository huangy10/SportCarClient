//
//  ModelManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AlecrimCoreData


class ModelManager {
    
    static let mainContext = DataContext()
    
    var defaultContext: DataContext {
        return ModelManager.mainContext
    }
    
    func saveAll() {
        try! defaultContext.save()
    }
}