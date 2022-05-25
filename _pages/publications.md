---
layout: page
permalink: /publications/
title: publications
description:
years: [2022]
nav: true
nav_order: 2
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>Conference Papers</h1>

{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}}]* %}
{% endfor %}

<h1>Theses</h1>

  <h2 class="year">2021</h2>
  {% bibliography -f papers -q @*[abbr=MSc]* %}

</div>
