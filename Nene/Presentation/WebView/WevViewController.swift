//
//  WebViewController.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa

final class WebViewController: UIViewController {
    
    static func instantiate(title: String, url: URL) -> WebViewController {
        let vc = R.storyboard.webView.webViewController()!
        vc.navTitle = title
        vc.url = url
        return vc
    }
    
    @IBOutlet private weak var navBarItem: UINavigationItem!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    private let wkWebView = WKWebView()
    
    private var navTitle: String = ""
    private var url: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarItem.title = navTitle

        wkWebView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.frame.width,
            height: view.frame.height - 160)
        wkWebView.navigationDelegate = self
        wkWebView.uiDelegate = self
        
        wkWebView.allowsBackForwardNavigationGestures = true
        
        let urlRequest = URLRequest(url: url)
        wkWebView.load(urlRequest)
        view.addSubview(wkWebView)
        
        bind()
    }
    
    private func bind() {
        backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    
}
