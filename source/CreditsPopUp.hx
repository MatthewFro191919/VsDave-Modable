package;

import flixel.FlxG;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.math.FlxMath;

typedef SongHeading = {
	var path:String;
	var antiAliasing:Bool;
	var ?animation:Animation;
	var iconOffset:Float;
}

class CreditsPopUp extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var bgHeading:FlxSprite;

	public var funnyText:FlxText;
	public var funnyIcon:FlxSprite;
	var iconOffset:Float;
	var curHeading:SongHeading;
	public static var songCreator:String = '';
	var rawJsonSettings:String;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
		add(bg);
		var songCreatorIcon:String = '';
		var headingPath:SongHeading = null;

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'warmup' | 'house' | 'insanity' | 'polygonized' | 'bonus-song' | 'blocked' | 'corn-theft' | 'maze' | 'indignancy' |  'splitathon' | 'shredder' | 'greetings' |
				'interdimensional' | 'cheating' | 'escape-from-california' | 'five-nights' | 'kabunga' | 'secret' | 'unfairness' | 'rano' | 'master':
				songCreator = 'MoldyGH';
			case 'exploitation':
				songCreator = 'Oxygen';
			case 'memory' | 'mealie':
				songCreator = 'Alexander Cooper 19';
			case 'glitch':
				songCreator = 'DeadShadow & PixelGH\nRemix by MoldyGH';
				songCreatorIcon = 'DeadShadow & PixelGH';
			case 'overdrive':
				songCreator = 'Top 10 Awesome';
			case 'supernovae':
				songCreator = 'ArchWk\nRemix by MoldyGH';
				songCreatorIcon = 'ArchWk';
			case 'vs-dave-rap' | 'vs-dave-rap-two':
				songCreator = 'Your mom';
			case 'recursed':
				songCreator = 'Aadsta';
			case 'adventure':
				songCreator = 'Ruby';
			case 'bot-trot':
				songCreator = 'TH3R34LD34L';
			case 'roofs':
				songCreator = 'sibottle';
			case 'backyard' | 'frenzy' | 'multidimensional':
				songCreator = 'zlix';
			default:
				if (PlayState.SONG.songCreators != null) {
         songCreator = PlayState.SONG.songCreators;
				}
		}
		switch (PlayState.storyWeek)
		{
			case 0 | 1:
				headingPath = {path: 'songHeadings/daveHeading', antiAliasing: false, iconOffset: 0};
			case 2:
				headingPath = {path: 'songHeadings/bambiHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 0};
			case 3:
				headingPath = {path: 'songHeadings/splitathonHeading', antiAliasing: false, iconOffset: 0};
			case 4:
				headingPath = {path: 'songHeadings/festivalHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 0};
			case 5:
				headingPath = {path: 'songHeadings/bevelHeading', antiAliasing: false, iconOffset: 0};
			case 6:
				headingPath = {path: 'songHeadings/kabungaHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 0};
			case 7:
				headingPath = {path: 'songHeadings/secretLeakHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 3};
			case 8:
				headingPath = {path: 'songHeadings/tristanHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 0};
			case 9:
				headingPath = {path: 'songHeadings/botHeading', antiAliasing: FlxG.save.data.antialiasing,
				animation: new Animation('botTrot', 'Bot trot', 24, true, [false, false]), iconOffset: 0};
			case 10:
				headingPath = {path: 'songHeadings/recursedHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 5};
			case 11:
				headingPath = {path: 'songHeadings/californiaHeading', antiAliasing: FlxG.save.data.antialiasing,
				animation: new Animation('california', 'California', 24, true, [false, false]), iconOffset: 0};
			case 12:
				headingPath = {path: 'songHeadings/fnafHeading', antiAliasing: FlxG.save.data.antialiasing, iconOffset: 0};
			case 13:
				headingPath = {path: 'songHeadings/fnfengeading', antiAliasing: false, iconOffset: 0};
			case 14:
				headingPath = {path: 'songHeadings/cheatingHeading', antiAliasing: FlxG.save.data.antialiasing,
				animation: new Animation('cheating', 'Cheating', 24, true, [false, false]), iconOffset: 0};
			case 15:
				headingPath = {path: 'songHeadings/unfairHeading', antiAliasing: FlxG.save.data.antialiasing,
				animation: new Animation('unfair', 'Unfairness', 24, true, [false, false]), iconOffset: 0};
			case 16:
				headingPath = {path: 'songHeadings/expungedHeading', antiAliasing: FlxG.save.data.antialiasing,
				animation: new Animation('expunged', 'Expunged', 24, true, [false, false]), iconOffset: 0};
			default:
				if (!FileSystem.exists(TitleState.modFolder + '/images/songHeadings/' + PlayState.SONG.songHeadings + '.xml')) {
			headingPath = {path: 'songHeadings/' + PlayState.SONG.songHeadings, antiAliasing: false, iconOffset: 0};
				} else {
					headingPath = {path: 'songHeadings/daveHeading', antiAliasing: false, iconOffset: 0};
				}
				
		
	}
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'polygonized':
				headingPath = {path: 'songHeadings/3D-daveHeading', antiAliasing: false, iconOffset: 0};
			case 'interdimensional':
				headingPath = {path: 'songHeadings/interdimensionalHeading', antiAliasing: false, iconOffset: 0};
			case 'backyard' | 'frenzy' | 'multidimensional':
				headingPath = {path: 'songHeadings/daveHeading', antiAliasing: false, iconOffset: 0};
			default:

				if (!FileSystem.exists(TitleState.modFolder + '/images/songHeadings/' + PlayState.SONG.songHeadings + '.xml')) {
					headingPath = {path: 'songHeadings/' + PlayState.SONG.songHeadings, antiAliasing: false, iconOffset: 0};
						} else {
							headingPath = {path: 'songHeadings/daveHeading', antiAliasing: false, iconOffset: 0};
						}
		}
		if (PlayState.recursedStaticWeek)
		{
			headingPath = {path: 'songHeadings/somethingHeading', antiAliasing: false,
				animation: new Animation('scramble', 'Scramble', 24, true, [false, false]), iconOffset: 0};
		}

		if (headingPath != null)
		{
			if (headingPath.animation == null)
			{
				if (FileSystem.exists('assets/shared/images/' + headingPath.path + '.png')) {
					//trace('yay');
				bg.loadGraphic(Paths.image(headingPath.path));
				} else if (FileSystem.exists(TitleState.modFolder + '/images/' + headingPath.path + '.png')) {
					//trace('nae');
				bg.loadGraphic(Paths.customImage(TitleState.modFolder + '/images/' + headingPath.path));
				} else {
				bg.loadGraphic(Paths.image('songHeadings/daveHeading'));	
				}
			}
			else
			{
				var info = headingPath.animation;
				if (FileSystem.exists('assets/shared/images/' + headingPath.path + '.png') ) {
				bg.frames = Paths.getSparrowAtlas(headingPath.path);
				bg.animation.addByPrefix(info.name, info.prefixName, info.frames, info.looped, info.flip[0], info.flip[1]);
				bg.animation.play(info.name);
				} else if (FileSystem.exists(TitleState.modFolder + '/images/' + headingPath.path + '.png')) {
				bg.frames = Paths.getCustomSparrowAtlas(TitleState.modFolder + '/images/' + headingPath.path);
				bg.animation.addByPrefix(info.name, info.prefixName, info.frames, info.looped, info.flip[0], info.flip[1]);
				bg.animation.play(info.name);
				} else {
				bg.frames = Paths.getSparrowAtlas('songHeadings/botHeading');
				bg.animation.addByPrefix(info.name, info.prefixName, info.frames, info.looped, info.flip[0], info.flip[1]);
				bg.animation.play(info.name);
				}
			}
			bg.antialiasing = headingPath.antiAliasing;
			curHeading = headingPath;
		}
		createHeadingText(LanguageManager.getTextString("credits_songby") + ' ' + songCreator);
		if (FileSystem.exists('assets/shared/images/songCreators/' + songCreatorIcon + '.png') || FileSystem.exists('assets/shared/images/songCreators/' + songCreator + '.png')) {
		funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/${songCreatorIcon != '' ? songCreatorIcon : songCreator}'));
		rescaleIcon();
		add(funnyIcon);
		} else if (FileSystem.exists(TitleState.modFolder + '/images/songCreators/' + songCreator + '.png')) {
		funnyIcon = new FlxSprite(0, 0, Paths.customImage(TitleState.modFolder + '/images/songCreators/' + songCreator));
		rescaleIcon();
		add(funnyIcon);
		} else {
			funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/MoldyGH'));
			rescaleIcon();
			add(funnyIcon);
		}
		

		rescaleBG();

		var yValues = CoolUtil.getMinAndMax(bg.height, funnyText.height);
		funnyText.y = funnyText.y + ((yValues[0] - yValues[1]) / 2);
	}
	public function switchHeading(newHeading:SongHeading)
	{
		if (bg != null)
		{
			remove(bg);
		}
		bg = new FlxSprite().makeGraphic(400, 50, FlxColor.WHITE);
		if (newHeading != null)
		{
			if (newHeading.animation == null)
			{
				bg.loadGraphic(Paths.image(newHeading.path));
			}
			else
			{
				var info = newHeading.animation;
				bg.frames = Paths.getSparrowAtlas(newHeading.path);
				bg.animation.addByPrefix(info.name, info.prefixName, info.frames, info.looped, info.flip[0], info.flip[1]);
				bg.animation.play(info.name);
			}
		}
		bg.antialiasing = newHeading.antiAliasing;
		curHeading = newHeading;
		add(bg);
		
		rescaleBG();
	}
	public function changeText(newText:String, newIcon:String, rescaleHeading:Bool = true)
	{
		createHeadingText(newText);
		
		if (funnyIcon != null)
		{
			remove(funnyIcon);
		}
		funnyIcon = new FlxSprite(0, 0, Paths.image('songCreators/' + newIcon, 'shared'));
		rescaleIcon();
		add(funnyIcon);

		if (rescaleHeading)
		{
			rescaleBG();
		}
	}
	function createHeadingText(text:String)
	{
		if (funnyText != null)
		{
			remove(funnyText);
		}
		funnyText = new FlxText(1, 0, 650, text, 16);
		funnyText.setFormat('Comic Sans MS Bold', 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		funnyText.borderSize = 2;
		funnyText.antialiasing = FlxG.save.data.antialiasing;
		add(funnyText);
	}
	public function rescaleIcon()
	{
		var offset = (curHeading == null ? 0 : curHeading.iconOffset);

		var scaleValues = CoolUtil.getMinAndMax(funnyIcon.height, funnyText.height);
		funnyIcon.setGraphicSize(Std.int(funnyIcon.height / (scaleValues[1] / scaleValues[0])));
		funnyIcon.updateHitbox();

		var heightValues = CoolUtil.getMinAndMax(funnyIcon.height, funnyText.height);
		funnyIcon.setPosition(funnyText.textField.textWidth + offset, (heightValues[0] - heightValues[1]) / 2);
	}
	function rescaleBG()
	{
		bg.setGraphicSize(Std.int((funnyText.textField.textWidth + funnyIcon.width + 0.5)), Std.int(funnyText.height + 0.5));
		bg.updateHitbox();
	}
}
