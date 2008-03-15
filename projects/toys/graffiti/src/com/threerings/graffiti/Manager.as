// $Id$

package com.threerings.graffiti {

import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Log;

import com.threerings.graffiti.model.Model;
import com.threerings.graffiti.model.OfflineModel;

import com.threerings.graffiti.throttle.AlterBackgroundMessage;
import com.threerings.graffiti.throttle.ManagerAlterBackgroundMessage;
import com.threerings.graffiti.throttle.Throttle;
import com.threerings.graffiti.throttle.ThrottleEvent;
import com.threerings.graffiti.throttle.ThrottleMessage;

public class Manager
{
    public function Manager (throttle :Throttle)
    {
        _throttle = throttle;
        _throttle.addEventListener(ThrottleEvent.TEMP_MESSAGE, tempMessageReceived);

        // the manager maintains an offline model that is what gets serialized into the item memory
        _model = new OfflineModel();
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
        }
    }

    private static const log :Log = Log.getLog(Manager);

    protected var _throttle :Throttle;
    protected var _model :Model;
    protected var _memoryDirty :Boolean = false;
}
}
