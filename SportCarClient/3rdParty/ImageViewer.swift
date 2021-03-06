//
//  ImageViewer.swift
//  ImageViewer
//
//  Created by Tan Nghia La on 30.04.15.
//  Copyright (c) 2015 Tan Nghia La. All rights reserved.
//

import UIKit
import Kingfisher
//import Haneke

class ImageViewer: UIViewController, LoadingProtocol {
    internal var delayWorkItem: DispatchWorkItem?
    // MARK: - Properties
    let kMinMaskViewAlpha: CGFloat = 0.3
    let kMaxImageScale: CGFloat = 2.5
    let kMinImageScale: CGFloat = 1.0
    
    var senderView: UIImageView!
    var originalFrameRelativeToScreen: CGRect!
    var originalCornerRadius: CGFloat = 0;
    var rootViewController: UIViewController!
    var imageView = UIImageView()
    var panGesture: UIPanGestureRecognizer!
    var panOrigin: CGPoint!
    var highQualityImageUrl: URL?
    
    var isAnimating = false
    var isLoaded = false
    var fadeToHide = false
    
    let closeButton = UIButton()
    let windowBounds = UIScreen.main.bounds
    var scrollView = UIScrollView()
    var maskView = UIView()
    
    var saveBtn: UIButton!
    
    // MARK: - Lifecycle methods
    init(senderView: UIImageView,highQualityImageUrl: URL?, backgroundColor: UIColor, fadeToHide: Bool = false) {
        self.senderView = senderView
        self.highQualityImageUrl = highQualityImageUrl
        self.fadeToHide = fadeToHide
        
        rootViewController = UIApplication.shared.keyWindow!.rootViewController!
        maskView.backgroundColor = backgroundColor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        configureView()
        configureMaskView()
        configureScrollView()
        configureCloseButton()
        configureSaveBtn()
        configureImageView()
        configureConstraints()
    }
    
    func configureSaveBtn() {
        closeButton.isHidden = true
        saveBtn = view.addSubview(UIButton.self).config(self, selector: #selector(saveToPhotos))
            .layout({ (mk) in
                mk.center.equalTo(closeButton)
                mk.width.equalTo(50)
                mk.height.equalTo(30)
            })
        
        saveBtn.setTitle(LS("保存"), for: .normal)
        saveBtn.layer.borderColor = kHighlightRed.cgColor
        saveBtn.layer.borderWidth = 1
        saveBtn.layer.cornerRadius = 3
        
        saveBtn.alpha = 0.0
    }
    
    // MARK: - View configuration
    func configureScrollView() {
        scrollView.frame = windowBounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = kMinImageScale
        scrollView.maximumZoomScale = kMaxImageScale
        scrollView.zoomScale = 1
        
        view.addSubview(scrollView)
    }
    
    func configureMaskView() {
        maskView.frame = windowBounds
        maskView.alpha = 0.0
        
        view.insertSubview(maskView, at: 0)
    }
    
    func configureCloseButton() {
        closeButton.alpha = 0.0
        
        let image = UIImage(named: "Close", in: Bundle(for: ImageViewer.self), compatibleWith: nil)
        
        closeButton.setImage(image, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(ImageViewer.closeButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(closeButton)
        
        view.setNeedsUpdateConstraints()
    }
    
    func configureView() {
        var originalFrame = senderView.convert(windowBounds, to: nil)
        originalFrame.origin = CGPoint(x: originalFrame.origin.x, y: originalFrame.origin.y)
        originalFrame.size = senderView.frame.size
        originalCornerRadius = senderView.layer.cornerRadius
        originalFrameRelativeToScreen = originalFrame
    }
    
    func configureImageView() {
        senderView.alpha = 0.0
        
        imageView.frame = originalFrameRelativeToScreen
        imageView.layer.cornerRadius = originalCornerRadius
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        if let highQualityImageUrl = highQualityImageUrl {
//            imageView.hnk_setImageFromURL(highQualityImageUrl, placeholder: senderView.image, format: nil, failure: nil, success: nil)
//            imageView.kf_setImageWithURL(highQualityImageUrl, placeholderImage: senderView.image)
            imageView.kf.setImage(with: highQualityImageUrl, placeholder: senderView.image, options: nil, progressBlock: nil, completionHandler: nil)
        } else {
            imageView.image = senderView.image
        }
        
        scrollView.addSubview(imageView)
        
        animateEntry()
        addPanGestureToView()
        addGestures()
        
        centerScrollViewContents()
    }
    
    func configureConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        let views: [String: UIView] = [
            "closeButton": closeButton
        ]
        constraints.append(NSLayoutConstraint(item: closeButton, attribute: .centerX, relatedBy: .equal, toItem: closeButton.superview, attribute: .centerX, multiplier: 1.0, constant: 0))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[closeButton(==64)]-40-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:[closeButton(==64)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Gestures
    func addPanGestureToView() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ImageViewer.gestureRecognizerDidPan(_:)))
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        
        imageView.addGestureRecognizer(panGesture)
    }
    
    func addGestures() {
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewer.didSingleTap(_:)))
        singleTapRecognizer.numberOfTapsRequired = 1
        singleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ImageViewer.didDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        singleTapRecognizer.require(toFail: doubleTapRecognizer)
    }
    
    func zoomInZoomOut(_ point: CGPoint) {
        let newZoomScale = scrollView.zoomScale > (scrollView.maximumZoomScale / 2) ? scrollView.minimumZoomScale : scrollView.maximumZoomScale
        
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = point.x - (w / 2.0)
        let y = point.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
        scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    // MARK: - Animation
    func animateEntry() {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.beginFromCurrentState, animations: {() -> Void in
            if let image = self.imageView.image {
                self.imageView.frame = self.centerFrameFromImage(image)
                self.imageView.layer.cornerRadius = 0
            } else {
                fatalError("Image within UIImageView needed.")
            }
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.03, options: UIViewAnimationOptions.beginFromCurrentState, animations: {() -> Void in
//            self.closeButton.alpha = 1.0
            self.saveBtn.alpha = 1.0
            self.maskView.alpha = 1.0
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: UIViewAnimationOptions.beginFromCurrentState, animations: {() -> Void in
            self.view.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            self.rootViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
            }, completion: nil)
    }
    
    func centerFrameFromImage(_ image: UIImage) -> CGRect {
        var newImageSize = imageResizeBaseOnWidth(windowBounds.size.width, oldWidth: image.size.width, oldHeight: image.size.height)
        newImageSize.height = min(windowBounds.size.height, newImageSize.height)
        
        return CGRect(x: 0, y: windowBounds.size.height / 2 - newImageSize.height / 2, width: newImageSize.width, height: newImageSize.height)
    }
    
    func imageResizeBaseOnWidth(_ newWidth: CGFloat, oldWidth: CGFloat, oldHeight: CGFloat) -> CGSize {
        let scaleFactor = newWidth / oldWidth
        let newHeight = oldHeight * scaleFactor
        return CGSize(width: newWidth, height: newHeight)
    }
    
    // MARK: - Actions
    func gestureRecognizerDidPan(_ recognizer: UIPanGestureRecognizer) {
        if scrollView.zoomScale != 1.0 || isAnimating {
            return
        }
        
        senderView.alpha = 0.0
        
        scrollView.bounces = false
        let windowSize = maskView.bounds.size
        let currentPoint = panGesture.translation(in: scrollView)
        let y = currentPoint.y + panOrigin.y
        
        imageView.frame.origin = CGPoint(x: currentPoint.x + panOrigin.x, y: y)
        
        let yDiff = abs((y + imageView.frame.size.height / 2) - windowSize.height / 2)
        maskView.alpha = max(1 - yDiff / (windowSize.height / 0.95), kMinMaskViewAlpha)
        closeButton.alpha = max(1 - yDiff / (windowSize.height / 0.95), kMinMaskViewAlpha) / 2
        
        if (panGesture.state == UIGestureRecognizerState.ended || panGesture.state == UIGestureRecognizerState.cancelled) && scrollView.zoomScale == 1.0 {
            if maskView.alpha < 0.85 {
                dismissViewController()
            } else {
                rollbackViewController()
            }
        }
    }
    
    func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1.0 {
            dismissViewController()
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    func didDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        zoomInZoomOut(pointInView)
    }
    
    func closeButtonTapped(_ sender: UIButton) {
        if scrollView.zoomScale != 1.0 {
            scrollView.setZoomScale(1.0, animated: true)
        }
        dismissViewController()
    }

    // MARK: - Misc.
    func centerScrollViewContents() {
        let boundsSize = rootViewController.view.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func rollbackViewController() {
        isAnimating = true
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.beginFromCurrentState, animations: {() in
            if let image = self.imageView.image {
                self.imageView.frame = self.centerFrameFromImage(image)
            } else {
                fatalError("Image within UIImageView needed.")
            }
            self.maskView.alpha = 1.0
            self.closeButton.alpha = 1.0
            }, completion: {(finished) in
                self.isAnimating = false
        })
    }
    
    func dismissViewController() {
        isAnimating = true
        DispatchQueue.main.async(execute: {
            self.imageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.2, animations: {() in
                self.closeButton.alpha = 0.0
            })
            
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: UIViewAnimationOptions.beginFromCurrentState, animations: {() in
                if !self.fadeToHide {
                    self.imageView.frame = self.originalFrameRelativeToScreen
                    self.imageView.layer.cornerRadius = self.originalCornerRadius
                    self.rootViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                    self.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                } else {
                    self.imageView.layer.opacity = 0.0
                    self.senderView.alpha = 1.0
                    self.rootViewController.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                    self.view.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
                }
                
                self.maskView.alpha = 0.0
                self.saveBtn.alpha = 0.0
                }, completion: {(finished) in
                    self.willMove(toParentViewController: nil)
                    self.view.removeFromSuperview()
                    self.removeFromParentViewController()
                    self.senderView.alpha = 1.0
                    self.isAnimating = false
            })
        })
    }
    
    func presentFromRootViewController() {
        willMove(toParentViewController: rootViewController)
        rootViewController.view.addSubview(view)
        rootViewController.addChildViewController(self)
        didMove(toParentViewController: rootViewController)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func saveToPhotos() {
        lp_start()
        UIImageWriteToSavedPhotosAlbum(imageView.image!, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        lp_stop()
        if let err = didFinishSavingWithError?.pointee {
            showToast(LS("保存失败: ") + err.description)
        } else {
            showToast(LS("保存成功"))
        }
        
    }
}

// MARK: - GestureRecognizer delegate
extension ImageViewer: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        panOrigin = imageView.frame.origin
        gestureRecognizer.isEnabled = true
        return !isAnimating
    }
}

// MARK: - ScrollView delegate
extension ImageViewer: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        isAnimating = true
        centerScrollViewContents()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isAnimating = false
    }
}
