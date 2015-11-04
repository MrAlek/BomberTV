//
//  Utility.swift
//  bomberTV
//
//  Created by Alek Åström on 2015-11-04.
//  Copyright © 2015 bomber. All rights reserved.
//

import UIKit
import SpriteKit

extension UIView {
    
    func renderToImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension String {
    
    func renderWithSystemFontSize(systemFontSize: CGFloat) -> UIImage {
        let label = UILabel()
        label.text = self
        label.font = UIFont.systemFontOfSize(systemFontSize)
        label.frame = CGRect(x: 0, y: 0, width: label.intrinsicContentSize().width, height: label.intrinsicContentSize().height)
        label.backgroundColor = UIColor.clearColor()
        
        return label.renderToImage()
    }
}

extension SKSpriteNode {
    
    convenience init(text: String, size: CGFloat) {
        self.init(texture: SKTexture(image: text.renderWithSystemFontSize(size)))
        self.size = texture!.size()
    }
}

public func + (lp: CGPoint, rp: CGPoint) -> CGPoint {
    return CGPoint(x: lp.x+rp.x, y: lp.y+rp.y)
}

public func - (lp: CGPoint, rp: CGPoint) -> CGPoint {
    return CGPoint(x: lp.x-rp.x, y: lp.y-rp.y)
}

public prefix func - (point: CGPoint) -> CGPoint {
    return CGPoint(x: -point.x, y: -point.y)
}

public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

public func * (lp: CGPoint, rp: CGPoint) -> CGFloat {
    return lp.x * rp.x + lp.y * rp.y
}

public func angle(lp: CGPoint, _ rp: CGPoint) -> CGFloat {
    return acos(lp.normalized()*rp.normalized())
}

public extension CGPoint {
    
    var magnitude: CGFloat {
        return sqrt(x*x + y*y)
    }
    
    public func normalized() -> CGPoint {
        return self / magnitude
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
