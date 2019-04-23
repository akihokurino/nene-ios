//
//  HomeViewController.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FSCalendar

final class HomeViewController: UIViewController {
    
    static func instantiate() -> HomeViewController {
        return R.storyboard.home.homeViewController()!
    }

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var chatButton: UIButton!
    @IBOutlet private weak var calendar: FSCalendar!
    
    private let disposeBag = DisposeBag()
    private var selectedMonth: YearMonth?
    private var selectedDay: YearMonthDay?
    private let cancelBooking: PublishSubject<Booking> = PublishSubject()
    private let selectMonth = BehaviorRelay<YearMonth>(value: YearMonth.from(date: Date()))
    private let selectDay = BehaviorRelay<YearMonthDay>(value: YearMonthDay.from(date: Date()))
    private let selectFrom: YearMonthDay = YearMonthDay.from(date: Date())
    private var bookings: [Booking] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = UIImageView(image: R.image.header_logo()!)
        tableView.contentInset.bottom = 80

        bind()
    }
    
    private func bind() {
        calendar.locale = Locale(identifier: "ja_JP")
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.register(CalendarCell.self, forCellReuseIdentifier: "cell")
        
        let dataSource = DataSource()
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        let vm = HomeViewModel(
            dependency: .init(
                userUseCase: DomainAssembly.injectUserUseCase(),
                bookingUseCase: DomainAssembly.injectBookingUseCase(),
                chatRoomUseCase: DomainAssembly.injectChatRoomUseCase()
            )
        )
        
        let output = vm.transform(input: .init(
            viewWillAppear: rx.viewWillAppear.asDriver(),
            selectedDay: selectDay.asDriver(onErrorDriveWith: .empty()),
            selectedMonth: selectMonth.asDriver(onErrorDriveWith: .empty()),
            cancelBooking: cancelBooking.asDriver(onErrorDriveWith: .empty())
        ))
        
        output.allBookings
            .drive(onNext: { [weak self] bookings in
                self?.bookings = bookings
                self?.calendar.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.dayBookings.drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        chatButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                let vc = ChatRoomViewController.instantiate()
                let nav = NavigationController(rootViewController: vc)
                self?.present(nav, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        output.selectedMonth
            .drive(onNext: { [weak self] yearMonth in
                self?.selectedMonth = yearMonth
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.selectedDay
            .drive(onNext: { [weak self] yearMonthDay in
                self?.selectedDay = yearMonthDay
                self?.calendar.reloadData()
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.isExecuting
            .drive(rx.isHUDAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                self?.showAlert(with: $0)
            })
            .disposed(by: disposeBag)
        
        output.cancelBooking
            .drive(onNext: { [weak self] in
                let vc = ChatRoomViewController.instantiate()
                let nav = NavigationController(rootViewController: vc)
                self?.present(nav, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected.asDriver()
            .withLatestFrom(output.dayBookings) { ($0, $1) }
            .drive(onNext: { [weak self] pair in
                let item = pair.1[pair.0.row]
                self?.showBookingMenu(booking: item)
            })
            .disposed(by: disposeBag)
    }
    
    private func showBookingMenu(booking: Booking) {
        var title = ""
        if let yearMonthDay = selectedDay {
            title = "\(yearMonthDay.month)月\(yearMonthDay.day)日 - \(booking.restaurantName)"
        }
        let alertViewController = AlertControllerBuilder
            .makeBuilder(title: title, preferedStyle: .actionSheet)
            .addAction(title: "キャンセル依頼", style: .destructive) { [weak self] _ in
                let alertViewController = AlertControllerBuilder
                    .makeBuilder(
                        title: "キャンセル料が発生する場合があります",
                        message: "キャンセル料がかかる場合がございます。ご了承の上ご依頼ください。",
                        preferedStyle: .alert
                    )
                    .addAction(title: "閉じる", style: .default, handler: nil)
                    .addAction(title: "依頼", style: .default, handler: { _ in
                        self?.cancelBooking.onNext(booking)
                    })
                    .build()
                self?.present(alertViewController, animated: true)
            }
            .addAction(title: "閉じる", style: .cancel) { _ in
                
            }
            .build()
        
        present(alertViewController, animated: true)
    }
    
    private class DataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType {
        typealias Element = [Booking]
        private var items: Element = []
        
        func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
            guard case .next(let element) = observedEvent else { return }
            self.items = element
            tableView.reloadData()
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookingCell.identifer, for: indexPath) as! BookingCell
            let item = items[indexPath.row]
            cell.apply(input: item)
            return cell
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        let label = UILabel(frame: CGRect(x: 20, y: 8, width: 120, height: 20))
        label.font = UIFont.bold(size: 14)
        if let yearMonthDay = selectedDay {
            label.text = "\(yearMonthDay.monthString)月\(yearMonthDay.dayString)日の予定"
        }
        label.textColor = UIColor.white
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension HomeViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectDay.accept(YearMonthDay.from(date: date.jst))
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let day = YearMonthDay.from(date: date.jst)
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date.jst, at: position) as! CalendarCell
        
        let isBooked = bookings.first(where: { $0.date == day.toString() }) != nil

        cell.apply(input: .init(
            selected: selectDay.value.equal(date: date.jst),
            isBooked: isBooked
        ))
        return cell
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let month = YearMonth.from(date: calendar.currentPage.jst)
        selectMonth.accept(month)
    }
}
