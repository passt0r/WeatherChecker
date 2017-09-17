//
//  CurrentCityTableViewCell.swift
//  WeatherChecker
//
//  Created by Dmytro Pasinchuk on 17.09.17.
//  Copyright © 2017 Dmytro Pasinchuk. All rights reserved.
//

import UIKit

class CurrentCityTableViewCell: UITableViewCell {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        weatherIconView.layer.cornerRadius = weatherIconView.bounds.width/2
        weatherIconView.clipsToBounds = true
        
        weatherIconView.layer.shadowColor = UIColor.black.cgColor
        weatherIconView.layer.shadowOpacity = 0.7
//        weatherIconView.layer.shadowOffset = CGSize.zero
        weatherIconView.layer.shadowRadius = weatherIconView.bounds.width/2
        
        weatherIconView.layer.shouldRasterize = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
