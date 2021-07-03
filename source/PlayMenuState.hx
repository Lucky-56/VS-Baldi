package;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import Alphabet.Skebeep;
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
	var comicSans:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Paths.font('bitmap/comic-sans-without-underline.png'),
		Paths.font('bitmap/comic-sans-without-underline.fnt'));
	var comicSansUnderlined:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Paths.font('bitmap/comic-sans-underlined.png'),
		Paths.font('bitmap/comic-sans-underlined.fnt'));

	var curSelected:Int = 0;

	var grpStory:FlxTypedSpriteGroup<FlxSprite>;
	var grpFreeplay:FlxTypedSpriteGroup<FlxSprite>;
	var menuItems:FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>;

	var menuItemsForMouse:FlxTypedGroup<FlxSprite>;

	private var backButton:FlxSprite;

	var leaving:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
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

		var tex = Paths.getSparrowAtlas('PlayMenuAssets');

		grpStory = new FlxTypedSpriteGroup<FlxSprite>();

		var storyButton:FlxSprite = new FlxSprite();
		storyButton.frames = tex;
		storyButton.animation.addByPrefix('idle', "story off", 24);
		storyButton.animation.addByPrefix('selected', "story on", 24);
		storyButton.animation.play('idle');
		storyButton.setPosition(175, 75);
		storyButton.scrollFactor.set();
		grpStory.add(storyButton);

		var storyText:Skebeep = new Skebeep();
		storyText.color = FlxColor.BLACK;
		storyText.alignment = CENTER;
		storyText.setPosition(0, 151);
		storyText.lineSpacing = 7;
		storyText.text = "Story;Mode:\nBeat;Baldi;and;his\nfriends;in;a;rap;battle!\n";
		storyText.scale.set(2, 2);
		storyText.updateHitbox();
		storyText.screenCenter(X);
		storyText.scrollFactor.set();
		grpStory.add(storyText);

		grpFreeplay = new FlxTypedSpriteGroup<FlxSprite>();

		var freeplayButton:FlxSprite = new FlxSprite();
		freeplayButton.frames = tex;
		freeplayButton.animation.addByPrefix('idle', "freeplay off", 24);
		freeplayButton.animation.addByPrefix('selected', "freeplay on", 24);
		freeplayButton.animation.play('idle');
		freeplayButton.setPosition(1070 - storyButton.x, 510 - storyButton.y);
		freeplayButton.scrollFactor.set();
		grpFreeplay.add(freeplayButton);

		var freeplayText:Skebeep = new Skebeep();
		freeplayText.color = FlxColor.BLACK;
		freeplayText.alignment = CENTER;
		freeplayText.setPosition(0, 510);
		freeplayText.lineSpacing = 7;
		freeplayText.text = "Freeplay;Mode:\nChoose;what;song\nyou;want;to;play!\n";
		freeplayText.scale.set(2, 2);
		freeplayText.updateHitbox();
		freeplayText.screenCenter(X);
		freeplayText.scrollFactor.set();
		grpFreeplay.add(freeplayText);

		menuItemsForMouse = new FlxTypedGroup<FlxSprite>();
		add(menuItemsForMouse);

		var storyButtonForMouse:FlxSprite = new FlxSprite(storyButton.x,storyButton.y).makeGraphic(720, 210);
		storyButtonForMouse.scrollFactor.set();
		storyButtonForMouse.ID = 0;
		menuItemsForMouse.add(storyButtonForMouse);

		var freeplayButtonForMouse:FlxSprite = new FlxSprite(560 - storyButton.x, 510 - storyButton.y).makeGraphic(720, 210);
		freeplayButtonForMouse.scrollFactor.set();
		freeplayButtonForMouse.ID = 1;
		menuItemsForMouse.add(freeplayButtonForMouse);

		backButton = new FlxSprite();
		backButton.frames = Paths.getSparrowAtlas('MainMenuButtons');
		backButton.animation.addByPrefix('idle', "return off", 24);
		backButton.animation.addByPrefix('selected', "return on", 24);
		backButton.animation.play('idle');
		backButton.setPosition(160, 0);
		backButton.scrollFactor.set();
		backButton.ID = 2;
		menuItemsForMouse.add(backButton);

		menuItems = new FlxTypedGroup<FlxTypedSpriteGroup<FlxSprite>>();
		add(menuItems);

		grpStory.ID = 0;
		menuItems.add(grpStory);
		grpFreeplay.ID = 1;
		menuItems.add(grpFreeplay);

		for (i in 0...menuItemsForMouse.length)
			{
				var grp:FlxSprite = menuItemsForMouse.members[i];
				FlxMouseEventManager.add(grp, onMouseDown, null, onMouseOver, onMouseOut);
			}

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	var mouse:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (FlxG.mouse.justMoved || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight || FlxG.mouse.wheel != 0)
				{
					switchToMouse();
				}
	
			if (controls.UP_P)
			{
				switchFromMouse();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				switchFromMouse();
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				changeItem(1);
			}

			if (controls.BACK)
			{
				switchFromMouse();
				backButton.animation.play('selected');
				menuButton(2);
			}

			if (controls.ACCEPT)
			{
				switchFromMouse();

				menuItems.forEach(function(grp:FlxTypedSpriteGroup<FlxSprite>)
				{
					menuButton(curSelected);
				});
			}
		}

		super.update(elapsed);
	}
	
	function menuButton(button:Int)
	{
		selectedSomethin = true;

		if (!leaving)
		{
			switch (button)
			{
				case 0:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new StoryMenuState());
				case 1:
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxG.switchState(new FreeplayState());
				case 2:
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.switchState(new MainMenuState());
			}
		}
		leaving = true;
	}
	
	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(grp:FlxTypedSpriteGroup<FlxSprite>)
		{
			grp.forEachOfType(FlxSprite, function(spr:FlxSprite)
			{
				spr.animation.play('idle');
			});
			grp.forEachOfType(Skebeep, function(txt:Skebeep)
			{
				txt.font = comicSans;
			});
			if (grp.ID == curSelected)
			{
				grp.forEachOfType(FlxSprite, function(spr:FlxSprite)
				{
					spr.animation.play('selected');
				});
				grp.forEachOfType(Skebeep, function(txt:Skebeep)
				{
					txt.font = comicSansUnderlined;
				});
			}
		});
	}

	function switchFromMouse()
	{
		changeItem();
		FlxG.mouse.visible = false;
		mouse = false;
	}
	
	function switchToMouse()
	{
		FlxG.mouse.visible = true;
		if(!mouse)
		{
			menuItems.forEach(function(grp:FlxTypedSpriteGroup<FlxSprite>)
			{
				grp.forEachOfType(FlxSprite, function(spr:FlxSprite){
					spr.animation.play('idle');
				});
				grp.forEachOfType(Skebeep, function(txt:Skebeep){
					txt.font = comicSans;
				});
			});
		}
		mouse = true;
	}

	function onMouseOver(spr:FlxSprite)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		if (spr.ID == 2)
		{
			spr.animation.play('selected');
		}
		else
		{
			menuItems.forEach(function(grp:FlxTypedSpriteGroup<FlxSprite>){
				if(grp.ID == spr.ID)
				{
					grp.forEachOfType(FlxSprite, function(spr:FlxSprite){
						spr.animation.play('selected');
					});
					grp.forEachOfType(Skebeep, function(txt:Skebeep){
						txt.font = comicSansUnderlined;
					});
				}
			});
		}
	}

	function onMouseOut(spr:FlxSprite)
	{
		if (spr.ID == 2)
			{
				spr.animation.play('idle');
			}
			else
			{
				menuItems.forEach(function(grp:FlxTypedSpriteGroup<FlxSprite>){
					if(grp.ID == spr.ID)
					{
						grp.forEachOfType(FlxSprite, function(spr:FlxSprite){
							spr.animation.play('idle');
						});
						grp.forEachOfType(Skebeep, function(txt:Skebeep){
							txt.font = comicSans;
						});
					}
				});
			}
	}

	function onMouseDown(spr:FlxSprite)
	{
		menuButton(spr.ID);
	}
}
