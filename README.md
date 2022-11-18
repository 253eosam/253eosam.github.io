---
layout: home
title: Home
permalink: /
---

<script>
(() => {
  console.log(
    "hash" , location.hash
  )
  openCity(location.hash.slice(1))
})()

function openCity(selected) {
  // Declare all variables
  var i, tabcontent, tablinks;

  // Get all elements with class="tabcontent" and hide them
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }

  // Get all elements with class="tablinks" and remove the class "active"
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  // Show the current tab, and add an "active" class to the button that opened the tab
  
  document.getElementById(selected).style.display = "block";
  document.querySelector(`.${selected}`).className += " active";
}
</script>

<div class="home">
  <!-- Tab links -->
  <div class="tab">
    <button class="home-post-btn tablinks active" onclick="openCity('home-post')">최신글</button>
    <button class="home-category tablinks" onclick="openCity('home-category')">카테고리</button>
    <button class="home-tag tablinks" onclick="openCity('home-tag')">태그</button>
  </div>

  <div id="home-post" style="display: block;" class="tabcontent">
    <ul>
      {% for post in site.posts %}
        <li>
          <div style="overflow: hidden;">
            {% if post.link %}
              <a href="{{post.link}}" class="link">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a>
            {% else %}
              <a href="{{ post.url }}" style="color: #364149;">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a>
            {% endif %}
          </div>
        </li>
      {% endfor %}
    </ul>
  </div>

  <!-- Tab content -->
  <div id="home-category" class="tabcontent">
    {% for category in site.categories %}
      <h5>{{ category[0] }}</h5>
      <ul>
        {% for post in category[1] %}
        <li>
          <div style="overflow: hidden;">
            {% if post.link %}
              <a href="{{post.link}}" class="link">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a>
            {% else %}
              <a href="{{ post.url }}" style="color: #364149;">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a>
            {% endif %}
          </div>
        </li>
        {% endfor %}
      </ul>
    {% endfor %}
  </div>

  <div id="home-tag" class="tabcontent">
    {% for tag in site.tags %}
      <h5 class="subtitle">{{ tag[0] }}</h5>
      <ul>
        {% for post in tag[1] %}
        <li>
          <div style="overflow: hidden;">
            {% if post.link %}
              <a href="{{post.link}}" class="link">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a>
            {% else %}
              <a href="{{ post.url }}" style="color: #364149;">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a>
            {% endif %}
          </div>
        </li>
        {% endfor %}
      </ul>
    {% endfor %}
  </div>

</div>
