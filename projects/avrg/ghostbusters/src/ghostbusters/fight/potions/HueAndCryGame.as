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

        mainLoop.pushMode(new LoadingMode());
    }
}

}

import com.threerings.util.ArrayUtil;

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.potions.*;
import ghostbusters.fight.common.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.display.MovieClip;

import flash.events.MouseEvent;

import ghostbusters.fight.ouija.BoardTimer;
import com.whirled.contrib.GameMode;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.flash.DisplayUtil;

class LoadingMode extends AppMode
{
    public function LoadingMode ()
    {
    }
    
    override protected function setup () :void
    {
        ResourceManager.instance.pendResourceLoad("swf", "gameSwf", { embeddedClass: Content.SWF_HUEANDCRYBOARD });
        ResourceManager.instance.load();
    }
    
    override public function update (dt:Number) :void
    {
        super.update(dt);
        
        if (!ResourceManager.instance.isLoading) {
            MainLoop.instance.popMode();
            GameMode.beginGame();
        }
    }
}

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        var targetColor :uint = Colors.getRandomSecondary();
        MainLoop.instance.pushMode(new GameMode(targetColor));
        
        //MainLoop.instance.pushMode(new IntroMode("Mix " + Colors.getColorName(targetColor) + "!"));
        MainLoop.instance.pushMode(new SplashMode("Hue And Cry"));
    }

    protected function endGame (success :Boolean) :void
    {
        if (!_done) {
            MainLoop.instance.pushMode(new OutroMode(success, beginGame));
            _done = true;
        }
    }

    public function GameMode (targetColor :uint)
    {
        _targetColor = targetColor;
    }

    override protected function setup () :void
    {
        // draw the board
        var swfResource :SwfResourceLoader = ResourceManager.instance.getResource("gameSwf") as SwfResourceLoader;
        
        var displayRoot :MovieClip = swfResource.displayRoot as MovieClip;
        this.modeSprite.addChild(displayRoot);
        
        // beaker's initial color?
        var validBeakerColors :Array;
        switch (_targetColor) {
        case Colors.COLOR_ORANGE:
            validBeakerColors = [ Colors.COLOR_RED, Colors.COLOR_YELLOW ];
            break;
            
        case Colors.COLOR_PURPLE:
            validBeakerColors = [ Colors.COLOR_RED, Colors.COLOR_BLUE ];
            break;
            
        case Colors.COLOR_GREEN:
            validBeakerColors = [ Colors.COLOR_YELLOW, Colors.COLOR_BLUE ];
            break;
        }
        
        var initialColor :uint = Colors.COLOR_CLEAR;
        if (validBeakerColors.length > 0 && Rand.nextBoolean(Rand.STREAM_COSMETIC)) {
            initialColor = validBeakerColors[Rand.nextIntRange(0, validBeakerColors.length, Rand.STREAM_COSMETIC)];
        }
        
        // target color
        var targetColorObj :MovieClip = displayRoot.target_card.card.target_color;
        var targetColorMatrix :ColorMatrix = new ColorMatrix();
        targetColorMatrix.colorize(Colors.getScreenColor(_targetColor));
        targetColorObj.filters = [ targetColorMatrix.createFilter() ];
        
        // beaker bottom
        _mixture = DisplayUtil.findInHierarchy(displayRoot, "liquid") as MovieClip;
        
        this.setBeakerColor(initialColor);
        
        // create the droppers
        var droppers :Array = [ displayRoot.dropper_1, displayRoot.dropper_2, displayRoot.dropper_3 ];
        var drops :Array = [ displayRoot.drop_1, displayRoot.drop_2, displayRoot.drop_3 ];
        
        var dropperColors :Array = [ Colors.COLOR_RED, Colors.COLOR_YELLOW, Colors.COLOR_BLUE ];
        ArrayUtil.shuffle(dropperColors);
        
        for (var i :uint = 0; i < 3; ++i) {
            var dropper :Dropper = new Dropper(dropperColors[i], droppers[i]);
            dropper.interactiveObject.addEventListener(MouseEvent.MOUSE_DOWN, this.createDropperClickHandler(dropper));
            this.addObject(dropper);
            
            // tint the drop
            var colorMatrix :ColorMatrix = new ColorMatrix();
            colorMatrix.colorize(Colors.getScreenColor(dropperColors[i]));
            var drop :MovieClip = drops[i];
            drop.filters = [ colorMatrix.createFilter() ];
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
    
    protected function createDropperClickHandler (dropper :Dropper) :Function
    {
        var localThis :GameMode = this;
        return function (e :MouseEvent) :void {
            localThis.addColorToBeaker(dropper.color);
        }
    }
    
    protected function addColorToBeaker (color :uint) :void
    {
        this.setBeakerColor(Colors.getMixedColor(_beakerColor, color));
    }
    
    protected function setBeakerColor (newColor :uint) :void
    {
        _beakerColor = newColor;
        
        if (_beakerColor == Colors.COLOR_CLEAR) {
            _mixture.visible = false;
        } else {
            _mixture.visible = true;
        
            var tintMatrix :ColorMatrix = new ColorMatrix();
            tintMatrix.colorize(Colors.getScreenColor(_beakerColor));
            
            _mixture.filters = [ tintMatrix.createFilter() ];
            
            if (_beakerColor == _targetColor) {
                this.endGame(true);
            } else if (_beakerColor == Colors.COLOR_BROWN) {
                this.endGame(false);
            }
        }
    }
    
    protected var _done :Boolean;
    protected var _targetColor :uint;
    
    protected var _beakerColor :uint;
    protected var _mixture :MovieClip;
    
    protected var _swf :MovieClip;
    
    protected static const GAME_TIME :Number = 6;
    
}
