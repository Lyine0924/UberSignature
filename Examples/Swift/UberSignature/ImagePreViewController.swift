//
//  ImagePreViewController.swift
//  UberSignatureDemo
//
//  Created by Lyine on 2020/09/17.
//  Copyright © 2020 Uber Technologies, Inc. All rights reserved.
//

import UIKit

import SnapKit
import Then
import UberSignature

class ImagePreViewController: UIViewController {
	
	var image: UIImage!
	
	let imageView = UIImageView().then {
		$0.contentMode = .scaleAspectFit
		$0.clipsToBounds = true
	}
	
	convenience init(image: UIImage) {
		defer{
			self.image = image
		}
		self.init()
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		configureUI()
		setupConstraints()
		fetchImage()
	}
	
	func configureUI() {
		
		self.view.backgroundColor = .white
		
		[imageView].forEach {
			self.view.addSubview($0)
		}
	}
	
	func setupConstraints() {
		imageView.snp.makeConstraints {
			$0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
			$0.left.right.equalToSuperview()
			$0.height.equalToSuperview().multipliedBy(0.5)
		}
	}
	
	func fetchImage() {
		DispatchQueue.main.async { [weak self] in
			self?.imageView.image = self?.image
		}
	}
}
