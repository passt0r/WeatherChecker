//
//  LocalCityTableViewCell.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

class LocalCityTableViewCell: UITableViewCell, WeatherViewCell {
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup(imageView: weatherIconView, shadowView: shadowView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
