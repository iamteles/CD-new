package data;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import data.GameData.MusicBeatSubState;

class GameTransition extends MusicBeatSubState
{
	public var blackFade:FlxSprite;
	public var bg:FlxSprite;
	
	public var finishCallback:Void->Void;
	
	public function new(fadeOut:Bool = true)
	{
		super();

		bg = new FlxSprite().loadGraphic(Paths.image('transition'));
		if(!fadeOut)
			bg.scale.set(3.8,3.8);
		else
			bg.scale.set(0.007,0.007);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		
		
		blackFade = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFF000000);
		blackFade.screenCenter();
		add(blackFade);
		
		blackFade.alpha = (fadeOut ? 1 : 0);
		FlxTween.tween(blackFade, {alpha: fadeOut ? 0 : 1}, 0.34);

		var finalScale:Float = 0.007;
		if(fadeOut)
			finalScale = 3.8;

		/*new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{*/
			FlxTween.tween(bg.scale, {x: finalScale, y:finalScale}, 0.4, {
				onComplete: function(twn:FlxTween)
				{
					if(finishCallback != null)
						finishCallback();
					else
						close();
				}
			});
		//}); 
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var lastCam = FlxG.cameras.list[FlxG.cameras.list.length - 1];
		bg.cameras = [lastCam];
		blackFade.cameras = [lastCam];

		bg.updateHitbox();
		bg.screenCenter();
	}
}