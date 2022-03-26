#  Cocoa MVC

**Cocoa MVC**は、Appleが推奨する`MVP(Passive View)アーキテクチャ`である。
数多く存在するアーキテクチャパターンは、**Presentation Domain Separation**の概念を根底としており、
**アプリケーションのUI(Presentation, View)**と**UIとは無関係な処理(Domain, Model)**を分離することを目的としている。

例として、以下の機能を有するアプリケーションを作成する。

1. ボタン([UIButton](https://developer.apple.com/documentation/uikit/uibutton))をタップ
2. 1から10の範囲でAPI([Int.random(in:)](https://developer.apple.com/documentation/swift/int/2995648-random))を用いて乱数を生成
3. 2.で生成した乱数をラベル([UILabel](https://developer.apple.com/documentation/uikit/uilabel))に表示

ここで、MVP(Passive View)アーキテクチャにおける`Model`・`View`・`Presenter`の役割はそれぞれ以下の通り。

|レイヤー|役割|
|---|---|
|Model|ビジネスロジック(データアクセスでないモデルデータ処理)の定義|
|View|UIコンポーネント(`UIButton`・`UILabel`)の描画|
|Presenter|ビジネスロジックとUIコンポーネントの紐付け|

## Model

`Model`は、アプリケーションが取り扱う**データ**と**データ処理のロジック**を定義する。
また、データが更新される場合は`Presenter`に更新を通知する。

```swift
/**
 ModelはDBやファイル操作(=データアクセス)を除くデータ処理を担当
 値の更新をPresenterに通知するのにNotificationCenterを利用
 */
final class Model {
  let notificationCenter: NotificationCenter = NotificationCenter.default
  
  /// UIコンポーネント(UILabel)に表示するデータ
  private(set) var num: Int = 0 {
    didSet {
      // 値に更新があった場合はNotificationCenterを通じてPresenterに更新後の値を送信
      /**
       NotificationCenterに送信する通知(NSNotification)のデータ
       | NSNotification | 概要 |
       | --- | --- |
       | name | 通知を特定するためのタグ情報 |
       | object | 通知元オブジェクト(任意) |
       | userInfo | 通知時に受け渡す辞書型データ |
       */
      notificationCenter.post(name: .init("number"),
                              object: nil,
                              userInfo: ["number" : num])
    }
  }
  
  /// 乱数を生成し、numプロパティに値を代入する
  func setRandomInt(from x: Int = 1, to y: Int = 10) {
    num = Int.random(in: x...y)
  }
}
```

## View

`View`は、アプリケーションで描画するUIコンポーネントを定義する。

```swift
/**
 ViewはUIコンポーネントの描画(=保持)を担当
  MVP(Passive View)アーキテクチャパターンでは、Presenterによってモデルデータの反映・ロジックの適用が行われる
 */
final class View: UIView {
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var button: UIButton!
}
```

## Presenter

`Presenter`は、`Model`によって送信される通知を購読し、値に更新があった場合は`View`に反映する。
また、`View`のUIコンポーネントをイベントリスナとして定義する。

```swift
/**
 PresenterはModelとViewをプロパティとして保持
 Modelを監視し、値の更新があった場合は更新後のデータをViewに反映
 Viewのイベント処理を定義
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
  
  /// ViewControllerインスタンスが破棄されるときに通知の購読を解除
  deinit {
    myModel?.notificationCenter.removeObserver(self)
  }
  
  /// ViewにModelを紐付ける(起動時のみ実行)
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
  
  /// Viewのボタンがタップされた場合に呼び出す処理
  @objc func onButtonTapped() {
    // Modelで定義した処理を呼び出す
    myModel?.setRandomInt()
  }
}
```
