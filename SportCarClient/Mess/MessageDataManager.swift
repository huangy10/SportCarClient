//
//  MessageDataManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import XMPPFramework

class MessageDataManager: NSObject, XMPPStreamDelegate {
    
    static let defaultManager = MessageDataManager()
    
    var eles: [MessageElementInterface] = []
    
    override init() {
        super.init()
        MessageManager.defaultManager.xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    deinit {
        MessageManager.defaultManager.xmppStream.removeDelegate(self)
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        
    }
    
    func xmppStreamDidDisconnect(sender: XMPPStream!, withError error: NSError!) {
        
    }
}
