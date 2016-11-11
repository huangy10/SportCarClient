//
//  FBAnnotationClusterView.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit


protocol ClusterAnnotationViewDelegate: class {
    func clusterAnnotationPressed(_ clusterView: ClusterAnnotationView)
}


class ClusterAnnotationView: BMKAnnotationView {
    
    weak var delegate: ClusterAnnotationViewDelegate!
    
    var countLbl: UILabel!
    var btn: UIButton!
    
    override init!(annotation: BMKAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        let cluster = annotation as! FBAnnotationCluster
        let count = cluster.annotations.count
        
        bounds = CGRect(x: 0, y: 0, width: 65, height: 65)
        let bg = addSubview(UIView.self).config(kHighlightRed)
            .layout { (mk) in
                mk.edges.equalTo(self)
        }.addShadow()
        bg.layer.cornerRadius = 32.5
        btn = addSubview(UIButton.self).config(self, selector: #selector(btnPressed))
            .layout({ (mk) in
                mk.edges.equalTo(self)
            })
        countLbl = addSubview(UILabel.self).config(21, fontWeight: UIFontWeightSemibold, textColor: .white, textAlignment: .center, text: count > 99 ? "99+" : "\(count)")
            .layout({ (mk) in
                mk.center.equalTo(self)
            })
    }
    
    func btnPressed() {
        delegate.clusterAnnotationPressed(self)
    }
    
    func resetCountLblVal() {
        let cluster = annotation as! FBAnnotationCluster
        let val = cluster.annotations.count
        countLbl.text = val > 99 ? "99+" : "\(val)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

open class FBAnnotationClusterView : BMKAnnotationView {
    
    var count = 0
    
    var fontSize:CGFloat = 12
    
    var imageName = "clusterSmall"
    var loadExternalImage : Bool = false
    
    var borderWidth:CGFloat = 3
    
    var countLabel:UILabel? = nil
    
    //var option : FBAnnotationClusterViewOptions? = nil
    
    public init(annotation: BMKAnnotation?, reuseIdentifier: String?, options: FBAnnotationClusterViewOptions?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let cluster:FBAnnotationCluster = annotation as! FBAnnotationCluster
        count = cluster.annotations.count
        
        // change the size of the cluster image based on number of stories
        switch count {
        case 0...5:
            fontSize = 12
            if (options != nil) {
                loadExternalImage=true;
                imageName = (options?.smallClusterImage)!
            }
            else {
                imageName = "clusterSmall"
            }
            borderWidth = 3
            
        case 6...15:
            fontSize = 13
            if (options != nil) {
                loadExternalImage=true;
                imageName = (options?.mediumClusterImage)!
            }
            else {
                imageName = "clusterMedium"
            }
            borderWidth = 4
            
        default:
            fontSize = 14
            if (options != nil) {
                loadExternalImage=true;
                imageName = (options?.largeClusterImage)!
            }
            else {
                imageName = "clusterLarge"
            }
            borderWidth = 5
            
        }
        
        backgroundColor = UIColor.clear
        bounds = CGRect(x: 0, y: 0, width: 65, height: 65)
        setupLabel()
        setTheCount(count)
    }
    
//    required override public init(frame: CGRect) {
//        super.init(frame: frame)
//        
//    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupLabel(){
        countLabel = UILabel(frame: bounds)
        
        if let countLabel = countLabel {
            countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            countLabel.textAlignment = .center
            countLabel.backgroundColor = UIColor.clear
            countLabel.textColor = UIColor.black
            countLabel.adjustsFontSizeToFitWidth = true
            countLabel.minimumScaleFactor = 2
            countLabel.numberOfLines = 1
            countLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
            countLabel.baselineAdjustment = .alignCenters
            addSubview(countLabel)
        }
        
    }
    
    func setTheCount(_ localCount:Int){
        count = localCount;
        
        countLabel?.text = "\(localCount)"
        setNeedsLayout()
    }
    
    override open func layoutSubviews() {
        
        // Images are faster than using drawRect:
        
//        let imageAsset = UIImage(named: imageName, in: (!loadExternalImage) ? Bundle(for: FBAnnotationClusterView.self) : nil, compatibleWith: nil)
        
        //UIImage(named: imageName)!
        
        countLabel?.frame = self.bounds
//        image = imageAsset
        centerOffset = CGPoint.zero
        
        // adds a white border around the green circle
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = self.bounds.size.width / 2
        
    }
    
}

open class FBAnnotationClusterViewOptions : NSObject {
    var smallClusterImage : String
    var mediumClusterImage : String
    var largeClusterImage : String
    
   
    public init (smallClusterImage : String, mediumClusterImage : String, largeClusterImage : String) {
        self.smallClusterImage = smallClusterImage;
        self.mediumClusterImage = mediumClusterImage;
        self.largeClusterImage = largeClusterImage;
    }
    
}
