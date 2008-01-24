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
        //mainLoop.pushMode(new ImageRecordMode());
    }
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;
import ghostbusters.fight.ouija.*;
import ghostbusters.fight.common.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import flash.events.Event;
import flash.geom.Point;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.Vector3;

class ImageRecordMode extends AppMode
{
    override protected function setup () :void
    {
        _drawing.graphics.lineStyle(Constants.PICTO_LINEWIDTH, 0xFFFFFF, 1);
        
        this.modeSprite.addChild(new Content.IMAGE_PICTOBOARD);
        this.modeSprite.addChild(_drawing);
        this.modeSprite.addChild(_linePreview);
        
        var doneButton :SimpleTextButton = new SimpleTextButton("Done");
        this.modeSprite.addChild(doneButton);
        doneButton.addEventListener(MouseEvent.MOUSE_DOWN, handleDone, false, 0, true);
        
        this.modeSprite.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
        this.modeSprite.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
    }
    
    protected function handleMouseDown (e :MouseEvent) :void
    {
        var p :Vector2 = new Vector2(e.localX, e.localY);
        if (_points.length == 0) {
            _drawing.graphics.moveTo(p.x, p.y);
        } else {
            _drawing.graphics.lineTo(p.x, p.y);
        }
        
        _points.push(p);
    }
    
    protected function handleMouseMove (e :MouseEvent) :void
    {
        if (_points.length > 0) {
            var lastPoint :Vector2 = _points[_points.length - 1];
            
            _linePreview.graphics.clear();
            _linePreview.graphics.lineStyle(Constants.PICTO_LINEWIDTH, 0xFF0000, 1);
            _linePreview.graphics.moveTo(lastPoint.x, lastPoint.y);
            _linePreview.graphics.lineTo(e.localX, e.localY);
        }
    }
    
    protected function handleDone (e :MouseEvent) :void
    {
        trace("[");
        for each (var p :Vector2 in _points) {
            trace("    new Vector2(" + p.x + ", " + p.y + "),");
        }
        trace("],");
        
        MainLoop.instance.popMode();
    }
    
    protected var _points :Array = new Array();
    protected var _drawing :Shape = new Shape();
    protected var _linePreview :Shape = new Shape();
}

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
        if (_done) {
            MainLoop.instance.pushMode(new OutroMode(success, beginGame));
            _done = true;
        }
    }

    public function GameMode ()
    {
        // choose a picture to draw
        _picture = Constants.PICTO_PICTURES[Rand.nextIntRange(0, Constants.PICTO_PICTURES.length, Rand.STREAM_COSMETIC)];
    }

    override protected function setup () :void
    {
        // draw the board
        this.modeSprite.addChild(new Content.IMAGE_PICTOBOARD);

        // draw the picture on the board
        this.modeSprite.addChild(this.createPicture());

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(Constants.PICTO_GAMETIME);
        this.addObject(boardTimer, this.modeSprite);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(Constants.PICTO_GAMETIME),
            new FunctionTask(
                function () :void { endGame(false); }
            )));

        this.addObject(timerObj);
        
        // create the drawing and cursor
        _drawing = new Drawing(this.modeSprite, _picture[0], _picture[_picture.length - 1]);
        this.addObject(_drawing, this.modeSprite);
        
        _cursor = new BasicCursor(this.modeSprite);
        this.addObject(_cursor, this.modeSprite);
        _cursor.alpha = 0.4;
    }
    
    override public function update (dt :Number) :void
    {
        super.update(dt);
        
        if (_drawing.isDone) {
            this.calculateScoreAndEndGame();
        }
    }
    
    protected function pictureSuccessful (iterateForwards :Boolean) :Boolean
    {
        // for each point in the drawing, calculate the distance between
        // it and the target line in the picture
        
        var picture :Array = (iterateForwards ? _picture : _picture.reverse());
        
        var linePt1 :Vector2 = picture[0];
        var linePt2 :Vector2 = picture[1];
        var pictureIdx :int = 1;
        var nextLinePt :Vector2 = getNextLinePt();
        
        var sumDistances :Number = 0;
        
        for each (var pt :Vector2 in _drawing.points) {
            var dist :Number = Collision.minDistanceFromPointToLineSegment(pt, linePt1, linePt2);
            
            if (null != nextLinePt) {
                // if there are more lines in the picture, compare pt
                // to the next line, to see if it's closer
                var distNext :Number = Collision.minDistanceFromPointToLineSegment(pt, linePt2, nextLinePt);
                
                if (distNext < dist) {
                    dist = distNext;
                    
                    // start comparing against the next line
                    linePt1 = linePt2;
                    linePt2 = nextLinePt;
                    nextLinePt = getNextLinePt();
                }
            }
            
            sumDistances += dist;
        }
        
        // if we didn't hit all the lines, we fail
        if (null != nextLinePt) {
            trace("missed lines");
            return false;
        }
        
        var avgDistance :Number = (sumDistances / _drawing.points.length);
        
        trace("total distance: " + sumDistances);
        trace("avg distance: " + avgDistance);
        
        return (avgDistance <= Constants.PICTO_MAXAVGDISTANCE);
        
        function getNextLinePt () :Vector2
        {
            pictureIdx += 1;
            return (picture.length > pictureIdx ? picture[pictureIdx] : null);
        }
    }
    
    protected function calculateScoreAndEndGame () :void
    {
        this.endGame(this.pictureSuccessful(true) || this.pictureSuccessful(false));
    }

    protected function createPicture () :DisplayObject
    {
        var pic :Shape = new Shape();

        // create start and end indicators
        pic.graphics.lineStyle(0, 0, 0);

        var start :Vector2 = _picture[0];
        pic.graphics.beginFill(0x00FF00);
        pic.graphics.drawCircle(start.x, start.y, Constants.PICTO_TARGETRADIUS);
        pic.graphics.endFill();

        var end :Vector2 = _picture[_picture.length - 1];
        if (!end.equals(start)) {
            pic.graphics.beginFill(0x00FF00);
            pic.graphics.drawCircle(end.x, end.y, Constants.PICTO_TARGETRADIUS);
            pic.graphics.endFill();
        }

        // draw the lines
        pic.graphics.lineStyle(Constants.PICTO_LINEWIDTH, 0xFFFFFF);

        var point :Vector2 = _picture[0];
        pic.graphics.moveTo(point.x, point.y);

        for (var i :int = 1; i < _picture.length; ++i) {
            point = _picture[i];
            pic.graphics.lineTo(point.x, point.y);
        }

        return pic;
    }

    protected var _done :Boolean;
    protected var _picture :Array;
    protected var _cursor :BasicCursor;
    protected var _drawing :Drawing;
}
