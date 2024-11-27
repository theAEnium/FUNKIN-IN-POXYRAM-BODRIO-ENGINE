package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 */
class FlxSoundTray extends Sprite
{
    public var active:Bool;
    var _timer:Float;
    var _bars:Array<Bitmap>;
    var _width:Int = 80;
    var _defaultScale:Float = 2.0;

    /** The sound used when increasing the volume. **/
    public var volumeUpSound:String = "flixel/sounds/Volup";

    /** The sound used when decreasing the volume. **/
    public var volumeDownSound:String = "flixel/sounds/Voldown";

    /** The sound used when the volume is at maximum. **/
    public var volumeMaxSound:String = "flixel/sounds/VolMAX";

    /** Whether or not changing the volume should make noise. **/
    public var silent:Bool = false;

    public function new()
    {
        super();

        visible = false;
        scaleX = _defaultScale;
        scaleY = _defaultScale;

        // Add the volumebox image
        var volumeImage:Bitmap = new Bitmap(Assets.getBitmapData("assets/shared/images/volumebox.png"));
        volumeImage.scaleX = 0.3; // Adjust the size of the volumebox
        volumeImage.scaleY = 0.3;
        addChild(volumeImage);

        // Create volume bars using images
        _bars = new Array();
        for (i in 1...11) // 10 bars
        {
            var barImagePath:String = "assets/shared/images/soundtray/bars_" + i + ".png";
            var bar:Bitmap = new Bitmap(Assets.getBitmapData(barImagePath));

            bar.scaleX = 0.34; // Adjust bar size
            bar.scaleY = 0.42;
            bar.visible = false; // Initially hidden
            bar.x = 4.5;
            bar.y = 1.9;  // Ajusta la posición y de las barras

            addChild(bar);
            _bars.push(bar);
        }

        y = -height; // Start hidden
        visible = false;
    }

    public function update(MS:Float):Void
    {
        if (_timer > 0)
        {
            _timer -= (MS / 1000);
        }
        else if (y > -height)
        {
            y -= (MS / 1000) * height * 0.5;

            if (y <= -height)
            {
                visible = false;
                active = false;

                #if FLX_SAVE
                if (FlxG.save.isBound)
                {
                    FlxG.save.data.mute = FlxG.sound.muted;
                    FlxG.save.data.volume = FlxG.sound.volume;
                    FlxG.save.flush();
                }
                #end
            }
        }
    }

    public function show(up:Bool = false):Void
    {
        if (!silent)
        {
            if (FlxG.sound.volume == 1) // Play max sound at full volume
            {
                var maxSound = FlxAssets.getSound(volumeMaxSound);
                if (maxSound != null)
                    FlxG.sound.load(maxSound).play();
            }
            else
            {
                var sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
                if (sound != null)
                    FlxG.sound.load(sound).play();
            }
        }

        _timer = 1;
        y = 0;
        visible = true;
        active = true;

        var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

        if (FlxG.sound.muted)
        {
            globalVolume = 0;
        }

        for (i in 0..._bars.length)
        {
            _bars[i].visible = (i < globalVolume);
        }
    }

    public function screenCenter():Void
    {
        scaleX = _defaultScale;
        scaleY = _defaultScale;

        x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
    }
}
#end