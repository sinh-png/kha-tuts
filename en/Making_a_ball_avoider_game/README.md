
In this tutorial, we are going to make [this little game](http://melonin.github.io/kha-tuts/ball-avoider/)/

Assume that you already know what [**Haxe**](http://haxe.org/) and [**Kha**](http://kha.tech) are, I will skip the boring introduction so we can sooner get into the more interesting part. 

If you don't yet know how to get started with Kha, please check [this](http://kha.tech/download) and [this](https://github.com/KTXSoftware/Kha/wiki/Getting-Started).

Now let's us start making this game together!

1. [Set up our project.](https://github.com/hazagames/kha-tuts/tree/master/en/Making_a_ball_avoider_game#1-set-up-our-project)
2. [Draw a circle.](https://github.com/hazagames/kha-tuts/tree/master/en/Making_a_ball_avoider_game#2-draw-a-circle)
3. [Make some bouncing balls.](https://github.com/hazagames/kha-tuts/tree/master/en/Making_a_ball_avoider_game#3-make-some-bouncing-balls)
4. [Make a player object.](https://github.com/hazagames/kha-tuts/tree/master/en/Making_a_ball_avoider_game#4-make-a-player-object)
5. [Use shader to make our background.](https://github.com/hazagames/kha-tuts/tree/master/en/Making_a_ball_avoider_game#5-use-shader-to-make-our-background)

##### 1. Set up our project:

In our [khafile.js](https://github.com/KTXSoftware/Kha/wiki/khafile.js):

```js
var project = new Project('Our Game Title');

project.addAssets('Assets/**');
project.addSources('Sources');

// We set the game screen size when target Flash and HTML5.
project.windowOptions.width = 800;
project.windowOptions.height = 600;

return project;
```

Then in Sources/Main.hx:

```haxe
package;

import kha.Assets;
import kha.System;

class Main {

	public static inline var width = 800;
	public static inline var height = 600;

	public static function main() {
		System.init( 
			{ 
				title: "Our Game Title",
				width: width, 
				height: height 
			}
			,
			function() Assets.loadEverything(onAssetsLoaded) // When the initialization is complete, load all assets.
		);
	}

	// Get called when all assets are loaded.
	static function onAssetsLoaded():Void {

	}

}
```

We init Kha with a title, window size and a callback which when called will load all assets. The window size set here won't have any effect on HTML5 and Flash targets, instead we set it via khafile.js.

Let's try building our project targeting HTML5: ```node Kha/make.js html5```. We can now run it by executing ```node Kha/make.js --server``` and see if we have a webpage served at 127.0.0.1:8080 with our set up title.

##### 2. Draw a circle:

```haxe
	static function onAssetsLoaded():Void {
		// We set listener for rendering.
		System.notifyOnRender(onRender);

		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
	}

	static function onRender(framebuffer:Framebuffer):Void {

	}

	static function onUpdate():Void {

	}

}
```
It's as straight forward as it looks, we do our rendering in onRender and updating in onUpdate.

Let's render a circle to make things more interesting. Below the import statements and above the ```class Main``` declaration write
```haxe
using kha.graphics2.GraphicsExtension;
```

I you don't what `using` does, you can read about it [here](http://haxe.org/manual/lf-static-extension.html).

Start extending the ```onRender()``` function.
```haxe
static function onRender(framebuffer:Framebuffer):Void {
	var g = framebuffer.g2;
	g.begin();
	g.color = 0xff00ffff; // In ARGB format.
	g.fillCircle(400, 300, 80);
	g.end();
}
```

We render a filled aqua blue circle at the center of the screen with a radius of 80. g2 is an instance of `kha.graphics2.Graphics`. So what is this `kha.graphics2`?

Here from the article on [kha.graphics2](https://github.com/KTXSoftware/Kha/wiki/kha.graphics2) from the Kha wiki:

> kha.graphics2 is a 2D drawing API providing functions to draw images and basic forms and applying 2D transformations. On platforms which support kha.graphics4 graphics2 additionally provides support for custom shaders.

> The graphics2 API is intentionally designed to be similar to APIs like the html5 canvas API or the Java Painter API and maps efficiently to those. On more capable targets graphics2 runs on a very fast graphics4 based implementation.

> kha.graphics2 is available on all platforms.

So we use graphics2 to render 2D graphics onto a framebuffer or an image. By default, g2 doesn't have the `fillCircle` method, the method we used is actually a static extension imported via  `using kha.graphics2.GraphicsExtension;`.

The full source code we have so far:

```haxe
package;

import kha.Assets;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {

	public static inline var width = 800;
	public static inline var height = 600;

	public static function main() {
		System.init( 
			{ 
				title: "Our Game Title",
				width: width, 
				height: height 
			}
			,
			function() Assets.loadEverything(onAssetsLoaded) // When the initialization is complete, load all assets.
		);
	}

	// Get called when all assets are loaded.
	static function onAssetsLoaded():Void {
		// We set listener for rendering.
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

##### 3. Make some bouncing balls:

We create a class for our balls below ```class Main```:

```haxe
class Ball {
	
	public static inline var gravity = 0.06;
	
	public var position:FastVector2;
	public var velocity:FastVector2;
	
	public var radius:FastFloat;
	
	public function new() {
		position = new FastVector2(radius + (Main.width - radius * 2) * Math.random(), -radius);
		velocity = new FastVector2( -3 + 6 * Math.random(), 0);
		
		radius = 20 + 20 * Math.random();
	}
	
	public function render(g:Graphics):Void {
		g.color = 0xff00ffff;
		g.drawCircle(position.x, position.y, radius, 5);
	}
	
	public function update():Void {
		velocity.y += gravity;
		
		position.x += velocity.x;
		position.y += velocity.y;
		
		// Bounce back when hitting left or right edge. 
		if (
			(velocity.x > 0 && position.x > Main.width - radius) ||
			(velocity.x < 0 && position.x < radius)
		) {
			velocity.x *= -1;
		}
		
		// Bounce up when hitting the ground.
		if (velocity.y > 0 && position.y > Main.height - radius) {
			velocity.y = -radius / 5; // The bigger the ball, the higher it bounces.
		}
	}

}
```

[FastFloat](https://github.com/KTXSoftware/Kha/blob/master/Sources/kha/FastFloat.hx) is a Kha typedef. You can get it via ```import kha.FastFloat;```. When target C++, it is a typedef of cpp.Float32 which is faster than cpp.Float64 and if I am correct, Float when target C++ is Float64 while most of the time Float32 is more than enough for us. Anything else with prefix "Fast" in Kha is probaly a type that uses FastFloat, for examples: FastVector2, FastMatrix3, etc. They can be pulled in via ```import kha.math.FastVector2;``` and so on. For the function ```render()``` also add ```import kha.graphics2.Graphics;```.

In ```class Main``` add an array to store some balls, fill it, update their internal states and draw all of them. So let's see some bouncing balls in action: 

```haxe
package;

import kha.Assets;
import kha.Color;
import kha.FastFloat;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.math.FastVector2;
import kha.Scheduler;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {

	public static inline var width = 800;
	public static inline var height = 600;

	public static var balls:Array<Ball> = new Array<Ball>();

	public static function main() {
		System.init( 
			{ 
				title: "Our Game Title",
				width: width, 
				height: height 
			}
			,
			function() Assets.loadEverything(onAssetsLoaded) // When the initialization is complete, load all assets.
		);
	}

	// Get called when all assets are loaded.
	static function onAssetsLoaded():Void {
		// We set listener for rendering.
		System.notifyOnRender(onRender);

		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);

		for (i in 0...10) {
			balls.push(new Ball());
		}
	}

	static function onRender(framebuffer:Framebuffer):Void {
		var g = framebuffer.g2;
		g.begin();
		for (ball in balls) ball.render(g);
		g.end();
	}

	static function onUpdate():Void {
		for (ball in balls) ball.update();
	}

}


class Ball {

	public static inline var gravity = 0.06;

	public var position:FastVector2;
	public var velocity:FastVector2;

	public var radius:FastFloat;

	public function new() {
		radius = 20 + 20 * Math.random();

		position = new FastVector2(radius + (Main.width - radius * 2) * Math.random(), -radius);
		velocity = new FastVector2( -3 + 6 * Math.random(), 0);
	}

	public function render(g:Graphics):Void {
		g.color = 0xff00ffff;
		g.drawCircle(position.x, position.y, radius, 5);
	}

	public function update():Void {
		velocity.y += gravity;

		position.x += velocity.x;
		position.y += velocity.y;

		// Bounce back when hitting left or right edge. 
		if (
			(velocity.x > 0 && position.x > Main.width - radius) ||
			(velocity.x < 0 && position.x < radius)
		) {
			velocity.x *= -1;
		}

		// Bounce up when hitting the ground.
		if (velocity.y > 0 && position.y > Main.height - radius) {
			velocity.y = -radius / 5; // The bigger the ball, the higher it bounces.
		}
	}

}
```

##### 4. Make a player object:

Create a new class for a player:
```haxe
class Player {

	public static inline var size = 32;

	public var position:FastVector2;

	public function new() {
		position = new FastVector2((Main.width - size) / 2, Main.height - size);
	}

	public function render(g:Graphics):Void {
		g.color = 0xffff0000;
		g.drawRect(position.x, position.y, size, size, 5);
	}

}
```

Instanciate this class via ```public static var player:Player = new Player();``` in ```class Main``` along with the width and height of the screen. In ```onAssetsLoaded()``` add a listener for mouse events. Don't forget ```import kha.input.Mouse;```

```haxe
package;

import kha.Assets;
import kha.Color;
import kha.FastFloat;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.input.Mouse;
import kha.math.FastVector2;
import kha.Scheduler;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {

	public static inline var width = 800;
	public static inline var height = 600;

	public static var player:Player = new Player();

	public static function main() {
		System.init( 
			{ 
				title: "Our Game Title",
				width: width, 
				height: height 
			}
			,
			function() Assets.loadEverything(onAssetsLoaded) // When the initialization is complete, load all assets.
		);
	}

	// Get called when all assets are loaded.
	static function onAssetsLoaded():Void {
		// We set listener for rendering.
		System.notifyOnRender(onRender);

		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);

		// We set listener for mouse move event.
		Mouse.get().notify(null, null, onMouseMove, null);
	}

	static function onRender(framebuffer:Framebuffer):Void {
		var g = framebuffer.g2;
		g.begin();
		player.render(g);
		g.end();
	}

	static function onUpdate():Void {

	}

	static function onMouseMove(mouseX:Int, mouseY:Int, _, _):Void {
		player.position.x = mouseX - Player.size / 2;

		if (player.position.x < 0) {
			player.position.x = 0;
		} else if (player.position.x > width - Player.size) {
			player.position.x = width - Player.size; 
		}
	}

}

class Player {

	public static inline var size = 32;

	public var position:FastVector2;

	public function new() {
		position = new FastVector2((Main.width - size) / 2, Main.height - size);
	}

	public function render(g:Graphics):Void {
		g.color = 0xffff0000;
		g.drawRect(position.x, position.y, size, size, 5);
	}

}
```

Notice the changes in onAssetsLoaded. By using `Mouse.get().notify()` we can set listeners for these mouse events:
- Mouse down / just pressed.
- Mouse up / just released.
- Mouse move.
- Mouse wheel.

In the above example, we only use mouse move event to control our little square. Now you should try putting the balls and the player object together.

##### 5. Use shader to make our background:

Writing the game-play for this game is not very fun and specific about Kha so we will skip that for now and try out something cooler, shader.

In our khafile.js, we add `project.addShaders('Sources/Shaders/**');`:

```js
var project = new Project('Ball Avoider');

project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**');
project.addSources('Sources');

// We set the screen size when target Flash and HTML5.
project.windowOptions.width = 800;
project.windowOptions.height = 600;

return project;
```

Our fragment shader in GLSL, we save it as `grid.frag.glsl` in `Sources/Shaders/`:

```glsl
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform float playerX;

// Either kore() or main() is fine.
void main() {

	vec2 xy = gl_FragCoord.xy;
	xy.y = 600. - xy.y;

	if (mod(xy.x + playerX / 5., 20.) < 1. || mod(xy.y - floor(time * 100.), 20.) < 1.) {
		float d = distance(xy, vec2(playerX, 600.));
		gl_FragColor.r = .6 - d / 600.;
		gl_FragColor.g = sin(xy.x + xy.y) / 3.;
		gl_FragColor.b = .25 + sin(time / 5.) / 6.;
	}

}
```

Set up a [graphics pipeline](https://en.wikipedia.org/wiki/Graphics_pipeline) to use this shader. Import kha.Shaders, kha.graphics4.PipelineState and kha.graphics4.VertexStructure to create

```haxe
    static var _pipeline:PipelineState;
```

in ```class Main``` and in ```onAssetsLoaded()```

```haxe
		// Setting up our pipeline.
        _pipeline = new PipelineState();
        _pipeline.inputLayout = [new VertexStructure()];
        _pipeline.vertexShader = Shaders.painter_colored_vert; // A Kha built-in vertex shader.
        _pipeline.fragmentShader = Shaders.grid_frag;
        _pipeline.compile();
```

Adjust ```onRender()``` as shown below. Use kha.graphics4.ConstantLocation and
```haxe
    static var _uTimeLoc:ConstantLocation;
    static var _uPlayerXLoc:ConstantLocation;
```
to get uniform locations.

```haxe
package;

import kha.Assets;
import kha.Color;
import kha.FastFloat;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.graphics4.ConstantLocation;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexStructure;
import kha.input.Mouse;
import kha.math.FastMatrix3;
import kha.math.FastVector2;
import kha.Scheduler;
import kha.Shaders;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {
	
	public static inline var width = 800;
	public static inline var height = 600;
	
	public static var player:Player = new Player();
	
	static var _pipeline:PipelineState;
	static var _uTimeLoc:ConstantLocation;
	static var _uPlayerXLoc:ConstantLocation;
	
	public static function main() {
		System.init( 
			{ 
				title: "Our Game Title",
				width: width, 
				height: height 
			}
			,
			function() Assets.loadEverything(onAssetsLoaded) // When the initialization is complete, load all assets.
		);
	}
	
	// Get called when all assets are loaded.
	static function onAssetsLoaded():Void {
		// We set listener for rendering.
		System.notifyOnRender(onRender);
		
		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
		
		// We set listener for mouse move event.
		Mouse.get().notify(null, null, onMouseMove, null);
		
		// Setting up our pipeline.
		_pipeline = new PipelineState();
		_pipeline.inputLayout = [new VertexStructure()];
		_pipeline.vertexShader = Shaders.painter_colored_vert; // A Kha built-in vertex shader.
		_pipeline.fragmentShader = Shaders.grid_frag;
		_pipeline.compile();
		
		// Get the uniform locations.
		_uTimeLoc = _pipeline.getConstantLocation("time");
		_uPlayerXLoc = _pipeline.getConstantLocation("playerX");
	}
	
	static function onRender(framebuffer:Framebuffer):Void {
		var g2 = framebuffer.g2;
		var g4 = framebuffer.g4;
		
		g2.begin();
		
		g2.pipeline = _pipeline;
		
		// Send uniform data to our shader. We use g4 for this.
		g4.setFloat(_uTimeLoc, System.time);
		g4.setFloat(_uPlayerXLoc, player.position.x + Player.size / 2);
		
		g2.fillRect(0, 0, width, height);
		
		g2.pipeline = null;
		
		player.render(g2);
		
		g2.end();
	}
	
	static function onUpdate():Void {
		
	}
	
	static function onMouseMove(mouseX:Int, mouseY:Int, _, _):Void {
		player.position.x = mouseX - Player.size / 2;
		
		if (player.position.x < 0) {
			player.position.x = 0;
		} else if (player.position.x > width - Player.size) {
			player.position.x = width - Player.size; 
		}
	}
	
}

class Player {
	
	public static inline var size = 32;

	public var position:FastVector2;
	
	public function new() {
		position = new FastVector2((Main.width - size) / 2, Main.height - size);
	}
	
	public function render(g:Graphics):Void {
		g.color = 0xffff0000;
		g.drawRect(position.x, position.y, size, size, 5);
	}
	
}
```

You will have to run khamake again (eg: `node kha_path/make html5`) to compile our GLSL shader to GLSL ES, the same as when you make any change on assets. Talk about khamake, you can use `--help` to see a list of options.

The rest of this tutorial is in the [source](https://en.wikipedia.org/wiki/Graphics_pipeline) and its comments.

Happy Kha learning!
