//
//  ChatController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

enum ChatRoomType {
    case Club
    case Private
}


class ChatRoomController: InputableViewController{
    
    var roomType: ChatRoomType = .Private
    
}
