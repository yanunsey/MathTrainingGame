//
//  DrawingImageView.swift
//  MathTrainingGame
//
//  Created by Yanunsey on 15/12/22.
//

import UIKit

protocol DrawingImageViewDelegate {
    func numberDrawn(_ resulImage : UIImage)
}

class DrawingImageView: UIImageView {

    var delegate : DrawingImageViewDelegate?
    var currentTouchPosition : CGPoint?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func draw(from start: CGPoint, to end: CGPoint) {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        
        self.image = renderer.image { ctx in
            self.image?.draw(in: self.bounds)
            
            //Define CGContext drawing parameters
            UIColor.black.setStroke()
            ctx.cgContext.setLineWidth(12)
            ctx.cgContext.setLineCap(.round)
            
            //Stroke the context's path
            ctx.cgContext.move(to: start)
            ctx.cgContext.addLine(to: end)
            ctx.cgContext.strokePath()
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        currentTouchPosition = touches.first?.location(in: self)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        guard let previousTouchPoint = currentTouchPosition else { return }
        
        draw(from: previousTouchPoint, to: newTouchPoint)
        
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        currentTouchPosition = nil
        
        perform(#selector(numberDrawnOnScreen), with: nil, afterDelay: 2)
    }
    
    @objc func numberDrawnOnScreen() {
        
        guard let userImage = self.image else { return }
        
        let drawRect = CGRect(x: 0, y: 0, width: 28, height: 28)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(bounds: drawRect, format: format)
        
        let imageWithWhiteBackground = renderer.image { ctx in
            
            UIColor.white.setFill()
            ctx.fill(self.bounds)
            userImage.draw(in: drawRect)
        }
        
        //Convert UIImage from CG to CI
        guard let cgImage = imageWithWhiteBackground.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        //Color inversion
        if let filter = CIFilter(name: "CIColorInvert") {
            //Defines the CIImage as the image to be transformed
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            

            let context = CIContext(options: nil)
            
            if let outputImage = filter.outputImage{
                
                if let imageRef = context.createCGImage(outputImage, from: ciImage.extent){
                   
                    let resultImage = UIImage(cgImage: imageRef)
                    
                    self.delegate?.numberDrawn(resultImage)
                }
            }
        }
    }
}
