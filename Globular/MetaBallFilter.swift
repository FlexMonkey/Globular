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
    
    let blurFilter = CIFilter(name: "CIGaussianBlur")!
    let thresholdFilter = ThresholdFilter()
    let heightmapFilter = CIFilter(name: "CIHeightFieldFromMask")!
    let falseColorFilter = CIFilter(name: "CIFalseColor",
        withInputParameters: ["inputColor0": CIColor(red: 1, green: 1, blue: 0),
            "inputColor1": CIColor(red: 0, green: 0.5, blue: 1)])!
    
    /// The false color effect, which uses a height map, is quite slow on iPads
    /// but acceptable on my iPhone 6s. `useFalseColor` controls whether to 
    /// output the funky amoeba style effect or simply display the output from 
    /// the threshold filter.
    var useFalseColor = false
    
    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        thresholdFilter.threshold = 0.2
        
        blurFilter.setValue(25, forKey: kCIInputRadiusKey)
        blurFilter.setValue(inputImage, forKey: kCIInputImageKey)
        
        thresholdFilter.setValue(blurFilter.outputImage, forKey: kCIInputImageKey)
        
        if useFalseColor
        {
            heightmapFilter.setValue(thresholdFilter.outputImage, forKey: kCIInputImageKey)
            
            falseColorFilter.setValue(heightmapFilter.outputImage, forKey: kCIInputImageKey)
            
            return falseColorFilter.outputImage
        }
        else
        {
            return thresholdFilter.outputImage
        }
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