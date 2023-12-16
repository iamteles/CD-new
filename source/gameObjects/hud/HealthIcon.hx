package gameObjects.hud;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class HealthIcon extends FlxSprite
{
	public function new()
	{
		super();
		//setIcon("face");
	}

	public var isPlayer:Bool = false;
	public var curIcon:String = "";
	public var maxFrames:Int = 0;

	public function setIcon(curIcon:String = "face", isPlayer:Bool = false):HealthIcon
	{
		this.curIcon = curIcon;

		if(curIcon == "watts" && isPlayer)
			return setIcon("bex", isPlayer);

		if(curIcon == "watts-alt" && isPlayer)
			return setIcon("bella", isPlayer);

		trace("attempt icon " + curIcon);
		if(!Paths.fileExists('images/icons/icon-${curIcon}.png'))
		{
			if(curIcon.contains('-')) {
				switch(curIcon) {
					case 'bree-2dp' | 'bree-2d':
						return setIcon("angry-bree", isPlayer);
					case 'angry-bree':
						//
					case 'bella-2d' | 'bella-2dp' | 'bex-2d' | 'bex-2dp':
						return setIcon("duo", isPlayer);
					default:
						return setIcon(CoolUtil.formatChar(curIcon), isPlayer);
				}
			}
			else
				return setIcon("face", isPlayer);
		}

		trace("loaded icon " + curIcon);

		var iconGraphic = Paths.image("icons/icon-" + curIcon);

		maxFrames = Math.floor(iconGraphic.width / 150);

		loadGraphic(iconGraphic, true, Math.floor(iconGraphic.width / maxFrames), iconGraphic.height);

		animation.add("icon", [for(i in 0...maxFrames) i], 0, false);
		animation.play("icon");

		this.isPlayer = isPlayer;
		flipX = isPlayer;

		return this;
	}

	public function setAnim(health:Float = 1)
	{
		health /= 2;
		var daFrame:Int = 0;

		if(health < 0.3)
			daFrame = 1;

		if(health > 0.7)
			daFrame = 2;

		if(daFrame >= maxFrames)
			daFrame = 0;

		animation.curAnim.curFrame = daFrame;
	}

	public static function getColor(char:String = ""):FlxColor
	{
		var colorMap:Map<String, FlxColor> = [
			"face" 		=> 0xFFA1A1A1,
			"watts" 		=> 0xFFe5e07f,
			"bree" 		=> 0xFF7f7387,
			"angry-bree" 		=> 0xFF7f7387,
			"bella"		=> 0xffFFD6D6,
			"bex"	=> 0xFF262932,
			"spicy"	=> 0xFFc65343,
			"duo"	=> 0xffffffff,
			"cute"		=> 0xffffffff,
			"evil"	=> 0xFF262932,
			"helica" => 0xFFe39a78,
			"drown" => 0xFF448499,
			"wave" => 0xFFEE6D48,
			"empitri" => 0xFFF1ABAB,
			"duo2" => 0xFFF1ABAB
		];

		function loopMap()
		{
			if(!colorMap.exists(char))
			{
				if(char.contains('-'))
				{
					char = CoolUtil.formatChar(char);
					loopMap();
				}
				else
					char = "face";
			}
		}
		loopMap();

		return colorMap.get(char);
	}
}