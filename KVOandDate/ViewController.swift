//
//  ViewController.swift
//  KVOandDate
//
//  Created by 今橋浩樹 on 2022/06/06.
//

import UIKit
import WebKit
import RealmSwift

class ViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var initialUrl: String = "https://www.google.com/"
    var receiveUrl: String!
    
    var currentPageName: String = ""
    var currentUrl: String = ""
    
    var bookmarksButtonItem: UIBarButtonItem!
    var goBackButtonItem: UIBarButtonItem!
    var goForwardButtonItem: UIBarButtonItem!
    var goGoogleButtonItem: UIBarButtonItem!
    
    let dt = Date()
    let dateFormatter = DateFormatter()
    
    var realm = try! Realm()
    
    
    override func loadView() {
        // webビューの定義
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初回はGoogleを表示させるようにしてwebビューを起動させる
        // 引数に予めGoogleのURLを入れた変数を渡す
        webViewLoad(initialUrl)
        // KVOが最初は動かないので、GoogleのURLを予め渡しておく
        currentUrl = initialUrl
        
        // オブザーバーの設定(表示しているURLとページ名を監視して、変化した際に取得できるようにする)
        self.webView?.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        self.webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
                
        // ブラウザバック・進むボタン
        goBackButtonItem = UIBarButtonItem(title: "←", style: .plain, target: self, action: #selector(backBarButtonTapped))
        goForwardButtonItem = UIBarButtonItem(title: "→", style: .plain, target: self, action: #selector(forwardBarButtonTapped))
        // Googleへ遷移するボタン
        goGoogleButtonItem = UIBarButtonItem(title: "GG", style: .plain, target: self, action: #selector(ggButtonTapped))
        
        self.navigationItem.leftBarButtonItems = [goBackButtonItem,goForwardButtonItem,goGoogleButtonItem]
        
        
    }
    
    // KVOの破棄
    deinit {
        self.webView?.removeObserver(self, forKeyPath: "URL")
        self.webView?.removeObserver(self, forKeyPath: "title")
    }
    
    // URLとページ名に変化が入ったら行われる処理(現在表示しているwebページの情報を格納する)
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // 変更が入った際に、常に現在のURLとページ名を変数に格納する
        if let url = change![NSKeyValueChangeKey.newKey] as? URL {
            let urlString: String = url.absoluteString
            currentUrl = urlString
        }
        
        if let title = change![NSKeyValueChangeKey.newKey] as? String {
            currentPageName = title
        }
        
        
        // URLが初回ページ(Google)と同じであればrealmには登録しない
        if currentUrl != initialUrl {
            historyRegister(currentUrl, currentPageName)
        }
                        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // メモからとってきたURLを使ってwebビューを起動させる
        if let bookmarkUrl = receiveUrl {
            webViewLoad(bookmarkUrl)
        }
        
        // ログ状監視のためのprint(消してもいい)
        print("viewWillAppear browser")
    }
            
    // webビューを戻す処理
    @objc func backBarButtonTapped() {
        webView.goBack()
    }
    
    // webビューを進める処理
    @objc func forwardBarButtonTapped() {
        webView.goForward()
    }
    
    // GGボタンを押すとwebビューをGoogleへ遷移させる処理
    @objc func ggButtonTapped() {
        // Googleを表示する(initialUrlを渡して処理する)
        webViewLoad(initialUrl)
    }

    // webビューを作る処理
    func webViewLoad(_ nextUrl: String) {
        let url = URL(string: nextUrl)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // 履歴への登録処理
    func historyRegister(_ registerURL: String, _ registerPageName: String) {
        // realmへの登録関連ロジック(ここから、切り出したい)
        
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.locale = Locale(identifier: "ja_JP")

        print(dateFormatter.string(from: dt))
        print(registerURL)
        print(registerPageName)
        
        let memo = MemoDate()
        
        memo.URL = registerURL
        memo.pageName = registerPageName
        memo.watchDate = dateFormatter.string(from: dt)

        
        try! realm.write {
            realm.add(memo)
        }
        
        let objects = realm.objects(MemoDate.self).sorted(byKeyPath: "watchDate", ascending: false)
        print(objects)
        
        // realmへの登録関連ロジック(ここまで、切り出したい)

        
    }

}


