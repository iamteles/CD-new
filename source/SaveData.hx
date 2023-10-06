package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import data.Highscore;

enum SettingType
{
	CHECKMARK;
	SELECTOR;
}

@:allow(flixel.util.FlxSharedObject)
class SaveData
{
	public static var data:Map<String, Dynamic> = [];
	public static var displaySettings:Map<String, Dynamic> = [
		"Ghost Tapping" => [
			true,
			CHECKMARK,
			"Makes you able to press keys freely without missing notes."
		],
		"Downscroll" => [
			false,
			CHECKMARK,
			"Makes the notes scroll down instead of up."
		],
		"Middlescroll" => [
			false,
			CHECKMARK,
			"Moves your notes to the center of the screen and hides the opponent's."
		],
		"Antialiasing" => [
			true,
			CHECKMARK,
			"Disables smoothing in scaling sprites. Might increase performance."
		],
		"Shaders" => [
			true,
			CHECKMARK,
			"Whether to display graphical shaders. Disabling them improves performance."
		],
		"Note Splashes" => [
			"ON",
			SELECTOR,
			"Whether a splash appear when you hit a note perfectly.",
			["ON", "PLAYER ONLY", "OFF"],
		],
		"Skin" => [
			"CD",
			SELECTOR,
			"Skins can be acquired in Watts' Shop!",
			["CD", "Tails.EXE", "The Funk Shack", "Mirror Life Crisis", "Classic", "Pixel Classic", "YLYL Reloaded", "FITDON", "Doido"],
		],
		"Ratings on HUD" => [
			false,
			CHECKMARK,
			"Makes the ratings stick on the HUD."
		],
		"Framerate Cap"	=> [
			120,
			SELECTOR,
			"How many frames appear on screen in a second.",
			[30, 360]
		],
		
		"Split Holds" => [
			false,
			CHECKMARK,
			"Cuts the end of each hold note like classic engines did."
		],
		"Smooth Healthbar" => [
			true,
			CHECKMARK,
			"Makes the healthbar move smoothly."
		],
		"Song Timer" => [
			true,
			CHECKMARK,
			"Whether the song timer appears or not."
		],
		
		"Cutscenes" => [
			"ON",
			SELECTOR,
			"Whether to play song cutscenes or dialogues.",
			["ON", "FREEPLAY OFF", "OFF"],
		],

		// this one doesnt actually appear at the regular options menu
		"Song Offset" => [
			0,
			[-500, 500]
		],
		"Preload Songs" => [
			true,
			CHECKMARK,
			"Whether to preload music for the Music Player."
		]
	];

	public static var progression:Map<String, Dynamic> = [
		"shopentrance" => false,
		"week2" => false,
		"week1" => false
	];
	public static var money:Int = 0;
	public static var shop:Map<String, Dynamic> = [];
	public static var displayShop:Map<String, Dynamic> = [
		"crown" => [
			false,
			"People say it transports you to a far away place. Probably junk."
		],
		"mic" => [
			false,
			"Some old thing. I have no use for it myself."
		],
		"ticket" => [
			false,
			"A ticket to a flavorfull festival. Didn't feel like going myself, schedule too busy."
		],
		"tails" => [
			false,
			"Its just a can of fake blood. I'm not sure why someone would want it."
		],
		"mlc" => [
			false,
			"Something to blow bubbles with. Very popular among sponges."
		],
		"base" => [
			false,
			"Previously owned by some soldier guy. I don't have actual children of my own."
		],
		"shack" => [
			false,
			"FYI, this is not a drink. Don't drink it. Seriously. I'm not trying to get sued."
		],
		"music" => [
			false,
			"An old disc with some banger tunes to listen. Favourite among collectors."
		],
		"gallery" => [
			false,
			"Makes you able to press keys freely without missing notes."
		],
		"mania" => [
			false,
			"Only for the biggest gamers. Not liable for any injures caused to your fingers."
		],
		"fitdon" => [
			false,
			"secret"
		],
		"ylyl" => [
			false,
			"secret"
		],
		"cd" => [
			true,
			"default"
		],
		"doido" => [
			true,
			"default"
		]
	];
	
	public static var saveFile:FlxSave;
	public static var progressionFile:FlxSave;

	public static var skinCodes:Array<String> = ["cd", "tails", "shack", "mlc", "base", "pixel", "ylyl", "fitdon", "doido"];
	public static function init()
	{
		saveFile = new FlxSave();
		saveFile.bind("settings",	"teles/CD"); // use these for settings

		progressionFile = new FlxSave();
		progressionFile.bind("progression",	"teles/CD");

		FlxG.save.bind("save-data", "teles/CD"); // these are for other stuff

		load();

		Controls.load();
		Highscore.load();
		
		// uhhh
		subStates.editors.ChartAutoSaveSubState.load();
	}
	
	public static function load()
	{
		if(saveFile.data.settings == null || Lambda.count(displaySettings) != Lambda.count(saveFile.data.settings))
		{
			for(key => values in displaySettings)
				data[key] = values[0];
			
			saveFile.data.settings = data;
		}

		if(progressionFile.data.money == null) {
			progressionFile.data.money = money;
		}

		if(progressionFile.data.money < 0)
			progressionFile.data.money = 0;

		
		if(progressionFile.data.shop == null)
		{
			trace("shop save null");
			for(key => values in displayShop)
				shop[key] = values[0];
			
			progressionFile.data.shop = shop;
		}

		if(progressionFile.data.progression == null)
		{
			progressionFile.data.progression = progression;
		}
		
		money = progressionFile.data.money;
		shop = progressionFile.data.shop;
		progression = progressionFile.data.progression;
		data = saveFile.data.settings;

		if(findMod("gameSettings", "fitdon"))
		{
			buyItem("fitdon");
			trace("found fitdon");
		}
		else {
			trace("not found fitdon");
		}

		save();
	}

	public static function findMod(file:String, localPath:String) {
		var directory = lime.system.System.applicationStorageDirectory;
		var path = haxe.io.Path.normalize('$directory/../../../$localPath') + "/";
		
		file = StringTools.replace(file, "//", "/");
		file = StringTools.replace(file, "//", "/");
		
		if (StringTools.startsWith(file, "/"))
		{
			file = file.substr(1);
		}
		
		if (StringTools.endsWith(file, "/"))
		{
			file = file.substring(0, file.length - 1);
		}
		
		if (file.indexOf("/") > -1)
		{
			var split = file.split("/");
			file = "";
			
			for (i in 0...(split.length - 1))
			{
				file += "#" + split[i] + "/";
			}
			
			file += split[split.length - 1];
		}

		var yeah = path + file + ".sol";
		return sys.FileSystem.exists(yeah);
	}
	
	public static function save()
	{
		saveFile.data.settings = data;
		saveFile.flush();

		progressionFile.data.money = money;
		progressionFile.data.shop = shop;
		progressionFile.data.progression = progression;
		progressionFile.flush();
		update();
	}

	public static function update()
	{
		Main.changeFramerate(data.get("Framerate Cap"));

		FlxSprite.defaultAntialiasing = data.get("Antialiasing");
	}

	public static function buyItem(item:String) {
		shop.set(item, true);
		save();
	}

	public static function transaction(ammt:Int) {
		money += ammt;
		if(money < 0)
			money = 0;
		save();
	}

	public static function skin():String {
		var string:String = "base";
		var curMain:String = data.get("Skin");
		var skinArray = displaySettings.get("Skin")[3];
		var index:Int = skinArray.indexOf(curMain);
		string = skinCodes[index];
		trace('current skin is $string');
		return string;
	}

	public static function skinFromCode(code:String):String {
		var index:Int = skinCodes.indexOf(code);
		var skin = displaySettings.get("Skin")[3][index];
		return skin;
	}

	public static function returnSkins():Array<String> {
		var skinArray:Array<String> = [];
		for(i in skinCodes) {
			if(shop.get(i)) {
				skinArray.push(skinFromCode(i));
				if(i == "base")
					skinArray.push("Pixel Classic");
			}
		}

		return skinArray;
	}
}