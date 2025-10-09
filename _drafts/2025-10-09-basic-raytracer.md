---
title: Basic Raytracer in C++
background: /assets/posts/2025/basic-raytracer/background.jpg
tags: ["Raytracing", "C++", "Computer Graphics"]
---

Computer graphics has always felt like a magic to me, which I was distantly approaching from different sides, yet haven't been getting close enough to. Once I've realized my interest in it, I wanted to find something to start with to satisfy my curiosity, yet to not be overwhelming and steep to learn.

So I've found a book [Computer Graphics from Scratch](https://gabrielgambetta.com/computer-graphics-from-scratch), which gives a nice introduction into the area starting with the basic Raytracing problems and a Linear Algebra required for it. What I especially liked about it, is that the implementation doesn't depend on any external libraries. The book has JavaScript sample code to demonstrate algorithms by drawing the results on the HTML Canvas. The raytracing part of the book ends with a exercises and ideas for the reader to experiment with.

Here I'll share what I've learnt from the book and how I've implemented the raytacing exercises.

### The Basics

Following the first chapters of the book is pretty straightforward - we're starting with basics.
First it describes a very high-level raytracing algorithm we'll be implementing, and introduces basic components like canvas, viewport and camera.
* **Canvas** is a grid of pixels on which we'll be drawing colors of the world we observe through the viewport.
* **Viewport** can be thought of as a window into the world.
* **Camera** is a position from which we're observing the world in a particular direction.
* **Field of View** (FOV) depends on how close the camera is to the viewport and/or how big the viewport is.

Next we figure out how to map pixels on the canvas to a viewport points, and then the magic starts.
In real life the light is first emmitted from the light source and then it travels into our eyes, while reflecting from the objects.
However when tracing rays, this process is reversed - we emit rays of light from the camera, going through a viewport until they hit the objects.

![basic scene with camera, viewport and an object](/assets/posts/2025/basic-raytracer/basics.jpg)
_basic scene with camera, viewport and an object_

### Project Setup

I've decided to go with C++ while following the book examples and extending it with my own implementation.
To match the simplicity of the examples in the book, I'm also avoiding any external libraries.
When it came to showing the results, I thought why bother drawing them on the screen - maybe a BMP image would be quite straightforward to implement instead, [and it actually is](https://github.com/a-voronov/computer-graphics-from-scratch/blob/main/examples/bmp.h) `:)`

Whole Raytracer implementation can be found on my [Github](https://github.com/a-voronov/computer-graphics-from-scratch) split into separate chapters to follow the progress.

### Tracing Rays

Now after we setup the project and our scene is ready, we'll drop a few objects in it, and you guessed it, it's gonna be spheres!
Once we emit a ray, the tracing algorithm goes through each object in the scene and calculates the intersection between the ray and the object.
We emit a ray for every pixel on the canvas starting from the camera position since we're not interested in the objects behind the camera.
The first result just shows the colors of the objects (green, red, blue and yellow spheres), so they look pretty flat.

![basic raytracing](/assets/posts/2025/basic-raytracer/basic-raytracing.jpg)
_[basic raytracing](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/01-basic-raytracing.bmp)_

### Lights and Shadows

We improve it by first introducing a concept of light and defining three sources:
- **Point light** has a position in 3D space, emits light equally in every direction.
- **Directional light** has no position, emits light in a single direction.
- **Ambient light** contributes some light to every point in the scene.

These sources of light are designed to resemble a very simplified version of how light works in the real world, however it is good enough to create an illusion which can be computed with nowadays hardware.

Next we need to specify how these lights interact with the objects in our scene.
For simplicity, we classify objects into _**matte**_ and _**shiny**_ ones, which sets the way they reflect the lights.

- **Diffuse Reflection** - a process of scattering of light from a matte surface in many directions.
- **Specular Reflection** - mirror-like reflection of light from a shiny surface, where light rays reflect at the same angle they hit the surface.

We apply both diffuse and specular reflection to the objects by specifying their _specular exponent_.

Now that we have lights, we should have shadows to make scene look more realistic.
**Shadow** basically means a spot where a light couldn't reach because of another object in the way.
Since we've agreed to have ambient light everywhere in the scene, shadows will be affecting directional and point lights.
The algorithm is pretty simple - before calculating the lighting of the object we check if there's any obstructing object in front of it following a direction of light.
And if there's one, then we don't proceed with lighting calculations.

This is the first time we've made objects interact with each other and result looks quite impressive, given that we're mostly relying on a few vector operations!

![diffuse reflection, specular reflection, shadows](/assets/posts/2025/basic-raytracer/lights-and-shadows.jpg)
_[diffuse reflection](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/02-diffuse-reflection.bmp) > [specular reflection](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/03-specular-reflection.bmp) > [shadows](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/04-shadows.bmp)_

### Reflections

Now that we have shiny objects and objects interacting with each other, we can implement a proper reflection.
For that we'll need to add a new property to specify how much reflective objects are, in a range 0...1.
And in order to implement the way we trace a ray when it hits a reflective surface, we need to calculate the mirrored vector and trace the ray recursively.
However recursion should stop at some point, and we need a way to exit it in case our ray is stuck between reflective surfaces. So we introduce a number of recursive raytracing operations we can do before we stop. Finally, a reflective surface can have its own color, so we blend these colors by computing weighted average of the surface color and reflected color.

...

And honestly I'm impressed - the whole implementation so far takes less than 300 loc.

![shadow acne, clipped colors, final reflections](/assets/posts/2025/basic-raytracer/reflections-issues.jpg)
_[shadow acne](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/05-shadow-acne.bmp) > [clipped colors](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/05-old-colors.bmp) > [final reflections](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/05-reflections.bmp)_

### Links

- [Computer Graphics from Scratch](https://gabrielgambetta.com/computer-graphics-from-scratch)
- [My Implementation on Github](https://github.com/a-voronov/computer-graphics-from-scratch)