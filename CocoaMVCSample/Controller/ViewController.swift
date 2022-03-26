//
//  ViewController.swift
//  CocoaMVCSample
//
//  Created by 伊藤 直輝 on 2022/03/22.
//

import UIKit

/**
 `Presenter`は`Model`と`View`をプロパティとして保持
 `Model`を監視し、値の更新があった場合は更新後のデータを`View`に反映
 `View`のイベント処理を定義
 */
final class ViewController: UIViewController {
  /// Modelプロパティ
  var myModel: Model? {
    didSet {
      // Modelプロパティにオブジェクトが代入された場合(=起動時)に呼び出す
      registerModel()
    }
  }
  
  /// Viewプロパティ
  @IBOutlet var myView: View!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Modelをインスタンス化し、registerModel()を発火させる
    myModel = Model()
  }
  
  /// `ViewController`インスタンスが破棄されるときに通知の購読を解除
  deinit {
    myModel?.notificationCenter.removeObserver(self)
  }
  
  /// `View`に`Model`を紐付ける(起動時のみ実行)
  private func registerModel() {
    guard let model = myModel else { return }
    
    // Modelのデータを表示するためのViewのUIコンポーネントに対してはModelの初期データを反映
    myView.label.text = model.num.description
    
    // Modelのデータを更新するためのViewのUIコンポーネントに対してはイベントリスナとしてセット
    myView.button.addTarget(
      self,
      action: #selector(onButtonTapped),
      for: .touchUpInside)
    
    // Modelからの通知を監視し、更新後のデータをViewに反映
    model.notificationCenter.addObserver(
      forName: .init("number"),
      object: nil,
      queue: nil,
      using: { [unowned self] (notification: Notification) -> Void in
        if let num = notification.userInfo?["number"] as? Int {
          self.myView.label.text = num.description
        }
      })
  }
  
  /// `View`のボタンがタップされた場合に呼び出す処理
  @objc func onButtonTapped() {
    // Modelで定義した処理を呼び出す
    myModel?.setRandomInt()
  }
}

