package;

import kha.Assets;
import kha.Color;
import kha.FastFloat;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.graphics4.ConstantLocation;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexData;
import kha.graphics4.VertexStructure;
import kha.Image;
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
	
	public static var backbuffer:Image;

	public static var blueBalls:Array<Ball> = new Array<Ball>();
	public static var redBall:Ball = new Ball();
	public static var player:Player = new Player();
	
	public static var score:UInt = 0;
	public static var hiscore:UInt = 0;
	
	static var _playing:Bool = false;
	
	static var _pipeline:PipelineState;
	static var _uTimeLoc:ConstantLocation;
	static var _uPlayerXLoc:ConstantLocation;

	public static function main() {
		// Init Kha.
		System.init(
			{ 
				title: "Ball Avoider",
				width: width,
				height: height 
			},
			function() Assets.loadEverything(onAssetsLoaded) // When the initialization is complete, load all assets.
		);
	}
	
	//
	
	public static function startGame():Void {
		score = 0;
		redBall.spawn(true);
		_playing = true;
	}
	
	public static function scoreUp():Void {
		score++;
		if (score > hiscore) hiscore = score;
		
		redBall.spawn(true);
		spawnBlueBall();
	}
	
	public static function gameOver():Void {
		_playing = false;
		for (ball in blueBalls) ball.active = false; // Set all blue balls to be waiting for recycling.
	}
	
	public static function spawnBlueBall():Void {
		// Find an inactive ball.
		for (ball in blueBalls) {
			if (!ball.active) {
				ball.spawn(false);
				return;
			}
		}
		
		// If there is no inactive ball, create a new one.
		var ball = new Ball();
		ball.spawn(false);
		blueBalls.push(ball);
	}
	
	// Get called when all assets are loaded.
	static function onAssetsLoaded():Void {
		// We set listener for rendering.
		System.notifyOnRender(onRender);
		
		// We want onUpdate to be called 60 times per second because 60fps master race!
		Scheduler.addTimeTask(onUpdate, 0, 1 / 60);
		
		// We set listeners for mouse down and mouse move events.
		Mouse.get().notify(onMouseDown, null, onMouseMove, null);
		
		// Everything will be rendered on this backbuffer then the backbuffer will be rendered to the framebuffer.
		// We do this to achieve ratio screen scaling as well as avoid artifacts like tearing, etc.
		backbuffer = Image.createRenderTarget(width, height);
		
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
	
	// Get called on every screen refresh. We do all of our rendering here.
	static function onRender(framebuffer:Framebuffer):Void {
		
		// Render everything on backbuffer.
		
		var g2 = backbuffer.g2;
		var g4 = backbuffer.g4;
		
		g2.begin();
		
		g2.pipeline = _pipeline;
		// Send uniform data to our shader. We use g4 for this.
		g4.setFloat(_uTimeLoc, System.time);
		g4.setFloat(_uPlayerXLoc, player.position.x + Player.size / 2);
		g2.fillRect(0, 0, width, height);
		g2.pipeline = null;
		
		g2.font = Assets.fonts.ClearSans_Regular;
		
		if (_playing) {
			for (ball in blueBalls) if (ball.active) ball.render(g2);
			redBall.render(g2);
			player.render(g2);
		} else {
			var str = "COLLECT RED BALL - AVOID BLUE BALLS";
			g2.color = 0xffffffff; // ARGB format.
			g2.fontSize = 40;
			g2.drawString(
				str, 
				(width - g2.font.width(g2.fontSize, str)) / 2,
				height / 2 - g2.font.height(g2.fontSize) - 4
			);
			
			str = "CLICK TO PLAY";
			g2.drawString(
				str, 
				(width - g2.font.width(g2.fontSize, str)) / 2,
				height / 2 + 8
			);
		}

		var str = 'SCORE: $score                HI-SCORE: $hiscore';
		g2.color = 0xffffffff;
		g2.fontSize = 40;
		g2.drawString(str, (width - g2.font.width(g2.fontSize, str)) / 2, 5);
		
		g2.end();
		
		// Render backbuffer to framebuffer.
		
		g2 = framebuffer.g2;
		g2.begin();
		
		
		var scaleX = framebuffer.width / width; // Get the width ratio.
		var scaleY = framebuffer.height / height; // Get the height ratio.
		var scale = scaleX < scaleY ? scaleX : scaleY; // Choose the smaller ratio for scaling.
		
		// Set transformation matrix. We scale backbuffer to screen size while keeping its ratio.
		g2.transformation = FastMatrix3.scale(scale, scale);
		g2.color = 0xffffffff;
		
		g2.drawImage(
			backbuffer, 
			// We center the backbuffer.
			(framebuffer.width - width * scale) / 2,
			(framebuffer.height - height * scale) / 2
		);
		
		g2.transformation = null;
		g2.end();
	}
	
	// We update our game logic here.
	static function onUpdate():Void {
		if (!_playing) return;
		
		for (ball in blueBalls) if (ball.active) ball.update();
		redBall.update();
	}
	
	// Hey, I'm hungry. :(
	// These comments are kinda unnecessary right? I know you know what all these do already.
	static function onMouseDown(button:Int, mouseX:Int, mouseY:Int):Void {
		if (!_playing) startGame();
	}
	
	static function onMouseMove(mouseX:Int, mouseY:Int, _, _):Void {
		if (!_playing) return;
		
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

class Ball {
	
	public static inline var gravity = 0.06;
	
	public var position:FastVector2;
	public var velocity:FastVector2;
	
	public var radius:FastFloat;
	public var color:Color;
	
	public var active:Bool; // This set to false means this ball is waiting to be recycled,
							// it will stop being rendered and updated. 
	
	public function new() {
		position = new FastVector2();
		velocity = new FastVector2();
	}
	
	public function render(g:Graphics):Void {
		g.color = color;
		g.drawCircle(position.x, position.y, radius, 5);
	}
	
	public function update():Void {
		velocity.y += gravity;
		
		position.x += velocity.x;
		position.y += velocity.y;

		if (overlapPlayer()) {
			if (color == 0xffff0000) { // This red ball hits player.
				Main.scoreUp();
				return;
			} else { // This blue ball hits player.
				Main.gameOver();
			}
		}
		
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
	
	public function spawn(red:Bool):Void {
		radius = 20 + 20 * Math.random(); // We set radius to be randomly between 20 and 40.
		
		position.x = radius + (Main.width - radius * 2) * Math.random();
		position.y = -radius;
		
		velocity.x = -3 + 6 * Math.random();
		velocity.y = 0;
		
		color = red ? 0xffff0000 : 0xff00ffff;
		
		active = true;
	}
	
	/**
	 * Check if this ball is hitting the player object.
	 */
	function overlapPlayer():Bool {
		var cx = Math.min(Math.max(Main.player.position.x, position.x), Main.player.position.x + Player.size);
		var cy = Math.min(Math.max(Main.player.position.y, position.y), Main.player.position.y + Player.size);

		var dx = position.x - cx;
		var dy = position.y - cy;

		var dsqrt = dx * dx + dy * dy;
		
		return dsqrt < radius * radius;
	}
	
}