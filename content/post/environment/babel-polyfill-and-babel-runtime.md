---
title: "Babel polyfill and babel runtime"
date: "2020-01-17"
tags: ["babel", "environment"]
draft: false
---

### Babel ?

바벨은 Javascript ES6+ 문법을 ES5로 변환해서 ES6+ 문법을 지원하지 않는 브라우저에서도 동작하도록 만들어주는 `컴파일러` 이다. 그리고 Javascript라는 같은 언어 내에서 소스코드를 변환하기 때문에 동등한 추상화를 거치게 되는데, 이를 `트랜스파일러` 라고도 부른다. 그러니까... `트랜스컴파일러` 정도의 느낌? ~~거의 트랜스포머~~.

<br /><hr />

### Babel-polyfill has been deprecated !

그런데 바벨은 ES5 문법에 존재하지 않는 Promise같은 전역객체 및 이에 추가된 메소드들은 변환해주지 않는다. 이때 필요한 것이 바로 `폴리필(Polyfill)`이다. 폴리필은 특정 기능을 지원하지 않는 브라우저에서 해당 기능을 구현하기 위해 사용하는 코드이다. 바벨로 이러한 폴리필을 추가할 수 있는데, 최근까지는 [generator](https://github.com/facebook/regenerator)로 컴파일된 런타임 라이브러리인 [regenerator-runtime](https://github.com/facebook/regenerator/tree/master/packages/regenerator-runtime)과, [core-js](https://github.com/zloirock/core-js)를 의존성으로 가지고 있는 `@babel/polyfill`을 사용했다.

하지만 [@babel/polyfill 문서](https://babeljs.io/docs/en/babel-polyfill)를 보면 알 수 있듯, babel 7.4.0 버전부터 deprecated되었으므로 좋은 방식은 아니다.

> As of Babel 7.4.0, this package has been deprecated in favor of directly including core-js/stable (to polyfill ECMAScript features) and regenerator-runtime/runtime (needed to use transpiled generator functions)

<br /><hr />

### Then, How to use polyfill ?

<br />

#### **(1) Directly import `core-js` and `regenerator-runtime`**

스크립트 최상단에 두 스크립트를 직접 불러오면 전역에서 모든 ES6+ 문법을 사용할 수 있게 된다. 하지만 이렇게 전역에서 직접 불러오는 방식은 해당 스크립트에 내장된 전역객체를 사용한다. 즉, 해당 스크립트를 통해 한번 감싸여 변환된 네임스페이스를 사용하기 때문에 실제 전역 스코프가 불분명해진다. 물론 [core-js 문서](https://github.com/zloirock/core-js)에 나온 아래의 코드처럼 사용할 부분만 골라서 네임스페이스를 지정해주면 되지만 굉장히 번거로운 작업이 될 것이다.

```javascript
import flat from "core-js-pure/features/array/flat";
import Set from "core-js-pure/features/set";
import Promise from "core-js-pure/features/promise";

from(new Set([1, 2, 3, 2, 1])); // => [1, 2, 3]
flat([1, [2, 3], [4, [5]]], 2); // => [1, 2, 3, 4, 5]
Promise.resolve(32).then(x => console.log(x)); // => 32
```

<br />

게다가 바벨은 `_extend`와 같은 helper 함수들로 구성되어 있는데, 기본적으로 특정 기능이 필요할 때 필요한 모든 곳에서 불러와야 한다. 그러면 자연스럽게 중복되는 import가 발생한다. 특히 여러 파일들로 분산하여 작업한 후 번들링하는 경우가 많기 때문에 이는 아주 불필요한 작업일 수 있다.

<br />

#### **(2) Using [@babel/plugin-transform-runtime](https://babeljs.io/docs/en/babel-plugin-transform-runtime)**

직접 스크립트를 불러왔을 때의 단점이 있으므로 바벨은 해당 플러그인을 제공하고 있다. 이는 실제로 코드에 사용된 폴리필 전역객체 및 메소드만 런타임 시 변환시킨다. 변환될 코드를 위한 일종의 환경(sandboxed environment)을 구성해놓고, 런타임 시 해당 코드만 변환하는 것이다. 따라서 바벨의 helper 함수 코드를 재사용하므로 실제 코드의 크기도 줄일 수 있다. 나는 `Webpack` 번들러에서 바벨 로더를 설정해뒀는데 여기에 해당 플러그인을 함께 사용하고 있다.

```javascript
{
  test: /\.js$/,
  include: path.resolve(__dirname, "src"),
  exclude: /node_modules/,
  use: {
    loader: "babel-loader",
    options: {
      presets: ["@babel/preset-env"],
      plugins: [
        [
          "@babel/plugin-transform-runtime",
          {
            absoluteRuntime: false, // default
            corejs: 3,
            helpers: true, // default
            regenerator: true, // default
            useESModules: false // default
          }
        ]
      ]
    }
  }
},
```

<br />

이 플러그인은 디폴트로는 제안 단계에 있는 기능들까지 폴리필이 제공되지 않는다. 따라서 `corejs` 옵션을 설정해주어야 한다. 현재 시점의 바벨 버전(7.8.0)에서는 `core-js@3` 가 가장 최신으로써 ECMA 제안 단계에 있는 기능들을 사용할 수 있다. ECMAScript의 어떤 기능들이 변환되어 제공되는지 자세한 사항은 [core-js@3](https://github.com/zloirock/core-js/blob/master/docs/2019-03-19-core-js-3-babel-and-a-look-into-the-future.md)문서를 읽어보자!
