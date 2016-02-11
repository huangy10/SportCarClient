//
//  OtherPerson.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class PersonOtherController: PersonBasicController {
    /*
     基于basic改造而来，主要是替换了用户信息面板的类
    */
    
    override func getPersonInfoPanel() -> PersonHeaderMine {
        let panel = PersonHeaderOther()
        totalHeaderHeight = 906 / 750 * self.view.frame.width
        panel.followBtn.addTarget(self, action: "followBtnPressed", forControlEvents: .TouchUpInside)
        panel.chatBtn.addTarget(self, action: "chatBtnPressed", forControlEvents: .TouchUpInside)
        panel.locBtn.addTarget(self, action: "locateBtnPressed", forControlEvents: .TouchUpInside)
        return panel
    }
    
    func followBtnPressed() {
        
    }
    
    func chatBtnPressed() {
        
    }
    
    func locateBtnPressed() {
        
    }
}
