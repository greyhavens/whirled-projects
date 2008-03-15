// $Id$

package com.threerings.graffiti {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.geom.Point;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.setInterval; // function import
import flash.utils.clearInterval; // function import

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import com.threerings.graffiti.tools.BrushTool;
import com.threerings.graffiti.tools.Tool;
import com.threerings.graffiti.tools.ToolBox;
import com.threerings.graffiti.tools.ToolEvent;

import com.threerings.graffiti.model.Model;
import com.threerings.graffiti.model.OfflineModel;
import com.threerings.graffiti.model.OnlineModel;
import com.threerings.graffiti.model.Stroke;

public class Canvas extends Sprite
{
    public static const CANVAS_WIDTH :int = 600;
    public static const CANVAS_HEIGHT :int = 436;

    public function Canvas (model :Model)
    {
        addChild(_background = new Sprite());
        addChild(_canvas = new Sprite());
        addChild(_tempSurface = new Sprite());

        var masker :Shape = new Shape();
        masker.graphics.beginFill(0);
        masker.graphics.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        masker.graphics.endFill();
        addChild(masker);
        mask = masker;

        _model = model;
        var thisCanvas :Canvas = this;
        _model.registerCanvas(thisCanvas);
        addEventListener(Event.REMOVED_FROM_STAGE, function (event :Event) :void {
            _model.unregisterCanvas(thisCanvas);
        });
        redraw();
    }

    public function get toolbox () :ToolBox
    {
        // toolbox creation is deferred so view-only canvases don't instantiate one.
        if (_toolBox == null) {
            // defer adding the mouse listeners as well - we don't need them on a view-only canvas.
            addMouseListeners();

            _toolBox = new ToolBox(this, _model.getBackgroundColor(), 
                                   _model.getBackgroundTransparent());
            _toolBox.addEventListener(ToolEvent.TOOL_PICKED, function (event :ToolEvent) :void {
                _tool = event.value as Tool;
            });
            _toolBox.addEventListener(ToolEvent.BACKGROUND_COLOR, 
                function (event :ToolEvent) :void {
                    _model.setBackgroundColor(event.value as uint);
                });
            _toolBox.addEventListener(ToolEvent.CLEAR_CANVAS, function (event :ToolEvent) :void {
                _model.clearCanvas();
            });
            _toolBox.addEventListener(ToolEvent.BACKGROUND_TRANSPARENCY, 
                function (event :ToolEvent) :void {
                    _model.setBackgroundTransparent(event.value as Boolean);
                });
        }

        return _toolBox;
    }

    public function setBackgroundTransparent (transparent :Boolean) :void
    {
        var color :uint = transparent ? 0 : _model.getBackgroundColor();
        var g :Graphics = _background.graphics;
        g.clear();
        g.beginFill(color);
        g.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        g.endFill();
        _background.blendMode = transparent ? BlendMode.SCREEN : BlendMode.NORMAL;
    }

    /**
     * @param color if this isNaN(), the background will be made transparent.
     */
    public function paintBackground (color :uint) :void
    {
        if (_model.getBackgroundTransparent()) {
            return;
        }

        var g :Graphics = _background.graphics;
        g.clear();
        g.beginFill(_backgroundColor = color);
        g.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        g.endFill();
    }

    /**
     * Draw a segment of a stroke on the drawing surface.  If this is an extension of the stroke
     * that was previously being drawn, then it will simply extend.  Otherwise, it will draw this
     * segment as if it were an independent stroke.
     */
    public function tempStroke (id :String, stroke :Stroke, startPoint :int = 0) :void
    {
        log.debug("temp stroke [" + this.name + ", " + id + ", " + stroke + ", " + startPoint + 
            "]");

        var start :Point = stroke.getPoint(startPoint);
        if (start == null) {
            log.warning("null start point [" + stroke + ", " + startPoint + "]");
            return;
        }

        if (id != _lastId || startPoint != _lastEndPoint) {
            stroke.tool.mouseDown(_tempSurface.graphics, start);
        }

        _lastId = id;

        for (var ii :int = startPoint + 1; ii < stroke.getSize(); ii++) {
            stroke.tool.dragTo(_tempSurface.graphics, stroke.getPoint(ii));
            _lastEndPoint = ii;
        }
    }

    /** 
     * Draws a full stroke on the canvas.
     */
    public function canvasStroke (stroke :Stroke) :void
    {
        log.debug("canvas stroke [" + this.name + ", " + stroke + "]");

        if (stroke.getSize() < 2) {
            log.warning("Asked to draw stroke with less than two points [" + stroke + "]");
            return;
        }

        stroke.tool.mouseDown(_canvas.graphics, stroke.getPoint(0));

        for (var ii :int = 1; ii < stroke.getSize(); ii++) {
            stroke.tool.dragTo(_canvas.graphics, stroke.getPoint(ii));
        }
    }

    public function reportFillPercent (percent :Number) :void
    {
        if (_toolBox != null) {
            _toolBox.displayFillPercent(percent);
        }
    }

    protected function addMouseListeners () :void
    {
        var sprites :Array = [ _background, _canvas, _tempSurface ];
        for each (var sprite :Sprite in sprites) {
            sprite.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
            sprite.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
            sprite.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
        }
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
        maybeAddStroke(localPoint, true);
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

    protected function maybeAddStroke (p :Point, end :Boolean = false) :void
    {
        if (p.x < 0 || p.x > CANVAS_WIDTH || p.y < 0 || p.y > CANVAS_HEIGHT) {
            return;
        }

        if (_lastStrokePoint == null || _inputKey == null) {
            return;
        }

        var dx :Number = p.x - _lastStrokePoint.x;
        var dy :Number = p.y - _lastStrokePoint.y;
        if (dx*dx + dy*dy < 9) {
            if (end) {
                _model.endStroke(_inputKey);
            }
            return;
        }

        if (_newStroke && end) {
            log.warning("newStroke and end!");
        } else {
            if (_newStroke) {
                _model.beginStroke(_inputKey, _lastStrokePoint, p, _tool);

            } else {
                _model.extendStroke(_inputKey, p, end);
            }
        }

        _lastStrokePoint = p;
        _newStroke = false;
    }

    public function redraw () :void
    {
        paintBackground(_model.getBackgroundColor());

        _canvas.graphics.clear();
        var strokes :Array = _model.getCanvasStrokes();
        for each (var stroke :Stroke in strokes) {
            canvasStroke(stroke);
        }

        redrawTemp();
    }

    public function redrawTemp () :void
    {
        _tempSurface.graphics.clear();
        var ids :Array = _model.getTempStrokeIds();
        for each (var id :String in ids) {
            tempStroke(id, _model.getTempStroke(id));
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
    protected var _tempSurface :Sprite;
    protected var _toolBox :ToolBox;

    // variables for user input
    protected var _inputKey :String;

    protected var _backgroundColor :uint;
    protected var _tool :Tool = new BrushTool();

    protected var _timer :int;
    protected var _lastStrokePoint :Point;
    protected var _newStroke :Boolean;

    // variables for canvas output
    protected var _outputKey :String;

    protected var _lastId :String;
    protected var _lastEndPoint :int;
}
}
