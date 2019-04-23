//
//  YourMessageCell.swift
//  Nene
//
//  Created by akiho on 2019/01/12.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

final class YourMessageCell: UITableViewCell, InputAppliable {

    static let identifer = "YourMessageCell"
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    typealias Input = Message
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func apply(input: Input) {
        let message = input
        
        textView.text = message.text
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M月d日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "ja_JP")
        
        dateLabel.text = dateFormatter.string(from: message.createdAt)
        timeLabel.text = timeFormatter.string(from: message.createdAt)
    }
}
