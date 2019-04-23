//
//  EnterPinCodeViewModel.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class EnterPincodeViewModel: InjectableViewModel {
    
    struct Dependency {
        
    }
    
    struct Input {
        let codeText: Driver<String>
        let resetCodeTrigger: Driver<Void>
    }
    
    struct Code {
        var firstText: String?
        var secondText: String?
        var thirdText: String?
        var forthText: String?
        var fifthText: String?
        var sixthText: String?
    }
    
    struct Output {
        let codeText: Driver<String>
        let pincode: Driver<String>
        let cursorIndex: Driver<Int>
        let code: Driver<Code>
    }
    
    init(dependency: Dependency) {
        
    }
    
    func transform(input: Input) -> Output {
        let codeLength = 6
        
        let codeText = Driver
            .merge(input.codeText, input.resetCodeTrigger.map { _ in "" })
            .map { text -> String in
                guard text.count > codeLength else {
                    return text
                }
                return String(text.prefix(codeLength))
            }
            .distinctUntilChanged()
        
        let cursorIndex = codeText
            .map { $0.count }
            .filter { $0 < codeLength }
            .distinctUntilChanged()
        
        let createCode: (String) -> EnterPincodeViewModel.Code = { text in
            let code: EnterPincodeViewModel.Code
            switch text.count {
            case 1:
                code = EnterPincodeViewModel.Code(
                    firstText: String(text[text.index(text.startIndex, offsetBy: 0)]),
                    secondText: nil,
                    thirdText: nil,
                    forthText: nil,
                    fifthText: nil,
                    sixthText: nil
                )
            case 2:
                code = EnterPincodeViewModel.Code(
                    firstText: String(text[text.index(text.startIndex, offsetBy: 0)]),
                    secondText: String(text[text.index(text.startIndex, offsetBy: 1)]),
                    thirdText: nil,
                    forthText: nil,
                    fifthText: nil,
                    sixthText: nil
                )
            case 3:
                code = EnterPincodeViewModel.Code(
                    firstText: String(text[text.index(text.startIndex, offsetBy: 0)]),
                    secondText: String(text[text.index(text.startIndex, offsetBy: 1)]),
                    thirdText: String(text[text.index(text.startIndex, offsetBy: 2)]),
                    forthText: nil,
                    fifthText: nil,
                    sixthText: nil
                )
            case 4:
                code = EnterPincodeViewModel.Code(
                    firstText: String(text[text.index(text.startIndex, offsetBy: 0)]),
                    secondText: String(text[text.index(text.startIndex, offsetBy: 1)]),
                    thirdText: String(text[text.index(text.startIndex, offsetBy: 2)]),
                    forthText: String(text[text.index(text.startIndex, offsetBy: 3)]),
                    fifthText: nil,
                    sixthText: nil
                )
                
            case 5:
                code = EnterPincodeViewModel.Code(
                    firstText: String(text[text.index(text.startIndex, offsetBy: 0)]),
                    secondText: String(text[text.index(text.startIndex, offsetBy: 1)]),
                    thirdText: String(text[text.index(text.startIndex, offsetBy: 2)]),
                    forthText: String(text[text.index(text.startIndex, offsetBy: 3)]),
                    fifthText: String(text[text.index(text.startIndex, offsetBy: 4)]),
                    sixthText: nil
                )
                
            case 6:
                code = EnterPincodeViewModel.Code(
                    firstText: String(text[text.index(text.startIndex, offsetBy: 0)]),
                    secondText: String(text[text.index(text.startIndex, offsetBy: 1)]),
                    thirdText: String(text[text.index(text.startIndex, offsetBy: 2)]),
                    forthText: String(text[text.index(text.startIndex, offsetBy: 3)]),
                    fifthText: String(text[text.index(text.startIndex, offsetBy: 4)]),
                    sixthText: String(text[text.index(text.startIndex, offsetBy: 5)])
                )
                
            default:
                code = EnterPincodeViewModel.Code()
            }
            
            return code
        }
        
        let code = codeText
            .flatMap { text -> Driver<EnterPincodeViewModel.Code> in
                return Driver.just(createCode(text))
            }
        
        let pincode = codeText.filter { $0.count == codeLength }
        
        return Output(codeText: codeText,
                      pincode: pincode,
                      cursorIndex: cursorIndex,
                      code: code)
    }
}
