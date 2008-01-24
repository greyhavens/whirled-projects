//
// $Id$

package {

import flash.display.BlendMode;
import flash.display.CapsStyle;
import flash.display.LineScaleMode;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.setInterval;
import flash.utils.clearInterval;

import com.threerings.util.Log;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

[SWF(width="256", height="256")]
public class Board extends Sprite
{
    public static const log :Log = Log.getLog(Board);

    public function Board ()
    {
        _canvas = new Sprite();
        this.addChild(_canvas);

        _palette = new Palette(this, 0);
        this.addChild(_palette);

        _points = new Sprite();
        _points.visible = false;
        this.addChild(_points);

        _strokes = new Array();

        var control :FurniControl = new FurniControl(this);

        _model = control.isConnected() ? new OnlineModel(this, control) : new OfflineModel(this);

        _canvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _canvas.addEventListener(MouseEvent.MOUSE_UP, mouseUp);

        redraw();
    }

    public function pickColour (colour :int) :void
    {
        _colour = colour;
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        _lastStrokePoint = _canvas.globalToLocal(new Point(evt.stageX, evt.stageY));
        _newStroke = true;
        _timer = setInterval(tick, 200);
    }

    protected function tick () :void
    {
        maybeAddStroke(new Point(_canvas.mouseX, _canvas.mouseY));
    }

    protected function mouseUp (evt :MouseEvent) :void
    {
        maybeAddStroke(_canvas.globalToLocal(new Point(evt.stageX, evt.stageY)));
        if (_timer > 0) {
            clearInterval(_timer);
            _timer = 0;
        }
    }

    protected function maybeAddStroke (p :Point) :void
    {
        if (p.x < 0 || p.x > 255 || p.y < 0 || p.y > 255) {
            return;
        }
        var dx :Number = p.x - _lastStrokePoint.x;
        var dy :Number = p.y - _lastStrokePoint.y;
        if (dx*dx + dy*dy < 9) {
            return;
        }

        if (_newStroke) {
            _model.beginStroke(String(_lastKey), _lastStrokePoint, p, _colour);
            _lastKey ++;

        } else {
            _model.extendStroke(String(_lastKey), p);
        }

        _lastStrokePoint = p;
        _newStroke = false;
    }

// TODO: reintegrate control points
//         var point :Shape = new Shape();
//         _points.addChild(point);
//         point.x = stroke[0];
//         point.y = stroke[1];
//         point.graphics.beginFill(0xFF0000);
//         point.graphics.drawCircle(0, 0, 1);
//         point.graphics.endFill();

    protected function redraw () :void
    {
        _canvas.graphics.clear();

        _canvas.graphics.beginFill(0x444444);
        _canvas.graphics.drawRect(0, 0, 256, 256);
        _canvas.graphics.endFill();

        var lastKey :String = "0";
        for (var ii :int = 0; ii < _strokes.length; ii ++) {
            paintStroke(_strokes[ii]["stroke"] as Array);
            lastKey = _strokes[ii]["key"];
        }
        _lastKey = Number(lastKey);
    }

    protected function paintStroke (stroke :Array) :void
    {
        if (stroke.length == 5) {
            _canvas.graphics.moveTo(stroke[2], stroke[3]);
            _canvas.graphics.lineStyle(4, stroke[4], 0.7);

            _lastX = stroke[2];
            _lastY = stroke[3];
            _oldDeltaX = _oldDeltaY = 0;
        }
        var dX :Number = stroke[0] - _lastX;
        var dY :Number = stroke[1] - _lastY;

        // the new spline is continuous with the old, but not aggressively so
        var controlX :Number = _lastX + _oldDeltaX * 0.4;
        var controlY :Number = _lastY + _oldDeltaY * 0.4;

        _canvas.graphics.curveTo(controlX, controlY, stroke[0], stroke[1]);

        _lastX = stroke[0];
        _lastY = stroke[1];

        _oldDeltaX = stroke[0] - controlX;
        _oldDeltaY = stroke[1] - controlY;
    }

    protected var _model :Model;

    protected var _canvas :Sprite;
    protected var _points :Sprite;
    protected var _palette :Palette;

    protected var _colour :int;

    protected var _strokes :Array;
    protected var _lastKey :int;

    protected var _timer :int;
    protected var _lastStrokePoint :Point;
    protected var _newStroke :Boolean;

    protected var _lastX :Number;
    protected var _lastY :Number;

    protected var _oldDeltaX :Number;
    protected var _oldDeltaY :Number;
}
}
