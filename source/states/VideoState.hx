package states;

import hxcodec.flixel.FlxVideo;
import flixel.system.FlxSound;
import data.GameData.MusicBeatState;

class VideoState extends MusicBeatState
{
    var video:FlxVideo;
    var audio:FlxSound;

    public static var name:String = "divergence";
	override public function create():Void
	{
        CoolUtil.playMusic();

        Main.setMouse(false);

        #if mobile
        onComplete();
        #else
        video = new FlxVideo();
		video.onEndReached.add(onComplete);
		video.play(Paths.video(name));

        audio = new FlxSound();
		audio.loadEmbedded(Paths.sound('video/$name'), false, false);
        FlxG.sound.list.add(audio);
        audio.play();
        #end
		super.create();
	}

    public function onComplete():Void
    {
        #if !mobile
        audio.stop();
        video.dispose();
        #end

        switch(name) {
            case "divergence":
                // pop up here?
                //SaveData.progression.set("week1", true);
                if(!SaveData.progression.get("week1"))
                    states.cd.MainMenu.unlocks.push("Week 2!\nFreeplay!");
                SaveData.progression.set("week1", true);
                SaveData.save();
                Main.switchState(new states.cd.MainMenu());
            case "panic":
                states.cd.Dialog.dialog = "panic-attack";
                Main.switchState(new states.cd.Dialog());
            default:
                Main.switchState(new states.cd.MainMenu());
        }

    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(FlxG.keys.justPressed.SPACE) {
            onComplete();
        }
    }
}