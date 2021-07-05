package;

import flixel.input.mouse.FlxMouseEventManager;
import flixel.graphics.frames.FlxBitmapFont;
import Alphabet.Skebeep;
import flixel.addons.display.FlxBackdrop;
import Song.SwagSong;
import flixel.input.gamepad.FlxGamepad;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;


#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = FlxG.save.data.difficulty;

	var songText:Skebeep;
	var informationText:Skebeep;

	var icon:String = "";
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Skebeep>;
	private var backButton:FlxSprite;
	private var curPlaying:Bool = false;

	public static var songData:Map<String,Array<SwagSong>> = [];

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try 
		{
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name));
		}
		catch(ex)
		{
			// do nada
		}
	}

	override function create()
	{
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
			// if(Std.parseInt(data[2]) <= FlxG.save.data.weekUnlocked - 1)
			// {
				songs.push(meta);
				var format = StringTools.replace(meta.songName, " ", "-");
				switch (format) {
					case 'Dad-Battle': format = 'Dadbattle';
					case 'Philly-Nice': format = 'Philly';
				}

				var diffs = [];
				FreeplayState.loadDiff(0,format,meta.songName,diffs);
				FreeplayState.loadDiff(1,format,meta.songName,diffs);
				FreeplayState.loadDiff(2,format,meta.songName,diffs);
				FreeplayState.loadDiff(3,format,meta.songName,diffs);
				FreeplayState.songData.set(meta.songName,diffs);
				trace('loaded diffs for ' + meta.songName);
			// }
		}

		for (i in 0...10)
		{
			songs.push(new SongMetadata('filler song $i', 0, 'bf-pixel'));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var backButtonForMouse:FlxSprite = new FlxSprite(160, 0).makeGraphic(64, 64);
		backButtonForMouse.scrollFactor.set();
		add(backButtonForMouse);
		FlxMouseEventManager.add(backButtonForMouse, onMouseDown, null, onMouseOver, onMouseOut);
		
		var menuBG:FlxBackdrop = new FlxBackdrop(Paths.image("wall"));
		menuBG.antialiasing = true;
		add(menuBG);
		
		var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bars'));
		bars.scrollFactor.set();
		bars.updateHitbox();
		bars.screenCenter();
		bars.antialiasing = false;
		add(bars);

		backButton = new FlxSprite();
		backButton.frames = Paths.getSparrowAtlas('MainMenuButtons');
		backButton.animation.addByPrefix('idle', "return clear off", 24);
		backButton.animation.addByPrefix('selected', "return clear on", 24);
		backButton.animation.play('idle');
		backButton.setPosition(160, 0);
		backButton.scrollFactor.set();
		add(backButton);

		grpSongs = new FlxTypedGroup<Skebeep>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			songText = new Skebeep();
			songText.color = FlxColor.BLACK;
			songText.text = songs[i].songName.replace(" ", ";");
			songText.isMenuItem = true;
			songText.myID = i;
			songText.scale.set(3, 3);
			songText.updateHitbox();
			songText.screenCenter();
			grpSongs.add(songText);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		informationText = new Skebeep(3);
		informationText.color = FlxColor.BLACK;
		informationText.screenCenter(X);
		informationText.y = 400;
		informationText.scale.set(2, 2);
		informationText.updateHitbox();
		informationText.scrollFactor.set();
		add(informationText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var mouse:Bool = false;
	var backSel:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (songText.finishedFunnyMove)
			informationText.visible = true;

		informationText.text = 'Score: $lerpScore ${CoolUtil.difficultyFromInt(curDifficulty).toUpperCase()} $combo\nOpponent: $icon';
		informationText.screenCenter(X);

		if (!mouse && FlxG.mouse.justMoved || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight || FlxG.mouse.wheel != 0)
		{
			switchToMouse();
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.DPAD_UP)
			{
				if (mouse)
					switchFromMouse();
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN)
			{
				if (mouse)
					switchFromMouse();
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT)
			{
				if (mouse)
					switchFromMouse();
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT)
			{
				if (mouse)
					switchFromMouse();
				changeDiff(1);
			}
		}

		if (FlxG.keys.justPressed.UP)
		{
			if (mouse)
				switchFromMouse();
			changeSelection(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			if (mouse)
				switchFromMouse();
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			if (mouse)
				switchFromMouse();
			changeDiff(-1);
		}
		if (FlxG.keys.justPressed.RIGHT)
		{
			if (mouse)
				switchFromMouse();
			changeDiff(1);
		}

		if (controls.BACK)
		{
			if (mouse)
				switchFromMouse();
			backButton.animation.play('selected');
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new PlayMenuState());
		}

		if (controls.ACCEPT)
		{
			if (mouse)
				switchFromMouse();
			startSong();
		}

		if (mouse)
		{
			if (FlxG.mouse.justPressed && !backSel)
				startSong();

			if (FlxG.mouse.justPressedRight)
				changeDiff(1);

			if (FlxG.mouse.wheel > 0)
				changeSelection(-1);

			if (FlxG.mouse.wheel < 0)
				changeSelection(1);
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;

		FlxG.save.data.difficulty = curDifficulty;
		FlxG.save.flush();

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}
		
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		songText.doFunnyMove = true;
		informationText.visible = false;

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		
		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle': songHighscore = 'Dadbattle';
			case 'Philly-Nice': songHighscore = 'Philly';
		}

		icon = songs[curSelected].songCharacter;
		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		var comicSans:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Paths.font('bitmap/comic-sans-without-underline.png'),Paths.font('bitmap/comic-sans-without-underline.fnt'));
		var comicSansUnderlined:FlxBitmapFont = FlxBitmapFont.fromAngelCode(Paths.font('bitmap/comic-sans-underlined.png'),Paths.font('bitmap/comic-sans-underlined.fnt'));
		
		for (item in grpSongs.members)
		{
			item.myID = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			item.font = comicSans;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.myID == 0)
			{
				item.alpha = 1;
				item.font = comicSansUnderlined;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function startSong()
	{
		// adjusting the song name to be compatible
		var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songFormat) {
			case 'Dad-Battle': songFormat = 'Dadbattle';
			case 'Philly-Nice': songFormat = 'Philly';
		}
		var hmm;
		try
		{
			hmm = songData.get(songs[curSelected].songName)[curDifficulty];
			if (hmm == null)
				return;
		}
		catch(ex)
		{
			return;
		}


		PlayState.SONG = hmm;
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = songs[curSelected].week;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function switchFromMouse()
	{
		changeSelection();
		FlxG.mouse.visible = false;
		mouse = false;
	}
	
	function switchToMouse()
	{
		FlxG.mouse.visible = true;
		mouse = true;
	}

	function onMouseOver(spr:FlxSprite)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		backButton.animation.play('selected');
		backSel = true;
	}

	function onMouseOut(spr:FlxSprite)
	{
		backButton.animation.play('idle');
		backSel = false;
	}

	function onMouseDown(spr:FlxSprite)
	{
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('cancelMenu'));
		FlxG.switchState(new PlayMenuState());
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
