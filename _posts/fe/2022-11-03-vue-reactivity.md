---
title: Vue data reactivity
layout: post
category: front-end
tags: [Vue.js]
---

Created: July 6, 2022 2:15 PM
Date: July 6, 2022 2:15 PM
Tags: Vue.js, observer, proxy

## **Vue 2 data reactivity**

In Vue 2, data reactivity is achieved by traversing the data, and making use of `Object.definedProperty()` to convert its properties to getter/setter. It collects data dependencies via custom getter, and monitors data change and subscribe events in a custom setter.

![Untitled](/assets/post-img/2022-11-03-vue-reactivity/Untitled.png)

### defineReactive 코드분석

```jsx
Object.defineProperty(obj, key, {
  enumerable: true,
  configurable: true,
  get: function reactiveGetter() {
    const value = getter ? getter.call(obj) : val
    if (Dep.target) {
      dep.depend()
      if (childOb) {
        childOb.dep.depend()
        if (Array.isArray(value)) {
          dependArray(value)
        }
      }
    }
    return value
  },
  set: function reactiveSetter(newVal) {
    const value = getter ? getter.call(obj) : val
    /* eslint-disable no-self-compare */
    if (newVal === value || (newVal !== newVal && value !== value)) {
      return
    }
    /* eslint-enable no-self-compare */
    if (process.env.NODE_ENV !== 'production' && customSetter) {
      customSetter()
    }
    // #7981: for accessor properties without setter
    if (getter && !setter) return
    if (setter) {
      setter.call(obj, newVal)
    } else {
      val = newVal
    }
    childOb = !shallow && observe(newVal)
    dep.notify()
  },
})
```

위 함수는 초기화 `defineReactive` 될 때 데이터 개체의 모든 속성에 대해 호출된다.

Observer getter가 종속성을 수집하도록 정의된 것을 볼 수 있으며 설정은 데이터 변경을 모니터링하고 변경이 감지되면 알림을 보낸다.

### 위 메커니즘에서 두가지 문제가 발생함

- 속성의 삭제 or 추가를 감지할 수 없음
  - 반응성은 앱이 초기화될 때만 적용된다. 런타임에 새 속성을 추가하면 새 속성은 반응하지 않는다. 즉, 속성 값을 변경해도 반응적인 부작용이 발생하지 않는다. Vue2는 `.set` 을 개발자가 수동으로 속성을 반응형으로 추가할 수 있도록 하는 해결방법을 제공한다.
- 성능
  - 대규모/ 중첩 데이터 셋의 경우 vue2가 모든 속성의 데이터 횡단에 getter/setter 생성이 필요하기 때문에 성능에 부정적인 영향을 미칠 수 있다.

## vue3

es6에 도입된 Proxy를 사용하여 기존의 상태객체에 getter/setter를 이것으로 대체하여 반응성을 구현가능.

프록시는 새로운 속성 추가를 감지할 수 있음

### MDN Proxy

[Proxy - JavaScript | MDN](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/Proxy)

### createReactiveObject 분석

```jsx
function createReactiveObject(target: Target, isReadonly: boolean, baseHandlers: ProxyHandler<any>, collectionHandlers: ProxyHandler<any>, proxyMap: WeakMap<Target, any>) {
  if (!isObject(target)) {
    if (__DEV__) {
      console.warn(`value cannot be made reactive: ${String(target)}`)
    }
    return target
  }
  // target is already a Proxy, return it.
  // exception: calling readonly() on a reactive object
  if (target[ReactiveFlags.RAW] && !(isReadonly && target[ReactiveFlags.IS_REACTIVE])) {
    return target
  }
  // target already has corresponding Proxy
  const existingProxy = proxyMap.get(target)
  if (existingProxy) {
    return existingProxy
  }
  // only a whitelist of value types can be observed.
  const targetType = getTargetType(target)
  if (targetType === TargetType.INVALID) {
    return target
  }
  const proxy = new Proxy(target, targetType === TargetType.COLLECTION ? collectionHandlers : baseHandlers)
  proxyMap.set(target, proxy)
  return proxy
}
```

- 위 코드는 객체만 처리하기를 원하므로 기본 유형의 데이터가 직접 반환합니다.
  vue3는 대신 **ref**를 사용하여 기본 유형을 처리. 내부적으로 반응 프록시 개체를 사용
- 객체에 이미 해당 프록시가 있을 경우 캐시된 프록시를 직접 반환
- 대상 객체 유형을 유추하면 vue3는 Array, Object, Map, Set, WeakMap, WeakSet에 대해서만 프록시를 생성. 대상 유형 외부의 개체는 INVALID로 설정되고 반환
- 새 프록시 개체를 만들고 반환하기 전에 proxyMap캐시에 저장

### Proxy는 Vue2 반응성 문제를 어떻게 해결할까?

proxy 개체를 사용하면 개체에 액세스하거나 개체를 수정하기 위한 모든 호출이 차단된다.
사용자 정의 작업은 getter / setter에서 정의된다.

```jsx
const hadKey = isArray(target) && isIntegerKey(key) ? Number(key) < target.length : hasOwn(target, key)
const result = Reflect.set(target, key, value, receiver)
// don't trigger if target is something up in the prototype chain of original
if (target === toRaw(receiver)) {
  if (!hadKey) {
    trigger(target, TriggerOpTypes.ADD, key, value)
  } else if (hasChanged(value, oldValue)) {
    trigger(target, TriggerOpTypes.SET, key, value, oldValue)
  }
}
```

속성이 존재하지 않는 경우(`hadKey` false인 경우) 트리거 메서드를 사용하여 새속성이 추가되었음을 종속성에 알린다. 이것은 Vue2에서 추가 속성을 감지할 수 없는 문제를 해결한다. 마찬가지로 `deleteProperty` 핸들러 작업은 Vue2에서 삭제 속성을 감지 할 수 없는 문제를 해결한다.

Vue3에서 반응성 API의 프록시 구현을 사용하면 데이터의 모든 속성을 탐색할 필요가 없다. 이는 대규모 데이터 세트를 처리할 때 상당한 성능 향상을 가져온다.

## 결론

프록시는 강력한 메타프로그래밍 기능이다. Vue3에서 Proxy를 적용하는 것은 훌륭한 솔루션입니다. Vue2의 문제를 해결할 뿐 아니라 추가 확장 가능성도 열어준다.

---

참고

[When Vue Meets Proxy](https://levelup.gitconnected.com/when-vue-meets-proxy-402e9e3c6722)
