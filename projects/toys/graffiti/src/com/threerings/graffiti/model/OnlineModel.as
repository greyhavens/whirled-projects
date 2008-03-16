// $Id$

package com.threerings.graffiti.model {

import flash.geom.Point;

import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.threerings.graffiti.Canvas;
import com.threerings.graffiti.Manager;

import com.threerings.graffiti.throttle.AlterBackgroundMessage;
import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;
import com.threerings.graffiti.throttle.ThrottleMessage;
import com.threerings.graffiti.throttle.ThrottleStrokeMessage;
import com.threerings.graffiti.throttle.StrokeBeginMessage;
import com.threerings.graffiti.throttle.StrokeExtendMessage;
import com.threerings.graffiti.throttle.StrokeEndMessage;

public class OnlineModel extends Model
{
    public function OnlineModel (throttle :Throttle)
    {
        super();

        _throttle = throttle;
        _throttle.addEventListener(ThrottleEvent.TEMP_MESSAGE, tempMessageReceived);
        _throttle.addEventListener(ThrottleEvent.MANAGER_MESSAGE, managerMessageReceived);

        var bytes :ByteArray = 
            _throttle.control.lookupMemory(Manager.MEMORY_MODEL, null) as ByteArray;
        if (bytes != null && bytes.length != 0) {
            deserialize(bytes);
        }
    }

    override public function registerCanvas (canvas :Canvas) :void
    {
        super.registerCanvas(canvas);
        paintCanvas(canvas);
    }

    override public function extendStroke (id :String, to :Point, end :Boolean = false) :void
    {
        super.extendStroke(id, to, end);
        if (idFromMe(id)) {
            _throttle.pushMessage(new StrokeExtendMessage(id, to));
        }
    }

    override public function endStroke (id :String) :void
    {
        super.endStroke(id);
        if (idFromMe(id)) {
            var stroke :Stroke = _tempStrokesMap.get(id);
            if (stroke != null) {
                _throttle.pushMessage(new StrokeEndMessage(id, stroke));
            }
        }
    }

    override public function getKey () :String
    {
        // in the online model, keys are prepended with the instance id
        return _throttle.control.getInstanceId() + ":" + super.getKey();
    }

    override public function setBackgroundColor (color :uint) :void
    {
        _throttle.pushMessage(new AlterBackgroundMessage(AlterBackgroundMessage.COLOR, color));
    }

    override public function setBackgroundTransparent (transparent :Boolean) :void
    {
        _throttle.pushMessage(
            new AlterBackgroundMessage(AlterBackgroundMessage.TRANSPARENCY, transparent));
    }

    override protected function strokeBegun (id :String, stroke :Stroke) :void
    {
        super.strokeBegun(id, stroke);
        if (idFromMe(id)) {
            _throttle.pushMessage(new StrokeBeginMessage(id, stroke));
        }
    }

    protected function paintCanvas (canvas :Canvas) :void
    {
        canvas.clear();
        if (_backgroundTransparent) {
            canvas.setBackgroundTransparent(true);
        } else {
            canvas.paintBackground(_backgroundColor);
        }

        for each (var stroke :Stroke in _canvasStrokes) {
            canvas.canvasStroke(stroke);
        }
    }

    protected function idFromMe (id :String) :Boolean {
        return id.indexOf(_throttle.control.getInstanceId() + ":") != -1;
    }

    protected function tempMessageReceived (event :ThrottleEvent) :void
    {
        var message :ThrottleMessage = event.message;
        if (!(message is ThrottleStrokeMessage)) {
            return;
        }

        var strokeMessage :ThrottleStrokeMessage = message as ThrottleStrokeMessage;
        if (idFromMe(strokeMessage.strokeId)) {
            return;
        }

        log.debug("processing message [" + message + "]");
        if (strokeMessage is StrokeBeginMessage) {
            strokeBegun(strokeMessage.strokeId, (strokeMessage as StrokeBeginMessage).stroke);
        } else if (strokeMessage is StrokeExtendMessage) {
            extendStroke(strokeMessage.strokeId, (strokeMessage as StrokeExtendMessage).to);
        } else if (strokeMessage is StrokeEndMessage) {
            // NOOP - managers care about this.
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
        }
    }

    private static const log :Log = Log.getLog(OnlineModel);

    protected var _throttle :Throttle;
}
}
