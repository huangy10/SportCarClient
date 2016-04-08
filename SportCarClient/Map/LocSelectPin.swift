//
//  LocSelectPin.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class UserSelectAnnotationView: BMKAnnotationView {
    var icon: UIImageView!
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.bounds = CGRectMake(0, 0, 38, 74)
        icon = self.addSubview(UIImageView).config(UIImage(named: "map_default_marker"), contentMode: .ScaleAspectFit)
            .setFrame(self.bounds)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
