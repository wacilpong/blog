---
title: "Test with jest the untranspiled external libraries"
date: "2020-01-02"
tags: ["configuration"]
draft: false
og_description: "create-react-app로 만들어진 리액트 프로젝트에는 jest가 이미 적용되어 있는데, react-scripts 의 jest 설정부분을 보면 알 수 있다. 그런데 node_modules를 트랜스파일링하지 않는다."
---

## jest in CRA

```javascript
// react-scripts/config/jest/babelTransform.js
const babelJest = require("babel-jest");

module.exports = babelJest.createTransformer({
  presets: [require.resolve("babel-preset-react-app")],
  babelrc: false,
  configFile: false
});
```

_create-react-app_ 로 만들어진 리액트 프로젝트에는 [**jest**](https://jestjs.io/)가 이미 적용되어 있는데, _react-scripts_ 의 jest 설정부분을 보면 알 수 있다. 그런데 jest는 [**문서 - transformignorepatterns**](https://jestjs.io/docs/en/configuration#transformignorepatterns-arraystring)의 다음과 같은 말을 보면 알 수 있듯이 `node_modules/`를 트랜스파일링하지 않는다.

> Since all files inside node_modules are not transformed by default, Jest will not understand the code in these modules, resulting in syntax errors.

<br /><hr />

## ES6 module syntax error in jest

해당 프로젝트에 외부 라이브러리를 적용했는데 jest로 테스트를 돌리니 자꾸 아래와 같은 에러가 발생했다.

```s
SyntaxError: Cannot use import statement outside a module
```

<br />

참고로 import는 ES6부터 적용된 **모듈 시스템**인데, NodeJs에서는 [**CommonJs**](https://ko.wikipedia.org/wiki/CommonJS) 기반의 모듈시스템을 사용해왔기 때문에 import/export 구문을 사용하려면 babel과 같은 트랜스파일러로 변환과정이 필요하다. 물론 노드에서도 [**v10+**](https://nodejs.org/docs/latest-v10.x/api/esm.html#esm_enabling)에서 도입된 `--experimental-modules` 옵션, 혹은 [**v13+**](https://nodejs.org/docs/latest-v13.x/api/esm.html)에서 나온 `--experimental-conditional-exports` 옵션을 통해 해당 모듈시스템을 이용할 수는 있다.

그러나 말 그대로 아직 실험적이라서 해당 옵션에서만 서포트되고 있고, [**문서 - plan for new modules implementation**](https://github.com/nodejs/modules/blob/master/doc/plan-for-new-modules-implementation.md)에 따르면 계속 대체 솔루션을 찾고 있다. 그러므로 노드가 런타임에서 해당 구문을 실행할 수 있게 변환하는 것이 더 바람직하다.

CRA 또한 노드 환경에서 빌드되기 때문에 해당사항이 있으므로 트랜스파일링 과정(물론 CRA는 babel이나 webpack과 같은 설정들이 이미 되어 있는 보일러플레이트)이 필요하다. 앞서 문서에 나와있듯 jest 테스트 프레임워크에서도 ES6 기반의 import/export 구문은 이해하지 못한다. 따라서 위의 에러는 트랜스파일링되지 않은 외부 라이브러리의 코드 때문에 발생한다고 추측했다.

<br />

`import` is ES6+ statement, and it is called **module system**. NodeJs have been using CommonJs-based module system, so it needs to be transpiled with transpiler such as babel when want to use import statement. In fact, It can be possible to use ES6 module system with `--experimental-modules`(v10+) or `--experimental-conditional-exports`(v13+) command options.

But it is only experimental and supported in that option, not default. So I think traspiling is the right choice for node runtime. CRA is also build in Node environment. and jest test framework also can't understands import/export statement based ES6. So I think the error caused by the untranspiled external library!

<br /><hr />

## how to solve ?

```s
--transformIgnorePatterns \'node_modules/(blah-blah|test-test|blah-test)/\'
```

이에 따라 jest 문서를 보니 위와 같은 옵션이 있었다. `--transformIgnorePatterns` 옵션을 통해 해당 라이브러리를 node_modules에서 예외적으로 처리할 수 있다고 한다. 해당 옵션은 babel을 통해 트랜스파일되도록 허용한다. `|`를 이용해 배열 형태로도 가능하다.

solution is the `--transformIgnorePatterns` option in testing with jest. it makes the matched node modules be transpiled with babel. can be array with `|`.
