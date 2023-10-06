package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import shaders.ColorSwap;
import states.PlayState;
import sys.io.File;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

typedef StageInfo =
{
	var objects:Array<StageObject>;
	var foreground:Array<StageObject>;

	var zoom:Null<Float>;
	var dadPos:Array<Float>;
	var bfPos:Array<Float>;
	var thirdPos:Array<Float>;
	var middle:Array<Float>;
}

typedef StageObject =
{
	var objName:Null<String>; // for the var/object name
	var path:Null<String>; // image path
	var animations:Null<Array<Animation>>;
	var position:Null<Array<Float>>; // position of the object
	var flipped:Null<Array<Bool>>; // whether object is flipped, on the X or Y axis
	var scale:Null<Float>; // sizer for object
	var alpha:Null<Float>; // alpha
	var scrollFactor:Null<Array<Int>>; // self explanatory i hope
	var height:Null<Bool>; // wether to subtract the objects height (like chars in playstate do)
}

typedef Animation =
{
	var name:String;
	var prefix:String;
	var framerate:Int;
	var looped:Bool;
}

class Stage extends FlxGroup
{
	public var curStage:String = "";
	public var stageData:StageInfo;

	public var bfPos:FlxPoint  = new FlxPoint();
	public var dadPos:FlxPoint = new FlxPoint();

	public var bfCam:FlxPoint  = new FlxPoint();
	public var dadCam:FlxPoint = new FlxPoint();

	public var thirdCam:FlxPoint  = new FlxPoint();
	public var thirdPos:FlxPoint = new FlxPoint();

	public var camMiddle:FlxPoint  = new FlxPoint();

	public var objectMap:Map<String, FlxSprite> = new Map<String, FlxSprite>();
	public var foreground:FlxGroup;

	var colorSwap:ColorSwap;

	public function new() {
		super();
		foreground = new FlxGroup();
		//colorSwap = new ColorSwap();
	}

	public function reloadStageFromSong(song:String = "test"):Void
	{
		switch(song) {
			case 'conservation':
				curStage = 'irritation';
			default:
				curStage = song;
		}
		reloadStage(curStage);
	}

	function loadFromJson() {
		//trace('Finish load.');

		if(stageData.zoom != null) 
			PlayState.defaultCamZoom = stageData.zoom;
		if(stageData.dadPos != null) {
			dadPos.x = stageData.dadPos[0];
			dadPos.y = stageData.dadPos[1];

			dadCam.x = stageData.dadPos[2];
			dadCam.y = stageData.dadPos[3];
		}

		if(stageData.bfPos != null) {
			bfPos.x = stageData.bfPos[0];
			bfPos.y = stageData.bfPos[1];

			bfCam.x = stageData.bfPos[2];
			bfCam.y = stageData.bfPos[3];
		}

		if(stageData.thirdPos != null) {
			thirdPos.x = stageData.thirdPos[0];
			thirdPos.y = stageData.thirdPos[1];

			thirdCam.x = stageData.thirdPos[2];
			thirdCam.y = stageData.thirdPos[3];
		}

		if(stageData.middle != null) {
			camMiddle.x = stageData.middle[0];
			camMiddle.y = stageData.middle[1];
		}

		if (stageData.objects != null)
		{
			for (object in stageData.objects)
			{
				var newSpr:FlxSprite = new FlxSprite(object.position[0], object.position[1]);

				if(object.animations != null) {
					newSpr.frames = Paths.getSparrowAtlas(object.path);
					for (anim in object.animations) {
						newSpr.animation.addByPrefix(anim.name, anim.prefix, anim.framerate, anim.looped);
					}
					newSpr.animation.play('idle');
				}
				else {
					newSpr.loadGraphic(Paths.image(object.path));
				}

				if (object.scale != null)
				{
					newSpr.setGraphicSize(Std.int(newSpr.width * object.scale));
					newSpr.updateHitbox();
					//trace('Scaled.');
				}

				if (object.alpha != null)
					newSpr.alpha = object.alpha;

				if(object.scrollFactor != null) {
					newSpr.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);
				}

				if (object.flipped != null)
				{
					newSpr.flipX = object.flipped[0];
					newSpr.flipY = object.flipped[1];
				}

				if(colorSwap != null) {
					newSpr.shader = colorSwap.shader;
				}

				objectMap.set(object.objName, newSpr);
				trace('added ' + object.objName);
				add(newSpr);
			}
		}

		if (stageData.foreground != null)
		{
			for (object in stageData.foreground)
			{
				var newSpr:FlxSprite = new FlxSprite(object.position[0], object.position[1]);
				
				if(object.animations != null) {
					newSpr.frames = Paths.getSparrowAtlas(object.path);
					for (anim in object.animations) {
						newSpr.animation.addByPrefix(anim.name, anim.prefix, anim.framerate, anim.looped);
					}
					newSpr.animation.play('idle');
				}
				else {
					newSpr.loadGraphic(Paths.image(object.path));
				}

				if (object.scale != null)
				{
					newSpr.setGraphicSize(Std.int(newSpr.width * object.scale));
					newSpr.updateHitbox();
					//trace('Scaled.');
				}

				if(object.height)
					newSpr.y -= newSpr.height;

				if (object.alpha != null)
					newSpr.alpha = object.alpha;

				if(object.scrollFactor != null) {
					newSpr.scrollFactor.set(object.scrollFactor[0], object.scrollFactor[1]);
				}

				if (object.flipped != null)
				{
					newSpr.flipX = object.flipped[0];
					newSpr.flipY = object.flipped[1];
				}

				if(colorSwap != null) {
					newSpr.shader = colorSwap.shader;
				}

				objectMap.set(object.objName, newSpr);
				foreground.add(newSpr);
			}
		}
	}

	public function reloadStage(curStage:String = "")
	{
		this.clear();
		foreground.clear();

		dadPos.set(50,700);
		bfPos.set(850,700);

		this.curStage = curStage;
		switch(curStage)
		{
			case 'stage':
				//lmao
			default:
				try
				{
					stageData = haxe.Json.parse(File.getContent('assets/data/stage/' + curStage + '.json').trim());
					loadFromJson();
				}
				catch (e)
				{
					trace('Uncaught Error: $e');
		
					reloadStage("stage");
				}
		}
	}

	public function stepHit(curStep:Int = -1)
	{
		// put your song stuff here
		
		// beat hit
		if(curStep % 4 == 0)
		{
			
		}
	}

	public function tweenStage(alpha:Float, time:Float) {
		for (obj in this) {
			FlxTween.tween(obj, {alpha: alpha}, time, {ease: FlxEase.expoOut});
		}
	}
	public function red(yeah:Bool = true) {
		if(yeah) {
			for(obj in this) {
				if(colorSwap != null) {
					colorSwap.hue = 140 / 360;
					colorSwap.saturation = 0 / 360;
					colorSwap.brightness = 0 / 360; //oops?
				}
			}
		}
		else {
			for(obj in this) {
				if(colorSwap != null) {
					colorSwap.hue = 0 / 360;
					colorSwap.saturation = 0 / 360;
					colorSwap.brightness = 0 / 360; //oops?
				}
			}
		}
	}
}