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

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var newGaming:FlxText;
	var newGaming2:FlxText;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.5.3" + nightly;
	public static var gameVer:String = "0.2.7.1";
	public static var baldiVer:String = "v0.1\n";

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('baldiIntro'));

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('BG'));
		bg.scrollFactor.set();
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = false;
		add(bg);

		var baldi:FlxSprite = new FlxSprite().loadGraphic(Paths.image('baldiBG'));
		baldi.scrollFactor.set();
		baldi.updateHitbox();
		baldi.screenCenter();
		baldi.antialiasing = false;
		add(baldi);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('MainMenuButtons');

		var playButton:FlxSprite = new FlxSprite();
		playButton.frames = tex;
		playButton.animation.addByPrefix('idle', "play off", 24);
		playButton.animation.addByPrefix('selected', "play on", 24);
		playButton.animation.play('idle');
		playButton.ID = 0;
		playButton.x = 684;
		playButton.y = 196;
		playButton.scrollFactor.set();
		playButton.antialiasing = false;
		menuItems.add(playButton);

		var optionsButton:FlxSprite = new FlxSprite();
		optionsButton.frames = tex;
		optionsButton.animation.addByPrefix('idle', "options off", 24);
		optionsButton.animation.addByPrefix('selected', "options on", 24);
		optionsButton.animation.play('idle');
		optionsButton.ID = 1;
		optionsButton.x = 636;
		optionsButton.y = 290;
		optionsButton.scrollFactor.set();
		optionsButton.antialiasing = false;
		menuItems.add(optionsButton);

		var aboutButton:FlxSprite = new FlxSprite();
		aboutButton.frames = tex;
		aboutButton.animation.addByPrefix('idle', "about off", 24);
		aboutButton.animation.addByPrefix('selected', "about on", 24);
		aboutButton.animation.play('idle');
		aboutButton.ID = 2;
		aboutButton.x = 604;
		aboutButton.y = 368;
		aboutButton.scrollFactor.set();
		aboutButton.antialiasing = false;
		menuItems.add(aboutButton);

		var versionStuff:FlxText = new FlxText(166, 930, 0, baldiVer, 54);
		versionStuff.scrollFactor.set();
		versionStuff.setFormat("Comic Sans MS", 18, FlxColor.BLACK, LEFT);
		add(versionStuff);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " FNF - " + kadeEngineVer + " Kade Engine" : ""), 12);
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

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
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
							FlxG.switchState(new PlayMenuState());
						case 1:
							FlxG.switchState(new OptionsMenu());
						case 2:
							FlxG.switchState(new AboutMenuState());
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
