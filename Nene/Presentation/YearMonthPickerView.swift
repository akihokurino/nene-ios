//
//  YearMonthPickerView.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class YearMonthPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var months: [String]!
    private var years: [Int]!
    
    private var year = Calendar.current.component(.year, from: Date()) {
        didSet {
            selectRow(years.index(of: year)!, inComponent: 1, animated: true)
        }
    }
    
    private var month = Calendar.current.component(.month, from: Date()) {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    fileprivate var onDateSelected: PublishSubject<YearMonth> = PublishSubject()
    
    var current: YearMonth {
        return YearMonth(year: String(year), month: String(month))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    private func commonSetup() {
        // population years
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            for _ in 1...15 {
                years.append(year)
                year += 1
            }
        }
        
        self.years = years
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        for _ in 1...12 {
            months.append(formatter.monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        self.delegate = self
        self.dataSource = self
        
        let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
        self.selectRow(currentMonth - 1, inComponent: 0, animated: false)
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow != nil {
            inputView?.backgroundColor = UIColor.background
        }
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRow(inComponent: 0)+1
        let year = years[self.selectedRow(inComponent: 1)]
        
        self.month = month
        self.year = year
        
        onDateSelected.onNext(YearMonth(year: String(year), month: String(month)))
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title: String
        switch component {
        case 0:
            title = "\(months[row])"
        case 1:
            title = "\(years[row])"
        default:
            title = ""
        }

        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
}

extension Reactive where Base: YearMonthPickerView {
    var didSelected: Driver<YearMonth> {
        return base.onDateSelected.asDriver(onErrorDriveWith: .empty())
    }
}

