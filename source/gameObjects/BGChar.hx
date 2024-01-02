package gameObjects;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import states.PlayState;
import flixel.util.FlxTimer;

class BGChar extends FlxSprite
{
    public var speed:Int = 300;
    public var side:String = "right";
    public function new(anim:String, side:String, vip:Bool = false) {
        super();

        this.side = side;

        if(vip)
            frames = Paths.getSparrowAtlas('backgrounds/vip/vip bg');
        else
            frames = Paths.getSparrowAtlas('backgrounds/week1/bgchars');
        animation.addByPrefix("idle", anim, 24, true);
        animation.play('idle');
        scale.set(1.1,1.1);
        updateHitbox();

        y -= height;
        y-= 40;

        if(side == "right") {
            x = 2800;
        }
        else {
            x = -2100;
        }
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(side == "right" && x <= -2100) {
            //trace('went');
            velocity.x = 0;
            //x = 2800;
            goOtherWay();
            PlayState.charGroup.ammtWalking--;
        }
        else if(side == "left" && x >= 3000) {
            //trace('went');
            velocity.x = 0;
            //x = -2100;
            goOtherWay();
            PlayState.charGroup.ammtWalking--;
        }
    }

    function goOtherWay() {
        var hasChanged:Bool = false;
        flipX = !flipX;
        speed = -speed;
        if(side == "right" && !hasChanged) {
            side = "left";
            hasChanged = true;
        }

        if(side == "left" && !hasChanged) {
            side = "right";
            hasChanged = true;
        }
    }
}

class CharGroup extends FlxTypedGroup<BGChar>
{
    var right:Array<String> = ['Justin', 'Antony', 'Crimson', 'Starry', 'Yair'];
    var left:Array<String> = ['Wave', 'SourSweet', 'Shaya', 'Leo', 'Astro'];
    public function new(vip:Bool = false) {
		super();

        if(vip) {
            right = ['Whisper', 'Sam', 'Nyako', 'Evelyn', 'Abi'];
            left = ['Nobodi', 'Jewel', 'Drown', 'Dorothy', 'Claire'];
        }

        for(i in 0...right.length) {
            var char = new BGChar(right[i], "right", vip);
            if(right[i] == 'Crimson')
                char.speed = 800;
            char.ID = i;
            add(char);
        }

        for(i in 0...left.length) {
            var char = new BGChar(left[i], "left", vip);
            char.speed = -300;
            if(left[i] == 'Shaya' || left[i] == 'Claire')
                char.speed = -700;
            char.ID = 5+i;
            add(char);
        }
	}
	public var ammtWalking = 0;
    public var canWalk:Bool = true;
    override function update(elapsed:Float) {
        super.update(elapsed);
        
        var chance:Bool = FlxG.random.bool(0.4);
        if(chance && ammtWalking <= 2) {
            ammtWalking++;
            var which:Int = FlxG.random.int(0, 9);
            for(char in this) {
                if(char.ID == which) {
                    if(canWalk) {
                        var random:Float = FlxG.random.int(-20, 200);
                        char.velocity.x = -(char.speed+random);
                    }

                    canWalk = false;
                    var countTimer = new FlxTimer().start(1.2, function(tmr:FlxTimer)
                    {
                        canWalk = true;
                    }, 5);
                }

            }
        }
    }
}