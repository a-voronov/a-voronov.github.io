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

Next we have a `SampleRender` framework which defines the necessary abstractions and primitives for rendering. It uses the surface view to display the rendering results and handle `GLSurfaceView.Renderer` drawing requests. When surface view is configured with a renderer, it starts a background GL Thread where all rendering needs to happen.

And finally we have a `HelloArRenderer`. It implements `SampleRender.Renderer` requirements (which is basically an abstraction over `GLSurfaceView.Renderer`) and is delegated to handle the actual rendering logic. Under the hood it connects to a session to get updates, delegates rendering of the background, planes and objects, and applies lighting, which we will discuss soon.

![alt-text](/assets/posts/2025/arcore-sample/diagram.svg)

### SampleRender

Now let's look at `SampleRender` and what it consists of.

**BackgroundRenderer** is responsible for rendering camera feed as the background image. It applies background shaders and renders depth occlusion heat-map if depth API is supported by the device.

**PlaneRenderer** visualizes detected AR planes, renders grid overlays, and applies plane shaders.

Both of them are managed by `HelloArRenderer`.

{:.col-md-8 .mx-auto}
![alt-text](https://developers.google.com/static/ar/develop/depth/images/android-without-and-with-map.png){: .rounded}
_developers.google.com/ar/develop/depth_

**SpecularCubemapFilter** processes environmental lighting for realistic rendering.
It filters the environment cubemap provided by ARCore, generates mipmaps for different roughness levels, and supplies filtered cubemap to shaders for lighting calculations. It is used to give virtual objects more immersive look by applying real-world light reflection.

You can think of a cubemap as a cube (with camera in the center) unfolded into a flat 6-square-images texture.
And the reason it creates a mipmap (a set of blurred textures of the environment cubemap) is to simulate reflections at a different surface roughness. For clear and shiny surfaces a higher-resolution texture is used and for rougher surfaces the lower-resolution and blurrier one is used.
The approach is called physically based rendering (PBR).

{:.col-md-8 .mx-auto}
![alt-text](/assets/posts/2025/arcore-sample/cubemap.png)

Another PBR approach is used in `HelloArRenderer`, but to simulate diffuse (soft and ambient) reflections, and it's called Spherical Harmonics (SH).
Next to it they reference a [Filament engine](https://google.github.io/filament/Filament.html) to share more about the math behind it, and it's quite crazy. In the sample project, both cubemap filter and spherical harmonics coefficients are updated on every frame according to light estimates we're getting from the `ARCore.LightEstimate` data.

- ...
- Mesh
  - VertexBuffer
  - IndexBuffer
  - GpuBuffer
- Framebuffer
- Texture
- Shader

