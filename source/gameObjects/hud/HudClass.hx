package gameObjects.hud;

import lime.tools.Platform;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import data.Conductor;
import data.Timings;
import states.PlayState;

class HudClass extends FlxGroup
{
	public var infoTxt:FlxText;
	public var timeTxt:FlxText;

	// health bar
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var beamBar:FlxSprite;
	var smoothBar:Bool = true;

	// icon stuff
	public var iconBf:HealthIcon;
	public var iconDad:HealthIcon;
	public var iconCenter:HealthIcon;

	public var invertedIcons:Bool = false;
	public var health:Float = 1;

	var botplaySin:Float = 0;
	var botplayTxt:FlxText;
	var badScoreTxt:FlxText;

	public function new()
	{
		super();

		healthBarBG = new FlxSprite().loadGraphic(Paths.image("hud/base/healthBar"));

		if(PlayState.SONG.song.toLowerCase() == 'nefarious' || PlayState.SONG.song.toLowerCase() == 'divergence')
			invertedIcons = true;
		else if(PlayState.SONG.song.toLowerCase() == "desertion") {
			beamBar = new FlxSprite();
			beamBar.frames = Paths.getSparrowAtlas("hud/base/beambar");
			beamBar.animation.addByPrefix("idle", 'bar', 24, true);
			beamBar.alpha = 0.4;
			beamBar.animation.play('idle');
			beamBar.updateHitbox();
			//add(beamBar);
		}

		healthBar = new FlxBar(
			0, 0,
			RIGHT_TO_LEFT,
			Math.floor(healthBarBG.width) - 140,
			Math.floor(healthBarBG.height) - 20
		);
		healthBar.createFilledBar(0xFFFF0000, 0xFF00FF00);
		healthBar.updateBar();

		add(healthBar);
		add(healthBarBG);

		smoothBar = SaveData.data.get('Smooth Healthbar');

		iconDad = new HealthIcon();
		iconDad.setIcon(PlayState.SONG.player2, false);
		iconDad.ID = 0;
		add(iconDad);

		iconBf = new HealthIcon();
		iconBf.setIcon(PlayState.SONG.player1, true);
		iconBf.ID = 1;
		add(iconBf);

		var centeric:String = "heart";

		iconCenter = new HealthIcon();
		switch(PlayState.daSong) {
			case 'panic-attack' | 'convergence' | 'desertion':
				centeric = 'bolt';
			case 'irritation' | 'conservation':
				centeric = 'cent';

		}
		iconCenter.setIcon(centeric, false);
		//iconCenter.ID = 0;
		add(iconCenter);

		changeIcon(0, iconDad.curIcon);

		infoTxt = new FlxText(0, 0, 0, "hi there! i am using whatsapp");
		infoTxt.setFormat(Main.gFont, 20, 0xFFFFFFFF, CENTER);
		infoTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		add(infoTxt);
		
		timeTxt = new FlxText(0, 0, 0, "nuts / balls even");
		timeTxt.setFormat(Main.gFont, 32, 0xFFFFFFFF, CENTER);
		timeTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		timeTxt.visible = SaveData.data.get('Song Timer');
		add(timeTxt);

		badScoreTxt = new FlxText(0,0,0,"SAVING SCORES DISABLED");
		badScoreTxt.setFormat(Main.gFont, 20, 0xFFFF0000, CENTER);
		badScoreTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		badScoreTxt.screenCenter(X);
		badScoreTxt.visible = false;
		add(badScoreTxt);

		botplayTxt = new FlxText(0,0,0,"[BOTPLAY]");
		botplayTxt.setFormat(Main.gFont, 40, 0xFFFFFFFF, CENTER);
		botplayTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		botplayTxt.visible = false;
		add(botplayTxt);

		updateHitbox();
		health = PlayState.health;
	}

	public final separator:String = " | ";

	public function updateText()
	{
		infoTxt.text = "";
		
		infoTxt.text += 			'Score: '		+ Timings.score;
		infoTxt.text += separator + 'Accuracy: '	+ Timings.accuracy + "%" + ' [${Timings.getRank()}]';
		infoTxt.text += separator + 'Breaks: '		+ Timings.misses;

		infoTxt.screenCenter(X);
	}
	
	public function updateTimeTxt()
	{
		timeTxt.text
		= CoolUtil.posToTimer(Conductor.songPos)
		+ ' / '
		+ CoolUtil.posToTimer(PlayState.songLength);
		timeTxt.screenCenter(X);
	}

	public function updateHitbox(downscroll:Bool = false)
	{
		healthBarBG.screenCenter(X);
		healthBarBG.y = (downscroll ? 50 : FlxG.height - healthBarBG.height - 50);

		if(beamBar != null) {
			beamBar.x = (healthBarBG.x + (healthBarBG.width/2) - (beamBar.width/2));
			beamBar.y = (healthBarBG.y + (healthBarBG.height/2) - (beamBar.height/2)) + 10;
		}

		healthBar.setPosition(healthBarBG.x + 73, healthBarBG.y + 18);
		updateIconPos();

		updateText();
		infoTxt.screenCenter(X);
		infoTxt.y = healthBarBG.y + healthBarBG.height + 4;
		
		badScoreTxt.y = infoTxt.y + infoTxt.height;

		botplayTxt.screenCenter(X);
		botplayTxt.y = (!downscroll ? 40 + 50 : FlxG.height - 40 - 50);
		updateTimeTxt();
		timeTxt.y = downscroll ? (FlxG.height - timeTxt.height - 8) : (8);
	}
	
	public function setAlpha(hudAlpha:Float = 1, ?tweenTime:Float = 0)
	{
		// put the items you want to set invisible when the song starts here
		var allItems:Array<FlxSprite> = [
			infoTxt,
			timeTxt,
			healthBar,
			healthBarBG,
			iconBf,
			iconDad,
			iconCenter
		];

		if(beamBar != null) {
			var beamAlpha = hudAlpha;
			if(beamAlpha > 0.4)
				beamAlpha = 0.4;

			if(tweenTime <= 0)
				beamBar.alpha = beamAlpha;
			else
				FlxTween.tween(beamBar, {alpha: beamAlpha}, tweenTime, {ease: FlxEase.cubeOut});
		}

		for(item in allItems)
		{
			if(tweenTime <= 0)
				item.alpha = hudAlpha;
			else
				FlxTween.tween(item, {alpha: hudAlpha}, tweenTime, {ease: FlxEase.cubeOut});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		health = FlxMath.lerp(health, PlayState.health, elapsed * 8);
		if(Math.abs(health - PlayState.health) <= 0.00001 || !smoothBar)
			health = PlayState.health;
		
		healthBar.percent = (health * 50);

		botplayTxt.visible = PlayState.botplay;
		badScoreTxt.visible = !PlayState.validScore;

		if(botplayTxt.visible)
		{
			botplaySin += elapsed * Math.PI;
			botplayTxt.alpha = 0.5 + Math.sin(botplaySin) * 0.8;
		}

		updateIconPos();
		updateTimeTxt();
	}

	public function updateIconPos()
	{
		var formatHealth = (2 - health);
		if(invertedIcons)
			formatHealth = health;

		var barX:Float = (healthBar.x + (healthBar.width * (formatHealth) / 2));
		var barY:Float = (healthBarBG.y + healthBarBG.height / 2);

		for(icon in [iconDad, iconBf, iconCenter])
		{
			icon.scale.set(
				FlxMath.lerp(icon.scale.x, 1, FlxG.elapsed * 6),
				FlxMath.lerp(icon.scale.y, 1, FlxG.elapsed * 6)
			);
			icon.updateHitbox();

			iconDad.x = (healthBarBG.x - (iconDad.width/2)) - 25;
			iconBf.y = (healthBarBG.y - iconBf.height/ 2) + (healthBarBG.height/2);
			iconBf.x = ((healthBarBG.x + healthBarBG.width) - (iconBf.width/2)) + 25;
			iconDad.y = (healthBarBG.y - iconDad.height/ 2) + (healthBarBG.height/2);
			iconCenter.y = (healthBarBG.y - iconBf.height/ 2) + (healthBarBG.height/2);
			iconCenter.x = barX - (iconCenter.width/2);

			if(!icon.isPlayer)
				icon.setAnim(2 - health);
			else
				icon.setAnim(health);
		}

		healthBar.flipX = invertedIcons;
	}

	public function changeIcon(iconID:Int = 0, newIcon:String = "face")
	{
		for(icon in [iconDad, iconBf])
		{
			if(icon.ID == iconID)
				icon.setIcon(newIcon, icon.isPlayer);
		}
		updateIconPos();

		if(invertedIcons) {
			healthBar.createFilledBar(
				HealthIcon.getColor(iconBf.curIcon),
				HealthIcon.getColor(iconDad.curIcon)
			);
		}
		else {
			healthBar.createFilledBar(
				HealthIcon.getColor(iconDad.curIcon),
				HealthIcon.getColor(iconBf.curIcon)
			);
		}

		healthBar.updateBar();
	}

	public function beatHit(curBeat:Int = 0)
	{
		var iconspeed:Int = 2;
		if(PlayState.beatSpeed <= iconspeed)
			iconspeed = PlayState.beatSpeed;
		if(curBeat % iconspeed == 0)
		{
			for(icon in [iconDad, iconBf, iconCenter])
			{
				icon.scale.set(1.3,1.3);
				icon.updateHitbox();
				updateIconPos();
			}
		}
	}
}