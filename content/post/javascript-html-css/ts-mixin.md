---
title: "Typescript mixins in Angular"
date: "2022-01-16"
tags: ["javascript/html/css"]
draft: false
og_description: "믹스인은 객체지향에서 범용적으로 쓰이는 개념으로, 부모클래스가 되지 않으면서 다른 클래스에서 사용할 수 있는 메서드를 포함하는 클래스다."
---

## What

> [ts mixins](https://www.typescriptlang.org/docs/handbook/mixins.html)

- 믹스인은 객체지향에서 범용적으로 쓰이는 개념으로, 부모클래스가 되지 않으면서 다른 클래스에서 사용할 수 있는 메서드를 포함하는 클래스다.
- 베이스 클래스 확장을 위해 제네릭과 상속을 활용한다.
- 베이스 클래스를 확장하는 클래스 표현식을 반환해주는 팩토리 함수(다른 객체를 생성하기 위한 객체)가 필요하다.

  ```ts
  type Constructor = new (...args: any[]) => {};

  function Scale<TBase extends Constructor>(Base: TBase) {
    return class Scaling extends Base {
      _scale = 1;

      setScale(scale: number) {
        this._scale = scale;
      }

      get scale(): number {
        return this._scale;
      }
    };
  }
  ```

- ts 데코레이터 패턴과 함께 사용할 수도 있다.

  ```ts
  const Pausable = (target: typeof Player) => {
    return class Pausable extends target {
      shouldFreeze = false;
    };
  };

  @Pausable
  class Player {
    x = 0;
    y = 0;
  }
  ```

<br />

## With angular

- A, B컴포넌트가 팩토리함수 Mixin의 Base 클래스이다.
- 이처럼 **믹스인을 통해 다양한 컴포넌트에서 같은 클래스를 확장해 사용할 수 있다.**

  ```ts
  function Mixin<T extends Constructor<{}>>(Base: T = class {} as any) {
    return class Some extends Base {
      blah(name: string, count: number): string {
        return `${name}: ${count}번 blahblah했대요`;
      }
    };
  }
  ```

  ```ts
  export class AClassComponent extends Mixin() {
    name: "roomy";
    count: 5;

    constructor() {
      super();
    }

    blahHandler(): void {
      return this.blah(this.name, this.count);
    }
  }

  export class BClassComponent extends Mixin() {
    // A와 동일
  }
  ```

- 앵귤러의 공식적인(?) 문법으로 믹스인을 지원하지 않기 때문에, 혹시 생성자로 DI를 받는 부분에서 상충되는 것이 있을까 싶었다.
- 그러나 DI는 말그대로 해당 클래스가 필요한 의존성들을 외부로부터 주입받는 것뿐이다.
- 따라서 주입받은 의존 객체들을 상속하는 것이 앵귤러 DI시스템에 상충되지는 않을 것이다.
- 다만 의존관계가 복잡해질 것 같아서 꼭 필요할 때 써야할 것 같다.
