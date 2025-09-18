---
title: "Jenkins와 github trigger설정"
date: "2025-09-17T07:45:58.200Z"
tags:
  - TRIGGER
  - github
  - jenkins
description: "새로운 개발팀에 합류하고, CI/CD tool인 jenkins build가 git에 trigger되지 않아 불편했던 경험을 개선 후 그 과정을 기록으로 남깁니다.

개요

github의 push event 발생시 webhook을 통해 jenkins가 이것을 감지하고 b"
url: "https://velog.io/@253eosam/Jenkins%EC%99%80-github-trigger%EC%84%A4%EC%A0%95"
---

> 새로운 개발팀에 합류하고, CI/CD tool인 jenkins build가 git에 trigger되지 않아 불편했던 경험을 개선 후 그 과정을 기록으로 남깁니다.

## 개요

github의 push event 발생시 webhook을 통해 jenkins가 이것을 감지하고 build & deploy를 실행하도록 설정할 계획입니다.

Jenkins task의 config 옵션을 통해 hook을 받을 수 있도록 설정하고, 이후 github에서 어떤 도메인으로 webhook을 요청할지 설정합니다.

여기서는 2가지 방법에대해 설정합니다.

*   jenkins의 형상관리 repository인 SCM이 이것을 감지하도록 설정합니다.
*   generic-webhook-trigger를 사용하여 task에 설정된 repository의 훅을 감지하도록 설정합니다.

> **Webwook이란?**  
> ”Webhooks allow external services to be notified when certain events happen. When the specified events happen, we’ll send a POST request to each of the URLs you provide.”  
> 특정 이벤트가 발생할 때 외부 서비스에 알릴 수 있습니다. 지정된 이벤트가 발생하면 제공하는 각 URL에 게시물 요청을 보내드립니다.

## Jenkins, Github 설정

> 이미 jenkins task에는 dev branch를 감지하도록 설정되어있습니다.

먼저 Jenkins에서 webHook을 받을때 build가 동작할 수 있도록 trigger 설정을 살펴보았습니다.

_configuration > general > build trigger : **GitHub hook trigger for GITScm polling**_

이 설정을 하기전에 GITSCM이 무엇인지부터 알아야합니다.

> GITSCM이란?  
> Jenkins의 pipeline config 문서를 관리하기위한 repository 입니다.  
> jenkins는 gui기반으로 배포설정을 할 수 있지만 이 설정들은 프로젝트가 진화하면서 같이 관리되기가 어렵습니다. 그래서 문서 역시 형상관리가 필요하겠다고 느꼈고 이것을 위한 git repository를 생성하여 그곳에서 설정문서의 버전을 관리하는 전력입니다.

![](https://velog.velcdn.com/images/253eosam/post/591c87ce-5f15-4317-9cac-1022b63d8137/image.png)

SCM을 polling 하기위한 트리거 설정을 켜고, github repository에서 해당 scm으로 hook을 보내도록 설정합니다.

_github repository > setting > hooks_

훅을 설정할땐 `http://{jenkins domain, https라면 https로 작성}/github-webhook/`을 payload URL에 설정해줘야합니다.

*   Payload URL : `http://{jenkins domain, https라면 https로 작성}/github-webhook/`
*   Content type : `application/x-www-form-urlencoded`
*   Secret: (empty)
*   SSL verification : `Enable SSL verification`
*   Which events would you like to trigger this webhook? : `Just the push event.`
*   Active: `checked`

`Add webhook`

이렇게 설정을 끝내고나면 간단하게 테스트를 해볼 수 있습니다.

### 동작 테스트

빈 커밋을 등록하고 깃으로 push하여 push event가 동작하도록 하였습니다.

```bash
$ git commit --allow-empty -m "test jenkins webhook trigger" & git push
```

성공적으로 remote에 push가 되면 jenkins가 이것을 감지하고 build되는 것을 확인 할 수 있습니다.

### 문제점 개선하기

저희팀 환경에서는 한가지 문제가 있었습니다. 그것은 scm을 통해 trigger가 동작하기 때문에 pusher가 (SCM Change)로 로그가 남는 것이였습니다.

이 문제를 해결하기위해 다른 설정을 통해 trigger가 동작하도록 하였습니다.

#### generic-webhook-trigger 사용하기

> **generic-webhook-trigger란?**  
> 특정 시스템에 종속적이지 않고 **모든 종류의 웹훅을 받을 수 있도록** 만들이전 설정입니다.

generic-webhook-trigger은 post content paramerters와 request paramerters 설정을 통해 필요한 정보를 넘길 수 있습니다.

*   post content parameter : WebHook으로 받은 JSON Payload에서 내가 필요한 부분만 뽑아서, Jenkins 빌드 파라미터로 넘길때 사용
*   request parameters : URL의 query string을 받아서 Jenkins의 파라미터로 사용

**webhook post payload**

```json
{
  "ref": "refs/heads/main",
  "repository": {
    "name": "example-repo"
  },
  "pusher": {
    "name": "sungjun-lee"
  }
}
```

*   ref : 브랜치명
*   repository.name : 저장소 이름
*   pusher.name : 푸시한 사람

이 설정을 jenkins task config에 추가하고, github webhook 설정을 변경해야하합니다.

*   Payload URL : `http://{jenkins domain, https라면 https로 작성}/generic-webhook-trigger/invoke?token={generic-webhook-trigger token}`
*   Content Type : `application/json`

이 설정 후 테스트를 진행해보니 정상적으로 trigger가 동작하고 pusher 역시 정상적으로 노출되는것을 확인 할 수 있습니다.