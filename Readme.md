# 全角ビュー

[全角チェッカー](https://ao-system.net/doublecharcheck/) を参考に `Elm` で実装しました。

実際に [デモ](https://waddlaw.github.io/ZenkakuView/) から試すことができます。

## Elm のインストール

- [Elm Platform](http://elm-lang.org/install).
- [architectcodes/elm-live](https://github.com/architectcodes/elm-live)

**Ubuntu** の場合は以下のコマンドでインストールできます。

```sh
$ sudo npm i -g elm elm-live --unsafe-perm=true --allow-root
```

## Elm について

- [Elm tutorial](https://www.elm-tutorial.org/jp/)
- [Elm Syntax](http://elm-lang.org/docs/syntax)

## このアプリケーションで利用しているもの

フレームワーク

- [BULMA](https://bulma.io/)

elm パッケージ

- [norpan/elm-file-reader](http://package.elm-lang.org/packages/norpan/elm-file-reader/2.0.1/)
- [danyx23/elm-mimetype](http://package.elm-lang.org/packages/danyx23/elm-mimetype/4.0.0/)
- [elm-lang/html](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/)
- [elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/)

## 開発方法

`elm-live` を使うと良い感じに開発が進みます。

```sh
$ elm-live Zenkaku.elm --output=zenkaku.js --open
```

上記コマンドを実行すると、自動的にブラウザが開くのでデバッグできます。

### elm パッケージのインストール方法

```sh
$ elm package install --yes xxxx/yyyyy
```