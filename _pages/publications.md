---
layout: page
permalink: /publications/
title: publications
description:
years: [2024, 2022]
nav: true
nav_order: 1
---
<!-- _pages/publications.md -->
<div class="publications">

<h1>Papers</h1>

{%- for y in page.years %}
  <h2 class="year">{{y}}</h2>
  {% bibliography -f papers -q @*[year={{y}},abbr!=Poster]* %}
{% endfor %}

<h1>Posters</h1>
  {% bibliography -f papers -q @*[abbr=Poster]* %}

<h1>Theses</h1>
  {% bibliography -f papers -q @*[abbr=MSc]* %}

</div>
