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
        var targetColor :uint = Rand.nextIntRange(0, Colors.COLOR__LIMIT, Rand.STREAM_COSMETIC);
        
        MainLoop.instance.pushMode(new GameMode(Colors.COLOR_WHITE, targetColor));
        
        //MainLoop.instance.pushMode(new IntroMode("Spell '" + word.toLocaleUpperCase() + "'"));
        MainLoop.instance.pushMode(new SplashMode("Hue And Cry"));
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.popMode(); // pop this mode
        GameMode.beginGame(); // start a new game
        MainLoop.instance.pushMode(new OutroMode(success)); // but put the game over screen up in front
    }

    public function GameMode (initialColor :uint, targetColor :uint)
    {
        _initialColor = initialColor;
        _targetColor = targetColor;
    }

    override protected function setup () :void
    {
        // draw the board
        this.modeSprite.addChild(new Content.IMAGE_HUEANDCRYBOARD());
        
        // draw the beaker bottom
        _beakerBottom = new Content.IMAGE_BEAKERBOTTOM();
        _beakerBottom.x = BEAKERBOTTOM_LOC.x;
        _beakerBottom.y = BEAKERBOTTOM_LOC.y;
        this.setBeakerColor(_initialColor);
        this.modeSprite.addChild(_beakerBottom);
        
        // add a dropper
        this.addObject(new Dropper(Colors.COLOR_PURPLE), this.modeSprite);

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
    
    protected var _initialColor :uint;
    protected var _targetColor :uint;
    
    protected var _beakerColor :uint;
    protected var _beakerBottom :Bitmap;
    
    protected static const GAME_TIME :Number = 5;
    protected static const BEAKERBOTTOM_LOC :Vector2 = new Vector2(99, 146);
    
}
