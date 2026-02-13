---
layout: post
title: Docker를 사용해서 간단한 로컬 DB 셋팅
categories: Develop
tags: [Docker, DB, MySQL]
---

## 목적

- 로컬 환경에서 Docker를 이용하여 간단하게 DB를 환경 셋팅
- 같은 포트에서 간단한 명령어를 통해 여러 버전, 다양한 DB를 관리하기 위함.
- 작은 프로젝트라 같은 서버에 (디비+ 백 + 프론트) 배포 할 목적, 미리 배포 환경을 셋팅 할 수 있음.

<br>

## 📖 스토리

회사 동기와 간단하게 프로젝트를 진행하게 되었다.

백엔드는 MySQL과 Spring을 이용하여 서버를 만들었고 간단한 미팅을 통해 DB모델링과 아키텍처를 설계하고 Back과 Front는 REST API를 통해 데이터를 주고 받으며 작업 공간을 분리하기로 하였다.

백엔드쪽에서 swagger가 완성되고 아직 배포 환경이 셋팅되지않아 직접 로컬에서 서버를 실행 시켜확인해야 했고, 이러한 광정에서 도커를 이용해서 간편하게 껏다 킬 수 있는 디비를 셋팅 해볼까한다.😁

<br>

## 설치 가이드

### 도커 설치

1. [Docker](https://www.notion.so/donaldd/Docker-2a385060554b429aac487405550d11fc#6676687b26554c0cbc00903dd4b2446b)를 설치한다.

2. 설치가 완료되면 기본적으로 튜토리얼을 실행시켜 사용하기 전 올바르게 설치되어있는지 확인할 수 있습니다. (선택)

   ![docker01](./images/placeholder.png)

   위 명령어를 통해 도커에서 제공하는 기본 스타트 프로젝트를 클론 받습니다.

   ![docker02](./images/placeholder.png)

   클론 받은 경로로 이동하여 도커 파일을 빌드합니다.

   빌드를 성공하면 도커 이미지가 생성됩니다.

   ![docker03](./images/placeholder.png)

   생성한 도커 이미지 파일을 80포트로 실행한다. 이렇게 되면 도커 컨테이너가 올라가게 된다. (접속가능)
   브라우저에 localhost로 접속해보면 아래와 같은 화면을 볼 수 있습니다. 😋

   아래와 같은 화면이 뜨면 도커가 올바르게 실행되고 있다는 뜻입니다.

   ![docker04](./images/placeholder.png)

   도커에는 도커 허브라는 이미지를 공유하는 커뮤니티 공간이 있는데 github과 비슷합니다.

   이 공간을 통해서 타사에서 제공하는 미리 셋팅된 이미지를 클론받아 빠르고 쉽게 환경을 구축 할 수 있습니다.

   또 자신만의 배포 환경이나 배포 버전을 관리하여 배포하고 싶은 서버에서 클론받아 실행시켜 편리하게 환경을 구축 할 수 있습니다.

   ![docker05](./images/placeholder.png)
   ![docker06](./images/placeholder.png)

## MySQL 컨테이너 실행

[MySQL](https://hub.docker.com/_/mysql)이 도커 허브에서 이미지를 공식적으로 제공합니다.

일단 원하는 DB와 버전을 확인합니다. 저는 `MySQL 5.7.30` 버전을 사용하기로 했습니다.
터미널을 열어 `docker pull mysql:tag` 명령어를 실행합니다 (tag에는 버전을 기입)

![docker](./images/placeholder.png)

pull을 성공적으로 했다면 mysql 이미지가 생겼을 것이다.
`docker images` 명령어를 통해 확인할 수 있습니다.

![docker](./images/placeholder.png)

이제 이미지를 통해 컨테이너를 생성하고 실행해보겠습니다.

컨테이너 생성은 이미지를 한번이라도 실행시키면 자동으로 생성됩니다. 이렇게 만들어진 컨테이너는 명령어를 통해 작동을 컨트롤 할 수 있습니다.

```bash
docker run -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234 --name to-do-noti-2007-db-mysql -v /Users/ddd/Documents/repository/To-do-list2007/DB:/var/lib/mysql mysql:5.7.30 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

- d: 백그라운드에서 실행
- p: 포트 설정
- e: 환경 변수 설정
- name: 컨테이너 이름
- v: 저장소를 마운트 (컨테이너를 삭제 시 데이터 복구가 힘들 것 같아서)
- 마지막은 실행 시킬 이미지와 버전 그리고 옵션을 추가해서 한글 입력이 가능하도록 만들었습니다.

명령어를 실행하면 이제 백그라운에서 mysql container를 실행합니다.
확인을 해보고 싶다면 `docker ps` 명령어를 입력해봅니다.

![docker](./images/placeholder.png)

> 혹시나 실행되지 않는다면 기존의 설치된 DB와 포트가 충돌했을 수 있습니다.

정상적으로 컨테이너가 실행되고 있는 것을 확인 할 수 있습니다.
해당 DB로 접속해 보겠습니다.

```bash
docker exec -it to-do-noti-2007-db-mysql bash
```

명령어를 통해 컨테이너의 bash로 접속합니다. 다음 `mysql -u root -p` 명령어를 통해 설치한 mysql로 접속합니다.

![docker](./images/placeholder.png)

## [심화] docker-compose로 관리

> docker-compose는 도커 파일 또는 컨테이너를 효율적으로 실행시키고 설정들을 문서화하여 관리 할 수 있습니다.

docker-compose.yml 파일을 만듭니다.

좋은 예제가 있어서 공유하겠습니다.

```yml
// docker-compose.yml

version: "3" # 파일 규격 버전
services: # 이 항목 밑에 실행하려는 컨테이너 들을 정의
db: # 서비스 명
    image: mysql:5.7.30 # 사용할 이미지
    container_name: 253eosam-todoNoti-mysql # 컨테이너 이름 설정
    ports:
    - "3306:3306" # 접근 포트 설정 (컨테이너 외부:컨테이너 내부)
    environment: # -e 옵션
    MYSQL_ROOT_PASSWORD: "1234"  # MYSQL 패스워드 설정 옵션
    command: # 명령어 실행
    - --character-set-server=utf8mb4
    - --collation-server=utf8mb4_unicode_ci
    volumes:
    - /Users/ddd/Documents/repository/To-do-list-noti2007/DB:/var/lib/mysql # -v 옵션 (다렉토리 마운트 설정)
```

실행 방법은 `docker-compose up -d` 입니다.
