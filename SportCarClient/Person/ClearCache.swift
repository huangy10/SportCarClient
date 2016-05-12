//
//  ClearCache.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ClearCacheController: PresentTemplateViewController {
    
    var cacheSizeInfoLabl: UILabel!
    var clearBtn: UIButton!
    
    override func createContent() {
        cacheSizeInfoLabl = UILabel()
        cacheSizeInfoLabl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        cacheSizeInfoLabl.textColor = UIColor.whiteColor()
        cacheSizeInfoLabl.textAlignment = .Center
        // 由于这个页面只能由mine setting调出，而mine settng出现时，缓存描述符已经可用
        cacheSizeInfoLabl.text = LS("清除全部缓存") + PersonMineSettingsDataSource.sharedDataSource.cacheSizeDes! + "?"
        container.addSubview(cacheSizeInfoLabl)
        cacheSizeInfoLabl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(sepLine).offset(45)
        }
        //
        clearBtn = UIButton()
        clearBtn.setImage(UIImage(named: "clear_cache_confirm"), forState: .Normal)
        clearBtn.addTarget(self, action: #selector(ClearCacheController.clearBtnPressed), forControlEvents: .TouchUpInside)
        container.addSubview(clearBtn)
        clearBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(cacheSizeInfoLabl.snp_bottom).offset(45)
            make.size.equalTo(CGSizeMake(105, 50))
        }
    }
    
    func clearBtnPressed() {
        PersonMineSettingsDataSource.sharedDataSource.clearCacheFolder()
        cacheSizeInfoLabl.text = LS("缓存已清除")
    }
}
