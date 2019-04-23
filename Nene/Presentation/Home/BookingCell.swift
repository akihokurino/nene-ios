//
//  BookingCell.swift
//  Neon
//
//  Created by akiho on 2019/01/11.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

final class BookingCell: UITableViewCell, InputAppliable {
    
    static let identifer = "BookingCell"

    @IBOutlet private weak var restaurantNameLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    
    typealias Input = Booking
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func apply(input: Input) {
        let booking = input
        
        restaurantNameLabel.text = booking.restaurantName
        detailLabel.text = "\(booking.time) \(booking.subscriberName) \(booking.numberOfPeople)人 \(booking.seat)"
    }
}
