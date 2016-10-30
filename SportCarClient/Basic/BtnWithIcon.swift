//
//  BtnWithIcon.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/29.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class SSButton: UIButton {
    var icon: UIImageView!
    var iconSize: CGFloat = -1 {
        didSet {
            icon.snp.remakeConstraints { (make) in
                make.center.equalTo(icon)
                make.size.equalTo(iconSize)
            }
        }
    }
    
    func resetIconImageWithPulse(_ image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else {
                return
            }
            sSelf.icon.image = image
            sSelf.icon.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.3, animations: { 
                sSelf.icon.transform = .identity
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        icon = UIImageView()
        addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
