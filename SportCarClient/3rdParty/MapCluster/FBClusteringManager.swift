//
//  FBClusteringManager.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

public protocol FBClusteringManagerDelegate {
    
    func cellSizeFactorForCoordinator(_ coordinator:FBClusteringManager) -> CGFloat
    
}

open class FBClusteringManager : NSObject {
    
    open var delegate:FBClusteringManagerDelegate? = nil
    
    var tree:FBQuadTree? = nil
    
    var lock:NSRecursiveLock = NSRecursiveLock()
    var userAnno: BMKAnnotation?
    
    open var maxZoomLevel = 1.0
    
    public override init(){
        super.init()
    }
    
    public init(annotations: [BMKAnnotation]){
        super.init()
        addAnnotations(annotations)
    }
    
    open func setAnnotations(_ annotations:[BMKAnnotation]){
        tree = nil
        addAnnotations(annotations)
    }
    
    open func addAnnotations(_ annotations:[BMKAnnotation]){
        if tree == nil {
            tree = FBQuadTree()
        }
        
        lock.lock()
        for annotation in annotations {
            _ = tree!.insertAnnotation(annotation)
        }
        lock.unlock()
    }
    
    // rect传入的是map的visibleRect
    open func clusteredAnnotationsWithinMapRect(_ rect:BMKMapRect, withZoomScale zoomScale:Double, zoomLevel: Float) -> [BMKAnnotation]{
        guard !zoomScale.isInfinite else { return [] }
        
        let cellSize:CGFloat = FBClusteringManager.FBCellSizeForZoomLevel(zoomLevel)
        
        //        if delegate?.respondsToSelector("cellSizeFactorForCoordinator:") {
        //            cellSize *= delegate.cellSizeFactorForCoordinator(self)
        //        }
        
        let scaleFactor:Double = zoomScale / Double(cellSize)
        
        let minX:Int = Int(floor(BMKMapRectGetMinX(rect) * scaleFactor))
        let maxX:Int = Int(floor(BMKMapRectGetMaxX(rect) * scaleFactor))
        let minY:Int = Int(floor(BMKMapRectGetMinY(rect) * scaleFactor))
        let maxY:Int = Int(floor(BMKMapRectGetMaxY(rect) * scaleFactor))
        
        var clusteredAnnotations = [BMKAnnotation]()
        
        lock.lock()
//        print(FBQuadTreeNode.FBBoundingBoxForMapRect(rect))
//        for a in self.allAnnotations() {
//            print(a.coordinate)
//        }
        
        for i in minX...maxX {
            
            for j in minY...maxY {
                
                let mapPoint = BMKMapPoint(x: Double(i)/scaleFactor, y: Double(j)/scaleFactor)
                
                let mapSize = BMKMapSize(width: 1.0/scaleFactor, height: 1.0/scaleFactor)
                
                let mapRect = BMKMapRect(origin: mapPoint, size: mapSize)
                let mapBox:FBBoundingBox  = FBQuadTreeNode.FBBoundingBoxForMapRect(mapRect)
                
                var totalLatitude:Double = 0
                var totalLongitude:Double = 0
                
                var annotations = [BMKAnnotation]()
                
                tree?.enumerateAnnotationsInBox(mapBox){ obj in
                    totalLatitude += obj.coordinate.latitude
                    totalLongitude += obj.coordinate.longitude
                    annotations.append(obj)
                }
                
                let count = annotations.count
                
                if count == 1 {
                    clusteredAnnotations += annotations
                }
                
                if count > 1 && zoomScale < self.maxZoomLevel {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(count),
                        longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(count)
                    )
                    let cluster = FBAnnotationCluster()
                    cluster.coordinate = coordinate
                    cluster.annotations = annotations
                    clusteredAnnotations.append(cluster)
                } else {
                    clusteredAnnotations += annotations
                }
            }
            
        }
        
        
        lock.unlock()
        
        return clusteredAnnotations
    }
    
    open func allAnnotations() -> [BMKAnnotation] {
        
        var annotations = [BMKAnnotation]()
        
        lock.lock()
        tree?.enumerateAnnotationsUsingBlock(){ obj in
            annotations.append(obj)
        }
        lock.unlock()
        
        return annotations
    }
    
    open func displayAnnotations(_ annotations: [BMKAnnotation], onMapView mapView:BMKMapView){
        
        DispatchQueue.main.async  {
            
            let before = NSMutableSet(array: mapView.annotations)
            if let userLocation = self.userAnno {
                before.remove(userLocation)
            }

//            before.remove(mapView.userLocation)
            let after = NSSet(array: annotations)
            let toKeep = NSMutableSet(set: before)
            toKeep.intersect(after as Set<NSObject>)
            let toAdd = NSMutableSet(set: after)
            toAdd.minus(toKeep as Set<NSObject>)
            let toRemove = NSMutableSet(set: before)
            toRemove.minus(after as Set<NSObject>)
            
            if let toAddAnnotations = toAdd.allObjects as? [BMKAnnotation]{
                mapView.addAnnotations(toAddAnnotations)
            }
            
            if let removeAnnotations = toRemove.allObjects as? [BMKAnnotation]{
                mapView.removeAnnotations(removeAnnotations)
            }
        }
        
    }
    
    open class func FBZoomScaleToZoomLevel(_ scale:MKZoomScale) -> Int{
        let totalTilesAtMaxZoom:Double = MKMapSizeWorld.width / 256.0
        let zoomLevelAtMaxZoom:Int = Int(log2(totalTilesAtMaxZoom))
        let floorLog2ScaleFloat = floor(log2f(Float(scale))) + 0.5
        guard !floorLog2ScaleFloat.isInfinite else { return (floorLog2ScaleFloat.sign == .minus) ? 0 : 19 }
        let sum:Int = zoomLevelAtMaxZoom + Int(floorLog2ScaleFloat)
        let zoomLevel:Int = max(0, sum)
        return zoomLevel;
    }
    
    open class func FBCellSizeForZoomLevel(_ zoomLevel: Float) -> CGFloat {
        
        switch (Int(zoomLevel)) {
        case 13:
            return 64
        case 14:
            return 64
        case 15:
            return 64
        case 16:
            return 32
        case 17:
            return 32
        case 18:
            return 32
        case 18 ..< Int.max:
            return 16
            
        default:
            // less than 13 zoom level
            return 88
        }
    }
    
    open class func FBCellSizeForZoomScale(_ zoomScale:MKZoomScale) -> CGFloat {
        
        let zoomLevel:Int = FBClusteringManager.FBZoomScaleToZoomLevel(zoomScale) - 1
        
        switch (zoomLevel) {
        case 13:
            return 64
        case 14:
            return 64
        case 15:
            return 64
        case 16:
            return 32
        case 17:
            return 32
        case 18:
            return 32
        case 18 ..< Int.max:
            return 16
            
        default:
            // less than 13 zoom level
            return 88
        }
        
    }
    
}
