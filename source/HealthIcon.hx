package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		antialiasing = true;
		animation.add('gf', [0, 1], 0, false, isPlayer);
		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-pixel', [0, 1], 0, false, isPlayer);
		animation.add('baldi', [2, 3], 0, false, isPlayer);
		animation.add('bully', [4, 5], 0, false, isPlayer);
		animation.play(char);

		switch(char)
		{
			case 'bf-pixel' | 'senpai' | 'senpai-angry' | 'spirit' | 'gf-pixel':
				antialiasing = false;
		}

		scrollFactor.set();
	}
}
