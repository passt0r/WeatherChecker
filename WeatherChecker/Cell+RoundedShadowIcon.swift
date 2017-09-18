//
//  Cell+RoundedShadowIcon.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 18.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

protocol WeatherViewCell: class {
    
}

extension WeatherViewCell {
    func setup(imageView: UIImageView, shadowView: UIView) {
        // Initialization code
        imageView.layer.cornerRadius = imageView.bounds.width/2
        imageView.clipsToBounds = true
        
//        shadowView.clipsToBounds = false
//        shadowView.layer.shadowColor = UIColor.black.cgColor
//        shadowView.layer.shadowOpacity = 0.7
//        shadowView.layer.shadowRadius = 10
//        shadowView.layer.shadowPath = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: imageView.bounds.width/2).cgPath
    }
}
