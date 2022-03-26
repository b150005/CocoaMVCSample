//
//  View.swift
//  CocoaMVCSample
//
//  Created by 伊藤 直輝 on 2022/03/22.
//

import UIKit

/**
 `View`はUIコンポーネントの描画(=保持)を担当
 MVP(Passive View)アーキテクチャパターンでは、`Presenter`によってモデルデータの反映・ロジックの適用が行われる
 */
final class View: UIView {
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var button: UIButton!
}
