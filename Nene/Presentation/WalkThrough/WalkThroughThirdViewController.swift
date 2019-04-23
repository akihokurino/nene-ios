//
//  WalkThroughThirdViewController.swift
//  Nene
//
//  Created by akiho on 2019/03/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

final class WalkThroughThirdViewController: UIViewController {
    
    static func instantiate() -> WalkThroughThirdViewController {
        return R.storyboard.walkThrough.walkThroughThirdViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
