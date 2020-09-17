//
//  UIImage+Bitmap.swift
//  UberSignatureDemo
//
//  Created by bbros on 2020/09/17.
//  Copyright © 2020 Uber Technologies, Inc. All rights reserved.
//

import UIKit

extension UIImage {
	
	var pixelData: [Pixel] {
		let bmp = self.cgImage!.dataProvider!.data
		var data: UnsafePointer<UInt8> = CFDataGetBytePtr(bmp)
		var r, g, b, a: UInt8
		var pixels = [Pixel]()
		
		for row in 0 ..< Int(self.size.width) {
			for col in 0 ..< Int(self.size.height) {
				r = data.pointee
				data = data.advanced(by: 1)
				g = data.pointee
				data = data.advanced(by: 1)
				b = data.pointee
				data = data.advanced(by: 1)
				a = data.pointee
				data = data.advanced(by: 1)
				pixels.append(Pixel(r: r, g: g, b: b, a: a, row: row, col: col))
			}
		}
		return pixels
	}
	
	var monochrome: UIImage? {
		let context = CIContext(options: nil)
		//        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
		let currentFilter = CIFilter(name: "CIColorMonochrome")
		currentFilter?.setValue(CIImage(image: self), forKey: kCIInputImageKey)
		guard let output = currentFilter?.outputImage,
			let cgImage = context.createCGImage(output, from: output.extent) else {
				print("Failed to create output image")
				return nil
		}
		return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
	}
	
	func toBlackAndWhite() -> UIImage? {
		guard let ciImage = CIImage(image: self) else {
			return nil
		}
		guard let grayImage = CIFilter(name: "CIPhotoEffectNoir", withInputParameters: [kCIInputImageKey: ciImage])?.outputImage else {
			return nil
		}
		let bAndWParams: [String: Any] = [kCIInputImageKey: grayImage,
										  kCIInputContrastKey: 50.0,
										  kCIInputBrightnessKey: 10.0]
		guard let bAndWImage = CIFilter(name: "CIColorControls", withInputParameters: bAndWParams)?.outputImage else {
			return nil
		}
		guard let cgImage = CIContext(options: nil).createCGImage(bAndWImage, from: bAndWImage.extent) else {
			return nil
		}
		return UIImage(cgImage: cgImage)
	}
	
}
