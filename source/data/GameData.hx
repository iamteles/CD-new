package data;

import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIState;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	var focused:Bool = true;
	override function create()
	{
		super.create();
		Main.activeState = this;
		//trace('switched to ${Type.getClassName(Type.getClass(FlxG.state))}');
		
		Controls.setSoundKeys();

		if(!Main.skipClearMemory)
			Paths.clearMemory();
		
		if(!Main.skipTrans)
			openSubState(new GameTransition(true));

		// go back to default automatically i dont want to do it
		Main.skipStuff(false);
		curStep = _curStep = Conductor.calcStateStep();
		curBeat = Math.floor(curStep / 4);
	}

	private var _curStep = 0; // actual curStep
	private var curStep = 0;
	private var curBeat = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateBeat();
	}

	private function updateBeat()
	{
		_curStep = Conductor.calcStateStep();

		while(_curStep != curStep)
			stepHit();
	}

	private function stepHit()
	{
		if(_curStep > curStep)
			curStep++;
		else
		{
			curStep = _curStep;
		}

		if(curStep % 4 == 0)
			beatHit();

		function loopGroup(group:FlxGroup):Void
		{
			if(group == null) return;
			for(item in group.members)
			{
				if(item == null) continue;
				if(Std.isOfType(item, FlxGroup))
					loopGroup(cast item);
	
				if (item._stepHit != null)
					item._stepHit(curStep);
			}
		}
		loopGroup(this);
	}

	private function beatHit()
	{
		// finally you're useful for something
		curBeat = Math.floor(curStep / 4);
	}

	override function onFocusLost():Void
	{
		super.onFocusLost();

		focused = false;
		//trace(focused);
	}

	override function onFocus():Void
	{
		super.onFocus();

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			focused = true;
		});

		//trace(focused);
	}
}

class MusicBeatSubState extends FlxSubState
{
	var focused:Bool = true;
	var subParent:FlxState;

	override function create()
	{
		super.create();
		subParent = Main.activeState;
		Main.activeState = this;
		persistentDraw = true;
		persistentUpdate = false;
		curStep = _curStep = Conductor.calcStateStep();
		curBeat = Math.floor(curStep / 4);
	}
	
	override function close()
	{
		Main.activeState = subParent;
		super.close();
	}

	private var _curStep = 0; // actual curStep
	private var curStep = 0;
	private var curBeat = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		updateBeat();
	}

	private function updateBeat()
	{
		_curStep = Conductor.calcStateStep();

		while(_curStep != curStep)
			stepHit();
	}

	private function stepHit()
	{
		if(_curStep > curStep)
			curStep++;
		else
		{
			curStep = _curStep;
		}

		if(curStep % 4 == 0)
			beatHit();

		function loopGroup(group:FlxGroup):Void
		{
			if(group == null) return;
			for(item in group.members)
			{
				if(item == null) continue;
				if(Std.isOfType(item, FlxGroup))
					loopGroup(cast item);
	
				if (item._stepHit != null)
					item._stepHit(curStep);
			}
		}
		loopGroup(this);
	}

	private function beatHit()
	{
		// finally you're useful for something
		curBeat = Math.floor(curStep / 4);
	}

	override function onFocusLost():Void
	{
		super.onFocusLost();

		focused = false;
		//trace(focused);
	}

	override function onFocus():Void
	{
		super.onFocus();

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			focused = true;
		});

		//trace(focused);
	}
}

