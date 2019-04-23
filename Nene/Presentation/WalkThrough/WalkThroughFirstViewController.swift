//
//  WalkThroughFirstViewController.swift
//  Nene
//
//  Created by akiho on 2019/03/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

final class WalkThroughFirstViewController: UIViewController {
    
    static func instantiate() -> WalkThroughFirstViewController {
        return R.storyboard.walkThrough.walkThroughFirstViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
