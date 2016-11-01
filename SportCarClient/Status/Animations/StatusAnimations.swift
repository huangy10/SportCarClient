//
//  StatusAnimations.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

protocol StatusCoverPresentable: class {
    func initialCoverPosition() -> CGRect
}

class StatusCoverPresentAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var slowDownFactor: Double = 1
    weak var delegate: StatusCoverPresentable!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 * slowDownFactor
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! StatusDetailController
        let containerView = transitionContext.containerView
        
        let fromView = fromVC.view
        let toView = toVC.view
        containerView.addSubview(toView!)
        toView?.layer.opacity = 0
        toView?.frame = transitionContext.finalFrame(for: toVC)
        
        let tempCover = UIImageView()
        tempCover.contentMode = .scaleAspectFill
        tempCover.clipsToBounds = true
        tempCover.kf.setImage(with: toVC.status.coverURL!)
        containerView.addSubview(tempCover)
        tempCover.frame = delegate.initialCoverPosition()
        
        toVC.detail.cover.isHidden = true
        
        UIView.animate(withDuration: 0.5 * slowDownFactor, animations: {
            toView?.layer.opacity = 1
            fromView?.layer.opacity = 0
            tempCover.frame = CGRect(x: 0, y: 64 + toVC.detail.headerHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        }, completion: { (_) in
            tempCover.removeFromSuperview()
            toVC.detail.cover.isHidden = false
            if transitionContext.transitionWasCancelled {
                toView?.removeFromSuperview()
            } else {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

class StatusCoverDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var slowDownFactor: Double = 1
    weak var delegate: StatusCoverPresentable!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 * slowDownFactor
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! StatusDetailController
        let containerView = transitionContext.containerView
        
        let fromView = fromVC.view
        let toView = toVC.view
        toView?.layer.opacity = 0
        toView?.frame = transitionContext.finalFrame(for: toVC)
        containerView.addSubview(toView!)
        
        let tempCover = UIImageView()
        tempCover.contentMode = .scaleAspectFill
        tempCover.clipsToBounds = true
        tempCover.kf.setImage(with: fromVC.status.coverURL!)
        containerView.addSubview(tempCover)
        tempCover.frame = fromVC.detail.convert(CGRect(x: 0, y: fromVC.detail.headerHeight + 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width), to: fromView!)
        
        UIView.animate(withDuration: 0.5 * slowDownFactor, animations: {
            toView?.layer.opacity = 1
            fromView?.layer.opacity = 0
            tempCover.frame = self.delegate.initialCoverPosition()
        }, completion: { (_) in
            tempCover.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                toView?.removeFromSuperview()
            } else {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


class StatusDetailDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var slowDownFactor: Double = 1
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 * slowDownFactor
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! StatusHomeController
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! StatusDetailController
        let containerView = transitionContext.containerView
        
        let fromView = fromVC.view
        let toView = toVC.view
        
        toView?.layer.opacity = 0
        toView?.frame = transitionContext.finalFrame(for: toVC)
        containerView.addSubview(toView!)
        
        let tempDetail = StatusDetailHeaderView()
        containerView.addSubview(tempDetail)
        fromVC.detail.isHidden = true
        tempDetail.status = fromVC.status
        
        let headerHeight = fromVC.header.bounds.height
        let offset = fromVC.tableView.contentOffset.y
        let y = -min(offset, headerHeight)
        tempDetail.snp.makeConstraints { (make) in
            make.left.equalTo(containerView)
            make.right.equalTo(containerView)
            make.top.equalTo(containerView).offset(y + 64)
            make.height.equalTo(headerHeight)
        }
        containerView.updateConstraints()
        containerView.layoutIfNeeded()
        
        let rect2 = fromVC.preCellDetailRect!
        tempDetail.snp.remakeConstraints { (make) in
            make.top.equalTo(rect2.origin.y)
            make.left.equalTo(rect2.origin.x)
            make.size.equalTo(rect2.size)
        }
        
        UIView.animate(withDuration: 0.5 * slowDownFactor, animations: {
            fromView?.layer.opacity = 0
            toView?.layer.opacity = 1
            containerView.layoutIfNeeded()
        }, completion: { (_) in
            tempDetail.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                toView?.removeFromSuperview()
            } else {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


class StatusDetailEntranceAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var fromVC: StatusBasicController!
    let slowDownFactor: Double = 1
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 * slowDownFactor
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! StatusBasicController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! StatusDetailController
        let containerView = transitionContext.containerView
        
        let fromView = fromVC.view.snapshotView(afterScreenUpdates: false)
        let toView = toVC.view
        
        toView?.layer.opacity = 0
        toView?.frame = transitionContext.finalFrame(for: toVC)
        containerView.addSubview(toView!)
        
        let tempDetail = StatusDetailHeaderView()
        containerView.addSubview(tempDetail)
        //        tempDetail.frame = fromVC.getSelectedCellFrame()
        tempDetail.status = toVC.status
        
        
        let rect = fromVC.getSelectedCellFrame()
        toVC.preCellDetailRect = rect
        tempDetail.snp.makeConstraints { (make) in
            make.top.equalTo(rect.origin.y)
            make.left.equalTo(rect.origin.x)
            make.size.equalTo(rect.size)
        }
        containerView.updateConstraints()
        containerView.layoutIfNeeded()
        
        let rect2 = toVC.getHeaderFrame()
        tempDetail.snp.remakeConstraints { (make) in
            make.top.equalTo(rect2.origin.y)
            make.left.equalTo(rect2.origin.x)
            make.size.equalTo(rect2.size)
        }
        
  
        UIView.animate(withDuration: 0.5 * slowDownFactor, animations: {
            fromView?.layer.opacity = 0
            toView?.layer.opacity = 1
            containerView.layoutIfNeeded()
        }, completion: { (_) in
            tempDetail.removeFromSuperview()
            toVC.detail.layer.opacity = 1
            if transitionContext.transitionWasCancelled {
                toView?.removeFromSuperview()
            } else {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

