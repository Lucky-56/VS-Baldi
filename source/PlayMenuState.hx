package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class PlayMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay'];

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.playMusic(Paths.music('Elevator'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		
		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bars'));
		bars.scrollFactor.set();
		bars.updateHitbox();
		bars.screenCenter();
		bars.antialiasing = false;
		add(bars);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('PlayMenuAssets');

		var storyButton:FlxSprite = new FlxSprite();
		storyButton.frames = tex;
		storyButton.animation.addByPrefix('idle', "story off", 24);
		storyButton.animation.addByPrefix('selected', "story on", 24);
		storyButton.animation.play('idle');
		storyButton.ID = 0;
		storyButton.x = 200;
		storyButton.y = 75;
		storyButton.scrollFactor.set();
		storyButton.antialiasing = false;
		menuItems.add(storyButton);

		var storyText:FlxText = new FlxText(5, FlxG.height - 18, 0, 'NO', 18 * 3);
		storyText.scrollFactor.set();
		storyText.setFormat("Comic Sans MS", 18, FlxColor.BLACK, CENTER);
		add(storyText);

		var freeplayButton:FlxSprite = new FlxSprite();
		freeplayButton.frames = tex;
		freeplayButton.animation.addByPrefix('idle', "freeplay off", 24);
		freeplayButton.animation.addByPrefix('selected', "freeplay on", 24);
		freeplayButton.animation.play('idle');
		freeplayButton.ID = 1;
		freeplayButton.x = 870;
		freeplayButton.y = 435;
		freeplayButton.scrollFactor.set();
		freeplayButton.antialiasing = false;
		menuItems.add(freeplayButton);

		var backButton:FlxSprite = new FlxSprite();
		backButton.frames = Paths.getSparrowAtlas('MainMenuButtons');
		backButton.animation.addByPrefix('idle', "return off", 24);
		backButton.animation.addByPrefix('selected', "return on", 24);
		backButton.animation.play('idle');
		backButton.ID = 2;
		backButton.x = 160;
		backButton.y = 0;
		backButton.scrollFactor.set();
		backButton.antialiasing = false;
		menuItems.add(backButton);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "FNF - " + gameVer +  " | KE - " + kadeEngineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite)
				{
					switch (curSelected)
					{
						case 0:
							FlxG.switchState(new StoryMenuState());
						case 1:
							FlxG.switchState(new FreeplayState());
						case 2:
							FlxG.switchState(new MainMenuState());
					}
				});
			}
		}

		super.update(elapsed);
	}
	
	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
			}

			spr.updateHitbox();
		});
	}
}
