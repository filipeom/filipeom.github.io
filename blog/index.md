---
layout: base
page_title: Blog
---

<div class="post-list">
{% for post in posts %}
  <a href="{{ post.url }}" class="post-card">
  <div class="post-card-content">
    <h3 class="post-title">{{ post.page_title }}</h3>
    {% if post.summary %}
    <p class="post-description">{{ post.summary }}</p>
    {% endif %}
  </div>

  <div class="post-meta">
  {% if post.date %}
  <span class="post-date"><i class="far fa-calendar-alt"></i> {{ post.date }}</span>
  {% else %}
  <span class="post-date-placeholder">Recent Post</span>
  {% endif %}
  </div>
  </a>
{% endfor %}
</div>
