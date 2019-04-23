# nene-ios

* Xcode 10.1
* Swift 4.2

## 環境構築

1. `make pod_install`
2. `make carthage_install`

## プロビジョニング

match(https://docs.fastlane.tools/actions/match/) を使用

使用するコマンドはmakeファイルを参照

## 開発環境配信

fastlaneで配信

`make adhoc`

## GUIアーキテクチャ

MVVMを採用。

## 懸念点

* 工数的な問題で、システム全体で使う管理者マスターのIDを全ての環境で固定しており、そのIDを各アプリケーションでハードコードしています。本来的には、CustomClameとかで管理するべきかと思います。
