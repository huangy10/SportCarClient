//
//  Refresh.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring

class SSPullToRefresh: UIView {
    var pullingLbl: UILabel!
    var confirmingLabl: UILabel!
    var actIndicator: UIActivityIndicatorView!
    
    var action: (()->())?
    var hideDelay: NSTimeInterval = 0
    var refreshing: Bool = false
    deinit {
        removeScrollViewObserving()
    }
    
    private var state: State = .Inital {
        didSet {
            refreshing = false
            switch state {
            case .Loading:
                refreshing = true
                pullingLbl.layer.opacity = 0
                confirmingLabl.layer.opacity = 0
                actIndicator.hidden = false
                actIndicator.startAnimating()
                if let scrollView = scrollView where oldValue != .Loading {
                    scrollView.contentOffset = previousScrollViewOffset
                    scrollView.bounces = false
                    UIView.animateWithDuration(0.3, animations: { 
                        let insets = self.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets)
                        }, completion: { _ in
                            scrollView.bounces = true
                    })
                }
                action?()
            case .Finished:
                removeScrollViewObserving()
                SpringAnimation.springWithCompletion(1, animations: { 
                    self.scrollView?.contentInset = self.scrollViewDefaultInsets
                    self.scrollView?.contentOffset.y -= self.scrollViewDefaultInsets.top
                    self.actIndicator.layer.opacity = 0
                    }, completion: { (_) in
                        self.addScrollViewObserving()
                        self.state = .Inital
                        self.actIndicator.layer.opacity = 1
                        self.actIndicator.hidden = true
                })
            case .Releasing(let progress):
                pullingLbl.layer.opacity = max(Float(1 - (progress-0.5) * 2), 0)
                confirmingLabl.layer.opacity = max(Float((progress - 0.5) * 2), 0)
            default: break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToSrollView(scrollView: UIScrollView, action: ()->()) {
        self.scrollView = scrollView
        self.action = action
        scrollView.addSubview(self)
        self.frame  = CGRectMake(0, scrollView.contentInset.top - 80, UIScreen.mainScreen().bounds.width, 80)
    }
    
    func createSubviews() {
        pullingLbl = self.addSubview(UILabel).config(textColor: UIColor.whiteColor(), textAlignment: .Center)
            .layout({ (make) in
                make.center.equalTo(self)
            })
        
        confirmingLabl = self.addSubview(UILabel).config(textColor: UIColor.whiteColor(), textAlignment: .Center)
            .layout({ (make) in
                make.center.equalTo(self)
            })
        confirmingLabl.text = LS("放开切换到当前地点")
        confirmingLabl.layer.opacity = 0
        
        actIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.addSubview(actIndicator)
        actIndicator.layout({ (make) in
            make.center.equalTo(self)
            make.size.equalTo(40)
        })
        actIndicator.hidden = true
    }
    
    private var scrollViewDefaultInsets = UIEdgeInsetsZero
    weak var scrollView: UIScrollView? {
        willSet {
            removeScrollViewObserving()
        }
        didSet {
            if let scrollView = scrollView {
                scrollViewDefaultInsets = scrollView.contentInset
                addScrollViewObserving()
            }
        }
    }
    
    private func addScrollViewObserving() {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .Initial, context: &KVOContext)
    }
    
    private func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &KVOContext)
    }
    
    // MARK: - KVO
    private var KVOContext = "PullToRefreshKVOContext"
    private var previousScrollViewOffset: CGPoint = CGPointZero
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == &KVOContext && keyPath == "contentOffset" && object as? UIScrollView == scrollView) {
            let offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = self.frame.height
        
            switch offset {
            case 0 where (state != .Loading): state = .Inital
            case -refreshViewHeight...0 where (state != .Loading && state != .Finished):
                state = .Releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == State.Releasing(progress: 1) && scrollView?.dragging == false {
                    state = .Loading
                } else if state != State.Loading && state != State.Finished {
                    state = .Releasing(progress: 1)
                }
            default: break
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    func startRefreshing() {
        if self.state != State.Inital {
            return
        }
        scrollView?.setContentOffset(CGPointMake(0, -self.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.27 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { 
            self.state = State.Loading
        }
        
    }
    
    func endRefreshing() {
        if state == .Loading {
            state = .Finished
        }
    }
}

public enum State:Equatable, CustomStringConvertible {
    case Inital, Loading, Finished
    case Releasing(progress: CGFloat)
    
    public var description: String {
        switch self {
        case .Inital: return "Inital"
        case .Releasing(let progress): return "Releasing:\(progress)"
        case .Loading: return "Loading"
        case .Finished: return "Finished"
        }
    }
}

public func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.Inital, .Inital): return true
    case (.Loading, .Loading): return true
    case (.Finished, .Finished): return true
    case (.Releasing, .Releasing): return true
    default: return false
    }
}
