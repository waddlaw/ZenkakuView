# ZenkakuView

Inspired [全角チェッカー](https://ao-system.net/doublecharcheck/).

- [x] Support D&D Mode
- [x] Support Copy&Paste TextArea
- [ ] Universal Color Design
- [ ] Completely to use Offiline
- [ ] Require options?
- [ ] Show line number
- [ ] Support ACE editor

## Install Elm

- [Elm Platform](http://elm-lang.org/install).
- [architectcodes/elm-live](https://github.com/architectcodes/elm-live)

### Ubuntu

```shell
$ sudo npm i -g elm elm-live --unsafe-perm=true --allow-root
```

## Learning Elm

- [Elm tutorial](https://www.elm-tutorial.org/jp/)

## dependencies

framework

- [BULMA](https://bulma.io/)

elm package

- [norpan/elm-file-reader](http://package.elm-lang.org/packages/norpan/elm-file-reader/2.0.1/)
- [danyx23/elm-mimetype](http://package.elm-lang.org/packages/danyx23/elm-mimetype/4.0.0/)
- [elm-lang/html](http://package.elm-lang.org/packages/elm-lang/html/2.0.0/)
- [elm-lang/core](http://package.elm-lang.org/packages/elm-lang/core/5.1.1/)

## develop

rapid development.

```sh
$ elm-live Zenkaku.elm --output=zenkaku.js --open
```

Let's access to [http://localhost:8000/Zenkaku.elm](http://localhost:8000/Zenkaku.elm).

### Option

package install.

```sh
$ elm package install --yes xxxx/yyyyy
```