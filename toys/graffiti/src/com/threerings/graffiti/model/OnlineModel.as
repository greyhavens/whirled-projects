// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.whirled.ControlEvent;

import com.threerings.graffiti.Canvas;
import com.threerings.graffiti.Manager;

import com.threerings.graffiti.throttle.AlterBackgroundMessage;
import com.threerings.graffiti.throttle.EditorClosedMessage;
import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;
import com.threerings.graffiti.throttle.ThrottleMessage;
import com.threerings.graffiti.throttle.ThrottleStrokeMessage;
import com.threerings.graffiti.throttle.RemoveStrokeMessage;
import com.threerings.graffiti.throttle.StripIdMessage;
import com.threerings.graffiti.throttle.StrokeBeginMessage;
import com.threerings.graffiti.throttle.StrokeExtendMessage;
import com.threerings.graffiti.throttle.StrokeEndMessage;
import com.threerings.graffiti.throttle.StrokeReplacementMessage;

public class OnlineModel extends Model
{
    public function OnlineModel (throttle :Throttle)
    {
        super();

        _throttle = throttle;
        _throttle.addEventListener(ThrottleEvent.TEMP_MESSAGE, tempMessageReceived);
        _throttle.addEventListener(ThrottleEvent.MANAGER_MESSAGE, managerMessageReceived);
        _throttle.control.addEventListener(ControlEvent.MEMORY_CHANGED, memoryChanged);

        var bytes :ByteArray = 
            _throttle.control.getMemory(Manager.MEMORY_MODEL, null) as ByteArray;
        if (bytes != null && bytes.length != 0) {
            deserialize(bytes);
        }
    }

    override public function registerCanvas (canvas :Canvas) :void
    {
        super.registerCanvas(canvas);
        paintCanvas(canvas);
    }

    override public function unregisterCanvas (canvas :Canvas, editingCanvas :Boolean) :void
    {
        super.unregisterCanvas(canvas, editingCanvas);
        if (editingCanvas) {
            var instanceId :int = _throttle.control.getInstanceId() % Math.pow(KEY_BITS.length, 2);
            _throttle.pushMessage(new EditorClosedMessage(getKeyString(instanceId)));
        }
    }

    override public function extendStroke (id :String, to :Point, end :Boolean = false) :void
    {
        super.extendStroke(id, to, end);
        if (idFromMe(id)) {
            _throttle.pushMessage(new StrokeExtendMessage(id, to));
        }

        updateSizeLimit();
    }

    override public function endStroke (id :String) :void
    {
        super.endStroke(id);
        if (idFromMe(id)) {
            var stroke :Stroke = _strokesMap.get(id);
            if (stroke != null) {
                _throttle.pushMessage(new StrokeEndMessage(stroke));
            }
        }

        updateSizeLimit();
    }

    override public function getKey () :String
    {
        // In the online model, keys are prepended with the instance id.  We want to limit keys
        // to a length of 4 characters for encoding reasons, so we're limiting the prepended 
        // encoded instanceId space to KEY_BITS.length ^ 2, which is 3844.  If two instances
        // are active that have the same instance id mod 3844, strange things could happen during
        // undo.  That's not very likely, so we'll punt on it for now.
        var instanceId :int = _throttle.control.getInstanceId() % Math.pow(KEY_BITS.length, 2);
        return getKeyString(instanceId) + super.getKey();
    }

    override public function setBackgroundColor (color :uint) :void
    {
        // wait to hear from the manager before changing it locally
        _throttle.pushMessage(new AlterBackgroundMessage(AlterBackgroundMessage.COLOR, color));
    }

    override public function setBackgroundTransparent (transparent :Boolean) :void
    {
        // wait to hear from the manager before changing it locally
        _throttle.pushMessage(
            new AlterBackgroundMessage(AlterBackgroundMessage.TRANSPARENCY, transparent));
    }

    override protected function strokeBegun (stroke :Stroke) :void
    {
        super.strokeBegun(stroke);
        if (idFromMe(stroke.id)) {
            _throttle.pushMessage(new StrokeBeginMessage(stroke));
        }
    }

    override protected function forgetUndoStroke (stroke :Stroke) :void
    {
        super.forgetUndoStroke(stroke);
        if (idFromMe(stroke.id)) {
            _throttle.pushMessage(new StripIdMessage(stroke.id));
            _canvases.idStripped(stroke.id);
            stroke.id = null;
        }
    }

    override protected function strokeRemoved (stroke :Stroke) :void
    {
        super.strokeRemoved(stroke);
        if (idFromMe(stroke.id)) {
            _throttle.pushMessage(new RemoveStrokeMessage(stroke.id));
        }
        stroke.id = null;
        updateSizeLimit();
    }

    protected function memoryChanged (event :ControlEvent) :void
    {
        if (event.name == Manager.MEMORY_MODEL && event.value == null) {
            _strokesList = [];
            _strokesMap.clear();
            _canvases.clear();
            _backgroundTransparent = false;
            _canvases.paintBackground(_backgroundColor = 0xFFFFFF);
        }
    }

    protected function updateSizeLimit () :void
    {
        _canvases.reportFillPercent(serialize().length / MAX_STORAGE_SIZE);
    }

    protected function paintCanvas (canvas :Canvas) :void
    {
        canvas.clear();
        if (_backgroundTransparent) {
            canvas.setBackgroundTransparent(true);
        } else {
            canvas.paintBackground(_backgroundColor);
        }

        for each (var stroke :Stroke in _strokesList) {
            canvas.drawStroke(stroke);
        }
    }

    protected function idFromMe (id :String) :Boolean 
    {
        if (id == null) {
            return false;
        }
        var instanceId :int = _throttle.control.getInstanceId() % Math.pow(KEY_BITS.length, 2);
        return id.indexOf(getKeyString(instanceId)) == 0;
    }

    protected function tempMessageReceived (event :ThrottleEvent) :void
    {
        var message :ThrottleMessage = event.message;
        if (message is EditorClosedMessage) {
            stripAllIds((message as EditorClosedMessage).editorId);
            updateSizeLimit();
            return;
        } else if (!(message is ThrottleStrokeMessage)) {
            return;
        }

        var strokeMessage :ThrottleStrokeMessage = message as ThrottleStrokeMessage;
        if (idFromMe(strokeMessage.strokeId)) {
            return;
        }

        log.debug("processing message [" + message + "]");
        if (strokeMessage is StrokeBeginMessage) {
            strokeBegun((strokeMessage as StrokeBeginMessage).stroke);
        } else if (strokeMessage is StrokeExtendMessage) {
            extendStroke(strokeMessage.strokeId, (strokeMessage as StrokeExtendMessage).to);
        } else if (strokeMessage is StrokeEndMessage) {
            // NOOP - ending the stroke puts it on the undo stack, which we don't want here.
        } else if (strokeMessage is StripIdMessage) {
            stripId(strokeMessage.strokeId);
        } else if (strokeMessage is RemoveStrokeMessage) {
            removeStroke(strokeMessage.strokeId);
        } else {
            log.debug("unkown temp stroke message type [" + message + "]");
        }
    }

    protected function managerMessageReceived (event :ThrottleEvent) :void
    {
        var message :ThrottleMessage = event.message;
        if (message is AlterBackgroundMessage) {
            var backgroundMessage :AlterBackgroundMessage = message as AlterBackgroundMessage;
            if (backgroundMessage.type == AlterBackgroundMessage.COLOR) {
                _canvases.paintBackground(_backgroundColor = backgroundMessage.value as uint);
            } else if (backgroundMessage.type == AlterBackgroundMessage.TRANSPARENCY) {
                _canvases.setBackgroundTransparent(
                    _backgroundTransparent = backgroundMessage.value as Boolean);
            }
        } else if (message is StrokeReplacementMessage) {
            var strokeReplacement :StrokeReplacementMessage = message as StrokeReplacementMessage;
            _canvases.replaceStroke(strokeReplacement.stroke, strokeReplacement.layer);
        }
    }

    private static const log :Log = Log.getLog(OnlineModel);

    protected var _throttle :Throttle;
}
}
