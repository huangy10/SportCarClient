//
//  AuthCodeBtnView.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/12.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

enum AuthCodeBtnViewStatus {
    case normal
    case pending
    case countDown
}


class AuthCodeBtnView: UIButton {
    var status = AuthCodeBtnViewStatus.normal {
        didSet {
            switch status{
            case .normal:
                self.updateTimer?.invalidate()
                self.setTitle(displayText, for: UIControlState())
                self.indicator.stopAnimating()
                self.isUserInteractionEnabled = true
                break
            case .pending:
                self.setTitle("", for: UIControlState())
                self.indicator.startAnimating()
                self.isUserInteractionEnabled = false
                break
            case .countDown:
                self.indicator.stopAnimating()
                self.setTitle("\(maxCD)", for: UIControlState())
                updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(AuthCodeBtnView.countDownUpdater), userInfo: nil, repeats: true)
                self.isUserInteractionEnabled = false
                break
            }
        }
        willSet(newStatus) {
            if cdTime != maxCD && newStatus != .countDown{
                assertionFailure()
            }
        }
    }
    var cdTime = 60
    var displayText: String?
    let maxCD = 60
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var updateTimer: Timer?
    
    convenience init() {
        self.init(frame: CGRect.zero)
        createSubviews()
        self.titleLabel?.textAlignment = .right
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createSubviews() {
        self.addSubview(indicator)
        indicator.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        indicator.hidesWhenStopped = true
    }
    
    func countDownUpdater() {
        cdTime -= 1
        if cdTime < 0 {
            cdTime = maxCD
            status = .normal
            return
        }
        self.setTitle("\(cdTime)", for: UIControlState())
    }
    
}
