// $Id$

package com.threerings.graffiti {

import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.MouseEvent;

import flash.utils.setInterval;
import flash.utils.clearInterval;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.FurniControl;

public class Canvas extends Sprite
{
    public static const CANVAS_WIDTH :int = 400;
    public static const CANVAS_HEIGHT :int = 400;

    public static function createCanvas (control :FurniControl) :Canvas
    {
        var canvas :Canvas = new Canvas();
//        var model :Model = 
//            control.isConnected() ? new OnlineModel(canvas, control) : new OfflineModel(canvas);
//        canvas.setModel(model);
        // TODO: temporarily just staying offline while we get the tools sorted out.
        canvas.setModel(new OfflineModel(canvas));
        return canvas;
    }

    /**
     * This function should not be called directly.  Instead, call createCanvas() with the 
     * FurniControl.
     */
    public function Canvas ()
    {
        _canvas = new Sprite();
        addChild(_canvas);

        _canvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _canvas.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
    }

    public function pickColor (color :int) :void
    {
        _color = color;
    }

    public function strokeBegun (id :String, from :Point, to :Point, color :int) :void
    {
        _outputKey = id;

        _canvas.graphics.moveTo(from.x, from.y);
        _canvas.graphics.lineStyle(4, color, 0.7);

        _lastX = from.x;
        _lastY = from.y;
        _oldDeltaX = _oldDeltaY = 0;

        strokeExtended(id, to);
    }

    public function strokeExtended (id :String, to :Point) :void
    {
        if (id != _outputKey) {
            redraw(id);
            return;
        }
        var dX :Number = to.x - _lastX;
        var dY :Number = to.y - _lastY;

        // the new spline is continuous with the old, but not aggressively so
        var controlX :Number = _lastX + _oldDeltaX * 0.4;
        var controlY :Number = _lastY + _oldDeltaY * 0.4;

        _canvas.graphics.curveTo(controlX, controlY, to.x, to.y);

        _lastX = to.x;
        _lastY = to.y;

        _oldDeltaX = to.x - controlX;
        _oldDeltaY = to.y - controlY;
    }

    protected function setModel (model :Model) :void
    {
        _model = model;
        redraw();
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        _lastStrokePoint = _canvas.globalToLocal(new Point(evt.stageX, evt.stageY));
        _newStroke = true;
        _inputKey = _model.getKey();
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
        _inputKey = null;
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
            _model.beginStroke(_inputKey, _lastStrokePoint, p, _color);

        } else {
            _model.extendStroke(_inputKey, p);
        }

        _lastStrokePoint = p;
        _newStroke = false;
    }

    protected function redraw (lastId :String = null) :void
    {
        _canvas.graphics.clear();

        _canvas.graphics.beginFill(0x444444);
        _canvas.graphics.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        _canvas.graphics.endFill();

        var strokes :HashMap = _model.getStrokes();
        var keys :Array = strokes.keys();
        for (var ii :int = 0; ii < keys.length; ii ++) {
            if (keys[ii] == lastId) {
                continue;
            }
            drawStroke(keys[ii], strokes.get(keys[ii]));
        }
        if (lastId != null) {
            drawStroke(lastId, strokes.get(lastId));
        }
    }

    protected function drawStroke (key :String, stroke :Array) :void
    {
        var first :Array = stroke[0] as Array;
        strokeBegun(key, first[0], first[1], first[2]);
        for (var jj :int = 1; jj < stroke.length; jj ++) {
            strokeExtended(key, stroke[jj]);
        }
    }

    private static const log :Log = Log.getLog(Canvas);

    protected var _model :Model;

    protected var _canvas :Sprite;

    // variables for user input
    protected var _inputKey :String;

    protected var _color :int;

    protected var _timer :int;
    protected var _lastStrokePoint :Point;
    protected var _newStroke :Boolean;

    // variables for canvas output
    protected var _outputKey :String;

    protected var _lastX :Number;
    protected var _lastY :Number;

    protected var _oldDeltaX :Number;
    protected var _oldDeltaY :Number;
}
}
