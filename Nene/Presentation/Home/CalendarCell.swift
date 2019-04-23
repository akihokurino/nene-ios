//
//  CalendarCell.swift
//  Neon
//
//  Created by akiho on 2019/01/10.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import FSCalendar

enum SelectionType : Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

final class CalendarCell: FSCalendarCell, InputAppliable {
    
    private weak var selectionLayer: CAShapeLayer!
    private var coloredView: UIView?
    private var pinView: UIView?
    
    var selectionType: SelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.black.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        contentView.layer.insertSublayer(selectionLayer, below: titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        shapeLayer.isHidden = true
        
        coloredView = UIView(frame: bounds)
        coloredView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        backgroundView = coloredView
        coloredView?.cornerRadius = 4.0
        coloredView?.clipsToBounds = true
        
        pinView = UIView(frame: CGRect(x: bounds.width / 2 - 4, y: 30, width: 8, height: 8))
        pinView?.backgroundColor = UIColor.activeColor
        pinView?.cornerRadius = 4
        contentView.addSubview(pinView!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView?.frame = bounds.insetBy(dx: 1, dy: 1)
        selectionLayer.frame = contentView.bounds
        
        if selectionType == .middle {
            selectionLayer.path = UIBezierPath(rect: selectionLayer.bounds).cgPath
        }
        else if selectionType == .leftBorder {
            selectionLayer.path = UIBezierPath(
                roundedRect: selectionLayer.bounds,
                byRoundingCorners: [.topLeft, .bottomLeft],
                cornerRadii: CGSize(
                    width: selectionLayer.frame.width / 2,
                    height: selectionLayer.frame.width / 2
                )
            ).cgPath
        }
        else if selectionType == .rightBorder {
            selectionLayer.path = UIBezierPath(
                roundedRect: selectionLayer.bounds,
                byRoundingCorners: [.topRight, .bottomRight],
                cornerRadii: CGSize(
                    width: selectionLayer.frame.width / 2,
                    height: selectionLayer.frame.width / 2
                )
            ).cgPath
        }
        else if selectionType == .single {
            let diameter: CGFloat = min(selectionLayer.frame.height, selectionLayer.frame.width)
            selectionLayer.path = UIBezierPath(
                ovalIn: CGRect(
                    x: contentView.frame.width / 2 - diameter / 2,
                    y: contentView.frame.height / 2 - diameter / 2,
                    width: diameter,
                    height: diameter
                )
            ).cgPath
        }
        
        titleLabel.frame = CGRect(x: frame.size.width / 2 - 10, y: 2, width: 20, height: 20)
    }
    
    override func configureAppearance() {
        super.configureAppearance()
       
        if isPlaceholder {
            eventIndicator.isHidden = true
            titleLabel.textColor = UIColor.inactiveColor
        }
    }
    
    struct Input {
        let selected: Bool
        let isBooked: Bool
    }
    
    func apply(input: Input) {
        if input.selected {
            coloredView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
        } else {
            coloredView?.backgroundColor = UIColor.clear
        }
        
        pinView?.isHidden = !input.isBooked
    }
}
