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

Now that's where I started experiencing differences from the original implementation.
First is appearance of a _**shadow acne**_ artefact after adding a reflections implementation.
And you can see it's mostly happening on the big yellow sphere because it looks almost flat, and the rays could be bouncing off the surface and recursively hitting it again caused by a floating point error. You see, since JS is used for the books examples, it has double-precision numbers, while I'm using a single-precision float in my C++ implementation, which can be more sensitive to small floating point errors. To fix it, I introduced a small epsilon margin every time we recursively trace a ray to calculate reflections, so that the ray would originate slightly above the surface.

Another thing I've noticed was light reflections on the green and red spheres were slightly different in my implementation.
The reason for that was that I was using `uint8_t` to represent the color values with 0...255 range which seemed quite logical to me in the beginning.
However it didn't produce the same smooth gradients sometimes, so I switched to `float` with 0...1 range and the issue was fixed, because the colors wouldn't get clamped during computations until we need to render the final result.

And honestly I'm impressed - the whole implementation so far takes less than 300 loc, and runs in 50 ms on my machine.

![shadow acne, clamped colors, final reflections](/assets/posts/2025/basic-raytracer/reflections-issues.jpg)
_[shadow acne](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/05-shadow-acne.bmp) > [clamped colors](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/05-old-colors.bmp) > [final reflections](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/05-reflections.bmp)_

---

{: .text-center}
## Extending the Raytracer

Here starts the fun part where we're on our own. There're few ideas/exercises in the book for us to implement, so we can extend our Raytracer with more features and think of a few optimization techniques. However my goal is not to squeeze the performance out of it, but rather to learn, observe and play around. So far it's all running on a CPU in a single thread `:)`

### Subsampling

One way to optimize performance is by using a subsampling the scene. It's a tradeoff - we can trace less rays to save computation costs but in return we'll need to interpolate the missing colors based on the neighbors which might not end up in a crispy result. I decided to skip every other row and column when tracing rays and then simply come up with an average color between the known neighbors.

During _**interpolation**_ I will start with an offset and also skip every other row and column so I can visit missing colors. You can image being in the center `X` surrounded by known colors in the corners and having top, bottom, right, left and center colors empty for now. In our algorithm we're moving from the bottom left corner to the top right corner when iterating through the image. So in order to not calculate same colors twice, we only need to interpolate left, bottom and center colors on every interation and only when we hit the borders of the image we'll do the top and right ones. Left color is based on its top and bottom neighbors, bottom color is based on its left and right neighbors, and center color is based on its four corner neighbors. Colors are mixed by simply getting an average color.

```
┌─────┐   ┌─────┐     ┌─────┐   ┌─────┐
│■ □ ■│   │■ □ ■│     │■ □ ■│   │■ □ ■│
│□ X □│ > │■ ■ □│ ==> │□ X □│ > │■ ■ □│ ==> ...
│■ □ ■│   │■ ■ ■│     │■ □ ■│   │■ ■ ■│
└─────┘   └─────┘     └─────┘   └─────┘
```

So the results on my machine are following - before subsamplingit it took ~52ms and after subsampling it takes ~22ms, which is not 4x but still quite a speed-up!

![sampling, interpolation](/assets/posts/2025/basic-raytracer/subsampling.png)
_[sampling + interpolation](https://raw.githubusercontent.com/a-voronov/computer-graphics-from-scratch/refs/heads/main/results/07-optimizations-subsampling.bmp)_

### Bounding Volume Hierarchy

Right now, in order to check if a ray intersects with an object, we need to go through all the objects in the scene for each ray and calculate whether they intersect while figuring out the closest of them to the camera. It sounds like a lot of work especially when there're hundreds or thousands of objects in the scene.

Imagine if we could divide our scene into zones which would group the objects that spatially belong there, and instead of traversing every single object, we would travers zones first. If a ray hits one of the zones, then we can only check the objects inside of it. It sounds like a drastic improvement if for 1000 of objects we have i.e. 10 zones, where each has ~100 objects. Of course we can go deeper and divide those zones further and further. And it looks like a tree data structure would fit well here, which is in fact called a _**bounding volume hierarchy tree (BVH Tree)**_.

In order to build such a tree, we first need to feed it the objects from the scene. It will create a box which perfectly fits those objects so that it becomes easier to compute whether the ray even hits the area with objects. Then it starts splitting the box into smaller boxes by the longest axis (x, y or z). The box is called an _**axis-aligned bounding box (AABB)**_. The objects get sorted by their centroids on the splitting axis, then divided in half and are moved to the left and right sub-boxes (BVH tree nodes). The process repeats until we either hit the limit of splitting levels or the minimum amount of objects per AABB.

Figuring out the ray intersection is relatively simple. We first check if the ray hits a root AABB of the tree, then we go deeper into nodes of the tree by checking their AABBs intersections until we actually hit leaf nodes. Inside the leaf node we check for an intersection with its AABB and its objects by figuring out the closest one. Since we were always halving the nodes, there's always left and right child node, so if both of them have been intersected by a ray, then we compare which of their hit objects is closer to the camera and return it as a result. You can imagine there might be as well only one leaf's object hit or even none at all.

![bounding volume hierarchy tree](/assets/posts/2025/basic-raytracer/bvh.jpg)
_[bounding volume hierarchy tree](https://github.com/a-voronov/computer-graphics-from-scratch/blob/main/examples/bvh.h)_

Implementing it in C++ was more or less straightforward. This whole time we were working with spheres only, however next exercise encourages us to implement another shape. Which is why I've introduced an `Object` abstraction and a `HitInfo` structure which contains necessary info to render the object hit by ray. As per ownership, scene is the owner of both - the BVH tree via a `unique_ptr` and the objects as a `vector<unique_ptr<Object>>`, while the tree references objects through `const Object*`.

### Triangles

...

### Constructive Solid Geometry

...

### Transparency

...

---

## Links

- [Computer Graphics from Scratch](https://gabrielgambetta.com/computer-graphics-from-scratch)
- [My Implementation on Github](https://github.com/a-voronov/computer-graphics-from-scratch)