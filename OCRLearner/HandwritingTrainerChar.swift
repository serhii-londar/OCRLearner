//
//  HandwritingTrainer.swift
//  OCRLearner
//
//  Created by Rosenstein on 3/23/16.
//  Copyright © 2016 Rosenstein. All rights reserved.
//

import Foundation
import UIKit

class HandwritingTrainerChar {
    
    let numberOfClasses = 6
    
    var network = FFNN(inputs: 704, hidden: 20, outputs: 6)
    
    fileprivate var trainingImages = [[Float]] ()
    fileprivate var trainingLabels = [[Float]] ()
    fileprivate var validationImages = [[Float]] ()
    fileprivate var validationLabels = [[Float]] ()
    
    // Correspond to number in sample folder
    // Only train network on A, B, C, D, J, and R
    
    internal enum Label: Int {
        case a = 11
        case b = 12
        case c = 13
        case d = 14
        case j = 20
        case r = 28
        
    }
    
    let labelEnums = [Label.a, Label.b, Label.c, Label.d, Label.j, Label.r]
    
    func constructNetwork() {
        
        for i in 0...labelEnums.count - 1 { // Iterate through all chacters
            print("Char: \(labelEnums[i])")
            let sampleName = "img0" + labelEnums[i].rawValue.stringRep() + "-0"
            let start = Date();
            
            // Train 55 samples of each character
            for j in 1...55 {
                let imageName = sampleName + j.stringRep() + ".png"
                let image = UIImage(named: imageName)
                let imageData = (image?.floatRepresentation())!
                trainingImages.append(imageData)
                trainingLabels.append(labelToArray(i, numberOfClasses: numberOfClasses))
                
                // Use the first ten samples of each character as validation data
                if j < 10 {
                    validationImages.append(imageData)
                    validationLabels.append(labelToArray(i, numberOfClasses: numberOfClasses))
                }
            }
            
            let end = Date();   // <<<<<<<<<<   end time
            let timeInterval: Double = end.timeIntervalSince(start); // <<<<< Difference in seconds (double)
            print("Time for num \(labelEnums[i]): \(timeInterval) seconds");
            
        }
        
       
        do {
            try network.train(inputs: trainingImages, answers: trainingLabels, testInputs: validationImages, testAnswers: validationLabels, errorThreshold: 0.7)
        } catch {
            print("There was an error training the network")
        }
        
        // Save FFNN to project directory
        // let filePath = // Enter file location here
        // network.writeToFile(filePath)
    }
    
    fileprivate func labelToArray(_ label: Int, numberOfClasses: Int) -> [Float] {
        var answer = [Float](repeating: 0, count: numberOfClasses)
        answer[Int(label)] = 1
        return answer
    }
    
    func outputToLabel(_ output: [Float]) -> (label: Int, confidence: Double)? {
        guard let max = output.max() else {
            return nil
        }
        return (output.index(of: max)!, Double(max / 1.0))
    }
}
