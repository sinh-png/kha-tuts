package;

import kha.Canvas;
import kha.Color;
import kha.FastFloat;
import kha.Framebuffer;
import kha.input.Mouse;
import kha.math.FastVector2;
import kha.Scheduler;
import kha.System;

using kha.graphics2.GraphicsExtension;

class Main {
	
	public static function main() {
		System.init(
			{ 
				title: "Circle Avoider",
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
		
		// We want onUpdate to be called 60 times per second because 60 FPS master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
		
		for (i in 0...100) {
			var c = Ball.get(400, 300, 30, 0xff00ffff);
			c.velocity.x = Math.random() * 5;
			c.velocity.y = Math.random() * 5;
		}
	}
	
	static function onRender(framebuffer:Framebuffer):Void {
		Ball.renderCircles(framebuffer);
	}
	
	static function onUpdate():Void {
		Ball.updateCircles();
	}
	
}

class Ball {
	
	public static inline var gravity:FastFloat = 0.25;
	
	static var _balls:Array<Ball> = new Array<Ball>();

	/**
	 * Get a (new) ball.
	 */
	public static function get(x:FastFloat, y:FastFloat, radius:Int, color:Color):Ball {
		// Find an inactive ball and use it.
		for (circle in _balls) {
			if (!circle.active) {
				circle.position.x = x;
				circle.position.y = y;
				
				circle.radius = radius;
				circle.color = color;
				
				circle.active = true;
				
				return circle;
			}
		}
		
		// If there is no inactive ball, create a new one.
		var circle = new Ball(x, y, radius, color);
		_balls.push(circle);
		
		return circle;
	}
	
	/**
	 * Render all active circles.
	 * 
	 * @param	canvas		The canvas to render the balls onto.
	 */
	public inline static function renderCircles(canvas:Canvas):Void {
		for (ball in _balls) if (ball.active) ball.render(canvas);
	}
	
	/**
	 * Update all active balls.
	 */
	public inline static function updateCircles():Void {
		for (ball in _balls) if (ball.active) ball.update();
	}
	
	//
	
	public var position:FastVector2;
	public var velocity:FastVector2;
	
	public var radius:Int;
	public var color:Color;
	
	public var active:Bool;
	
	public function new(x:FastFloat, y:FastFloat, radius:Int, color:Color) {
		position = new FastVector2(x, y);
		velocity = new FastVector2(0, 0);
		
		this.radius = radius;
		this.color = color;
		
		active = true;
	}
	
	public function render(canvas:Canvas):Void {
		canvas.g2.color = color;
		canvas.g2.fillCircle(position.x, position.y, radius);
	}
	
	public function update():Void {
		velocity.y += gravity;
		
		position.x += velocity.x;
		position.y += velocity.y;
		
		if (
			(velocity.x > 0 && position.x > 800 - radius) ||
			(velocity.x < 0 && position.x < radius)
		) {
			velocity.x *= -1;
		}
		
		if (velocity.y > 0 && position.y > 600 - radius) {
			velocity.y = -40 * radius;
		}
	}
	
}
