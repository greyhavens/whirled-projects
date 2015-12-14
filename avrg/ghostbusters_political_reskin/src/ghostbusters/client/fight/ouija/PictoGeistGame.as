package ghostbusters.client.fight.ouija {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Shape;

import ghostbusters.client.fight.*;
import ghostbusters.client.fight.common.*;

public class PictoGeistGame extends MicrogameMode
{
    public static const GAME_NAME :String = "";//"Exit Iraq!";
    public static const GAME_DIRECTIONS :String = "Draw Exit Strategy!";

    public function PictoGeistGame (difficulty :int, context :MicrogameContext)
    {
        super(difficulty, context);

        _settings = DIFFICULTY_SETTINGS[Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1)];

        // choose a picture to draw
//        _picture = Constants.PICTO_PICTURES[Rand.nextIntRange(difficulty, Math.min(difficulty + 5, Constants.PICTO_PICTURES.length), Rand.STREAM_COSMETIC)];
        _difficulty = Rand.nextIntRange(0,  Constants.PICTO_PICTURES.length, Rand.STREAM_COSMETIC);
        _picture = Constants.PICTO_PICTURES[_difficulty];
    }

    override public function begin () :void
    {
        
        MainLoop.instance.pushMode(this);
        MainLoop.instance.pushMode(new IntroMode(GAME_NAME, GAME_DIRECTIONS));
        
//        MainLoop.instance.pushMode(new ImageRecordMode());
    }

    override protected function get duration () :Number
    {
        return _settings.gameTime;
    }

    override protected function get timeRemaining () :Number
    {
        return (_done ? 0 : GameTimer.timeRemaining);
    }

    override public function get isDone () :Boolean
    {
        return (_done && !WinLoseNotification.isPlaying);
    }

    override public function get gameResult () :MicrogameResult
    {
        return _gameResult;
    }

    override protected function setup () :void
    {
        // draw the board
//        this.modeSprite.addChild(ImageResource.instantiateBitmap("iraq.board"));

        var iraqboard :MovieClip = SwfResource.getSwfDisplayRoot("iraq.board") as MovieClip;
        
        var soldier :MovieClip = MovieClip(iraqboard["cursor"]);
        trace(soldier.alpha);
//        soldier.x = 50;
//        soldier.y = 50;
        
//        this.modeSprite.addChild(SwfResource.getSwfDisplayRoot("iraq.board"));
        this.modeSprite.addChild(iraqboard);
        
        
        // draw the picture on the board
        this.modeSprite.addChild(this.createPicture());

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, this.modeSprite);

        // install a failure timer
        GameTimer.install(this.duration, function () :void { gameOver(false) });

        // create the drawing and cursor
        _drawing = new Drawing(this.modeSprite, _picture[0], _picture[_picture.length - 1]);
        this.addObject(_drawing, this.modeSprite);
        
        _animatedPath = createAnimatedTarget();
        _drawing.addEventListener( Drawing.STARTED_DRAWING, removeAnimatedCursor);


        function removeAnimatedCursor() :void
        {
            _drawing.removeEventListener( Drawing.STARTED_DRAWING, removeAnimatedCursor);
            _animatedPath.destroySelf();
        }
        _cursor = new IraqCursor(this.modeSprite, soldier);
        this.addObject(_cursor, this.modeSprite);
//        _cursor.alpha = 0.4;
    }


    
    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            GameTimer.uninstall();
            WinLoseNotification.create(success, WIN_STRINGS, LOSE_STRINGS, this.modeSprite);

            _gameResult = new MicrogameResult();
            _gameResult.success = (success ? MicrogameResult.SUCCESS : MicrogameResult.FAILURE);
            _gameResult.damageOutput = (success ? _settings.damageOutput + _difficulty: 0);
//            _gameResult.damageOutput = (success ? 500: 0);0;//TESTING, nuke the ghost!!
            _done = true;
        }
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (_done) {
            return;
        }

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

//        trace("total distance: " + sumDistances);
//        trace("avg distance: " + avgDistance);

        return (avgDistance <= Constants.PICTO_MAXAVGDISTANCE);

        function getNextLinePt () :Vector2
        {
            pictureIdx += 1;
            return (picture.length > pictureIdx ? picture[pictureIdx] : null);
        }
    }

    protected function calculateScoreAndEndGame () :void
    {
        this.gameOver(this.pictureSuccessful(true) || this.pictureSuccessful(false));
    }

    protected function createPicture () :DisplayObject
    {
        var pic :Shape = new Shape();

        // create start and end indicators
        pic.graphics.lineStyle(0, 0, 0);

        var start :Vector2 = _picture[0];
        pic.graphics.beginFill(0x579FC6);
        pic.graphics.drawCircle(start.x, start.y, Constants.PICTO_TARGETRADIUS);
        pic.graphics.endFill();

        var end :Vector2 = _picture[_picture.length - 1];
        if (!end.equals(start)) {
            pic.graphics.beginFill(0x579FC6);
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
        
        pic.graphics.lineStyle(Constants.PICTO_LINEWIDTH-2, 0x579FC6);

        point = _picture[0];
        pic.graphics.moveTo(point.x, point.y);

        for ( i = 1; i < _picture.length; ++i) {
            point = _picture[i];
            pic.graphics.lineTo(point.x, point.y);
        }
        

        return pic;
    }
    
    protected function createAnimatedTarget () :SceneObject
    {
        var pic :Shape = new Shape();

        // create start and end indicators
        pic.graphics.lineStyle(0, 0, 0);

        var end :Vector2 = _picture[_picture.length - 1];
        pic.graphics.beginFill(0x579FC6);
        pic.graphics.drawCircle(0, 0, Constants.PICTO_TARGETRADIUS);
        pic.graphics.endFill();
        
        var speed :Number = 200;
        var point :Vector2 = _picture[0];
        var previouspoint :Vector2 = _picture[0];
        
        var moveOverPath :SerialTask = new SerialTask();
        moveOverPath.addTask( LocationTask.CreateLinear(point.x, point.y, 0));
        for (var i :int = 1; i < _picture.length; ++i) {
            point = _picture[i];
            moveOverPath.addTask( LocationTask.CreateLinear(point.x, point.y, previouspoint.subtract(point).length / speed ));
            previouspoint = _picture[i];
        }
        
        var repeatedTask :RepeatingTask = new RepeatingTask( moveOverPath );
        
        var animatedPoint :SimpleSceneObject = new SimpleSceneObject(pic);
        
        this.addObject( animatedPoint, this.modeSprite);
        animatedPoint.addTask( repeatedTask );
        return animatedPoint;
    }

    protected var _done :Boolean;
    protected var _gameResult :MicrogameResult;
    protected var _picture :Array;
    protected var _cursor :IraqCursor;
    protected var _drawing :Drawing;
    protected var _settings :PictoGeistSettings;
    protected var _animatedPath :SceneObject;

    protected static const DIFFICULTY_SETTINGS :Array = [

        new PictoGeistSettings(9, 8),

    ];

    protected static const WIN_STRINGS :Array = [
//        "\nSUCCESS!",
//        "\nREUNITED!",
        "\nUNTANGLED",
//        "SOLDIERS\nHOME!",
    ];

    protected static const LOSE_STRINGS :Array = [
//        "\n100 more years",
        "6 billion dollars later",
//        "\nneo-conned",
//        "\nquagmire",
    ];
}
}
    import com.whirled.contrib.simplegame.AppMode;
    import flash.events.MouseEvent;
    import flash.display.Shape;
    import com.threerings.flash.SimpleTextButton;
    import com.threerings.flash.Vector2;
    import ghostbusters.client.fight.ouija.Constants;
    import com.whirled.contrib.simplegame.MainLoop;
    import ghostbusters.client.Content;
    import com.whirled.contrib.simplegame.resource.SwfResource;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    


///*


//class ImageRecordMode extends AppMode
//{
//    override protected function setup () :void
//    {
//        _drawing.graphics.lineStyle(Constants.PICTO_LINEWIDTH, 0xFFFFFF, 1);
//
////        this.modeSprite.addChild(new Content.IMAGE_PICTOBOARD);
//        this.modeSprite.addChild( SwfResource.getSwfDisplayRoot("iraq.board") );
//        this.modeSprite.addChild(_drawing);
//        this.modeSprite.addChild(_linePreview);
//
//        var doneButton :SimpleTextButton = new SimpleTextButton("Done");
//        this.modeSprite.addChild(doneButton);
//        doneButton.addEventListener(MouseEvent.MOUSE_DOWN, handleDone, false, 0, true);
//
//        this.modeSprite.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
//        this.modeSprite.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove, false, 0, true);
//    }
//
//    protected function handleMouseDown (e :MouseEvent) :void
//    {
//        var p :Vector2 = new Vector2(e.localX, e.localY);
//        if (_points.length == 0) {
//            _drawing.graphics.moveTo(p.x, p.y);
//        } else {
//            _drawing.graphics.lineTo(p.x, p.y);
//        }
//
//        _points.push(p);
//    }
//
//    protected function handleMouseMove (e :MouseEvent) :void
//    {
//        if (_points.length > 0) {
//            var lastPoint :Vector2 = _points[_points.length - 1];
//
//            _linePreview.graphics.clear();
//            _linePreview.graphics.lineStyle(Constants.PICTO_LINEWIDTH, 0xFF0000, 1);
//            _linePreview.graphics.moveTo(lastPoint.x, lastPoint.y);
//            _linePreview.graphics.lineTo(e.localX, e.localY);
//        }
//    }
//
//    protected function handleDone (e :MouseEvent) :void
//    {
//        trace("[");
//        for each (var p :Vector2 in _points) {
//            trace("    new Vector2(" + p.x + ", " + p.y + "),");
//        }
//        trace("],");
//
//        MainLoop.instance.popMode();
//    }
//
//    
//    protected var _points :Array = new Array();
//    protected var _drawing :Shape = new Shape();
//    protected var _linePreview :Shape = new Shape();
//    protected var _difficulty :int;
//}
//*/


