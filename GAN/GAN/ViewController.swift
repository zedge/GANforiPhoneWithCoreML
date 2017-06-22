//
//  ViewController.swift
//  GAN
//
//  Created by Jørgen Henrichsen on 21/06/2017.
//  Copyright © 2017 Zedge. All rights reserved.
//

import UIKit
import CoreML


class ViewController: UIViewController {
    
    let generator = Generator()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Generate", for: .normal)
        button.addTarget(self, action: #selector(self.generateImage), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.regular)
        return button
    }()
    
    let bitMapInfo: CGBitmapInfo = DeviceInformation.simulator ? .floatComponents : .byteOrder16Little
    let bitsPerComponent: Int = DeviceInformation.simulator ? 32 : 8

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(generateButton)
        generateButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true
        generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        generateImage()
        
    }
    
    
    
    @objc func generateImage() {
        if let data = generator.generateRandomData(),
            let output = generator.generate(input: data, verbose: true) {
            
            let byteData = convert(output)
            let image = createImage(data: byteData, width: 28, height: 28, components: 1)
            
            // Display Image
            if let image = image {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(cgImage: image)
                }
            }
        }
    }
    
    
    /**
     * Convert a MLMultiarray, containig Doubles, to a bytearray.
     */
    func convert(_ data: MLMultiArray) -> [UInt8] {
        
        var byteData: [UInt8] = []
        
        for i in 0..<data.count {
            let out = data[i]
            let floatOut = out as! Float32
            
            if DeviceInformation.simulator {
                let bytesOut = toByteArray((floatOut + 1.0) / 2.0)
                byteData.append(contentsOf: bytesOut)
            }
            else {
                let byteOut: UInt8 = UInt8((floatOut * 127.5) + 127.5)
                byteData.append(byteOut)
            }
        }
        
        return byteData
        
    }
    
    
    /**
     * Create a CGImage from a bytearray.
     */
    func createImage(data: [UInt8], width: Int, height: Int, components: Int) -> CGImage? {
        
        let colorSpace: CGColorSpace
        switch components {
        case 1:
            colorSpace = CGColorSpaceCreateDeviceGray()
            break
        case 3:
            colorSpace = CGColorSpaceCreateDeviceRGB()
            break
        default:
            fatalError("Unsupported number of components per pixel.")
        }
        
        let cfData = CFDataCreate(nil, data, width*height*components*bitsPerComponent / 8)!
        let provider = CGDataProvider(data: cfData)!
        
        let image = CGImage(width: width,
                            height: height,
                            bitsPerComponent: bitsPerComponent, //
            bitsPerPixel: bitsPerComponent * components, //
            bytesPerRow: ((bitsPerComponent * components) / 8) * width, // comps
            space: colorSpace,
            bitmapInfo: bitMapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: CGColorRenderingIntent.defaultIntent)!
        
        return image
        
    }
    
    
    func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafeBytes(of: &value) { Array($0) }
    }


}

