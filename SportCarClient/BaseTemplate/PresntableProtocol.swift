//
//  PresntableProtocol.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol PresentableProtocol: class {
    
    func pp_presentFromController(_ parent: UIViewController)
    
    func pp_presentWithWrapperFromController(_ parent: UIViewController)
    
    func pp_dismissSelf()
    
    weak var presenter: UIViewController? {get set}
}

extension PresentableProtocol where Self: UIViewController{
    
    func pp_presentFromController(_ parent: UIViewController) {
        self.presenter = parent
        parent.present(self, animated: true, completion: nil)
    }
    
    func pp_presentWithWrapperFromController(_ parent: UIViewController) {
        self.presenter = parent
        let wrapper = BlackBarNavigationController(rootViewController: self)
        parent.present(wrapper, animated: true, completion: nil)
    }
    
    func pp_dismissSelf() {
        self.presenter?.dismiss(animated: true, completion: nil)
    }
}
