//
//  WalkThroughPageViewController.swift
//  Nene
//
//  Created by akiho on 2019/03/16.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit

protocol WalkThroughPageViewControllerDelegate: class {
    func onChangePage(index: Int)
}

final class WalkThroughPageViewController: UIPageViewController {
    
    private var currentIndex: Int = 0
    
    weak var customDelegate: WalkThroughPageViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setViewControllers(
            [first],
            direction: .forward,
            animated: true,
            completion: nil)
        
        self.dataSource = self
        self.delegate = self
    }
    
    private var first: WalkThroughFirstViewController {
        return WalkThroughFirstViewController.instantiate()
    }
    
    private var second: WalkThroughSecondViewController {
        return WalkThroughSecondViewController.instantiate()
    }
    
    private var third: WalkThroughThirdViewController {
        return WalkThroughThirdViewController.instantiate()
    }
    
    private func currentIndexOf(_ vc: UIViewController) -> Int {
        switch vc {
        case is WalkThroughFirstViewController:
            return 0
        case is WalkThroughSecondViewController:
            return 1
        case is WalkThroughThirdViewController:
            return 2
        default:
            return 0
        }
    }
}

extension WalkThroughPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController is WalkThroughThirdViewController {
            // 3 -> 2
            return second
        } else if viewController is WalkThroughSecondViewController {
            // 2 -> 1
            return first
        } else {
            // 1 -> end of the road
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController is WalkThroughFirstViewController {
            // 1 -> 2
            return second
        } else if viewController is WalkThroughSecondViewController {
            // 2 -> 3
            return third
        } else {
            // 3 -> end of the road
            return nil
        }
    }
}

extension WalkThroughPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentVC = pageViewController.viewControllers?.first  {
            customDelegate?.onChangePage(index: currentIndexOf(currentVC))
        }
    }
}
