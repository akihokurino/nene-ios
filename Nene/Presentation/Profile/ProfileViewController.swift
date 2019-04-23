//
//  ProfileViewController.swift
//  Neon
//
//  Created by akiho on 2019/01/08.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: UITableViewController {
    
    static func instantiate() -> ProfileViewController {
        return R.storyboard.profile.profileViewController()!
    }
    
    @IBOutlet private weak var lastNameField: UITextField!
    @IBOutlet private weak var firstNameField: UITextField!
    @IBOutlet private weak var lastNameKanaField: UITextField!
    @IBOutlet private weak var firstNameKanaField: UITextField!
    @IBOutlet private weak var phoneNumberField: UITextField!
    @IBOutlet private weak var areaField: UITextField!
    @IBOutlet private weak var dislikeFoodField: UITextField!
    @IBOutlet private weak var tableCheckIcon: UIImageView!
    @IBOutlet private weak var selectTableButton: UIButton!
    @IBOutlet private weak var counterCheckIcon: UIImageView!
    @IBOutlet private weak var selectCounterButton: UIButton!
    @IBOutlet private weak var otherField: UITextView!
    
    @IBOutlet private weak var selectJapaneseButton: UIButton!
    @IBOutlet private weak var selectWesternButton: UIButton!
    @IBOutlet private weak var selectChineseButton: UIButton!
    @IBOutlet private weak var selectPotButton: UIButton!
    @IBOutlet private weak var selectAsiaButton: UIButton!
    @IBOutlet private weak var selectCurryButton: UIButton!
    @IBOutlet private weak var selectRamenButton: UIButton!
    @IBOutlet private weak var selectTavernButton: UIButton!
    @IBOutlet private weak var selectCreativeButton: UIButton!
    @IBOutlet private weak var selectGrilledMeatButton: UIButton!
    
    @IBOutlet private weak var saveButton: UIButton!
    
    private var genresButtons: [(UIButton, User.PreferenceGenre)] {
        return [
            (selectJapaneseButton, .japanese),
            (selectWesternButton, .western),
            (selectChineseButton, .chinese),
            (selectPotButton, .pot),
            (selectAsiaButton, .asia),
            (selectCurryButton, .curry),
            (selectRamenButton, .ramen),
            (selectTavernButton, .tavern),
            (selectCreativeButton, .creative),
            (selectGrilledMeatButton, .grilledMeat)
        ]
    }
    
    private let disposeBag = DisposeBag()
    private let preferenceSeatType: PublishSubject<User.PreferenceSeatType> = PublishSubject()
    private let preferenceGenres: BehaviorRelay<[User.PreferenceGenre]> = BehaviorRelay(value: [])
    private let otherText: PublishSubject<String> = PublishSubject()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        otherField.delegate = self
        tableCheckIcon.image = nil
        counterCheckIcon.image = nil
        
        otherField.keyboardAppearance = UIKeyboardAppearance.dark
        otherField.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        bind()
    }
    
    private func bind() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.rx.event.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
        tableView.addGestureRecognizer(tapGestureRecognizer)
        
        let vm = ProfileViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase()
        ))
        
        let output = vm.transform(input: .init(
            viewWillAppear: rx.viewWillAppear.asDriver(),
            didInputLastName: lastNameField.rx.text.orEmpty.asDriver(),
            didInputFirstName: firstNameField.rx.text.orEmpty.asDriver(),
            didInputLastNameKana: lastNameKanaField.rx.text.orEmpty.asDriver(),
            didInputFirstNameKana: firstNameKanaField.rx.text.orEmpty.asDriver(),
            didInputAreaField: areaField.rx.text.orEmpty.asDriver(),
            didInputDislikeFoodField: dislikeFoodField.rx.text.orEmpty.asDriver(),
            didSelectPreferenceSeatType: preferenceSeatType.asDriver(onErrorDriveWith: .empty()),
            didSelectPreferenceGenres: preferenceGenres.asDriver(),
            didInputOther: otherText.asDriver(onErrorDriveWith: .empty()),
            didTapSaveButton: saveButton.rx.tap.asDriver().do(onNext: { [weak self] in
                self?.view.endEditing(true)
            })
        ))
        
        output.user
            .drive(onNext: { [weak self] user in
                self?.allocateForm(user: user)
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
        
        selectTableButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.togglePreferenceSeatType(type: .table)
                self?.preferenceSeatType.onNext(.table)
            })
            .disposed(by: disposeBag)
        
        selectCounterButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.togglePreferenceSeatType(type: .counter)
                self?.preferenceSeatType.onNext(.counter)
            })
            .disposed(by: disposeBag)
        
        genresButtons.forEach { pair in
            pair.0.rx.tap.asDriver()
                .map { pair.1 }
                .drive(onNext: { [weak self] genre in
                    self?.updatePreferenceGenres(genre: genre)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private func allocateForm(user: User) {
        lastNameField.text = user.lastName
        lastNameField.sendActions(for: .valueChanged)
        firstNameField.text = user.firstName
        firstNameField.sendActions(for: .valueChanged)
        lastNameKanaField.text = user.lastNameKana
        lastNameKanaField.sendActions(for: .valueChanged)
        firstNameKanaField.text = user.firstNameKana
        firstNameKanaField.sendActions(for: .valueChanged)
        phoneNumberField.text = user.phoneNumber?.local
        phoneNumberField.sendActions(for: .valueChanged)
        areaField.text = user.area
        areaField.sendActions(for: .valueChanged)
        dislikeFoodField.text = user.dislikeFood
        dislikeFoodField.sendActions(for: .valueChanged)
        
        togglePreferenceSeatType(type: user.preferenceSeatType)
        preferenceSeatType.onNext(user.preferenceSeatType)
        
        togglePreferenceGenres(genres: user.preferenceGenres)
        preferenceGenres.accept(user.preferenceGenres)
        
        otherField.text = user.other
        otherText.onNext(user.other)
    }
    
    private func togglePreferenceSeatType(type: User.PreferenceSeatType) {
        tableCheckIcon.image = nil
        counterCheckIcon.image = nil
        switch type {
        case .table:
            tableCheckIcon.image = R.image.icon_done()!
        case .counter:
            counterCheckIcon.image = R.image.icon_done()!
        default:
            break
        }
    }

    private func togglePreferenceGenres(genres: [User.PreferenceGenre]) {
        genresButtons.forEach {
            $0.0.backgroundColor = UIColor.primary
        }
        
        genres.forEach {
            switch $0 {
            case .japanese:
                selectJapaneseButton.backgroundColor = UIColor.activeColor
            case .western:
                selectWesternButton.backgroundColor = UIColor.activeColor
            case .chinese:
                selectChineseButton.backgroundColor = UIColor.activeColor
            case .pot:
                selectPotButton.backgroundColor = UIColor.activeColor
            case .asia:
                selectAsiaButton.backgroundColor = UIColor.activeColor
            case .curry:
                selectCurryButton.backgroundColor = UIColor.activeColor
            case .ramen:
                selectRamenButton.backgroundColor = UIColor.activeColor
            case .tavern:
                selectTavernButton.backgroundColor = UIColor.activeColor
            case .creative:
                selectCreativeButton.backgroundColor = UIColor.activeColor
            case .grilledMeat:
                selectGrilledMeatButton.backgroundColor = UIColor.activeColor
            default:
                break
            }
        }
    }
    
    private func updatePreferenceGenres(genre: User.PreferenceGenre) {
        var genres = preferenceGenres.value
        
        if let index = genres.firstIndex(where: { $0.rawValue == genre.rawValue }) {
            genres.remove(at: index)
        } else {
            genres.append(genre)
        }
        
        togglePreferenceGenres(genres: genres)
        preferenceGenres.accept(genres)
    }
    
    
    private func createSectionView(index: Int) -> (UIView, CGFloat) {
        let titleSection: (String) -> (UIView, CGFloat) = { title -> (UIView, CGFloat) in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
            view.backgroundColor = UIColor.background
            let label = UILabel(frame: CGRect(x: 16, y: 24, width: 200, height: 12))
            label.font = UIFont.normal(size: 12)
            label.textColor = UIColor.white
            label.text = title
            view.addSubview(label)
            return (view, 44)
        }
        
        switch index {
        case 3:
            return titleSection("アレルギー、苦手なもの")
        case 4:
            return titleSection("好みの席のタイプ")
        case 5:
            return titleSection("好きな飲食店のジャンル")
        case 6:
            return titleSection("メモ")
        default:
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
            view.backgroundColor = UIColor.background
            return (view, 20)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionView(index: section).0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return createSectionView(index: section).1
    }
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        otherText.onNext(textView.text ?? "")
    }
}
