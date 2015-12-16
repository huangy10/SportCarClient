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
    case Normal
    case Pending
    case CountDown
}


class AuthCodeBtnView: UIButton {
    var status = AuthCodeBtnViewStatus.Normal {
        didSet {
            switch status{
            case .Normal:
                self.updateTimer?.invalidate()
                self.setTitle(displayText, forState: .Normal)
                self.indicator.stopAnimating()
                self.userInteractionEnabled = true
                break
            case .Pending:
                self.setTitle("", forState: .Normal)
                self.indicator.startAnimating()
                self.userInteractionEnabled = false
                break
            case .CountDown:
                self.indicator.stopAnimating()
                self.setTitle("\(maxCD)", forState: .Normal)
                updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "countDownUpdater", userInfo: nil, repeats: true)
                self.userInteractionEnabled = false
                break
            }
        }
        willSet(newStatus) {
            if cdTime != maxCD && newStatus != .CountDown{
                assertionFailure()
            }
        }
    }
    var cdTime = 60
    var displayText: String?
    let maxCD = 60
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var updateTimer: NSTimer?
    
    convenience init() {
        self.init(frame: CGRect.zero)
        createSubviews()
        self.titleLabel?.textAlignment = .Right
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        self.addSubview(indicator)
        indicator.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        indicator.hidesWhenStopped = true
    }
    
    func countDownUpdater() {
        cdTime -= 1
        // print("\(cdTime)")
        if cdTime < 0 {
            cdTime = maxCD
            status = .Normal
            return
        }
        self.setTitle("\(cdTime)", forState: .Normal)
    }
    
}
