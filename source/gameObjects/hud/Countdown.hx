package gameObjects.hud;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import data.Conductor;

class Countdown extends FlxSprite
{
    var cur:Int = -1;
	public function new()
	{
		super();

        frames = Paths.getSparrowAtlas("hud/base/countdown");
        
        animation.addByPrefix("idle", 'Go0008', 24, true);
        animation.addByPrefix("3", '3', 24, true);
        animation.addByPrefix("2", '2', 24, true);
        animation.addByPrefix("1", '1', 24, true);
        animation.addByPrefix("go", 'Go', 24, true);

        addOffset("idle");
        addOffset("go");
        addOffset("3", 6, -3);
        addOffset("2", 0, 13);
        addOffset("1");

        animation.play('idle');
        scale.set(0.6, 0.6);
        updateHitbox();
        screenCenter();
        alpha = 0;

        scaleOffset.set(offset.x, offset.y);
    }

    public function cycle(daCount:Int) {
        cur = daCount;

        var anim:String = ["3","2", "1", "go"][cur];

        playAnim(anim);

        if(cur == 0)
            alpha = 1;

        if(cur == 3)
            FlxTween.tween(this, {alpha: 0}, Conductor.stepCrochet * 2.8 / 1000, {startDelay: Conductor.stepCrochet * 1 / 1000});
    }

    public var scaleOffset:FlxPoint = new FlxPoint(0,0);
    public var animOffsets:Map<String, Array<Float>> = [];

	public function addOffset(animName, offX:Float = 0, offY:Float = 0):Void
		return animOffsets.set(animName, [offX, offY]);

	public function playAnim(animName:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0)
	{
		animation.play(animName, forced, reversed, frame);

		if(animOffsets.exists(animName))
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0] * scale.x, daOffset[1] * scale.y);
		}
		else
			offset.set(0,0);

		// useful for pixel notes since their offsets are not 0, 0 by default
		offset.x += scaleOffset.x;
		offset.y += scaleOffset.y;
	}
}