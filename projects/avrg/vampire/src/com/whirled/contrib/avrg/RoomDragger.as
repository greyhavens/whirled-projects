package com.whirled.contrib.avrg {

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.simplegame.objects.Dragger;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.geom.Rectangle;

public class RoomDragger extends Dragger
{
    public static const CONSTRAIN_PAINTABLE :int = 0;
    public static const CONSTRAIN_ROOM :int = 1;
    public static const CONSTRAIN_NONE :int = 2;

    public function RoomDragger (ctrl :AVRGameControl,
                                 draggableObj :InteractiveObject,
                                 displayObj :DisplayObject = null,
                                 draggedCallback :Function = null,
                                 droppedCallback :Function = null)
    {
        super(draggableObj, displayObj, draggedCallback, droppedCallback);
        _ctrl = ctrl;

        registerListener(_ctrl.local, AVRGameControlEvent.SIZE_CHANGED, onConstraintsChanged);
        registerListener(_ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, onConstraintsChanged);
    }

    public function set constraintType (val :int) :void
    {
        if (val != _constraintType) {
            _constraintType = val;
            onConstraintsChanged();
        }
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        onConstraintsChanged();
    }

    protected function onConstraintsChanged (...ignored) :void
    {
        var constraintBounds :Rectangle;

        if (_ctrl.isConnected()) {
            switch (_constraintType) {
            case CONSTRAIN_PAINTABLE:
                constraintBounds = _ctrl.local.getPaintableArea(true);
                break;

            case CONSTRAIN_ROOM:
                constraintBounds = _ctrl.local.getPaintableArea(false);
                break;
            }
        }

        setConstraints(constraintBounds, _xSnap, _ySnap, _customObjectBounds);
    }

    protected var _ctrl :AVRGameControl;
    protected var _constraintType :int = CONSTRAIN_PAINTABLE;
}

}
