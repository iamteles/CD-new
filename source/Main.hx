package;

import data.*;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxGame;
import openfl.display.Sprite;
import data.FPSCounter;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import openfl.Lib;
import data.Discord.DiscordClient;

using StringTools;

class Main extends Sprite
{
	public static var fpsVar:FPSCounter;

	public function new()
	{
		super();
		#if desktop
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if DISCORD_RPC
		if (!DiscordClient.isInitialized) {
			DiscordClient.initialize();
			Application.current.window.onClose.add(function() {
				DiscordClient.shutdown();
			});
		}
		#end

		addChild(new FlxGame(1280, 720, Init, 120, 120, true));

		#if desktop
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		#end
	}

	public static var gFont:String = Paths.font("matsaleh.ttf");
	
	public static var skipClearMemory:Bool = false; // dont
	public static var skipTrans:Bool = true; // starts on but it turns false inside Init
	public static function switchState(?target:FlxState):Void
	{
		var trans = new GameTransition(false);
		trans.finishCallback = function()
		{
			if(target != null)		
				FlxG.switchState(target);
			else
				FlxG.resetState();
		};

		if(skipTrans)
		{
			return trans.finishCallback();
		}
		
		FlxG.state.openSubState(trans);
	}

	// so you dont have to type it every time
	public static function skipStuff(?ohreally:Bool = true):Void
	{
		skipClearMemory = ohreally;
		skipTrans = ohreally;
	}

	public static function changeFramerate(rawFps:Float = 120)
	{
		var newFps:Int = Math.floor(rawFps);

		if(newFps > FlxG.updateFramerate)
		{
			FlxG.updateFramerate = newFps;
			FlxG.drawFramerate   = newFps;
		}
		else
		{
			FlxG.drawFramerate   = newFps;
			FlxG.updateFramerate = newFps;
		}
	}

	#if desktop
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "DoidoEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "Uncaught Error: " + e.error + "\nPlease report this error to the developers! Crash Handler written by: sqirra-rng";

		if (!sys.FileSystem.exists("./crash/"))
			sys.FileSystem.createDirectory("./crash/");

		sys.io.File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}