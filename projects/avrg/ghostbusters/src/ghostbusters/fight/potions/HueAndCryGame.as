package ghostbusters.fight.potions {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;

[SWF(width="296", height="223", frameRate="30")]
public class HueAndCryGame extends Sprite
{
    public function HueAndCryGame ()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();

        GameMode.beginGame();
    }
}

}

import com.threerings.util.ArrayUtil;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.potions.*;
import ghostbusters.fight.common.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.Bitmap;

import ghostbusters.fight.ouija.BoardTimer;

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        var targetColor :uint = Colors.getRandomSecondary();
        MainLoop.instance.pushMode(new GameMode(targetColor));
        
        MainLoop.instance.pushMode(new IntroMode("Mix " + Colors.getColorName(targetColor) + "!"));
        MainLoop.instance.pushMode(new SplashMode("Hue And Cry"));
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.popMode(); // pop this mode
        GameMode.beginGame(); // start a new game
        MainLoop.instance.pushMode(new OutroMode(success)); // but put the game over screen up in front
    }

    public function GameMode (targetColor :uint)
    {
        _targetColor = targetColor;
    }

    override protected function setup () :void
    {
        // draw the board
        this.modeSprite.addChild(new Content.IMAGE_HUEANDCRYBOARD());
        
        // beaker's initial color?
        var validBeakerColors :Array;
        switch (_targetColor) {
        case Colors.COLOR_RED:
        case Colors.COLOR_YELLOW:
        case Colors.COLOR_BLUE:
            validBeakerColors = [ Colors.COLOR_WHITE ];
            break;
            
        case Colors.COLOR_ORANGE:
            validBeakerColors = [ Colors.COLOR_WHITE, Colors.COLOR_RED, Colors.COLOR_YELLOW ];
            break;
            
        case Colors.COLOR_PURPLE:
            validBeakerColors = [ Colors.COLOR_WHITE, Colors.COLOR_RED, Colors.COLOR_BLUE ];
            break;
            
        case Colors.COLOR_GREEN:
            validBeakerColors = [ Colors.COLOR_WHITE, Colors.COLOR_YELLOW, Colors.COLOR_BLUE ];
            break;
        }
        
        var beakerColor :uint = validBeakerColors[Rand.nextIntRange(0, validBeakerColors.length, Rand.STREAM_COSMETIC)];
        
        // draw the beaker bottom
        _beakerBottom = new Content.IMAGE_BEAKERBOTTOM();
        _beakerBottom.x = BEAKERBOTTOM_LOC.x;
        _beakerBottom.y = BEAKERBOTTOM_LOC.y;
        this.setBeakerColor(beakerColor);
        this.modeSprite.addChild(_beakerBottom);
        
        // create the droppers
        var dropperColors :Array = [ Colors.COLOR_RED, Colors.COLOR_YELLOW, Colors.COLOR_BLUE ];
        ArrayUtil.shuffle(dropperColors);
        
        for (var i :uint = 0; i < DROPPER_DATA.length / 2; ++i) {
            var loc :Vector2 = (DROPPER_DATA[i * 2] as Vector2);
            var rot :Number = (DROPPER_DATA[(i * 2) + 1] as Number);
            
            var alignSprite :Sprite = new Sprite();
            alignSprite.x = loc.x;
            alignSprite.y = loc.y;
            alignSprite.rotation = rot;
            
            var dropper :Dropper = new Dropper(dropperColors[i]);
            dropper.x = dropper.width / 2;
            dropper.y = -dropper.height;
            
            this.modeSprite.addChild(alignSprite);
            alignSprite.addChild(dropper.displayObject);
            
            this.addObject(dropper);
        }

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(GAME_TIME);
        this.addObject(boardTimer, this.modeSprite);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(GAME_TIME),
            new FunctionTask(
                function () :void { endGame(false); }
            )));

        this.addObject(timerObj);
    }
    
    protected function setBeakerColor (newColor :uint) :void
    {
        _beakerColor = newColor;
        _beakerBottom.filters = [ ImageTool.createTintFilter(Colors.getScreenColor(_beakerColor)) ];
    }
    
    protected var _targetColor :uint;
    
    protected var _beakerColor :uint;
    protected var _beakerBottom :Bitmap;
    
    protected static const GAME_TIME :Number = 5;
    protected static const BEAKERBOTTOM_LOC :Vector2 = new Vector2(99, 146);
    
    protected static const DROPPER_DATA :Array = [
        new Vector2(108, 87), -30,   // location, rotation
        new Vector2(120, 75), 0,
        new Vector2(135, 63), 30,
    ];
    
}
