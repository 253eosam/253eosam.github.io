---
layout: home
title: Home
permalink: /
---
<script>
function openCity(evt, selected) {
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
  evt.currentTarget.className += " active";
}
</script>

<div class="home">
  <!-- Tab links -->
  <div class="tab">
    <button class="tablinks active" onclick="openCity(event, 'home-post')">최신글</button>
    <button class="tablinks" onclick="openCity(event, 'home-category')">카테고리</button>
    <button class="tablinks" onclick="openCity(event, 'home-tag')">태그</button>
  </div>

  <div id="home-post" style="display: block;" class="tabcontent">
    <ul>
      {% for post in site.posts %}
        {% assign last_posts = site[collection.label] %}
        <li><a style="overflow: hidden" href="{{ post.url }}">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a></li>
      {% endfor %}
    </ul>
  </div>

  <!-- Tab content -->
  <div id="home-category" class="tabcontent">
    {% for category in site.categories %}
      <span>{{ category[0] }}</span>
      <ul>
        {% for post in category[1] %}
        <li><a style="overflow: hidden" href="{{ post.url }}">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a></li>
        {% endfor %}
      </ul>
    {% endfor %}
  </div>

  <div id="home-tag" class="tabcontent">
    {% for tag in site.tags %}
      <span class="subtitle">{{ tag[0] }}</span>
      <ul>
        {% for post in tag[1] %}
        <li><a style="overflow: hidden" href="{{ post.url }}">{{ post.title }} <span style="float: right;">{{ post.date | date: "%Y-%m-%d" }}</span></a></li>
        {% endfor %}
      </ul>
    {% endfor %}
  </div>

</div>
