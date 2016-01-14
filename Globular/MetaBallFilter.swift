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
    
    let blurFilter = CIFilter(name: "CIGaussianBlur",
        withInputParameters: [kCIInputRadiusKey: 30])!
    
    let thresholdFilter = ThresholdFilter()
    let blendWithMask = CIFilter(name: "CIBlendWithMask")!

    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        thresholdFilter.threshold = 0.2

        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        thresholdFilter.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        
        blendWithMask.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        blendWithMask.setValue(CIImage(), forKey: kCIInputBackgroundImageKey)
        blendWithMask.setValue(thresholdFilter.outputImage, forKey: kCIInputMaskImageKey)

        return blendWithMask.outputImage
    }
}

class ThresholdFilter: CIFilter
{
    var inputImage : CIImage?
    var threshold: CGFloat = 0.75
    
    let thresholdKernel = CIColorKernel(string:
        "kernel vec4 thresholdFilter(__sample image, float threshold)" +
        "{" +
            "   float luma = (image.r * 0.2126) + (image.g * 0.7152) + (image.b * 0.0722);" +
            
            "   return (luma > threshold) ? vec4(1.0, 1.0, 1.0, 1.0) : vec4(0.0, 0.0, 0.0, 0.0);" +
        "}"
    )
    
    
    override var outputImage : CIImage!
    {
        guard let inputImage = inputImage,
            thresholdKernel = thresholdKernel else
        {
            return nil
        }
        
        let extent = inputImage.extent
        let arguments = [inputImage, threshold]
        
        return thresholdKernel.applyWithExtent(extent, arguments: arguments)
    }
}



