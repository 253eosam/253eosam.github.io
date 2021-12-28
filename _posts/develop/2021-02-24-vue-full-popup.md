---
layout: post
title: '[Vue.js] 모달 만드는 방법'
date: 2021-02-24
categories: Develop
tags: [JavaScript, Vue.js, HTML, CSS, modal]
description: '모달을 만들고, 효율적으로 관리하는 방법 등을 Vue.js를 통해 설명.'
---

# 📖 들어가기

프론트 디자인을 구성하다보면 Modal부분이 거의 필수적으로 사용되기 마련이다. 요즘은 여러 라이브러리에서 이런 모달들을 지원해주기 때문에 따로 내가 만들 필요는 없지만
나만의 커스텀 디자인을 만들고 싶은 경우도 있고, 어떤 구조로 만들어지는 궁금하기도하다. 그래서 오늘은 모달은 만드는 방법과 효율적으로 모달을 관리하는 방법을 설명해보려고한다.

> 전통적인 HTML로 먼저 Modal을 구현하고 이후에 Vue.js에서 컴포넌트 방식으로 모달을 관리하는 방법을 설명.

## 기술 스택

-   HTML
-   CSS
-   Vue.js(JS)

<br>

# HTML에서 Modal 만들기

모달이라고하면 어떤 버튼을 눌렀을때 새로운 작은 창이 생기면서 클릭한 부분의 서브 화면을 노출하는 것을 목적으로 사용합니다.

> **모달, 팝업 차이?** <br>
> 모달과 팝업은 비슷하지만 약간의 차이가 있습니다. 팝업은 새로운 윈도우창에 생겨난다는 점과 모달은 기존 윈도우화면을 덮으며 위로 생겨나는 창을 말합니다.

## HTML 코드

어떤 구조로 만들어 지는지 설명하기 위해서 HTML 코드를 이용해서 태그들이 어떤 방식으로 그려지고 사용되는지 살표 봅니다.

```html
<div id="app">
	<label id="modal__btn" for="modal-status"> 버튼 </label>
	<input type="checkbox" id="modal-status" />
	<div id="modal-wrap">
		<div id="modal-box"></div>
		<label id="modal-bg" for="modal-status" />
	</div>
</div>
```

모달이 현재 열려있는지 상태를 확인하기 위해서 체크박스(`modal-status`)를 만듭니다. 이 체크박스를 통해서 모달이 열려있는지 닫혀있는지를 확인할 것입니다. <br>
그리고 라벨(`modal__btn`)을 이용해 간단한 버튼을 만듭니다. 이 라벨은 체크박스의 상태를 변경하는 역할을 합니다.

이제 모달 화면을 만들 차례입니다. `modal-wrap`을 이용해서 모달 화면을 감싸줄 태그를 만듭니다. 모달안에는 까만 배경과 가운데 하얀 박스 모양으로 만들겁니다. 
`modal--box`를 만들고 그 아래에 `modal-bg`를 만듭니다. `modal-bg`를 라벨로 잡은 이유는 배경을 누르면 모달이 닫히게끔 만들기 위해서입니다.

> **모달과 모달리스 차이점** <br>
> 모달은 백그라운드를 가리고 자신의 작업에 집중할 수 있도록 되어있고 모달리스경우는 뒤에 그려진 화면과 상호작용할 수 있는 차이점이 있습니다.

이제 HTML은 준비가 끝났습니다. 여기에 CSS를 입히면 간단한 모달을 완성할 수 있습니다.

## CSS 코드

```css
html,
body,
#app {
	padding: 0;
	margin: 0;
	height: 100%;
	width: 100%;
}
#modal__btn {
	display: inline-block;
	margin: 10px;
	border-radius: 20px;
	box-shadow: #000 0px 0px 3px;
	padding: 5px 20px;
	cursor: pointer;
	user-select: none;
}
#modal-bg {
	position: fixed;
	top: 0;
	left: 0;
	display: block;
	height: 100%;
	width: 100%;
	background: #ddd;
	opacity: 0.6;
	z-index: 100;
}
#modal-box {
	position: fixed;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	min-width: 500px;
	min-height: 500px;
	background: #fff;
	z-index: 101;
}
#modal-status + #modal-wrap {
	display: none;
}
#modal-status:checked + #modal-wrap {
	display: initial;
}
```

위 코드를 보면서 하나하나씩 설명하겠습니다.

- **html, body, #app** : padding과 margin을 0을 줘서 기본적으로 브라우저에서 제공하는 태그의 속성값을 없앴습니다. height, width의 값에 100%를 준 이유는 화면 전체를 사용하기 위해서입니다. 기본적으로 퍼센트는 상위 부모의 값을 기준으로 가져오기 때문에 자식 요소에서 100%를 사용하기 위해서는 부모로부터 그 기준을 선택해줘야합니다.

- **#modal__btn** : 단순 버튼 모양을 만드는 코드라 설명은 넘어가겠습니다.

- **#modal-bg** : 화면 전체를 검정으로 칠하고 position fixed 를 이용해 요소를 고정해줍니다. 

- **#modal-box** : 모달 박스는 실질적으로 모달이 뜨는 창입니다. 가운데 위치하기 위해서 position 고정값으로 정해주고 translate을 이용해서 가운데 지점으로 이동시깁니다. 그리고 원하는 최소 사이즈를 정해 설정합니다. 이때 **bg** 와 **box**는 다른 요소들보다 위에 떠있어야하기때문에 z-index를 다른 요소들보다 높게 설정해줍니다.

- **#modal-status + #modal-wrap** : 체크박스가 체크되어있지않을때 **modal-wrap** 의 화면을 가립니다.

- **modal-status:checked + #modal-wrap** : 체크박스가 체크되어있을때 **modal-wrap** 의 화면을 보여줍니다.

위와 같이 코드를 작성하면 아래와 같은 화면을 볼 수 있습니다.

![](/assets/posts/vue-full-popup/html_modal.gif)

이렇게 간단하게 모달을 만들어봤습니다. 생각보다 간단한 매커니즘이며 CSS와 **modal-box**를 통해 모달을 커스텀하여 사용할 수 있습니다.

<br>

# Vue.js에서 Modal 만들기

위 방법은 모달을 만들때 각각의 모달요소들을 다 만들어야하는 리소스 낭비가 생길 수 있습니다. <br>
따라서 이번에는 전체적으로 사용할 수 있는 모달 창을 만들고 안의 내용은 파라메타값을 이용해서 동적으로 화면을 변경 할 수 있도록 해보겠습니다. <br>
실제로 위 **modal-box**안에 어떤 값을 넣을지 동적으로 결정할 수 있다고 이해하시면됩니다.

> 물론 위 HTML 방식에서도 가능하지만 컴포넌트를 이용한 방식을 이용해보겠습니다.

CSS 코드는 위를 그대로 사용하시면됩니다.

```html
<!DOCTYPE html>
<html lang="ko">
	<head>
		<meta charset="UTF-8" />
		<meta http-equiv="X-UA-Compatible" content="IE=edge" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />
		<title>make modal</title>
		<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
	</head>
	<body>
		<div id="app">
            <button type="button" @click="openModal" id="modal__btn">Open Modal</button>
            <div v-if="isOpenModal" id="modal-bg" @click.self="closeModal">
                <component id="modal--box" :is="modalCompo"></component>
            </div>
        </div>
		<script>
			const Home = { template: '<h1>Hello World</h1>' };
			const About = { template: "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.</p>" };


			const vm = new Vue({
				el: '#app',
				data() {
					return {
                        isOpenModal: false,
                        modalCompo: null
                    };
				},
                methods: {
                    setModalCompo (pCompo) {
                        if (pCompo === 'Home') this.modalCompo = Home
                        else if (pCompo === 'About') this.modalCompo = About
                        else this.modalCompo = null
                    },
                    openModal () {
                        const compo = prompt('열고싶은 컴포넌트를 입력해주세요.\nex) Home, About')
                        this.setModalCompo(compo)
                        this.isOpenModal = true;
                    },
                    closeModal () {
                        this.isOpenModal = false;
                    }
                }
			});
		</script>
	</body>
</html>
```

- **CDN** : Vue.js를 사용하기 위해서 CDN 링크를 넣어줍니다. <br>
```
		<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
```

- **modal__btn** : 모달 창을 열기위한 버튼입니다. <br>
버튼을 클릭하면 컴포넌트를 입력할 수 있는 창을 생성하고 원하는 컴포넌트를 입력하면 **data 값의 modalCompo** 값이 변경되면서 해당 값으로 모달 창을 엽니다.

- **modal-bg** : 모달 열기 버튼을 누르면 **data 값의 isOpenModal 상태값을 변경하여 v-if에 true/false 값을 통해** 모달을 열고 닫습니다.

- **modal--box** : **component를 동적으로 넣을수 있도록 요소를 생성하고 :is를 통해 원하는 값을 주입하면 해당 컴포넌트가 주입되는 방식입니다.** <br>
@click.self 이벤트를 넣은 이유는 이벤트 버블링으로인해 해당 창을 클릭시 상위 요소인 **modal-bg**의 closeModal 메소드를 실행 시키는 것을 막는 역할을 합니다.

여기서는 `Home`,`About` 컴포넌트를 미리 만들어두고 모달을 열때 원하는 컴포넌트를 선택하여 여는 방식을 취합니다.

![](/assets/posts/vue-full-popup/vue_modal.gif)
