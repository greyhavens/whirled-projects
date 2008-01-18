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
    public function Board ()
    {
        _canvas = new Sprite();
        this.addChild(_canvas);

        _control = new FurniControl(this);
        if (_control.isConnected()) {
            _control.addEventListener(ControlEvent.MEMORY_CHANGED, memoryChanged);
            initStrokes();
        }

        _canvas.graphics.beginFill(0xDDDDDD);
        _canvas.graphics.drawRect(0, 0, 256, 256);
        _canvas.graphics.endFill();

        _canvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _canvas.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        _lastStrokePoint = _canvas.globalToLocal(new Point(evt.stageX, evt.stageY));
        _newStroke = true;
        _timer = setInterval(tick, 200);
        log.debug("Started a stroke: " + _lastStrokePoint);
    }

    protected function tick () :void
    {
        maybeAddStroke(new Point(_canvas.mouseX, _canvas.mouseY));
    }

    protected function mouseUp (evt :MouseEvent) :void
    {
        log.debug("mouseUp(" + evt + ")");
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
        if (dx*dx + dy*dy < 8) {
            return;
        }

//        log.debug("Adding stroke: " + p);
        var stroke :Array;
        if (_newStroke) {
            stroke = [ p.x, p.y, _lastStrokePoint.x, _lastStrokePoint.y ];
        } else {
            stroke = [ p.x, p.y ];
        }
        if (_control.isConnected()) {
            _lastKey ++;
            _control.updateMemory(String(_lastKey), stroke);
        } else {
            paintStroke(stroke);
        }
        _lastStrokePoint = p;
        _newStroke = false;
    }

    protected function initStrokes () :void
    {
        _strokes = new Array();

        var memories :Object = _control.getMemories();
        for (var key :String in memories) {
            _strokes.push({ "key": key, "stroke": memories[key] });
        }
        _strokes.sortOn("key", Array.NUMERIC);

        var lastKey :String = "0";
        for (var ii :int = 0; ii < _strokes.length; ii ++) {
            paintStroke(_strokes[ii]["stroke"] as Array);
            lastKey = _strokes[ii]["key"];
        }
        _lastKey = Number(lastKey);
    }

    protected function memoryChanged (evt :ControlEvent) :void
    {
        _strokes.push({ "key": evt.name, "stroke": evt.value });
        paintStroke(evt.value as Array);
        _lastKey = Number(evt.name);
    }

    protected function paintStroke (stroke :Array) :void
    {
        log.debug("Painting stroke: " + stroke);

        if (stroke.length == 4) {
            _canvas.graphics.moveTo(stroke[2], stroke[3]);
            _canvas.graphics.lineStyle(4, 0, 0.7);

            _lastX = stroke[2];
            _lastY = stroke[3];
            _tanX = _tanY = 0;
            trace("YYYYYYYYYYY");
        }
        var dX :Number = stroke[0] - _lastX;
        var dY :Number = stroke[1] - _lastY;

        var dot :Number;
        if (_tanX == 0 && _tanY == 0) {
            // handle this as a special case
            dot = 0;

        } else {
            // find the dot product between previous tangent & new vector
            dot = _tanX * dX + _tanY * dY;
            if (dot < 0.3) {
                log.debug("Eek, reversal [dot=" + dot + "]; truncating at 0.1");
                dot = 0.3;
            }
        }

        // choose a controlpoint that's halway there
        var controlX :Number = _lastX + _tanX * dot/2;
        var controlY :Number = _lastY + _tanY * dot/2;

        var foo :Shape = new Shape();
        this.addChild(foo);
        foo.x = controlX;
        foo.y = controlY;
        foo.graphics.beginFill(0xFF0000);
        foo.graphics.drawCircle(0, 0, 3);
        foo.graphics.endFill();

        log.debug("delta = (" + dX + "/" + dY + "); control = (" + controlX + ", " + controlY + ")");
        _canvas.graphics.curveTo(controlX, controlY, stroke[0], stroke[1]);

        _lastX = stroke[0];
        _lastY = stroke[1];

        // now figure out what the tangent ended as
        dX = stroke[0] - controlX;
        dY = stroke[1] - controlY;
        var dLen :Number = Math.sqrt(dX*dX + dY*dY);

        if (dLen > 0) {
            _tanX = dX / dLen;
            _tanY = dY / dLen;

        } else {
            trace("XXXXXXXXX");
            _tanX = _tanY = 0;
        }
    }

    protected var _control :FurniControl;
    protected var _canvas :Sprite;
    protected var _strokes :Array;
    protected var _lastKey :int;

    protected var _timer :int;
    protected var _lastStrokePoint :Point;
    protected var _newStroke :Boolean;

    protected var _lastX :Number;
    protected var _lastY :Number;

    protected var _tanX :Number;
    protected var _tanY :Number;

    protected const log :Log = Log.getLog(Board);
}
}
