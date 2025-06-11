---
title: Android ARCore Sample
background: /assets/posts/2025/arcore-sample/background.jpg
tags: ["Android", "AR", "OpenGL"]
---

Recently I wanted to understand how to enable AR on Android. And the obvious solution was to use [ARCore](https://developers.google.com/ar/develop).
They have a seemingly good documentation with visual explanations, and [plenty of samples on Github](https://github.com/google-ar/arcore-android-sdk/tree/main/samples).

However unlike Apple, who are wrapping everything into their own interfaces,
which arguably makes learning curve more gradual, Google decided to expose all the low level details of interacting with ARCore and let you work straight with OpenGL from the day one.
For the sake of sample projects they're creating a [rendering framework](https://github.com/google-ar/arcore-android-sdk/tree/main/samples/hello_ar_kotlin/app/src/main/java/com/google/ar/core/examples/java/common/samplerender),
which interacts with [Android GLSurfaceView](https://developer.android.com/reference/android/opengl/GLSurfaceView).
It makes learning curve steeper but at the same time it gives more flexibility and creates a good opportunity to learn how rendering works which makes it even more fun!

Here we will try to understand the parts of the most basic `hello_ar` sample they're building, and how their rendering framework works.

### Sample Project Structure

Let's define a mental structure of the main project components.

It all starts with `HelloArActivity` and its main view which pretty much just holds a `GLSurfaceView`. It configures the `ARCore.Session` and hooks it to its lifecycle.

Next we have a `SampleRender` framework which defines the necessary abstractions and primitives for rendering. It uses the surface view to display the rendering results and handle `GLSurfaceView.Renderer` drawing requests.

And finally we have a `HelloArRenderer`. It implements `SampleRender.Renderer` requirements (which is basically an abstraction over `GLSurfaceView.Renderer`) and is delegated to handle the actual rendering logic. Under the hood it connects to a session to get updates, delegates rendering of the background, planes and objects, and applies lighting, which we will discuss soon.

![alt-text](/assets/posts/2025/arcore-sample/figure-1.svg)

### SampleRender

Now let's look at `SampleRender` and what it offers.
- BackgroundRenderer
- PlaneRenderer
- SpecularCubemapFilter
- Mesh
  - VertexBuffer
  - IndexBuffer
  - GpuBuffer
- Framebuffer
- Texture
- Shader

