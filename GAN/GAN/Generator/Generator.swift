//
//  Generator.swift
//  GAN
//
//  Created by Jørgen Henrichsen on 21/06/2017.
//  Copyright © 2017 Zedge. All rights reserved.
//

import Foundation
import CoreML


class Generator {
    
    let model = mnistGenerator3()
    
    /**
     * Generate some random data that can be used as input for the MLModel.
     */
    func generateRandomData() -> MLMultiArray? {
        guard let input = try? MLMultiArray(shape: [100], dataType: MLMultiArrayDataType.double) else {
            return nil
        }
        
        for i in 0...99 {
            let number = 2 * Double(Float(arc4random()) / Float(UINT32_MAX)) - 1
            input[i] = NSNumber(floatLiteral: number)
        }
        
        return input
    }
    
    
    /**
     * Use the model to generate picture data.
     */
    func generate(input: MLMultiArray) -> MLMultiArray? {
        if let generated = try? model.prediction(input1: input) {
            
            // Print the number to console.
            for i in 0..<28 {
                var s: String = ""
                for y in 0..<28 {
                    let out = Double(generated.output1[i*28 + y])
                    
                    if out < 0 {
                        s = "\(s)\(0)"
                    }
                    else {
                        s = "\(s)\(1)"
                    }
                }
                
                print(s)
            }
            
            return generated.output1
            
        }
        
        return nil
    }
}

