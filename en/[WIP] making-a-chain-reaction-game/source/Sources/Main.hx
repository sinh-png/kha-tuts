package;

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
	
	static var circles:Array<Circle>;
	
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
		
		// We want onUpdate to be called 60 times per second because 60 FPS master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
	}
	
	static function onRender(framebuffer:Framebuffer):Void {
		
	}
	
	static function onUpdate():Void {
		
	}
	
}

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
