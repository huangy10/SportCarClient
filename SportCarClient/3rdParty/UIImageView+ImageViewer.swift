//
//  UIImageView+ImageViewer.swift
//  ImageViewer
//
//  Created by Tan Nghia La on 03.05.15.
//  Copyright (c) 2015 Tan Nghia La. All rights reserved.
//

import Foundation
import UIKit

public extension UIImageView {
    
    public func setHighQualityImageURL(_ url: URL) {
        guard let gestures = gestureRecognizers else {
            assertionFailure("You should call setupForImageViewer before changing the high quality image url")
            return
        }
        for g in gestures {
            if let gg = g as? ImageViewerTapGestureRecognizer {
                gg.highQualityImageUrl = url
            }
        }
    }
    
    public func setupForImageViewer(_ highQualityImageUrl: URL? = nil, backgroundColor: UIColor = UIColor.white, fadeToHide: Bool = false) {
        isUserInteractionEnabled = true
        if gestureRecognizers != nil {
            for g in gestureRecognizers! {
                if let gg = g as? ImageViewerTapGestureRecognizer {
                    gg.highQualityImageUrl = highQualityImageUrl
                    gg.backgroundColor = backgroundColor
                    return
                }
            }
        }
        let gestureRecognizer = ImageViewerTapGestureRecognizer(target: self, action: #selector(UIImageView.didTap(_:)), highQualityImageUrl: highQualityImageUrl, backgroundColor: backgroundColor, fadeToHide: fadeToHide)
        addGestureRecognizer(gestureRecognizer)
    }
    
    internal func didTap(_ recognizer: ImageViewerTapGestureRecognizer) {        
        let imageViewer = ImageViewer(senderView: self, highQualityImageUrl: recognizer.highQualityImageUrl, backgroundColor: recognizer.backgroundColor, fadeToHide: recognizer.fadeToHide)
        imageViewer.presentFromRootViewController()
    }
}


extension UIImageView: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
}

class ImageViewerTapGestureRecognizer: UITapGestureRecognizer {
    var highQualityImageUrl: URL?
    var backgroundColor: UIColor!
    var fadeToHide: Bool = false
    
    init(target: AnyObject, action: Selector, highQualityImageUrl: URL?, backgroundColor: UIColor, fadeToHide: Bool = false) {
        self.highQualityImageUrl = highQualityImageUrl
        self.backgroundColor = backgroundColor
        self.fadeToHide = fadeToHide
        super.init(target: target, action: action)
    }
}


