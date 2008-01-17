package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

[SWF(width="296", height="223", frameRate="30")]
public class PictoGeistGame extends Sprite
{
    public function PictoGeistGame ()
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
import ghostbusters.fight.ouija.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.geom.Point;

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        MainLoop.instance.pushMode(new GameMode());
        MainLoop.instance.pushMode(new IntroMode("Draw!"));
        MainLoop.instance.pushMode(new SplashMode("PictoGeist"));
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.popMode(); // pop this mode
        GameMode.beginGame(); // start a new game
        MainLoop.instance.pushMode(new OutroMode(success)); // but put the game over screen up in front
    }

    public function GameMode ()
    {
        // choose a picture to draw
        _picture = PICTURES[Rand.nextIntRange(0, PICTURES.length, Rand.STREAM_COSMETIC)];
        _picture = this.chopLines(_picture, 4);
        trace("picture length: " + _picture.length);
    }

    override protected function setup () :void
    {
        // draw the board
        this.modeSprite.addChild(new Content.IMAGE_PICTOBOARD);

        // draw the picture on the board
        this.modeSprite.addChild(this.createPicture());

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
        
        // create the drawing and cursor
        _drawing = new Drawing(this.modeSprite, _picture[0], _picture[_picture.length - 1]);
        this.addObject(_drawing, this.modeSprite);
        
        _cursor = new BasicCursor(this.modeSprite);
        this.addObject(_cursor, this.modeSprite);
    }
    
    override public function update (dt :Number) :void
    {
        super.update(dt);
        
        if (_drawing.isDone) {
            this.calculateScoreAndEndGame();
        }
    }
    
    protected function calculateScoreAndEndGame () :void
    {
        
    }
    
    protected function chopLines (points :Array, maxDistance :Number) :Array
    {
        // chop up an array of points so that the distance between two consecutive points is no more than maxDistance
        
        if (points.length <= 1) {
            return new Array(); // need at least 2 points
        }
        
        var out :Array = new Array();
        
        out.push(points[0]);
        
        for (var i :uint = 1; i < points.length; ++i) {
            var thisPoint :Vector2 = points[i];
            var lastPoint :Vector2 = points[i - 1];
            
            var direction :Vector2 = lastPoint.getSubtract(thisPoint);
            var distance :Number = (direction.length);
            direction.length = 1;
            
            var numChops :int = Math.floor(distance / maxDistance);
            for (var j :uint = 1; j <= numChops; ++j) {
                var newPoint :Vector2 = direction.getScale(maxDistance * j);
                newPoint.add(lastPoint);
                
                out.push(newPoint);
            }
            
            out.push(thisPoint);
        }
        
        return out;
    }

    protected function createPicture () :DisplayObject
    {
        var pic :Shape = new Shape();

        // create start and end indicators
        pic.graphics.lineStyle(0, 0, 0);

        point = _picture[0];
        pic.graphics.beginFill(0x00FF00);
        pic.graphics.drawCircle(point.x, point.y, 6);
        pic.graphics.endFill();

        point = _picture[_picture.length - 1];
        pic.graphics.beginFill(0xFF0000);
        pic.graphics.drawCircle(point.x, point.y, 6);
        pic.graphics.endFill();

        // draw the lines
        pic.graphics.lineStyle(4, 0x000000);

        var point :Vector2 = _picture[0];
        pic.graphics.moveTo(point.x, point.y);

        for (var i :int = 1; i < _picture.length; ++i) {
            point = _picture[i];
            pic.graphics.lineTo(point.x, point.y);
        }

        return pic;
    }

    protected var _picture :Array;
    protected var _cursor :BasicCursor;
    protected var _drawing :Drawing;

    protected static const GAME_TIME :Number = 20000;

    protected static const PICTURES :Array = [

        // straight line
        [
            new Vector2(70, 130),
            new Vector2(220, 130),
        ],

        // box
        [
            new Vector2(70, 85),
            new Vector2(170, 85),
            new Vector2(170, 185),
            new Vector2(70, 185),
            new Vector2(70, 95),
        ],

    ];
}
