//
//  Model.swift
//  CocoaMVCSample
//
//  Created by 伊藤 直輝 on 2022/03/22.
//

import Foundation

/**
 `Model`はDBやファイル操作(=データアクセス)を除くデータ処理を担当
 値の更新を`Presenter`に通知するのに[NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter) を利用
 */
final class Model {
  let notificationCenter: NotificationCenter = NotificationCenter.default
  
  /// UIコンポーネント(`UILabel`)に表示するデータ
  private(set) var num: Int = 0 {
    didSet {
      // 値に更新があった場合はNotificationCenterを通じてPresenterに更新後の値を送信
      /**
       `NotificationCenter`に送信する通知(`NSNotification`)のデータ
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
  
  /// 乱数を生成し、`num`プロパティに値を代入する
  func setRandomInt(from x: Int = 1, to y: Int = 10) {
    num = Int.random(in: x...y)
  }
}
