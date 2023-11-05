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

		video = new FlxVideo();
		video.onEndReached.add(onComplete);
		video.play(Paths.video(name));

        audio = new FlxSound();
		audio.loadEmbedded(Paths.sound('video/$name'), false, false);
        FlxG.sound.list.add(audio);
        audio.play();

		super.create();
	}

    public function onComplete():Void
    {
        audio.stop();
        video.dispose();
        Main.switchState(new states.cd.MainMenu());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if(FlxG.keys.justPressed.SPACE) {
            onComplete();
        }
    }
}