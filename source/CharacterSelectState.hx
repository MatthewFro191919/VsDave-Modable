package;

import flixel.addons.transition.Transition;
import flixel.addons.transition.FlxTransitionableState;
import sys.io.File;
import lime.app.Application;
import haxe.Exception;
import Controls.Control;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.system.FlxSoundGroup;
import flixel.math.FlxPoint;
import openfl.geom.Point;
import flixel.*;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxStringUtil;
import flixel.FlxSprite;
#if windows
import lime.app.Application;
import sys.FileSystem;
#end
import haxe.Json;
import haxe.format.JsonParser;

 /**
	hey you fun commiting people, 
	i don't know about the rest of the mod but since this is basically 99% my code 
	i do not give you guys permission to grab this specific code and re-use it in your own mods without asking me first.
	the secondary dev, ben
*/

typedef CharacterSelectFile =
{
	var characters:Array<CharSelectStuff>;
}

typedef CharSelectStuff = 
{
	var newCharacter:Array<TheActualChar>;
	var mainName:String;
	var mainnotems:Array<Float>;
	
}

typedef TheActualChar = 
{
var playername:String;
var thecharactername:String;
var thenotems:Array<Float>;
var notestyle:String;
}
class CharacterInSelect
{
	public var name:String;
	public var noteMs:Array<Float>;
	public var forms:Array<CharacterForm>;

	public function new(name:String, noteMs:Array<Float>, forms:Array<CharacterForm>)
	{
		this.name = name;
		this.noteMs = noteMs;
		this.forms = forms;
	}
}
class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var noteType:String;
	public var noteMs:Array<Float>;

	public function new(name:String, polishedName:String, noteMs:Array<Float>, noteType:String = 'normal')
	{
		this.name = name;
		this.polishedName = polishedName;
		this.noteType = noteType;
		this.noteMs = noteMs;
	}
}
class CharacterSelectState extends MusicBeatState
{
	public var char:Boyfriend;
	public var current:Int = 0;
	public var curForm:Int = 0;
	public var notemodtext:FlxText;
	public var characterText:FlxText;
	public var wasInFullscreen:Bool;
	public static var inCS:Bool = false;
	public var funnyIconMan:HealthIcon;

	var strummies:FlxTypedGroup<FlxSprite>;

	var notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	public var isDebug:Bool = false;

	public var PressedTheFunny:Bool = false;

	var selectedCharacter:Bool = false;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camTransition:FlxCamera;

	var currentSelectedCharacter:CharacterInSelect;
	public var rawJson:String;
    public var json:CharacterSelectFile;
	public var rawJsonCustom:String;
    public var jsonCustom:CharacterSelectFile;
	public var rawJsonCustom2:String;
    public var jsonCustom2:CharacterSelectFile;
	var noteMsTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();

	var arrows:Array<FlxSprite> = [];
	var basePosition:FlxPoint;
	
	public var characters:Array<CharacterInSelect> = 
	[
		/*new CharacterInSelect('bf', [1, 1, 1, 1], [
			new CharacterForm('bf', 'Boyfriend', [1,1,1,1]),
			new CharacterForm('bf-pixel', 'Pixel Boyfriend', [1,1,1,1])
		]),
		new CharacterInSelect('dave', [0.25, 0.25, 2, 2], [
			new CharacterForm('dave', 'Dave', [0.25, 0.25, 2, 2]),
		]),
		new CharacterInSelect('bambi', [0, 0, 3, 0], [
			new CharacterForm('bambi-new', 'Bambi', [0, 0, 3, 0]),
		]),
		new CharacterInSelect('tristan', [2, 0.5, 0.5, 0.5], [
			new CharacterForm('tristan', 'Tristan', [2, 0.5, 0.5, 0.5]),
		]),
		new CharacterInSelect('tristan-golden', [0.25, 0.25, 0.25, 2], [
			new CharacterForm('tristan-golden', 'Golden Tristan', [0.25, 0.25, 0.25, 2])
		]),
		new CharacterInSelect('dave-angey', [2, 2, 0.25, 0.25], [
			new CharacterForm('dave-angey', '3D Dave', [2, 2, 0.25, 0.25], '3D')
		]),
		new CharacterInSelect('bambi-3d', [0, 3, 0, 0], [
			new CharacterForm('bambi-3d', 'Expunged', [0, 3, 0, 0], '3D'),
		]),
		new CharacterInSelect('shaggy', [1, 1, 1, 1], [
			new CharacterForm('shaggy', 'Shaggy', [1, 1, 1, 1]),
			new CharacterForm('supershaggy', 'Shaggy (0.001%)', [1, 1, 1, 1]),
			new CharacterForm('godshaggy', 'Shaggy (0.002%)', [1, 1, 1, 1]),
			new CharacterForm('redshaggy', 'Red Shaggy', [1, 1, 1, 1]),
		]),
		*/
	];
	#if SHADERS_ENABLED
	var bgShader:Shaders.GlitchEffect;
	#end

	var legs:FlxSprite;

	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{

		inCS = true;
		unlockCharacter('shaggy');
		if (PlayState.SONG.song.toLowerCase() == 'exploitation' && !FlxG.save.data.modchart)
		{
			if (FlxG.fullscreen)
			{
				FlxG.fullscreen = false;
				wasInFullscreen = true;
			}
		}
		rawJson = File.getContent(Paths.json('characterSelect'));
        json = cast Json.parse(rawJson);
		rawJsonCustom = File.getContent(('mods/global/characterSelect.json'));
        jsonCustom = cast Json.parse(rawJsonCustom);
		if (FileSystem.exists(TitleState.modFolder + '/data/characterSelect.json')) {
		rawJsonCustom2 = File.getContent((TitleState.modFolder + '/data/characterSelect.json'));
        jsonCustom2 = cast Json.parse(rawJsonCustom2);
		}

		var characterInSelectArray:Array<CharacterInSelect> = [];
trace(!TitleState.baseGameDeleted.deletedCharacterImages);
		if (!TitleState.baseGameDeleted.deletedCharacterImages) {

		for (character in json.characters) { // Normal
			var mainName:String = character.mainName;
			var thehotemsithink:Array<Float> = character.mainnotems;
			
			
			var newCharacterForms:Array<CharacterForm> = [];
			for (newChar in character.newCharacter) {
				newCharacterForms.push(new CharacterForm(newChar.playername, newChar.thecharactername, newChar.thenotems, newChar.notestyle));
			}
			
			characters.push(new CharacterInSelect(mainName, thehotemsithink, newCharacterForms));
		}
	} else {

			var newCharacterFormsbf:Array<CharacterForm> = [];
			var newCharacterFormsdave:Array<CharacterForm> = [];
			var newCharacterFormsshaggy:Array<CharacterForm> = [];
			
			newCharacterFormsbf.push(new CharacterForm('bf', 'Boyfriend', [1, 1, 1, 1], ''));
			newCharacterFormsbf.push(new CharacterForm('bf-pixel', 'Pixel Boyfriend', [1, 1, 1, 1], ''));
			
			
			characters.push(new CharacterInSelect('bf', [1, 1, 1, 1], newCharacterFormsbf));

			newCharacterFormsdave.push(new CharacterForm('dave', 'Dave', [0.25, 0.25, 2, 2], ''));
			
			
			characters.push(new CharacterInSelect('dave', [0.25, 0.25, 2, 2], newCharacterFormsdave));

			newCharacterFormsshaggy.push(new CharacterForm('shaggy', 'Shaggy', [1, 1, 1, 1], ''));
			newCharacterFormsshaggy.push(new CharacterForm('supershaggy', 'Shaggy (0.001%)', [1, 1, 1, 1], ''));
			newCharacterFormsshaggy.push(new CharacterForm('godshaggy', 'Shaggy (0.002%)', [1, 1, 1, 1], ''));
			newCharacterFormsshaggy.push(new CharacterForm('redshaggy', 'Red Shaggy', [1, 1, 1, 1], ''));
			
			
			characters.push(new CharacterInSelect('shaggy', [1, 1, 1, 1], newCharacterFormsshaggy));
	}
		if (FileSystem.exists('mods/global/characterSelect.json')) {
		for (character in jsonCustom.characters) { // For Globle Characters
			var mainName:String = character.mainName;
			var thehotemsithink:Array<Float> = character.mainnotems;
			
			var newCharacterForms:Array<CharacterForm> = [];
			for (newChar in character.newCharacter) {
				newCharacterForms.push(new CharacterForm(newChar.playername, newChar.thecharactername, newChar.thenotems, newChar.notestyle));
				unlockCharacter(newChar.playername);
			}
			
			characters.push(new CharacterInSelect(mainName, thehotemsithink, newCharacterForms));
			unlockCharacter(mainName);
		}
	}
		if (FileSystem.exists(TitleState.modFolder + '/data/characterSelect.json')) {
		for (character in jsonCustom2.characters) { // For Characters in Mod Packs
			var mainName:String = character.mainName;
			var thehotemsithink:Array<Float> = character.mainnotems;
			
			var newCharacterForms:Array<CharacterForm> = [];
			for (newChar in character.newCharacter) {
				newCharacterForms.push(new CharacterForm(newChar.playername, newChar.thecharactername, newChar.thenotems, newChar.notestyle));
				unlockCharacter(newChar.playername);
			}
			
			characters.push(new CharacterInSelect(mainName, thehotemsithink, newCharacterForms));
			unlockCharacter(mainName);
		}
	}

		//trace(characters);
		Conductor.changeBPM(110);

		camGame = new FlxCamera();
		camTransition = new FlxCamera();
		camTransition.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camTransition);
		FlxCamera.defaultCameras = [camGame];
		Transition.nextCamera = camTransition;
		
		FlxG.camera.zoom = 1.2;
		camHUD.zoom = 0.75;

		if (FlxG.save.data.charactersUnlocked == null)
		{
			reset();
		}
		currentSelectedCharacter = characters[current];

		if (PlayState.SONG.song.toLowerCase() == "exploitation")
			FlxG.sound.playMusic(Paths.music("badEnding"), 1, true);
		else
			FlxG.sound.playMusic(Paths.music("goodEnding"), 1, true);

		//create BG

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('backgrounds/shared/sky_night'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.scrollFactor.set(0.75, 0.75);
		bg.active = false;
		
		if (PlayState.SONG.song.toLowerCase() == "exploitation")
		{
			bg.loadGraphic(Paths.image('backgrounds/void/redsky', 'shared'));
			
			if (FlxG.save.data.wantShaders) {
			
			bgShader = new Shaders.GlitchEffect();
			bgShader.waveAmplitude = 0.1;
			bgShader.waveFrequency = 5;
			bgShader.waveSpeed = 2;
			
			bg.shader = bgShader.shader;
			}
		}
		add(bg);

		var hills:BGSprite = new BGSprite('hills', -133, 52, Paths.image('backgrounds/charSelect/hills'), null, 1, 1);
		add(hills);

		var house:BGSprite = new BGSprite('house', 385, 78, Paths.image('backgrounds/charSelect/house'), null, 1, 1);
		add(house);

		var behindGrass:BGSprite = new BGSprite('behindGrass', -33, 468, Paths.image('backgrounds/charSelect/behindGrass'), null, 1, 1);
		add(behindGrass);

		var gateLeft:BGSprite = new BGSprite('gateLeft', -38, 464, Paths.image('backgrounds/charSelect/gateLeft'), null, 1, 1);
		add(gateLeft);

		var gateRight:BGSprite = new BGSprite('gateRight', 1014, 464, Paths.image('backgrounds/charSelect/gateRight'), null, 1, 1);
		add(gateRight);
		
		var grass:BGSprite = new BGSprite('grass', -80, 385, Paths.image('backgrounds/charSelect/grass'), null, 1, 1);
		add(grass);
		
		var frontGrass:BGSprite = new BGSprite('frontGrass', -185, 382, Paths.image('backgrounds/charSelect/frontGrass'), null, 1, 1);
		add(frontGrass);
		
		var varientColor = 0xFF878787;
		
		frontGrass.color = varientColor;
		hills.color = varientColor;
		house.color = varientColor;
		behindGrass.color = varientColor;
		gateLeft.color = varientColor;
		gateRight.color = varientColor;
		grass.color = varientColor;

		char = new Boyfriend(FlxG.width / 2, FlxG.height / 2, 'bf');
		char.cameras = [camHUD];
		char.screenCenter();

		legs = new FlxSprite(630, 330);
		legs.cameras = [camHUD];
		legs.frames = Paths.getSparrowAtlas('characters/shaggy_god', 'shared');
		legs.animation.addByPrefix('legs', "solo_legs", 30);
		legs.animation.play('legs');
		legs.antialiasing = FlxG.save.data.antialiasing;
		legs.flipX = true;
		legs.updateHitbox();
		legs.offset.set(legs.frameWidth / 2, 10);
		legs.alpha = 0;

		add(legs);
		add(char);

		basePosition = char.getPosition();

		strummies = new FlxTypedGroup<FlxSprite>();
		strummies.cameras = [camHUD];
		
		add(strummies);
		generateStaticArrows(false);
		
		notemodtext = new FlxText((FlxG.width / 3.5) + 80, FlxG.height, 0, "1.00x       1.00x        1.00x       1.00x", 30);
		notemodtext.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		notemodtext.scrollFactor.set();
		notemodtext.alpha = 0;
		notemodtext.y -= 10;
		FlxTween.tween(notemodtext, {y: notemodtext.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * 0)});
		notemodtext.cameras = [camHUD];
		add(notemodtext);
		
		characterText = new FlxText((FlxG.width / 9) - 50, (FlxG.height / 8) - 225, "Boyfriend");
		characterText.font = 'Comic Sans MS Bold';
		characterText.setFormat(Paths.font("comic.ttf"), 90, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		characterText.autoSize = false;
		characterText.fieldWidth = 1080;
		characterText.borderSize = 5;
		characterText.screenCenter(X);
		characterText.cameras = [camHUD];
		characterText.antialiasing = FlxG.save.data.antialiasing;
		characterText.y = FlxG.height - 180;
		add(characterText);
		
		var resetText = new FlxText(FlxG.width, FlxG.height, LanguageManager.getTextString('character_reset'));
		resetText.setFormat(Paths.font("comic.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.autoSize = false;
		resetText.fieldWidth = FlxG.height;
		resetText.x -= resetText.textField.textWidth;
		resetText.y -= resetText.textField.textHeight - 100;
		resetText.borderSize = 3;
		resetText.cameras = [camHUD];
		resetText.antialiasing = FlxG.save.data.antialiasing;
		resetText.visible = false;
		add(resetText);

		funnyIconMan = new HealthIcon('bf', true);
		funnyIconMan.cameras = [camHUD];
		funnyIconMan.visible = false;
		funnyIconMan.antialiasing = FlxG.save.data.antialiasing;
		updateIconPosition();
		add(funnyIconMan);

		var tutorialThing:FlxSprite = new FlxSprite(-110, -30).loadGraphic(Paths.image('ui/charSelectGuide'));
		tutorialThing.setGraphicSize(Std.int(tutorialThing.width * 1.5));
		tutorialThing.antialiasing = FlxG.save.data.antialiasing;
		tutorialThing.cameras = [camHUD];
		add(tutorialThing);

		var arrowLeft:FlxSprite = new FlxSprite(10,0).loadGraphic(Paths.image("ui/ArrowLeft_Idle", "preload"));
		arrowLeft.screenCenter(Y);
		arrowLeft.antialiasing = FlxG.save.data.antialiasing;
		arrowLeft.scrollFactor.set();
		arrowLeft.cameras = [camHUD];
		arrows[0] = arrowLeft;
		add(arrowLeft);

		var arrowRight:FlxSprite = new FlxSprite(-5,0).loadGraphic(Paths.image("ui/ArrowRight_Idle", "preload"));
		arrowRight.screenCenter(Y);
		arrowRight.antialiasing = FlxG.save.data.antialiasing;
		arrowRight.x = 1280 - arrowRight.width - 5;
		arrowRight.scrollFactor.set();
		arrowRight.cameras = [camHUD];
		arrows[1] = arrowRight;
		add(arrowRight);

		super.create();

		Transition.nextCamera = camTransition;
	}

	private function generateStaticArrows(noteType:String = 'normal', regenerated:Bool):Void
	{
		if (regenerated)
		{
			if (strummies.length > 0)
			{
				strummies.forEach(function(babyArrow:FlxSprite)
				{
					remove(babyArrow);
					strummies.remove(babyArrow);
				});
			}
		}
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, FlxG.height - 40);

			var noteAsset:String = 'notes/NOTE_assets';
			switch (noteType)
			{
				case '3D':
					noteAsset = 'notes/NOTE_assets_3D';
			}

			babyArrow.frames = Paths.getSparrowAtlas(noteAsset);
			babyArrow.animation.addByPrefix('green', 'arrowUP0');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN0');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT0');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT0');

			babyArrow.antialiasing = FlxG.save.data.antialiasing;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.x += 160 * 0.7 * i;
			switch (Math.abs(i))
			{
				case 0:
					babyArrow.animation.addByPrefix('static', 'arrowLEFT0');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
				case 1:
					babyArrow.animation.addByPrefix('static', 'arrowDOWN0');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.animation.addByPrefix('static', 'arrowUP0');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT0');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();
			babyArrow.ID = i;
	
			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 3.5));
			babyArrow.y -= 10;
			babyArrow.alpha = 0;

			var baseDelay:Float = regenerated ? 0 : 0.5;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: baseDelay + (0.2 * i)});
			babyArrow.cameras = [camHUD];
			strummies.add(babyArrow);
		}
	}
	override public function update(elapsed:Float):Void
	{
		if (FlxG.save.data.wantShaders) {
		if (bgShader != null)
		{
			bgShader.shader.uTime.value[0] += elapsed;
		}
	}
		Conductor.songPosition = FlxG.sound.music.time;
		
		var controlSet:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		super.update(elapsed);

		legs.alpha = char.animation.name == 'idle' && char.curCharacter == 'godshaggy' ? 1 : 0;

		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (wasInFullscreen)
			{
				FlxG.fullscreen = true;
			}
			inCS = false;
			LoadingState.loadAndSwitchState(new FreeplayState());
		}

		for (i in 0...controlSet.length)
		{
			if (controlSet[i] && !PressedTheFunny)
			{
				switch (i)
				{
					case 0:
						char.playAnim(char.nativelyPlayable ? 'singLEFT' : 'singRIGHT', true);
					case 1:
						char.playAnim('singDOWN', true);
					case 2:
						char.playAnim('singUP', true);
					case 3:
						char.playAnim(char.nativelyPlayable ? 'singRIGHT' : 'singLEFT', true);
				}
			}
		}
		if (controls.ACCEPT)
		{
			if (isLocked(characters[current].forms[curForm].name) && !(char.curCharacter == 'godshaggy' && PlayState.SONG.song.toLowerCase() == "exploitation"))
			{
				FlxG.camera.shake(0.05, 0.1);
				FlxG.sound.play(Paths.sound('badnoise1'), 0.9);
				return;
			}
			if (PressedTheFunny)
			{
				return;
			}
			else
			{
				PressedTheFunny = true;
			}
			selectedCharacter = true;
			var heyAnimation:Bool = char.animation.getByName("hey") != null; 
			char.playAnim(heyAnimation ? 'hey' : 'singUP', true);
			FlxG.sound.music.fadeOut(1.9, 0);
			FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));
			inCS = false;
			new FlxTimer().start(1.9, endIt);
		}
		if (FlxG.keys.justPressed.LEFT && !selectedCharacter)
		{
			curForm = 0;
			current--;
			if (current < 0)
			{
				current = characters.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[0].loadGraphic(Paths.image("ui/ArrowLeft_Pressed", "preload"));
		}

		if (FlxG.keys.justPressed.RIGHT && !selectedCharacter)
		{
			curForm = 0;
			current++;
			if (current > characters.length - 1)
			{
				current = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			arrows[1].loadGraphic(Paths.image("ui/ArrowRight_Pressed", "preload"));
		}
		
		if (FlxG.keys.justReleased.LEFT)
			arrows[0].loadGraphic(Paths.image("ui/ArrowLeft_Idle", "preload"));
		if (FlxG.keys.justReleased.RIGHT)
			arrows[1].loadGraphic(Paths.image("ui/ArrowRight_Idle", "preload"));

		if (FlxG.keys.justPressed.DOWN && !selectedCharacter)
		{
			curForm--;
			if (curForm < 0)
			{
				curForm = characters[current].forms.length - 1;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.UP && !selectedCharacter)
		{
			curForm++;
			if (curForm > characters[current].forms.length - 1)
			{
				curForm = 0;
			}
			UpdateBF();
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}
		if (FlxG.keys.justPressed.R && !selectedCharacter)
		{
			reset();
			FlxG.resetState();
		}

		if (FlxG.keys.justPressed.SEVEN && FlxG.save.data.adminMode)
		{
			for (character in characters)
			{
				for (form in character.forms)
				{
					unlockCharacter(form.name); // unlock everyone
				}
			}
		}
	}
	public static function unlockCharacter(character:String)
	{
		if (!FlxG.save.data.charactersUnlocked.contains(character))
		{
			FlxG.save.data.charactersUnlocked.push(character);
			FlxG.save.flush();
		}
	}
	public static function isLocked(character:String):Bool
	{
		return !FlxG.save.data.charactersUnlocked.contains(character);
	}
	public static function reset()
	{
		FlxG.save.data.charactersUnlocked = new Array<String>();
		unlockCharacter('bf');
		unlockCharacter('bf-pixel');
		FlxG.save.flush();
	}

	public function UpdateBF()
	{
		var newSelectedCharacter = characters[current];
		if (currentSelectedCharacter.forms[curForm].noteType != newSelectedCharacter.forms[curForm].noteType)
		{
			generateStaticArrows(newSelectedCharacter.forms[curForm].noteType, true);
		}
		
		currentSelectedCharacter = newSelectedCharacter;
		characterText.text = currentSelectedCharacter.forms[curForm].polishedName;
		char.destroy();
		char = new Boyfriend(basePosition.x, basePosition.y, currentSelectedCharacter.forms[curForm].name);
		char.cameras = [camHUD];

		char.x += char.globalOffset[0];
		char.y += char.globalOffset[1];
		
		switch (char.curCharacter)
		{
			case 'bambi-new':
				char.x -= 30;
			case 'bambi-3d':
				char.x -= 150;
				char.y += 100;
			case 'shaggy' | 'supershaggy' | 'redshaggy' | 'godshaggy':
				char.x += 30;
				char.y += 130;
		}
		
		if (char.curCharacter == 'godshaggy') {
		}

		insert(members.indexOf(strummies), char);
		funnyIconMan.changeIcon(char.curCharacter);
		funnyIconMan.color = FlxColor.WHITE;
		if (isLocked(characters[current].forms[curForm].name) && !(char.curCharacter == 'godshaggy' && PlayState.SONG.song.toLowerCase() == "exploitation"))
		{
			char.color = FlxColor.BLACK;
			funnyIconMan.color = FlxColor.BLACK;
			characterText.text = '???';
		}
		legs.color = char.color;
		characterText.screenCenter(X);
		updateIconPosition();
		notemodtext.text = FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[0]) + "x       " + FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[3]) + "x        " + FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[2]) + "x       " + FlxStringUtil.formatMoney(currentSelectedCharacter.forms[curForm].noteMs[1]) + "x";
	}

	override function beatHit()
	{
		super.beatHit();
		if (char != null && !selectedCharacter && curBeat % 2 == 0)
		{
			char.dance();
		}
	}
	function updateIconPosition()
	{
		//var xValues = CoolUtil.getMinAndMax(funnyIconMan.width, characterText.width);
		var yValues = CoolUtil.getMinAndMax(funnyIconMan.height, characterText.height);
		
		funnyIconMan.x = characterText.x + characterText.width / 2;
		funnyIconMan.y = characterText.y + ((yValues[0] - yValues[1]) / 2);
	}
	
	public function endIt(e:FlxTimer = null)
	{
		PlayState.characteroverride = currentSelectedCharacter.name;
		PlayState.formoverride = currentSelectedCharacter.forms[curForm].name;
		PlayState.curmult = currentSelectedCharacter.forms[curForm].noteMs;

		if (PlayState.SONG.song.toLowerCase() == "exploitation" && !FlxG.save.data.modchart)
		{
			FlxG.fullscreen = false;
			FlxG.sound.play(Paths.sound('error'), 0.9);

			PlatformUtil.sendFakeMsgBox("Null Object Reference");
		}
		if (FlxTransitionableState.skipNextTransIn)
		{
			Transition.nextCamera = null;
		}
		FlxG.sound.music.stop();
		LoadingState.loadAndSwitchState(new PlayState());
	}
}
