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
    var hideDelay: TimeInterval = 0
    var refreshing: Bool = false
    deinit {
        removeScrollViewObserving()
    }
    
    fileprivate var state: State = .inital {
        didSet {
            refreshing = false
            switch state {
            case .loading:
                refreshing = true
                pullingLbl.layer.opacity = 0
                confirmingLabl.layer.opacity = 0
                actIndicator.isHidden = false
                actIndicator.startAnimating()
                if let scrollView = scrollView , oldValue != .loading {
                    scrollView.contentOffset = previousScrollViewOffset
                    scrollView.bounces = false
                    UIView.animate(withDuration: 0.3, animations: { 
                        let insets = self.frame.height + self.scrollViewDefaultInsets.top
                        scrollView.contentInset.top = insets
                        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: -insets)
                        }, completion: { _ in
                            scrollView.bounces = true
                    })
                }
                action?()
            case .finished:
                removeScrollViewObserving()
                SpringAnimation.springWithCompletion(duration: 1, animations: { 
                    self.scrollView?.contentInset = self.scrollViewDefaultInsets
                    self.scrollView?.contentOffset.y -= self.scrollViewDefaultInsets.top
                    self.actIndicator.layer.opacity = 0
                    }, completion: { (_) in
                        self.addScrollViewObserving()
                        self.state = .inital
                        self.actIndicator.layer.opacity = 1
                        self.actIndicator.isHidden = true
                })
            case .releasing(let progress):
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
    
    func addToSrollView(_ scrollView: UIScrollView, action: @escaping ()->()) {
        self.scrollView = scrollView
        self.action = action
        scrollView.addSubview(self)
        self.frame  = CGRect(x: 0, y: scrollView.contentInset.top - 80, width: UIScreen.main.bounds.width, height: 80)
    }
    
    func createSubviews() {
        pullingLbl = self.addSubview(UILabel.self).config(textColor: kTextGray87, textAlignment: .center)
            .layout({ (make) in
                make.center.equalTo(self)
            })
        
        confirmingLabl = self.addSubview(UILabel.self).config(textColor: kTextGray87, textAlignment: .center)
            .layout({ (make) in
                make.center.equalTo(self)
            })
        confirmingLabl.text = LS("放开切换到当前地点")
        confirmingLabl.layer.opacity = 0
        
        actIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.addSubview(actIndicator)
        actIndicator.layout({ (make) in
            make.center.equalTo(self)
            make.size.equalTo(40)
        })
        actIndicator.isHidden = true
    }
    
    fileprivate var scrollViewDefaultInsets = UIEdgeInsets.zero
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
    
    fileprivate func addScrollViewObserving() {
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .initial, context: &KVOContext)
    }
    
    fileprivate func removeScrollViewObserving() {
        scrollView?.removeObserver(self, forKeyPath: "contentOffset", context: &KVOContext)
    }
    
    // MARK: - KVO
    fileprivate var KVOContext = "PullToRefreshKVOContext"
    fileprivate var previousScrollViewOffset: CGPoint = CGPoint.zero
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (context == &KVOContext && keyPath == "contentOffset" && object as? UIScrollView == scrollView) {
            let offset = previousScrollViewOffset.y + scrollViewDefaultInsets.top
            let refreshViewHeight = self.frame.height
        
            switch offset {
            case 0 where (state != .loading): state = .inital
            case -refreshViewHeight...0 where (state != .loading && state != .finished):
                state = .releasing(progress: -offset / refreshViewHeight)
            case -1000...(-refreshViewHeight):
                if state == State.releasing(progress: 1) && scrollView?.isDragging == false {
                    state = .loading
                } else if state != State.loading && state != State.finished {
                    state = .releasing(progress: 1)
                }
            default: break
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        previousScrollViewOffset.y = scrollView!.contentOffset.y
    }
    
    func startRefreshing() {
        if self.state != State.inital {
            return
        }
        scrollView?.setContentOffset(CGPoint(x: 0, y: -self.frame.height - scrollViewDefaultInsets.top), animated: true)
        let delayTime = DispatchTime.now() + Double(Int64(0.27 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) { 
            self.state = State.loading
        }
        
    }
    
    func endRefreshing() {
        if state == .loading {
            state = .finished
        }
    }
}

public enum State:Equatable, CustomStringConvertible {
    case inital, loading, finished
    case releasing(progress: CGFloat)
    
    public var description: String {
        switch self {
        case .inital: return "Inital"
        case .releasing(let progress): return "Releasing:\(progress)"
        case .loading: return "Loading"
        case .finished: return "Finished"
        }
    }
}

public func ==(a: State, b: State) -> Bool {
    switch (a, b) {
    case (.inital, .inital): return true
    case (.loading, .loading): return true
    case (.finished, .finished): return true
    case (.releasing, .releasing): return true
    default: return false
    }
}
