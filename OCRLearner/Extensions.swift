import Foundation
import UIKit
import CoreImage

/**
 author: Samuel Rosenstein
 
 note: much of this code is highly based off of extensions found in the SwiftAI example code
 
*/
extension UIImage {
    
    public func floatRepresentation() -> [Float] {
        let preImage = self.getGrayScale()
        let image = preImage!.shrinkImage()
        
        let numPixels = Int((image?.size.width)!) * Int((image?.size.height)!)
        
        
        let trainImagesData = UIImagePNGRepresentation(self) // UIImageJPEGRepresentation(self, 1.0)
        // Extract training image pixels
        var trainPixelsArray = [UInt8](repeating: 0, count: numPixels)
        (trainImagesData! as NSData).getBytes(&trainPixelsArray, range: NSMakeRange(0, numPixels)) //length: numPixels)
        // Convert pixels to Floats
        var trainPixelsFloatArray = [Float](repeating: 0, count: numPixels)
        for (index, pixel) in trainPixelsArray.enumerated() {
            trainPixelsFloatArray[index] = Float(pixel) / 255 // Normalize pixel value
        }
        return Array(trainPixelsFloatArray[80...trainPixelsFloatArray.count-1])
    }
    
    // Get grayscale image from normal image.
    
    func getGrayScale() -> UIImage? {
        let inImage:CGImage = self.cgImage!
        let context = self.createARGBBitmapContextFromImage(inImage)
        let pixelsWide = inImage.width
        let pixelsHigh = inImage.height
        let rect = CGRect(x:0, y:0, width:Int(pixelsWide), height:Int(pixelsHigh))
        
        let bitmapBytesPerRow = Int(pixelsWide) * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        //Clear the context
        context?.clear(rect)
        
        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        context?.draw(inImage, in: rect)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        
        
        let data = context?.data
        let dataType = UnsafeMutablePointer<UInt8>(data)
        let point: CGPoint = CGPoint(x: 0, y: 0)
        
        for x in 0 ..< Int(pixelsWide) {
            for y in 0 ..< Int(pixelsHigh) {
                let offset = 4*((Int(pixelsWide) * Int(y)) + Int(x))
                let alpha = dataType[offset]
                let red = dataType[offset+1]
                let green = dataType[offset+2]
                let blue = dataType[offset+3]
                
                let avg = (UInt32(red) + UInt32(green) + UInt32(blue))/3
                
                dataType[offset + 1] = UInt8(avg)
                dataType[offset + 2] = UInt8(avg)
                dataType[offset + 3] = UInt8(avg)
            }
        }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        let finalcontext = CGContext(data: data, width: pixelsWide, height: pixelsHigh, bitsPerComponent: 8,  bytesPerRow: bitmapBytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        let imageRef = finalcontext?.makeImage()
        return UIImage(cgImage: imageRef!, scale: self.scale,orientation: self.imageOrientation)
    }
    
    public func createARGBBitmapContextFromImage(_ inImage: CGImage) -> CGContext? {
        
        let width = inImage.width
        let height = inImage.height
        
        let bitmapBytesPerRow = width * 4
        let bitmapByteCount = bitmapBytesPerRow * height
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if colorSpace == nil {
            return nil
        }
        
        let bitmapData = malloc(bitmapByteCount)
        if bitmapData == nil {
            return nil
        }
        
        let context = CGContext (data: bitmapData,
            width: width,
            height: height,
            bitsPerComponent: 8,      // bits per component
            bytesPerRow: bitmapBytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        return context
    }
    
    public func shrinkImage() -> UIImage? {
        // Scale character to max 20px in either dimension
        let scaledImage = self.scaleImageToSize(self, maxLength: 20)
        // Center character in 28x28 white box
        let character = self.addBorderToImage(scaledImage)
        return character
    }
    
    public func cropImage(_ image: UIImage, toRect: CGRect) -> UIImage {
        let imageRef = image.cgImage!.cropping(to: toRect)
        let newImage = UIImage(cgImage: imageRef!)
        return newImage
    }
    
    public func scaleImageToSize(_ image: UIImage, maxLength: CGFloat) -> UIImage {
        let size = CGSize(width: min(maxLength * image.size.width / image.size.height, maxLength), height: min(maxLength * image.size.height / image.size.width, maxLength))
        let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = CGInterpolationQuality.none
        image.draw(in: newRect)
        
        let newImageRef = (context?.makeImage()!)! as CGImage
        let newImage = UIImage(cgImage: newImageRef, scale: 1.0, orientation: UIImageOrientation.up)
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    public func addBorderToImage(_ image: UIImage) -> UIImage {
        let width = 28
        let height = 28
        
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let white = UIImage(named: "white")!
        white.draw(at: CGPoint.zero)
        image.draw(at: CGPoint(x: (CGFloat(width) - image.size.width) / 2, y: (CGFloat(height) - image.size.height) / 2))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}


extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}


extension Int {
    
    func stringRep() -> String {
        if self < 10 {
            return "0\(self)"
        } else {
            return "\(self)"
        }
    }
}

