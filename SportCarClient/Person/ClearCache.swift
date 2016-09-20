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
        cacheSizeInfoLabl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight)
        cacheSizeInfoLabl.textColor = UIColor.white
        cacheSizeInfoLabl.textAlignment = .center
        // 由于这个页面只能由mine setting调出，而mine settng出现时，缓存描述符已经可用
        cacheSizeInfoLabl.text = LS("清除全部缓存") + PersonMineSettingsDataSource.sharedDataSource.cacheSizeDes! + "?"
        container.addSubview(cacheSizeInfoLabl)
        cacheSizeInfoLabl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(sepLine).offset(45)
        }
        //
        clearBtn = UIButton()
        clearBtn.setImage(UIImage(named: "clear_cache_confirm"), for: UIControlState())
        clearBtn.addTarget(self, action: #selector(ClearCacheController.clearBtnPressed), for: .touchUpInside)
        container.addSubview(clearBtn)
        clearBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(cacheSizeInfoLabl.snp_bottom).offset(45)
            make.size.equalTo(CGSize(width: 105, height: 50))
        }
    }
    
    func clearBtnPressed() {
        PersonMineSettingsDataSource.sharedDataSource.clearCacheFolder()
        cacheSizeInfoLabl.text = LS("缓存已清除")
    }
}
