<?xml version="1.0" encoding="UTF-8"?>
<map version="1.0.1">
  <node TEXT="Project Review Public Template">
    <node TEXT="00 使い方">
      <node TEXT="プロジェクトレビュー テンプレート">
        <node TEXT="このテンプレートの目的"/>
        <node TEXT="使うタイミング">
          <node TEXT="週次レビュー: 進捗・リスク・TODOを更新"/>
          <node TEXT="フェーズゲート: 継続 / 変更 / 停止を判断"/>
          <node TEXT="炎上予防: 兆候・依存・未決事項を洗い出す"/>
        </node>
        <node TEXT="おすすめ進行 45分">
          <node TEXT="5分: 結論サマリーと今日の論点"/>
          <node TEXT="10分: 進捗・成果物・品質"/>
          <node TEXT="15分: 課題・リスク・依存関係"/>
          <node TEXT="10分: 意思決定"/>
          <node TEXT="5分: TODO・担当・期限・完了条件"/>
        </node>
        <node TEXT="マーカー凡例">
          <node TEXT="赤旗: 今すぐ扱うリスク / ブロッカー"/>
          <node TEXT="橙旗: 注意が必要な遅延・依存"/>
          <node TEXT="P1: 今日決める / 最優先"/>
          <node TEXT="P2: 次回までに確認"/>
          <node TEXT="完了: 証跡確認済み"/>
          <node TEXT="進行中: 完了条件を明記"/>
        </node>
        <node TEXT="配布前チェック">
          <node TEXT="固有名詞・機密情報が残っていない"/>
          <node TEXT="判断者・担当者・期限の欄がある"/>
          <node TEXT="リスクとTODOが別管理になっている"/>
          <node TEXT="次回レビューで更新する場所が明確"/>
        </node>
      </node>
    </node>
    <node TEXT="01 レビュー本体">
      <node TEXT="Project Review Board">
        <node TEXT="00 エグゼクティブサマリー">
          <node TEXT="総合判定: Green / Yellow / Red"/>
          <node TEXT="一言結論: [現在の状態を一文で]"/>
          <node TEXT="推奨判断: 継続 / 変更 / 保留 / 停止"/>
          <node TEXT="最大リスク: [影響と期限]"/>
          <node TEXT="次に進める条件: [承認・検証・完了条件]"/>
        </node>
        <node TEXT="01 前提・ゴール">
          <node TEXT="目的: なぜやるのか"/>
          <node TEXT="成功条件: KPI / 完了定義 / 受入条件"/>
          <node TEXT="対象範囲: 今回見るもの"/>
          <node TEXT="対象外: 今回見ないもの"/>
          <node TEXT="制約: 予算 / 期限 / 技術 / 契約"/>
        </node>
        <node TEXT="02 進捗・マイルストーン">
          <node TEXT="計画との差分: 予定通り / 遅れ / 前倒し"/>
          <node TEXT="完了済み: 成果物 / 証跡 / 確認者"/>
          <node TEXT="進行中: 担当 / 期限 / 完了条件"/>
          <node TEXT="遅延・停滞: 原因 / 影響 / リカバリ"/>
          <node TEXT="次のマイルストーン: 日付 / 判定条件"/>
        </node>
        <node TEXT="03 成果物・品質">
          <node TEXT="成果物一覧: 版 / リンク / オーナー"/>
          <node TEXT="レビュー状態: 未着手 / レビュー中 / 承認済み"/>
          <node TEXT="品質懸念: 欠陥 / 未検証 / 運用不安"/>
          <node TEXT="証跡: テスト結果 / 議事録 / 添付"/>
        </node>
        <node TEXT="04 課題・リスク Top 5">
          <node TEXT="R1: [内容] 影響 / 確率 / 期限 / 対応方針"/>
          <node TEXT="R2: [内容] 影響 / 確率 / 期限 / 対応方針"/>
          <node TEXT="R3: [内容] 影響 / 確率 / 期限 / 対応方針"/>
          <node TEXT="ブロッカー: 誰の判断・支援が必要か"/>
        </node>
        <node TEXT="05 今日決めること">
          <node TEXT="D1: 論点 / 選択肢 / 推奨案 / 決定者"/>
          <node TEXT="D2: 論点 / 選択肢 / 推奨案 / 決定者"/>
          <node TEXT="決定後は意思決定ログへ転記"/>
        </node>
        <node TEXT="06 次アクション">
          <node TEXT="P1 TODO: 担当 / 期限 / 完了条件"/>
          <node TEXT="P2 TODO: 担当 / 期限 / 完了条件"/>
          <node TEXT="ウォッチ項目: 次回確認すること"/>
          <node TEXT="次回レビュー: 日時 / 参加者 / 持参物"/>
        </node>
      </node>
    </node>
    <node TEXT="02 意思決定ログ">
      <node TEXT="Decision Log">
        <node TEXT="決定カードの型">
          <node TEXT="論点: 何を決めるか"/>
          <node TEXT="選択肢: A / B / C"/>
          <node TEXT="推奨案: 理由つき"/>
          <node TEXT="決定者: 名前 / 役割"/>
          <node TEXT="決定期限: YYYY-MM-DD"/>
          <node TEXT="決定結果: 採用案 / 条件 / 影響"/>
        </node>
        <node TEXT="今日決める">
          <node TEXT="[D-001] 論点 / 推奨案 / 決定者 / 期限"/>
          <node TEXT="[D-002] 論点 / 推奨案 / 決定者 / 期限"/>
        </node>
        <node TEXT="保留・持ち帰り">
          <node TEXT="[D-101] 誰が / 何を確認 / いつ戻す"/>
          <node TEXT="[D-102] 不足情報 / 入手先 / 期限"/>
        </node>
        <node TEXT="決定済みログ">
          <node TEXT="[D-900] 決定内容 / 日付 / 根拠 / 影響範囲"/>
        </node>
      </node>
    </node>
    <node TEXT="03 リスク台帳">
      <node TEXT="Risk Register">
        <node TEXT="評価基準">
          <node TEXT="影響: H=事業/顧客/期限に重大, M=局所影響, L=軽微"/>
          <node TEXT="確率: H=起きそう, M=可能性あり, L=低い"/>
          <node TEXT="対応: 回避 / 軽減 / 転嫁 / 受容"/>
        </node>
        <node TEXT="Critical: 今すぐ扱う">
          <node TEXT="[R-001] 内容 / 影響H / 確率H / オーナー / 期限 / 対応策"/>
          <node TEXT="[R-002] 内容 / 影響H / 確率M / オーナー / 期限 / 対応策"/>
        </node>
        <node TEXT="Watch: 監視する">
          <node TEXT="[R-101] トリガー条件 / 監視者 / 次回確認日"/>
          <node TEXT="[R-102] 依存先 / 代替案 / エスカレーション条件"/>
        </node>
        <node TEXT="カテゴリ別チェック">
          <node TEXT="技術・仕様: 未確定仕様 / 性能 / セキュリティ"/>
          <node TEXT="スケジュール: 遅延 / クリティカルパス / 休暇"/>
          <node TEXT="体制・負荷: キーマン依存 / レビュー不足"/>
          <node TEXT="関係者: 合意不足 / 承認待ち / 利害衝突"/>
          <node TEXT="運用: 移行 / 障害対応 / サポート"/>
        </node>
        <node TEXT="受容済みリスク">
          <node TEXT="[R-900] 受容理由 / 承認者 / 再評価日"/>
        </node>
      </node>
    </node>
    <node TEXT="04 アクショントラッカー">
      <node TEXT="Action Tracker">
        <node TEXT="TODOの書き方">
          <node TEXT="担当者: 個人名または明確な役割"/>
          <node TEXT="期限: YYYY-MM-DD"/>
          <node TEXT="完了条件: 何がどうなれば完了か"/>
          <node TEXT="証跡: リンク / 添付 / 確認者"/>
        </node>
        <node TEXT="P1 今週やる">
          <node TEXT="[A-001] 内容 / 担当 / 期限 / 完了条件"/>
          <node TEXT="[A-002] 内容 / 担当 / 期限 / 完了条件"/>
        </node>
        <node TEXT="P2 次回までに確認">
          <node TEXT="[A-101] 内容 / 担当 / 期限 / 完了条件"/>
          <node TEXT="[A-102] 内容 / 担当 / 期限 / 完了条件"/>
        </node>
        <node TEXT="Waiting 依存・返答待ち">
          <node TEXT="[A-201] 依頼先 / 依頼日 / 返答期限 / 次の手"/>
        </node>
        <node TEXT="Done 完了ログ">
          <node TEXT="[A-900] 完了内容 / 完了日 / 証跡 / 確認者"/>
        </node>
      </node>
    </node>
    <node TEXT="05 関係者・RACI">
      <node TEXT="Stakeholders and RACI">
        <node TEXT="主要関係者">
          <node TEXT="Project Owner: 最終責任 / 予算 / 優先順位"/>
          <node TEXT="PM: 進行 / 課題管理 / レビュー運営"/>
          <node TEXT="Tech/Design/Business Lead: 専門判断"/>
          <node TEXT="Approver: 承認者 / 決裁条件"/>
        </node>
        <node TEXT="RACI">
          <node TEXT="R Responsible: 実行責任"/>
          <node TEXT="A Accountable: 最終責任"/>
          <node TEXT="C Consulted: 相談先"/>
          <node TEXT="I Informed: 共有先"/>
        </node>
        <node TEXT="コミュニケーション設計">
          <node TEXT="定例: 頻度 / 参加者 / 判断テーマ"/>
          <node TEXT="報告: チャネル / 形式 / 締切"/>
          <node TEXT="エスカレーション: 条件 / 連絡先 / SLA"/>
        </node>
      </node>
    </node>
    <node TEXT="06 学び・改善">
      <node TEXT="Lessons and Template Improvement">
        <node TEXT="レビュー後5分">
          <node TEXT="Keep: 続けること"/>
          <node TEXT="Problem: 詰まったこと"/>
          <node TEXT="Try: 次回変えること"/>
        </node>
        <node TEXT="テンプレ改善メモ">
          <node TEXT="足りなかった枝"/>
          <node TEXT="使われなかった枝"/>
          <node TEXT="次版で標準化する運用"/>
        </node>
        <node TEXT="ナレッジ化">
          <node TEXT="[Lesson] 状況 / 学び / 再利用条件"/>
          <node TEXT="[Anti-pattern] 兆候 / 対策 / チェック方法"/>
        </node>
      </node>
    </node>
  </node>
</map>
