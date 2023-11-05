package;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import gameObjects.hud.note.Note;

using StringTools;

class CoolUtil
{
	// general things
	inline public static function formatChar(char:String):String
	{
		return char.substring(0, char.lastIndexOf('-'));
	}

	inline public static function mouseOverlap(sprite:flixel.FlxSprite, cam:FlxCamera, ?limit:FlxPoint):Bool {
		if(limit != null)
			return (FlxG.mouse.getScreenPosition(cam).x > sprite.x && FlxG.mouse.getScreenPosition(cam).x < limit.x && FlxG.mouse.getScreenPosition(cam).y > sprite.y && FlxG.mouse.getScreenPosition(cam).y < limit.y);
		else
			return (FlxG.mouse.getScreenPosition(cam).x > sprite.x && FlxG.mouse.getScreenPosition(cam).x < sprite.x + sprite.width && FlxG.mouse.getScreenPosition(cam).y > sprite.y && FlxG.mouse.getScreenPosition(cam).y < sprite.y + sprite.height);
	}

	public static function colorFromArray(rgb:Array<Int>):FlxColor
	{
		return FlxColor.fromRGB(rgb[0], rgb[1], rgb[2], 255);
	}
	
	public static function getDiffs(?week:String):Array<String>
	{
		return switch(week)
		{
			default: ["normal", "mania"];
		}
	}

	public static function flash(camera:FlxCamera, ?duration:Float = 0.5, ?color:FlxColor) {

		if(SaveData.data.get("Flashing Lights") == "OFF") return;

		var color2:FlxColor = color;
		if(color == null)
			color2 = 0xFFFFFFFF;
		if(SaveData.data.get("Flashing Lights") == "REDUCED")
			color2.alphaFloat = 0.4;

		camera.flash(color2, duration, null, true);
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function charList():Array<String>
	{
		var list:Array<String> = [];

		#if !html5
		for (character in sys.FileSystem.readDirectory("assets/data/chars/"))
		{
			var path = haxe.io.Path.join(["assets/data/chars/", character]);
			if (!sys.FileSystem.isDirectory(path) && !list.contains(character) && character.endsWith(".json")) {
				var dat = character.split(".json");
				list.push(dat[0]);
			}
		}
		#end
		return list;
	}

	public static function coolTextFile(key:String):Array<String>
	{
		var daList:Array<String> = Paths.text(key).split('\n');

		for(i in 0...daList.length)
			daList[i] = daList[i].trim();

		return daList;
	}
	
	public static function posToTimer(mil:Float = 0, ?divisor:String = ":"):String
	{
		if(mil < 0) mil = 0;
		// gets song pos and makes a timer out of it
		var sec:Int = Math.floor(mil / 1000);
		var min:Int = Math.floor(sec / 60);
		
		function forceZero(shit:String):String
		{
			while(shit.length <= 1)
				shit = '0' + shit;
			return shit;
		}
		
		var disSec:String = '${sec % 60}';
		var disMin:String = '$min';
		disSec = forceZero(disSec);
		//disMin = forceZero(disMin);
		
		return '$disMin$divisor$disSec';
	}
	
	inline public static function intArray(end:Int, start:Int = 0):Array<Int>
	{
		if(start > end) {
			var oldStart = start;
			start = end;
			end = oldStart;
		}
		
		var result:Array<Int> = [];
		for(i in start...end + 1)
		{
			result.push(i);
		}
		return result;
	}
	
	// custom camera follow because default lerp is broken :(
	public static function dumbCamPosLerp(cam:flixel.FlxCamera, target:flixel.FlxObject, lerp:Float = 1)
	{
		cam.scroll.x = FlxMath.lerp(cam.scroll.x, target.x - FlxG.width / 2, lerp);
		cam.scroll.y = FlxMath.lerp(cam.scroll.y, target.y - FlxG.height/ 2, lerp);
	}
	
	// NOTE STUFF
	public static function getDirection(i:Int)
		return ["left", "down", "up", "right"][i];
	
	public static function noteWidth()
	{
		return (160 * 0.7); // 112
	}
	
	public static function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.songTime, Obj2.songTime);

	// music management stuff
	public static var curMusic:String = "none";
	public static function playMusic(?key:String, ?force:Bool = false, ?vol:Float = 1)
	{
		if (Paths.dumpExclusions.contains('music/' + curMusic + '.ogg'))
			Paths.dumpExclusions.remove  ('music/' + curMusic + '.ogg');

		if(key == null)
		{
			curMusic = "none";
			FlxG.sound.music.stop();
		}
		else if(key == "MENU")
		{
			var song:String = Main.possibleTitles[Main.randomized][1];
			Paths.dumpExclusions.push('music/' + song + '.ogg');

			if(curMusic != song || force)
			{
				curMusic = song;
				FlxG.sound.playMusic(Paths.music(song), vol);
				//FlxG.sound.music.loadEmbedded(Paths.music(key), true, false);
				FlxG.sound.music.play(true);
			}
		}
		else
		{
			Paths.dumpExclusions.push('music/' + key + '.ogg');

			if(curMusic != key || force)
			{
				curMusic = key;
				FlxG.sound.playMusic(Paths.music(key), vol);
				//FlxG.sound.music.loadEmbedded(Paths.music(key), true, false);
				FlxG.sound.music.play(true);
			}
		}
	}
}