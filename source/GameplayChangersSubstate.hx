package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class GameplayChangersSubstate extends MusicBeatSubstate
{
	private var curOption:GameplayOption = null;
	private var curSelected:Int = 0;
	private var optionsArray:Array<Dynamic> = [];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var checkboxGroup:FlxTypedGroup<CheckboxThingie>;
	private var grpTexts:FlxTypedGroup<AttachedText>;

	// BIG FAIL
	//private var descBox:FlxSprite;
	//private var descText:FlxText;

	public static var inThePauseMenu:Bool = false;

	public var pauseState:PauseSubState;

	public static var cheater:Bool = false;

	function getOptions()
	{
		var skip:Bool = inThePauseMenu;

		var goption:GameplayOption = new GameplayOption('Scroll Type', 'scrolltype', 'string', 'multiplicative', ["multiplicative", "constant"]);
		optionsArray.push(goption);
		//descText = new FlxText(50, 600, 1180, "Change the Scroll type you want.", 32);

		var option:GameplayOption = new GameplayOption('Scroll Speed', 'scrollspeed', 'float', 1);
		option.scrollSpeed = 2.0;
		option.minValue = 0.35;
		option.changeValue = 0.05;
		option.decimals = 2;
		if (goption.getValue() != "constant")
		{
			option.displayFormat = '%vX';
			option.maxValue = 3;
		}
		else
		{
			option.displayFormat = "%v";
			option.maxValue = 6;
		}
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Change the scroll speed you want.", 32);

		var option:GameplayOption = new GameplayOption('Playback Rate', 'songspeed', 'float', 1);
		option.scrollSpeed = 1;
		option.minValue = -1;
		option.maxValue = 1000000.0; //had to put a limit cause when hold right, it no go fast :(
		option.changeValue = 0.05;
		option.displayFormat = '%vX';
		option.decimals = 2;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "How fast the song should be.", 32);

		var option:GameplayOption = new GameplayOption('Health Gain Multiplier', 'healthgain', 'float', 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.displayFormat = '%vX';
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "How much health do you wanna gain?", 32);

		var option:GameplayOption = new GameplayOption('Health Loss Multiplier', 'healthloss', 'float', 1);
		option.scrollSpeed = 2.5;
		option.minValue = 0.5;
		option.maxValue = 5;
		option.changeValue = 0.1;
		option.displayFormat = '%vX';
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "How much health do you wanna lose?", 32);

		var option:GameplayOption = new GameplayOption('Instakill on Miss', 'instakill', 'bool', false);
		option.onChange = onChangeChartOption;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Instant kill on miss, pretty simple.", 32);

		var option:GameplayOption = new GameplayOption('Practice Mode', 'practice', 'bool', false);
		option.onChange = onChangeCheat;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Basically, doesn't kill you.", 32);

		var option:GameplayOption = new GameplayOption('Botplay', 'botplay', 'bool', false);
		option.onChange = onChangeCheat;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "A bot plays for you!", 32);

		var option:GameplayOption = new GameplayOption('Modchart', 'modchart', 'bool', true);
		option.onChange = onChangeCheat;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Disable modchart and enable modchart.", 32);

		var option:GameplayOption = new GameplayOption('Play Both Sides', 'pbs', 'bool', false);
		option.onChange = onChangeChartOption;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Feeling a bit bored playing one side? How bout' 2 sides?", 32);

		var option:GameplayOption = new GameplayOption('Crash on miss', 'sd', 'bool', false);
		option.onChange = onChangeChartOption;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Crashes your game on miss! Used to be shut down on miss but replaced :(", 32);

		var option:GameplayOption = new GameplayOption('Health Drain', 'hd', 'bool', false);
		option.onChange = onChangeChartOption;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Opponent note hit, you lose health.", 32);

		var option:GameplayOption = new GameplayOption('Sustain 1 note', 'sn', 'bool', false);
		option.onChange = onChangeChartOption;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Really bad version of sustain as one note.", 32);

		var option:GameplayOption = new GameplayOption('Health Drain Part 2', 'hdp2', 'bool', false);
		option.onChange = onChangeChartOption;
		optionsArray.push(option);
		//descText = new FlxText(50, 600, 1180, "Whenever missed, you lose health and the more you miss, you lose more health.", 32);
	}

	public function getOptionByName(name:String)
	{
		for (i in optionsArray)
		{
			var opt:GameplayOption = i;
			if (opt.name == name)
				return opt;
		}
		return null;
	}

	public function new(?pause:MusicBeatSubstate = null)
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		add(bg);

		// avoids lagspikes while scrolling through menus!
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpTexts = new FlxTypedGroup<AttachedText>();
		add(grpTexts);

		checkboxGroup = new FlxTypedGroup<CheckboxThingie>();
		add(checkboxGroup);

		getOptions();

		for (i in 0...optionsArray.length)
		{
			var optionText:Alphabet = new Alphabet(200, 360, optionsArray[i].name, true);
			optionText.isMenuItem = true;
			optionText.setScale(0.8);
			optionText.targetY = i;
			grpOptions.add(optionText);

			if (optionsArray[i].type == 'bool')
			{
				optionText.x += 110;
				optionText.startPosition.x += 110;
				optionText.snapToPosition();
				var checkbox:CheckboxThingie = new CheckboxThingie(optionText.x - 105, optionText.y, optionsArray[i].getValue() == true);
				checkbox.sprTracker = optionText;
				checkbox.offsetX -= 20;
				checkbox.offsetY = -52;
				checkbox.ID = i;
				checkboxGroup.add(checkbox);
			}
			else
			{
				optionText.snapToPosition();
				var valueText:AttachedText = new AttachedText(Std.string(optionsArray[i].getValue()), optionText.width + 40, 0, true, 0.8);
				valueText.sprTracker = optionText;
				valueText.copyAlpha = true;
				valueText.ID = i;
				grpTexts.add(valueText);
				optionsArray[i].setChild(valueText);
			}
			updateTextFrom(optionsArray[i]);
		}

		changeSelection();
		reloadCheckboxes();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];	

		/*
		descText = new FlxText(50, 600, 1180, "ballsack", 32);
		descText.setFormat(Paths.font("funkin.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		*/
	}

	override function destroy()
	{
		if (inThePauseMenu)
		{
			PlayState.instance.changeTheSettingsBitch();
			inThePauseMenu = false;
		}
		super.destroy();
	}

	var nextAccept:Int = 5;
	var holdTime:Float = 0;
	var holdValue:Float = 0;

	override function update(elapsed:Float)
	{
		var shiftMult:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftMult = 10;

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			close();
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (nextAccept <= 0)
		{
			var usesCheckbox = true;
			if (curOption.type != 'bool')
			{
				usesCheckbox = false;
			}

			if (usesCheckbox)
			{
				if (controls.ACCEPT)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					curOption.setValue((curOption.getValue() == true) ? false : true);
					curOption.change();
					reloadCheckboxes();
				}
			}
			else
			{
				if (controls.UI_LEFT || controls.UI_RIGHT)
				{
					var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
					if (holdTime > 0.5 || pressed)
					{
						if (pressed)
						{
							var add:Dynamic = null;
							if (curOption.type != 'string')
							{
								add = controls.UI_LEFT ? -curOption.changeValue : curOption.changeValue;
							}
							if (FlxG.keys.pressed.SHIFT)
							{
								add = controls.UI_LEFT ? -shiftMult : shiftMult;
							}

							switch (curOption.type)
							{
								case 'int' | 'float' | 'percent':
									holdValue = curOption.getValue() + add;
									if (holdValue < curOption.minValue)
										holdValue = curOption.minValue;
									else if (holdValue > curOption.maxValue)
										holdValue = curOption.maxValue;

									switch (curOption.type)
									{
										case 'int':
											holdValue = Math.round(holdValue);
											curOption.setValue(holdValue);

										case 'float' | 'percent':
											holdValue = FlxMath.roundDecimal(holdValue, curOption.decimals);
											curOption.setValue(holdValue);
									}

								case 'string':
									var num:Int = curOption.curOption; // lol
									if (controls.UI_LEFT_P)
										--num;
									else
										num++;

									if (num < 0)
									{
										num = curOption.options.length - 1;
									}
									else if (num >= curOption.options.length)
									{
										num = 0;
									}

									curOption.curOption = num;
									curOption.setValue(curOption.options[num]); // lol

									if (curOption.name == "Scroll Type")
									{
										var oOption:GameplayOption = getOptionByName("Scroll Speed");
										if (oOption != null)
										{
											if (curOption.getValue() == "constant")
											{
												oOption.displayFormat = "%v";
												oOption.maxValue = 6;
											}
											else
											{
												oOption.displayFormat = "%vX";
												oOption.maxValue = 3;
												if (oOption.getValue() > 3)
													oOption.setValue(3);
											}
											updateTextFrom(oOption);
										}
									}
									// trace(curOption.options[num]);
							}
							updateTextFrom(curOption);
							curOption.change();
							FlxG.sound.play(Paths.sound('scrollMenu'));
						}
						else if (curOption.type != 'string')
						{
							holdValue = Math.max(curOption.minValue,
								Math.min(curOption.maxValue, holdValue + curOption.scrollSpeed * elapsed * (controls.UI_LEFT ? -1 : 1)));

							switch (curOption.type)
							{
								case 'int':
									curOption.setValue(Math.round(holdValue));

								case 'float' | 'percent':
									var blah:Float = Math.max(curOption.minValue,
										Math.min(curOption.maxValue, holdValue + curOption.changeValue - (holdValue % curOption.changeValue)));
									curOption.setValue(FlxMath.roundDecimal(blah, curOption.decimals));
							}
							updateTextFrom(curOption);
							curOption.change();
						}
					}

					if (curOption.type != 'string')
					{
						holdTime += elapsed;
					}
				}
				else if (controls.UI_LEFT_R || controls.UI_RIGHT_R)
				{
					clearHold();
				}
			}

			if (controls.RESET)
			{
				for (i in 0...optionsArray.length)
				{
					var leOption:GameplayOption = optionsArray[i];
					leOption.setValue(leOption.defaultValue);
					if (leOption.type != 'bool')
					{
						if (leOption.type == 'string')
						{
							leOption.curOption = leOption.options.indexOf(leOption.getValue());
						}
						updateTextFrom(leOption);
					}

					if (leOption.name == 'Scroll Speed')
					{
						leOption.displayFormat = "%vX";
						leOption.maxValue = 3;
						if (leOption.getValue() > 3)
						{
							leOption.setValue(3);
						}
						updateTextFrom(leOption);
					}
					leOption.change();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				reloadCheckboxes();
			}
		}

		if (nextAccept > 0)
		{
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function updateTextFrom(option:GameplayOption)
	{
		var text:String = option.displayFormat;
		var val:Dynamic = option.getValue();
		if (option.type == 'percent')
			val *= 100;
		var def:Dynamic = option.defaultValue;
		option.text = text.replace('%v', val).replace('%d', def);
	}

	function clearHold()
	{
		if (holdTime > 0.5)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		holdTime = 0;
	}

	function onChangeChartOption()
	{
		if (inThePauseMenu)
		{
			trace("HEY! You changed an option that requires a chart restart!");
			PauseSubState.requireRestart = true;
		}
	}

	function onChangeCheat()
	{
		if (inThePauseMenu)
		{
			trace("you really thought you would get away with it, invalidated your score");
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0)
			curSelected = optionsArray.length - 1;
		if (curSelected >= optionsArray.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
		for (text in grpTexts)
		{
			text.alpha = 0.6;
			if (text.ID == curSelected)
			{
				text.alpha = 1;
			}
		}
		curOption = optionsArray[curSelected]; // shorter lol
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function reloadCheckboxes()
	{
		for (checkbox in checkboxGroup)
		{
			checkbox.daValue = (optionsArray[checkbox.ID].getValue() == true);
		}
	}
}

class GameplayOption
{
	private var child:Alphabet;

	public var text(get, set):String;
	public var onChange:Void->Void = null; // Pressed enter (on Bool type options) or pressed/held left/right (on other types)

	public var type(get, default):String = 'bool'; // bool, int (or integer), float (or fl), percent, string (or str)

	// Bool will use checkboxes
	// Everything else will use a text
	public var showBoyfriend:Bool = false;
	public var scrollSpeed:Float = 50; // Only works on int/float, defines how fast it scrolls per second while holding left/right

	private var variable:String = null; // Variable from ClientPrefs.hx's gameplaySettings

	public var defaultValue:Dynamic = null;

	public var curOption:Int = 0; // Don't change this
	public var options:Array<String> = null; // Only used in string type
	public var changeValue:Dynamic = 1; // Only used in int/float/percent type, how much is changed when you PRESS
	public var minValue:Dynamic = null; // Only used in int/float/percent type
	public var maxValue:Dynamic = null; // Only used in int/float/percent type
	public var decimals:Int = 1; // Only used in float/percent type

	public var displayFormat:String = '%v'; // How String/Float/Percent/Int values are shown, %v = Current value, %d = Default value
	public var name:String = 'Unknown';

	public function new(name:String, variable:String, type:String = 'bool', defaultValue:Dynamic = 'null variable value', ?options:Array<String> = null)
	{
		this.name = name;
		this.variable = variable;
		this.type = type;
		this.defaultValue = defaultValue;
		this.options = options;

		if (defaultValue == 'null variable value')
		{
			switch (type)
			{
				case 'bool':
					defaultValue = false;
				case 'int' | 'float':
					defaultValue = 0;
				case 'percent':
					defaultValue = 1;
				case 'string':
					defaultValue = '';
					if (options.length > 0)
					{
						defaultValue = options[0];
					}
			}
		}

		if (getValue() == null)
		{
			setValue(defaultValue);
		}

		switch (type)
		{
			case 'string':
				var num:Int = options.indexOf(getValue());
				if (num > -1)
				{
					curOption = num;
				}

			case 'percent':
				displayFormat = '%v%';
				changeValue = 0.01;
				minValue = 0;
				maxValue = 1;
				scrollSpeed = 0.5;
				decimals = 2;
		}
	}

	public function change()
	{
		// nothing lol
		if (onChange != null)
		{
			onChange();
		}
	}

	public function getValue():Dynamic
	{
		return ClientPrefs.gameplaySettings.get(variable);
	}

	public function setValue(value:Dynamic)
	{
		ClientPrefs.gameplaySettings.set(variable, value);
	}

	public function setChild(child:Alphabet)
	{
		this.child = child;
	}

	private function get_text()
	{
		if (child != null)
		{
			return child.text;
		}
		return null;
	}

	private function set_text(newValue:String = '')
	{
		if (child != null)
		{
			child.text = newValue;
		}
		return null;
	}

	private function get_type()
	{
		var newValue:String = 'bool';
		switch (type.toLowerCase().trim())
		{
			case 'int' | 'float' | 'percent' | 'string':
				newValue = type;
			case 'integer':
				newValue = 'int';
			case 'str':
				newValue = 'string';
			case 'fl':
				newValue = 'float';
		}
		type = newValue;
		return type;
	}
}
