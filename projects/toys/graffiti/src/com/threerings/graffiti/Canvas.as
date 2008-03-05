// $Id$

package com.threerings.graffiti {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;

import flash.events.MouseEvent;

import flash.utils.setInterval;
import flash.utils.clearInterval;

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.whirled.FurniControl;

import com.threerings.graffiti.tools.Brush;
import com.threerings.graffiti.tools.ToolBox;
import com.threerings.graffiti.tools.ToolEvent;

import com.threerings.graffiti.model.Model;
import com.threerings.graffiti.model.OfflineModel;
import com.threerings.graffiti.model.OnlineModel;
import com.threerings.graffiti.model.Stroke;

public class Canvas extends Sprite
{
    public static const CANVAS_WIDTH :int = 400;
    public static const CANVAS_HEIGHT :int = 400;

    /**
     * This function should not be called directly.  Instead, call createCanvas() with the 
     * FurniControl.
     */
    public function Canvas (control :FurniControl)
    {
        _background = new Sprite();
        addChild(_background);
        _canvas = new Sprite();
        addChild(_canvas);

        var masker :Shape = new Shape();
        masker.graphics.beginFill(0);
        masker.graphics.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        masker.graphics.endFill();
        addChild(masker);
        mask = masker;

        // TODO: temporarily just staying offline while we get the tools sorted out.
        _model = new OfflineModel(this);
        redraw();
    }

    public function get toolbox () :ToolBox
    {
        // toolbox creation is deferred so view-only canvases don't instantiate one.
        if (_toolBox == null) {
            // defer adding the mouse listeners as well - we don't need them on a view-only canvas.
            addMouseListeners();

            _toolBox = new ToolBox(this);
            _toolBox.addEventListener(ToolEvent.COLOR_PICKED, function (event :ToolEvent) :void {
                _color = event.value as uint;
            });
            _toolBox.addEventListener(ToolEvent.BRUSH_PICKED, function (event :ToolEvent) :void {
                _brush = event.value as Brush;
            });
            _toolBox.addEventListener(ToolEvent.BACKGROUND_COLOR, 
                function (event :ToolEvent) :void {
                    _model.setBackgroundColor(event.value as uint);
                });
        }

        return _toolBox;
    }

    public function paintBackground (color :uint) :void
    {
        var g :Graphics = _background.graphics;
        g.clear();
        g.beginFill(_backgroundColor = color);
        g.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        g.endFill();
    }

    public function strokeBegun (id :String, stroke :Stroke) :void
    {
        _outputKey = id;

        _canvas.graphics.moveTo(stroke.start.x, stroke.start.y);
        _canvas.graphics.lineStyle(stroke.brush.thickness, stroke.color, stroke.brush.alpha);

        _lastX = stroke.start.x;
        _lastY = stroke.start.y;
        _oldDeltaX = _oldDeltaY = 0;

        strokeExtended(id, stroke.getPoint(0));
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

    public function reportFillPercent (percent :Number) :void
    {
        if (_toolBox != null) {
            _toolBox.displayFillPercent(percent);
        }
    }

    protected function addMouseListeners () :void
    {
        _background.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _canvas.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _background.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        _canvas.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        _background.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        _canvas.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        _lastStrokePoint = _canvas.globalToLocal(new Point(evt.stageX, evt.stageY));
        _newStroke = true;
        _inputKey = _model.getKey();
        _timer = setInterval(tick, TICK_INTERVAL);
    }

    protected function tick () :void
    {
        maybeAddStroke(new Point(_canvas.mouseX, _canvas.mouseY));
    }

    protected function mouseUp (evt :MouseEvent) :void
    {
        endStroke(_canvas.globalToLocal(new Point(evt.stageX, evt.stageY)));
    }

    protected function endStroke (localPoint :Point) :void 
    {
        maybeAddStroke(localPoint);
        if (_timer > 0) {
            clearInterval(_timer);
            _timer = 0;
        }
        _inputKey = null;
    }

    protected function mouseOut (evt :MouseEvent) :void
    {
        var canvasPoint :Point = _canvas.globalToLocal(new Point(evt.stageX, evt.stageY));
        var breakLine :Boolean = false;
        if (canvasPoint.x < 0) {
            breakLine = true;
            canvasPoint.x = 0;
        } else if (canvasPoint.x >= CANVAS_WIDTH) {
            breakLine = true;
            canvasPoint.x = CANVAS_WIDTH - 1;
        }
        
        if (canvasPoint.y < 0) {
            breakLine = true;
            canvasPoint.y = 0;
        } else if (canvasPoint.y >= CANVAS_HEIGHT) {
            breakLine = true;
            canvasPoint.y = CANVAS_HEIGHT - 1;
        }

        if (breakLine) {
            endStroke(canvasPoint);
        }
    }

    protected function maybeAddStroke (p :Point) :void
    {
        if (p.x < 0 || p.x > CANVAS_WIDTH || p.y < 0 || p.y > CANVAS_HEIGHT) {
            return;
        }

        if (_lastStrokePoint == null) {
            return;
        }

        var dx :Number = p.x - _lastStrokePoint.x;
        var dy :Number = p.y - _lastStrokePoint.y;
        if (dx*dx + dy*dy < 9) {
            return;
        }

        if (_inputKey == null) {
            return;
        }

        if (_newStroke) {
            _model.beginStroke(_inputKey, _lastStrokePoint, p, _color, _brush);

        } else {
            _model.extendStroke(_inputKey, p);
        }

        _lastStrokePoint = p;
        _newStroke = false;
    }

    protected function redraw (lastId :String = null) :void
    {
        paintBackground(_model.getBackgroundColor());
        _canvas.graphics.clear();
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

    protected function drawStroke (key :String, stroke :Stroke) :void
    {
        strokeBegun(key, stroke);
        for (var ii :int = 1; ii < stroke.getSize(); ii++) {
            strokeExtended(key, stroke.getPoint(ii));
        }
    }

    private static const log :Log = Log.getLog(Canvas);

    /** The number of milliseconds between mouse samples.  The lower the number, the higher the 
     * drawing resolution, but the faster it fills up the available memory.  We may want to make
     * this configurable in a slider control. Reasonable values are between 50 and 200ish. */
    protected static const TICK_INTERVAL :int = 100;

    protected var _model :Model;

    protected var _background :Sprite;
    protected var _canvas :Sprite;
    protected var _toolBox :ToolBox;

    // variables for user input
    protected var _inputKey :String;

    protected var _backgroundColor :uint;
    protected var _color :uint;
    protected var _brush :Brush;

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
