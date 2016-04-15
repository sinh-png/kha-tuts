In this tutorial, we are going to make a game like this. Boring right? Please bear with me, step by step and one day we will be able to finish that project of ours about the next gen 100% science based WoW game.

Assume that you already know what [**Haxe**](http://haxe.org/) and [**Kha**](http://kha.tech) are, I will skip the boring introduction and sooner get us into the interesting part. 

If you yet to know how to get started with Kha, please check [this link](http://kha.tech/download) and [this link](https://github.com/KTXSoftware/Kha/wiki/Getting-Started).

Now let's us make this game together!

#####TABLE OF CONTENTS:

1. Set up our project.
2. Render a circle.
3. Turn circles into individual objects.

#####1. Set up our project:

In our [khafile.js](https://github.com/KTXSoftware/Kha/wiki/khafile.js):

```js
var project = new Project('Our Chain Reaction Game');

project.addAssets('Assets/**');
project.addSources('Sources');

// We set the game screen size when target Flash and HTML5.
project.windowOptions.width = 800;
project.windowOptions.height = 600;

return project;
```

Then in Main.hx:

```haxe
package;

import kha.System;

class Main {
	
	public static function main() {
		System.init( 
			{ 
				title: "Our Chain Reaction Game",
				width: 800, 
				height: 600 
			}
			,
			onInitComplete
		);
	}
	
	static function onInitComplete():Void {
		
	}
	
}
```

We init Kha with a title, a window size and a callback that will be called when the initialization is complete. The window size set here won't have any effect on HTML5 and Flash targets, instead we set it via khafile.js.

Let's try building and running our project in HTML5 and see if we have a webpage with the set up title. If things work as expected, we continue by adding the codes below:

```haxe
	static function onInitCompleted():Void {
		// Set the listener for our rendering loop.
		System.notifyOnRender(onRender);
		
		// We want onUpdate to be called 60 times a second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
	}
	
	static function onRender(framebuffer:Framebuffer):Void {
		
	}
	
	static function onUpdate():Void {
		
	}
	
}
```
It's as straight forward as it looks, we do our rendering in onRender and updating in onUpdate.

#####2. Render a circle:

Let's render a circle to make things more interesting.
```haxe
using kha.graphics2.GraphicsExtension;
```

I assume you already know what the code above means. If not, check this: http://haxe.org/manual/lf-static-extension.html

```haxe
static function onRender(framebuffer:Framebuffer):Void {
	var g = framebuffer.g2;
	g.begin();
	g.color = 0xff00ffff; // In ARGB format.
	g.fillCircle(400, 300, 80);
	g.end();
}
```

We render a filled aqua blue circle at the center of the screen with a radius of 80. g2 is an instance of `kha.graphics2`. So what is this `kha.graphics2`?

Here I copied from Kha wiki (https://github.com/KTXSoftware/Kha/wiki/kha.graphics2):

> kha.graphics2 is a 2D drawing API providing functions to draw images and basic forms and applying 2D transformations. On platforms which support kha.graphics4 graphics2 additionally provides support for custom shaders.

> The graphics2 API is intentionally designed to be similar to APIs like the html5 canvas API or the Java Painter API and maps efficiently to those. On more capable targets graphics2 runs on a very fast graphics4 based implementation.

> kha.graphics2 is available on all platforms.

So we use g2 to render 2D graphics onto a framebuffer or an image. g2 by default doesn't have the `fillCircle` method, the method we used actually is a static extension imported via  `using kha.graphics2.GraphicsExtension;`.

Here is the full source code we have so far:

```haxe
package;

import kha.Framebuffer;
import kha.input.Mouse;
import kha.Scheduler;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {
	
	public static function main() {
		System.init(
			{ 
				title: "Our Chain Reaction Game",
				width: 800, 
				height: 600 
			}
			,
			onInitComplete
		);
	}
	
	static function onInitComplete():Void {
		// Set the listener for rendering.
		System.notifyOnRender(onRender);
		
		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
	}
	
	static function onRender(framebuffer:Framebuffer):Void {
		var g = framebuffer.g2;
		g.begin();
		g.color = 0xff00ffff; // In ARGB format.
		g.fillCircle(400, 300, 80);
		g.end();
	}
	
	static function onUpdate():Void {
		
	}
	
}
```

Still not exciting enough, we need some action.

#####3. Turn circles into individual objects:

We are going to make more circles. Moving circles! Ah.. It still sounds kinda boring but please bear with me.

We create a class for our circles:

```haxe
class Circle {
	
	public static var circles:Array<Circle> = new Array<Circle>();
	
	public static function create(x:FastFloat, y:FastFloat, radius:Int, color:Color):Circle {
		var circle = new Circle(x, y, radius, color);
		
		for (i in circles.length) {
			if (circles[i] == null) {
				circle[i] = circle;
				return circle;
			}
		}
		
		circles.push(circle);
		return circle;
	}
	
	//
	
	public var position:FastVector2;
	public var velocity:FastVector2;
	
	public var radius:Int;
	public var color:Color;
	
	public inline function new(x:FastFloat, y:FastFloat, radius:Int, color:Color) {
		position = new FastVector2(x, y);
		velocity = new FastVector2(0, 0);
		
		this.radius = radius;
		this.color = color;
	}
	
	@:extern
	public inline function destroy():Void {
		circles[circles.indexOf(this)] = null;
	}
	
	@:extern
	public inline function render(g:Graphics):Void {
		g.color = color;
		g.fillCircle(position.x, position.y, radius);
	}
	
	@:extern
	public inline function update():Void {
		position.add(velocity);
	}
	
}
```

There are quite some explanations needed here:

+ [FastFloat](https://github.com/KTXSoftware/Kha/blob/master/Sources/kha/FastFloat.hx) is a typedef by Kha. When target C++, it is a typedef of cpp.Float32 which is faster than cpp.Float64 and if I am correct, Float when target C++ is Float64. Most of the time, Float32 is already more than enough for us.

+ Anything else with prefix "Fast" in Kha is probaly a type that uses FastFloat, for examples: FastVec2, FastMatrix3, etc.

+ Color is an abstract type of Kha used for... color, obviously.

+ The class has an inline constructor, if you don't know what this means, you can read about it here: http://haxe.org/manual/lf-inline-constructor.html

+ Our methods are declared with `:extern` metadata which forces them to be inline. You can read more about this here: http://haxe.org/manual/class-field-inline.html

+ For a serious project, I always use object pooling because I just can't trust myself with garbage collection but we won't do that in this tutorial. In this case, inlining the class helps us reduce our anxiety.

+ When we destroy a circle (removing it from the circles array), we set the value at its index to null instead of using `circles.remove()` because changing the lenght of an array in loop  

#####4. Mouse input:

```haxe
package;

import kha.Framebuffer;
import kha.input.Mouse;
import kha.Scheduler;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {
	
	public static function main() {
		System.init(
			{ 
				title: "Our Chain Reaction Game",
				width: 800, 
				height: 600 
			}
			,
			onInitComplete
		);
	}
	
	static function onInitComplete():Void {
		// Set the listener for rendering.
		System.notifyOnRender(onRender);
		
		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
		
		// Set our listener for mouse down event.
		Mouse.get().notify(onMouseDown);
	}
	
	static function onRender(framebuffer:Framebuffer):Void {
		var g = framebuffer.g2;
		g.begin();
		g.color = 0xff00ffff; // In ARGB format.
		g.fillCircle(400, 300, 80);
		g.end();
	}
	
	static function onUpdate():Void {
		
	}
	
	static function onMouseDown(button:Int, mouseX:Int, mouseY:Int):Void {
		
	}
	
}
```

Notice the lines we added into `onInitComplete`. `Via Mouse.get().notify()` we can set listeners for these 4 mouse events:
+ Mouse down / just pressed.
+ Mouse up / just released.
+ Mouse move.
+ Mouse wheel.

Here we only need the mouse down event. 
