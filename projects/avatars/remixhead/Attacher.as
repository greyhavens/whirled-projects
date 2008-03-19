//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import flash.events.Event;

import com.threerings.flash.DisplayUtil;

/**
 * Utility to try to re-attach some object to a symbol, every frame.
 *
 * DOES NOT WORK. It's very flashy (blinky).
 */
public class Attacher
{
    public function Attacher (
        hier :DisplayObjectContainer, symbolName :String, attachment :DisplayObject)
    {
        _hier = hier;
        _name = symbolName;
        _attachment = attachment;

        hier.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        hier.addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        hier.addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
        
        if (hier.stage != null) {
            hier.addEventListener(Event.ENTER_FRAME, handleFrame);
            handleFrame();
        }
    }

    protected function handleAddRemove (event :Event) :void
    {
        if (event.type == Event.ADDED_TO_STAGE) {
            _hier.addEventListener(Event.ENTER_FRAME, handleFrame);
            handleFrame();
        } else {
            _hier.removeEventListener(Event.ENTER_FRAME, handleFrame);
        }
    }

    protected function handleFrame (... ignored) :void
    {
        var container :DisplayObjectContainer =
            DisplayUtil.findInHierarchy(_hier, _name) as DisplayObjectContainer;
        if (container == null) {
            trace("Eek! Unable to find '" + _name + "'");
            return;
        }

        try {
            container.getChildIndex(_attachment);
            return; //already there
        } catch (err :Error) {
            container.addChild(_attachment);
        }
    }

    protected function handleUnload (event :Event) :void
    {
        _hier.removeEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        _hier.removeEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);
        _hier.removeEventListener(Event.ENTER_FRAME, handleFrame);
    }

    protected var _hier :DisplayObjectContainer;

    protected var _name :String;

    protected var _attachment :DisplayObject;
}
}
