---
title: "HTML attribute vs DOM properties"
date: "2023-05-24"
tags: ["javascript/html/css"]
draft: false
og_description: ""
---

### Q. 앵귤러 템플릿에서 input disabled을 동적 처리하고 싶어요.

```ts
// ts
isDisabled = true;
```

```html
<div class="item_radio" *ngFor="let item of list">
  <input
    type="radio"
    id="type{{ item.value }}"
    class="inp_radio"
    name="type"
    formControlName="type"
    [value]="item.value"
    [disabled]="isDisabled"
  />
  ...
</div>
```

결과적으로 위 코드는 disabled를 동적 처리하지 못한다. 실제 DOM 트리의 해당 요소를 보면 disabled 대신 `ng-reflect-is-disabled="true"`만 생성되어 있다. ng-reflect-is-disabled는 앵귤러 프로덕션 빌드에서는 보이지 않는 단순 디버깅용으로 쓰이는 요소로, 결국 disabled 처리는 되지 않는다.

아래는 이 현상에 대해 앵귤러팀이 해준 답변이다.

<br />

> This is working as designed. Binding syntax (using square brackets `[disabled]`) **binds an expression to a DOM property, not an attribute**. Static values are added to elements as attributes, hence the difference between `input disabled` and `input [disabled]`. The ng-reflect-is-disabled is for debugging purposes and will not be present in production.

> If you need to set the disabled attribute, using `[attr.disabled]` is the correct way to go here.

`[disabled]=""` 혹은 `disabled="{{}}"` 문법은 attribute가 아닌 DOM property로 바인딩되므로 이것이 올바른 동작이라고 한다. 따라서 attribute에 직접 바인딩하는 `[attr.disabled]` 를 쓰라고 권장한다.

그렇다면 attribute와 property의 차이는 무엇인가?

<br />

### 1. attribute vs property

- HTML attribute는 대소문자를 가리지 않고, 모두 문자열이다.
- DOM property는 대소문자를 가리며, 어떤 타입의 값이든 올 수 있다.

  ```html
  <body something="non-standard">
    <script>
      // OK 1: attribute
      alert(document.body.getAttribute("Something"));
      alert(document.body.getAttribute("something"));

      // OK 2: property
      Element.prototype.sayHi = () => console.log("hi");
      document.body.sayHi();

      // ERROR:
      // DOM property not created, because it's non-standard
      alert(document.body.something);
    </script>
  </body>
  ```

- ~~attribute를 바꾸면 property도 업데이트되지만, property를 바꿔도 attribute가 바뀌진 않는다.~~
- (2023-08-02 수정) 표준 attribute를 바꾸면 property도 자동으로 동기화되며, property를 바꿨을 때도 표준 attribute는 같이 바뀌는 것이 맞다.

  ```html
  <!-- 😄 attribute -> property -->
  <input />
  <script>
    let input = document.querySelector("input");

    input.setAttribute("id", "roomy");
    console.log(input.id); // roomy

    input.id = "newRoomy";
    console.log(input.getAttribute("id")); // newRoomy
  </script>
  ```

- (2023-08-02 수정) 다만, `value`처럼 attr에서 prop 방향으로만 동기화되는 예외상황도 존재한다!

  ```html
  <!-- 😢 property -> attribute -->
  <input />
  <script>
    let input = document.querySelector("input");

    input.setAttribute("value", "roomy");
    console.log(input.value); // roomy

    input.value = "newRoomy";
    console.log(input.getAttribute("value")); // roomy
  </script>
  ```

- 표준 HTML attribute를 통해 DOM property가 생성된다.

  ```html
  <body id="test" something="non-standard">
    <script>
      // OK
      alert(document.body.id);

      // ERROR
      alert(document.body.something);
    </script>
  </body>
  ```

<br />

### 2. 음... 그래서 [disabled]=""가 동작하지 않은 이유?

disabled는 input태그의 표준 attribute이므로 property로도 접근 가능하다. 그래서 앵귤러쪽의 답변이 썩 속시원하지가 않았다. 표준 태그니까 property 바인딩이 되어야 하는 것 아니야? 그래서 더 찾아보니 아래의 두 글을 발견했다.

- [Bug: setting [disabled] attribute no longer works with formControlName](https://github.com/angular/angular/issues/48350)
- [Reactive forms - disabled attribute](https://stackoverflow.com/questions/40494968/reactive-forms-disabled-attribute)

결론만 말하면 **ReactiveFormsModule(ex. formControl)은 `[disabled]` 바인딩을 함께 사용할 수 없다.** 앵귤러에서는 반응형 폼 모듈을 쓸 때 disabled를 아래처럼 동작시키기를 권장하고 있다.

<br />

```ts
// 폼컨트롤에 disabled 옵션 처리
formBuilder.control({value: "ALL", disabled: true});

// 메서드를 통해 disabled 제어
form.controls["id"].enabled();
form.controls["id"].disabled();
```

즉, 반응형 폼은 formBuilder를 통해 만들어지므로 FormControlState 옵션에 disabled 속성을 지정하지 않으면, HTML attribute 자체가 생기지 않는 것이다. **그러면 당연히 DOM에도 없으니 property 접근도 불가하다.** _이런 내용을 앵귤러 측에서 다 생략해버려서 속시원하지가 않았던 거라고!_

<br />

### 3. formControl을 템플릿 기반으로 disable 처리하려면?

이벤트 기반이 아니라 모종의 이유(초기에만 disabled 처리를 한다든지)로 **enable/disable 메서드로 제어하고 싶지 않을 때는, 여전히 template-driven한 방식으로 disabled 처리를 할 수 있다.**

바로 `[attr.disabled]`이다. 이건 아예 disabled라는 속성을 DOM에 직접 만들어주고 직접 제어하는 것이므로 지정한 formControl과는 상관 없이 동작할 수 있다.

<br />

## 4. 결론

- formControl과 `[disalbed]`는 공존할 수 없다.
- formBuilder로 formControl을 정의할 때 disabled 옵션을 지정하든가, `[attr.disabled]`로 쓰자.
