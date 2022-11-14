---
layout: home
title: Home
permalink: /
---

<div class="home" style="display: flex;">

  <div style="flex: 1;">
    <h2> 카테고리 </h2>
    {% for category in site.categories %}
      <details open>
        <summary style="cursor: pointer;"><h3 > {{ category[0] }}</h3></summary>
        <ul>
          {% for post in category[1] %}
            <li><a href="{{ post.url }}">{{ post.title }}</a></li>
          {% endfor %}
        </ul>
      </details>
    {% endfor %}
  </div>
  
  <div style="flex: 1;">
    <h2> 태그 </h2>
    {% for tag in site.tags %}
      <details open>
        <summary style="cursor: pointer;"><h3>{{ tag[0] }}</h3></summary>
        <ul>
          {% for post in tag[1] %}
            <li><a href="{{ post.url }}">{{ post.title }}</a></li>
          {% endfor %}
        </ul>
      </details>
    {% endfor %}
  </div>

</div>
