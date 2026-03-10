---
title: 엑셀 파일 읽기
category: frontend
layout: post
tags: [ SheetJS, Excel ]
description: '서버에서 엑셀 파일을 읽어 데이터를 처리하는 방법을 정리한다.'
---

## 📖 스토리

서버측에서 엑셀 파일을 리드하여 원하는 작업을 수행하는 작업이 있었는데 엑셀 파일에 대량(5만개 정도)의 데이터보다 초과일때 response time이 예상보다 길어지는 이슈가 생겼습니다. 또 그 응답속도를 예측 할 수 없었기에 한정된 데이터의 크기만큼만 전송 가능하도록 하기로 했습니다.

> 프론트단에서 엑셀 파일을 리드하고 데이터 갯수를 카운팅하는 로직을 수행하고자합니다.

서버측 기술없이 클라이언트 기술로만 로컬에 저장된 엑셀 파일을 다룰 수 있는 라이브러리인 [SheetJS](https://github.com/SheetJS/sheetjs)를 사용하여 엑셀 파일을 읽는 방법을 JS코드로 정리해 봅니다.

해당 라이브러리는 별도로 다운로드 없이 CDN을 통해 이요할 수 있습니다.

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.15.5/xlsx.full.min.js"></script>
```

이번에 읽을 엑셀 파일 (행이 5만개 정도) ⬇️

![](https://velog.velcdn.com/images/253eosam/post/324f5486-5d21-4e3e-b3f4-7a8ebdd7f757/image.png)

## 비동기적 수행

### 코드

```html
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Read CSV File</title>
    <style>
      #input-box {
        display: inline-block;
        padding: 10px;
        border: 1px solid #ddd;
      }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.15.5/xlsx.full.min.js"></script>
  </head>
  <body>
    <div id="input-box">
      <input type="file" id="csv-file" onchange="readExcel()" />
    </div>

    <script>
      const readExcel = () => {
        const file = event.target.files[0]
        const reader = new FileReader()
        reader.onload = () => {
          const data = reader.result
          const workBook = XLSX.read(data, { type: 'binary' })
          workBook.SheetNames.forEach(sheetName => {
            console.log(`sheet name : ${sheetName}`)
            const row = XLSX.utils.sheet_to_json(workBook.Sheets[sheetName])
            console.log(row)
          })
        }
        reader.readAsBinaryString(file)
      }
    </script>
  </body>
</html>
```

### 출력

거의 5만개 이상의 행이 존재하는 파일로 실행해봤을때 0.2초 정도가 소요되는 퍼포먼스를 입니다.

![](https://velog.velcdn.com/images/253eosam/post/7a46463e-6c71-473d-9b83-89b9ead65130/image.png)

![](https://velog.velcdn.com/images/253eosam/post/bd0ce56b-5580-44f6-905c-96fc013daa93/image.png)

## 동기적 수행

`FileReader`의 경우 로직이 비동기로 수행되어 원하는 값을 원하는 타이밍에 `return` 받기가 곤란한 이슈가 발생했습니다. 따라서 이번에는 동기적으로 로직을 수행시켜 원하는 값을 받아내는 코드를 작성해 봅니다.

### 코드

```html
<!DOCTYPE html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Read CSV File</title>
    <style>
      #input-box {
        display: inline-block;
        padding: 10px;
        border: 1px solid #ddd;
      }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.15.5/xlsx.full.min.js"></script>
  </head>
  <body>
    <div id="input-box">
      <input type="file" id="csv-file" onchange="onChageFile()" />
      <span id="text"></span>
    </div>

    <script>
      const readExcel = () => {
        return new Promise((resolve, reject) => {
          const file = event.target.files[0]
          const reader = new FileReader()
          reader.onload = () =>
            resolve(
              (() => {
                const data = reader.result
                const workBook = XLSX.read(data, { type: 'binary' })
                return workBook.SheetNames.map(sheetName => {
                  const row = XLSX.utils.sheet_to_json(workBook.Sheets[sheetName])
                  return Object.entries(row).length
                })[0]
              })()
            )
          reader.onerror = reject
          reader.readAsBinaryString(file)
        })
      }
      const onChageFile = async () => {
        const size = await readExcel()
        document.getElementById('text').innerText = size
      }
    </script>
  </body>
</html>
```
