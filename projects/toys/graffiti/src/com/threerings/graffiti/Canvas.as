// $Id$

package com.threerings.graffiti {

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.geom.Matrix;
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

        var masker :Shape = new Shape();
        masker.graphics.beginFill(0);
        masker.graphics.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        masker.graphics.endFill();
        addChild(masker);
        mask = masker;

        _model = model;
        var thisCanvas :Canvas = this;
        _model.registerCanvas(thisCanvas);
        addEventListener(Event.REMOVED_FROM_STAGE, cleanup);
    }

    public function get toolbox () :ToolBox
    {
        // toolbox creation is deferred so view-only canvases don't instantiate one.
        if (_toolBox == null) {
            // defer adding the mouse listeners as well - we don't need them on a view-only canvas.
            addMouseListeners();

            _toolBox = new ToolBox(this, _model.getBackgroundColor(), 
                                   _model.getBackgroundTransparent(), 
                                   _model.calculateFullPercent());
            _toolBox.addEventListener(ToolEvent.TOOL_PICKED, function (event :ToolEvent) :void {
                var newTool :Tool = event.value as Tool;
                if (newTool == null) {
                    endStroke();
                } else if (!newTool.equals(_tool)) {
                    _tool = newTool;
                }
            });
            _toolBox.addEventListener(ToolEvent.BACKGROUND_COLOR, 
                function (event :ToolEvent) :void {
                    _model.setBackgroundColor(event.value as uint);
                });
            _toolBox.addEventListener(ToolEvent.BACKGROUND_TRANSPARENCY, 
                function (event :ToolEvent) :void {
                    _model.setBackgroundTransparent(event.value as Boolean);
                });
            _toolBox.addEventListener(ToolEvent.UNDO_ONCE, function (event :ToolEvent) :void {
                _model.undo();
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

    public function paintBackground (color :uint) :void
    {
        if (_model.getBackgroundTransparent()) {
            return;
        }

        _background.blendMode = BlendMode.NORMAL;
        var g :Graphics = _background.graphics;
        g.clear();
        g.beginFill(_backgroundColor = color);
        g.drawRect(0, 0, CANVAS_WIDTH, CANVAS_HEIGHT);
        g.endFill();
    }

    public function drawStroke (stroke :Stroke, startPoint :int = 0) :void
    {
        log.debug("draw stroke [" + this.name + ", " + stroke.id + ", " + stroke + ", " + 
            startPoint + "]");

        if (stroke.id != null && stroke.id == _inputKey) {
            return;
        }

        var start :Point = stroke.getPoint(startPoint);
        if (start == null) {
            log.warning("null start point [" + stroke + ", " + startPoint + "]");
            return;
        }

        var strokeLayer :Shape;
        if (stroke.id == null) {
            // This stroke is finalized and the artist has closed their editor, we won't need to 
            // remember it anymore.  Also, we'll only receive strokes like this when we first
            // start up, and they'll come in order, so we can just plunk it down on top
            strokeLayer = new Shape(); 
            addChild(strokeLayer);
            stroke.tool.mouseDown(strokeLayer.graphics, start);
        } else {
            strokeLayer = _layers.get(stroke.id);
            if (strokeLayer == null) {
                strokeLayer = new Shape();
                _layers.put(stroke.id, strokeLayer);
                addChild(strokeLayer);
                stroke.tool.mouseDown(strokeLayer.graphics, start);
            }
        }

        for (var ii :int = startPoint + 1; ii < stroke.getSize(); ii++) {
            stroke.tool.dragTo(strokeLayer.graphics, stroke.getPoint(ii));
        }
    }

    public function removeStroke (id :String) :void
    {
        var layer :Shape = _layers.remove(id);
        if (layer != null) {
            removeChild(layer);
        }
    }

    public function replaceStroke (stroke :Stroke, layer :int) :void
    {
        var oldLayer :Shape = stroke.id != null ? _layers.remove(stroke.id) : null;
        if (oldLayer != null) {
            removeChild(oldLayer);
        }

        var strokeLayer :Shape = new Shape();
        // add 2: one for the mask, one for the background;
        layer += 2;
        if (layer >= numChildren) {
            addChild(strokeLayer);
        } else {
            addChildAt(strokeLayer, layer);
        }
        stroke.tool.mouseDown(strokeLayer.graphics, stroke.getPoint(0));

        for (var ii :int = 1; ii < stroke.getSize(); ii++) {
            stroke.tool.dragTo(strokeLayer.graphics, stroke.getPoint(ii));
        }

        if (stroke.id != null) {
            _layers.put(stroke.id, strokeLayer);
        }
    }

    public function reportFillPercent (percent :Number) :void
    {
        if (_toolBox != null) {
            _toolBox.displayFillPercent(percent);
        }
    }

    public function reportUndoStackSize (size :int) :void
    {
        if (_toolBox != null) {
            _toolBox.setUndoEnabled(size != 0);
        }
    }

    public function clear () :void
    {
        while (numChildren > 0) {
            removeChildAt(0);
        }
        addChild(mask);
        addChild(_background);
        _layers.clear();
    }

    public function idStripped (id :String) :void
    {
        _layers.remove(id);
    }

    protected function cleanup (...ignored) :void
    {
        if (_toolBox != null) {
            endStroke();
        }
        _model.unregisterCanvas(this, _toolBox != null);
    }

    protected function addMouseListeners () :void
    {
        _background.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        _background.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _background.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
        _background.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
    }
    
    protected function mouseMove (evt :MouseEvent) :void
    {
        if (_inputKey != null && evt.buttonDown) {
            var layer :Shape = _layers.get(_inputKey);
            if (layer != null) {
                _tool.dragTo(layer.graphics, 
                             _background.globalToLocal(new Point(evt.stageX, evt.stageY)),
                             false);
            }
        }
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        if (_tool == null) {
            return;
        }
            
        _lastStrokePoint = _background.globalToLocal(new Point(evt.stageX, evt.stageY));
        _newStroke = true;
        _inputKey = _inputKey != null ? _inputKey : _model.getKey();
        _timer = setInterval(tick, TICK_INTERVAL);
        var layer :Shape = _layers.get(_inputKey);
        if (layer != null) {
            removeChild(layer);
        }
        layer = new Shape();
        _layers.put(_inputKey, layer);
        addChild(layer);
        _tool.mouseDown(layer.graphics, _lastStrokePoint);
    }

    protected function tick () :void
    {
        maybeAddStroke(new Point(_background.mouseX, _background.mouseY));
    }

    protected function mouseUp (evt :MouseEvent) :void
    {
        maybeAddStroke(_background.globalToLocal(new Point(evt.stageX, evt.stageY)));
        endStroke();
    }

    protected function endStroke () :void
    {
        if (_timer > 0) {
            clearInterval(_timer);
            _timer = 0;
        }

        if (_newStroke) {
            _lastStrokePoint = null;
            _newStroke = false;
            return;
        }

        if (_inputKey != null) {
            _model.endStroke(_inputKey);
        }
        _inputKey = null;
    }

    protected function mouseOut (evt :MouseEvent) :void
    {
        if (_inputKey == null) {
            return;
        }

        var canvasPoint :Point = _background.globalToLocal(new Point(evt.stageX, evt.stageY));
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
            maybeAddStroke(canvasPoint);
            endStroke();
        }
    }

    protected function maybeAddStroke (p :Point) :void
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
            return;
        }

        if (_newStroke) {
            _model.beginStroke(_inputKey, _lastStrokePoint, p, _tool);

        } else {
            _model.extendStroke(_inputKey, p);
        }

        _lastStrokePoint = p;
        _newStroke = false;
    }

    private static const log :Log = Log.getLog(Canvas);

    /** The number of milliseconds between mouse samples.  The lower the number, the higher the 
     * drawing resolution, but the faster it fills up the available memory.  We may want to make
     * this configurable in a slider control. Reasonable values are between 50 and 200ish. */
    protected static const TICK_INTERVAL :int = 100;

    protected var _model :Model;

    protected var _background :Sprite;
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

    protected var _layers :HashMap = new HashMap();
}
}
