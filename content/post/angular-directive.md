---
title: "Angular directive example"
date: "2018-08-02"
tags: ["web", "angular"]
draft: false
---

## What is directive ?

Use it to attach custom behavior to elements in the DOM.
<br><br>

## Basic Example

> This is a simple directive to change chevron background-image as clicking the element.
> <br>

(1) HTML
<br>

```
<label appChevron class="chevron" style="background-image: url('/assets/images/arrow-down.svg');"></label>
```

<br><br>

(2) TS (Of course it needs to be imported to app.module.ts declarations)
<br>

```
import { Directive, ElementRef } from '@angular/core';

@Directive({
  selector: '[appChevron]'
})
export class ChevronValidate {
  constructor(el: ElementRef) {
    const div = document.createElement('div');

    div.style.width = '100%';
    div.style.height = '100%';
    div.onclick = () => {
      let bg = el.nativeElement.style.backgroundImage;

      if (bg.indexOf('down') !== -1) {
        el.nativeElement.style.backgroundImage = `url('/assets/images/chevron-up.svg')`;
      } else {
        el.nativeElement.style.backgroundImage = `url('/assets/images/chevron-down.svg')`;
      }
    }

    el.nativeElement.appendChild(div);
  }
}
```

Someone think like "why did make stupid div in directive?". The reason why is because angular directive is not officially allow sending other element except the one marked that directive selector.
<br><br>

```
// HTML
<label [appChevron]="clickElem" ...>
    <div #clickElem click="something"></div>
</label>

// TS
...
export class ChevronValidate {
  @Input('clickElem') elem: ElementRef;

  constructor(el: ElementRef) {
  }
}
```

There is actually no syntax error. But you got `undefined` or error when you try attach to nativeElement with received element in directive. So I think it is better to use directive to only marked element in HTML.
