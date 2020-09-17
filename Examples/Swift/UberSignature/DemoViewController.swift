/**
 Copyright (c) 2017 Uber Technologies, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit
import UberSignature

import CoreGraphics

class DemoViewController: UIViewController, SignatureDrawingViewControllerDelegate {
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        signatureViewController.delegate = self
        addChildViewController(signatureViewController)
        view.addSubview(signatureViewController.view)
        signatureViewController.didMove(toParentViewController: self)
        
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        view.addSubview(resetButton)
        
		saveImageButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
		view.addSubview(saveImageButton)
		
		setUpSignatureViewController()
		
        // Constraints
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
		saveImageButton.translatesAutoresizingMaskIntoConstraints = false

		
        view.addConstraints([
            NSLayoutConstraint.init(item: resetButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint.init(item: resetButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20),
			
			NSLayoutConstraint.init(item: saveImageButton, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 20),
			NSLayoutConstraint.init(item: saveImageButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20),
            
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: signatureViewController.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            ])
        
    }
    
    // MARK: SignatureDrawingViewControllerDelegate
    
    func signatureDrawingViewControllerIsEmptyDidChange(controller: SignatureDrawingViewController, isEmpty: Bool) {
        resetButton.isHidden = isEmpty
    }
    
    // MARK: Private
	
	private func setUpSignatureViewController() {
		signatureViewController.signatureColor = .systemBlue
	}
    
    private let signatureViewController = SignatureDrawingViewController()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        return button
    }()
	
	
	private let saveImageButton: UIButton = {
		let button = UIButton(type: .custom)
		button.setTitle("save", for: .normal)
		button.setTitleColor(UIColor.blue, for: .normal)
		return button
	}()
    
    @objc private func resetTapped() {
        signatureViewController.reset()
    }
	
	@objc private func saveImage() {
		guard let image = signatureViewController.fullSignatureImage else { return }
		
		// 128*64 -> 1 bitamp -> data -> upload
//		let grayScale: [Bool] = image.pixelData.map {
//			var white: CGFloat = 0
//			var alpha: CGFloat = 0
//
//			$0.color.getWhite(&white, alpha: &alpha)
//			return white > 0.5
//		}
//
//		var trues  = 0
//		var falses = 0
//
//		grayScale.forEach {
//			if $0 {
//				trues += 1
//			} else {
//				falses += 1
//			}
//		}
//
//		print("trues: \(trues), falses: \(falses)")
		
		guard let convertedSizeImage = resizeImage(image: image, targetSize: CGSize(width: 128, height: 64)) else { return }
		
		guard let convertedImage = convertedSizeImage.toBlackAndWhite() else { return }
		
		let viewController = ImagePreViewController(image: convertedImage)
		
		self.present(viewController, animated: true)
	}
    
	
	// MARK: Delegtaes
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		print("터치 시작중")
	}
	
	
	func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
		let size = image.size
		
		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height
		
		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		} else {
			newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
		}
		
		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
}

