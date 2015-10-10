//
//  MetaBallFilter.swift
//  Globular
//
//  Created by SIMON_NON_ADMIN on 10/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class MetaBallFilter: CIFilter
{
    var inputImage : CIImage?
    
    override var outputImage: CIImage!
    {
        if let inputImage = inputImage
        {
            let blur = CIFilter(name: "CIGaussianBlur")!
            let edges = CIFilter(name: "CIToneCurve")!
            
            blur.setValue(20, forKey: kCIInputRadiusKey)
            blur.setValue(inputImage, forKey: kCIInputImageKey)
            
            edges.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
            edges.setValue(CIVector(x: 0.25, y: 0), forKey: "inputPoint1")
            edges.setValue(CIVector(x: 0.5, y: 0), forKey: "inputPoint2")
            edges.setValue(CIVector(x: 0.75, y: 1), forKey: "inputPoint3")
            edges.setValue(CIVector(x: 1,y: 1), forKey: "inputPoint4")
            
            edges.setValue(blur.outputImage, forKey: kCIInputImageKey)
            
            return edges.outputImage
        }
        
        return nil
    }
}