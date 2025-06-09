---
title: Android ARCore Sample
background: /assets/posts/2025/arcore-sample/background.jpg
tags: ["Android", "AR", "OpenGL"]
---

Recently I wanted to understand how to enable AR on Android. And the obvious solution was to use [ARCore](https://developers.google.com/ar/develop).
They have a seemingly good documentation with visual explanations, and [plenty of samples on Github](https://github.com/google-ar/arcore-android-sdk/tree/main/samples).

However unlike Apple, who are wrapping everything into their own interfaces,
which arguably makes learning curve more gradual, Google decided to expose all the low level details of interacting with ARCore and let you work straight with OpenGL from the day one.
For the sake of sample projects they create a [rendering framework](https://github.com/google-ar/arcore-android-sdk/tree/main/samples/hello_ar_kotlin/app/src/main/java/com/google/ar/core/examples/java/common/samplerender) which interacts with [Android GLSurfaceView](https://developer.android.com/reference/android/opengl/GLSurfaceView).
It makes learning curve steeper but at the same time it creates a good opportunity to learn how rendering works which makes it even more fun!

Here we will try to understand the parts of the most basic `hello_ar` sample they build, and how their rendering framework works.
