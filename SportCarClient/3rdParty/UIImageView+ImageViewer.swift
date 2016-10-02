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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    internal func didTap(_ recognizer: ImageViewerTapGestureRecognizer) {        
        let imageViewer = ImageViewer(senderView: self, highQualityImageUrl: recognizer.highQualityImageUrl, backgroundColor: recognizer.backgroundColor, fadeToHide: recognizer.fadeToHide)
        imageViewer.presentFromRootViewController()
    }
    
    internal func didLongPress(_ recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if image == nil {
                return
            }
            showSaveImageBtn()
        default:
            break
        }
    }
    
    func showSaveImageBtn() {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let popover = getPopoverControllerForImageSave()
        rootViewController?.present(popover, animated: true, completion: nil)
    }
    
    func getPopoverControllerForImageSave() -> UIViewController {
        let controller = UIViewController()
        controller.preferredContentSize = CGSize(width: 100, height: 44)
        controller.view.addSubview(UIButton.self).config(self, selector: #selector(saveImageToPhotoAlbums(_:)), title: LS("保存"), titleColor: UIColor.white, titleSize: 14, titleWeight: UIFontWeightRegular)
            .layout { (make) in
                make.edges.equalTo(controller.view)
        }
        controller.modalPresentationStyle = .popover
        let popover = controller.popoverPresentationController
        popover?.sourceRect = bounds
        popover?.sourceView = self
        popover?.permittedArrowDirections = [.down, .up]
        popover?.backgroundColor = UIColor.black
        popover?.delegate = self
        return controller
    }
    
    func saveImageToPhotoAlbums(_ sender: UIButton) {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController?.dismiss(animated: true, completion: nil)
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(imageSaved(_: didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController?.showToast(LS("保存成功"))
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


