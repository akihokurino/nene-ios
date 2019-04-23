//
//  WalkThroughSecondViewController.swift
//  Nene
//
//  Created by akiho on 2019/03/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

final class WalkThroughSecondViewController: UIViewController {
    
    static func instantiate() -> WalkThroughSecondViewController {
        return R.storyboard.walkThrough.walkThroughSecondViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
