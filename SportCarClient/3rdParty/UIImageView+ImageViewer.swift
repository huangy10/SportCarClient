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
    
    public func setHighQualityImageURL(url: NSURL) {
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
    
    public func setupForImageViewer(highQualityImageUrl: NSURL? = nil, backgroundColor: UIColor = UIColor.whiteColor(), fadeToHide: Bool = false) {
        userInteractionEnabled = true
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    internal func didTap(recognizer: ImageViewerTapGestureRecognizer) {        
        let imageViewer = ImageViewer(senderView: self, highQualityImageUrl: recognizer.highQualityImageUrl, backgroundColor: recognizer.backgroundColor, fadeToHide: recognizer.fadeToHide)
        imageViewer.presentFromRootViewController()
    }
    
    internal func didLongPress(recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            if image == nil {
                return
            }
            showSaveImageBtn()
        default:
            break
        }
    }
    
    func showSaveImageBtn() {
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        let popover = getPopoverControllerForImageSave()
        rootViewController?.presentViewController(popover, animated: true, completion: nil)
    }
    
    func getPopoverControllerForImageSave() -> UIViewController {
        let controller = UIViewController()
        controller.preferredContentSize = CGSizeMake(100, 44)
        controller.view.addSubview(UIButton).config(self, selector: #selector(saveImageToPhotoAlbums(_:)), title: LS("保存"), titleColor: UIColor.whiteColor(), titleSize: 14, titleWeight: UIFontWeightRegular)
            .layout { (make) in
                make.edges.equalTo(controller.view)
        }
        controller.modalPresentationStyle = .Popover
        let popover = controller.popoverPresentationController
        popover?.sourceRect = bounds
        popover?.sourceView = self
        popover?.permittedArrowDirections = [.Down, .Up]
        popover?.backgroundColor = UIColor.blackColor()
        popover?.delegate = self
        return controller
    }
    
    func saveImageToPhotoAlbums(sender: UIButton) {
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(imageSaved(_: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSaved(image: UIImage, didFinishSavingWithError: NSErrorPointer, contextInfo: UnsafePointer<Void>) {
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
        rootViewController?.showToast(LS("保存成功"))
    }
}


extension UIImageView: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
}

class ImageViewerTapGestureRecognizer: UITapGestureRecognizer {
    var highQualityImageUrl: NSURL?
    var backgroundColor: UIColor!
    var fadeToHide: Bool = false
    
    init(target: AnyObject, action: Selector, highQualityImageUrl: NSURL?, backgroundColor: UIColor, fadeToHide: Bool = false) {
        self.highQualityImageUrl = highQualityImageUrl
        self.backgroundColor = backgroundColor
        self.fadeToHide = fadeToHide
        super.init(target: target, action: action)
    }
}


