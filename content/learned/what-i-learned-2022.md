---
title: "2022"
date: "2022-01-01"
description: "About what I learned at 2022"
og_description: "About what I learned at 2022"
draft: false
---

## **2022-01-06**

- [ts의 데코레이터(decorator)](https://www.typescriptlang.org/docs/handbook/decorators.html)는 처음에 앵귤러를 지원하기 위해 추가되었다.
  - 현재까지도 표준화가 되지 않았기 때문에 앵귤러를 쓰거나 어노테이션이 필요한 프레임워크가 아니라면 쓰지 않는 게 좋다.
  - 데코레이터는 아래처럼 클래스, 메서드, 프로퍼티에 어노테이션(annotation)을 붙이거나 기능을 추가하는 데 사용할 수 있다.
    ```ts
    class Greeter {
      greeting: string;
      constructor(message: string) {
        this.greeting = message;
      }
      @logged
      greet() {
        return "hi," + this.greeting;
      }
    }
    function logged(target: any, name: string, descriptor: PropertyDescriptor) {
      const fn = target[name];
      descriptor.value = function () {
        console.log(`Calling ${name}`);
        return fn.apply(this, arguments);
      };
    }
    console.log(new Greeter("Roomy").greet());
    // Calling greet
    // hi,roomy
    ```

<br />
<hr />
