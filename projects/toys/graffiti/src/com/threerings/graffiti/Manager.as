// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.ByteArray;
import flash.utils.Timer;

import com.threerings.util.Log;

import com.whirled.ControlEvent;

import com.threerings.graffiti.model.Model;
import com.threerings.graffiti.model.OfflineModel;
import com.threerings.graffiti.model.Stroke;

import com.threerings.graffiti.throttle.AlterBackgroundMessage;
import com.threerings.graffiti.throttle.ManagerAlterBackgroundMessage;
import com.threerings.graffiti.throttle.StrokeEndMessage;
import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;
import com.threerings.graffiti.throttle.ThrottleMessage;

public class Manager
{
    public static const MEMORY_MODEL :String = "memoryModel";

    public function Manager (throttle :Throttle)
    {
        _throttle = throttle;
        _throttle.addEventListener(ThrottleEvent.TEMP_MESSAGE, tempMessageReceived);

        // the manager maintains an offline model that is what gets serialized into the item memory
        _model = new OfflineModel();

        _timer = new Timer(MEMORY_UPDATE_TIMING);
        _timer.addEventListener(TimerEvent.TIMER, tick);
        _timer.start();
        _throttle.control.addEventListener(Event.UNLOAD, unload);
        _throttle.control.addEventListener(ControlEvent.MEMORY_CHANGED, memoryChanged);
    }

    public function tempMessageReceived (event :ThrottleEvent) :void
    {
        var message :ThrottleMessage = event.message;
        if (message is AlterBackgroundMessage) {
            var backgroundMessage :AlterBackgroundMessage = message as AlterBackgroundMessage;
            if (backgroundMessage.type == AlterBackgroundMessage.COLOR) {
                _model.setBackgroundColor(backgroundMessage.value as uint);
            } else if (backgroundMessage.type == AlterBackgroundMessage.TRANSPARENCY) {
                _model.setBackgroundTransparent(backgroundMessage.value as Boolean);
            }
            _memoryDirty = true;

            _throttle.pushMessage(new ManagerAlterBackgroundMessage(backgroundMessage));
        } else if (message is StrokeEndMessage) {
            var strokeMessage :StrokeEndMessage = message as StrokeEndMessage;
            var id :String = strokeMessage.strokeId;
            var stroke :Stroke = strokeMessage.stroke;
            var size :int = stroke.getSize();
            if (size < 2) {
                log.warning("Received stroke end on a short stroke");
                return;
            }

            _model.beginStroke(id, stroke.getPoint(0), stroke.getPoint(1), stroke.tool);
            for (var ii :int = 2; ii < stroke.getSize(); ii++) {
                _model.extendStroke(id, stroke.getPoint(ii));
            }
            _model.endStroke(id);
            _memoryDirty = true;

            // TODO: send on as the official version of this stroke
        }
    }

    protected function memoryChanged (event :ControlEvent) :void
    {
        if (event.name == MEMORY_MODEL) {
            if (event.value == null) {
                _memoryDirty = false;
                _model = new OfflineModel();
            } else if (!_throttle.control.hasControl()) {
                _model.deserialize(event.value as ByteArray);
            }
        }
    }

    protected function tick (event :TimerEvent) :void
    {
        if (!_memoryDirty || !_throttle.control.hasControl()) {
            return;
        }

        _throttle.control.updateMemory(MEMORY_MODEL, _model.serialize());
        _memoryDirty = false;
    }

    protected function unload (event :Event) :void
    {
        _timer.stop();
    }

    private static const log :Log = Log.getLog(Manager);

    protected static const MEMORY_UPDATE_TIMING :int = 2000; // in ms

    protected var _throttle :Throttle;
    protected var _model :Model;
    protected var _memoryDirty :Boolean = false;
    protected var _timer :Timer;
}
}
