//
// $Id$

package locksmith.model {

import flash.events.EventDispatcher;

import com.whirled.game.GameControl;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.ElementChangedEvent;

import com.whirled.contrib.EventHandlerManager;

public /* abstract */ class ModelManager extends EventDispatcher
{
    public function ModelManager (gameCtrl :GameControl, eventMgr :EventHandlerManager)
    {
        _gameCtrl = gameCtrl;
        _eventMgr = eventMgr;
        _eventMgr.registerListener(
            _gameCtrl.net, PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _eventMgr.registerListener(
            _gameCtrl.net, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
    }

    protected function manageProperties (...properties) :void
    {
        _properties = _properties.concat(properties);
    }

    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (_properties.indexOf(event.name) < 0) {
            return;
        }

        managedPropertyUpdated(event.name, event.oldValue, event.newValue);
    }

    protected function elementChanged (event :ElementChangedEvent) :void
    {
        if (_properties.indexOf(event.name) < 0) {
            return;
        }

        managedPropertyUpdated(event.name, event.oldValue, event.newValue, event.key);
    }

    protected /* abstract */ function managedPropertyUpdated (prop :String, oldValue :Object, 
        newValue :Object, key :int = -1) :void
    {
        throw new Error("Abstract");
    }

    protected function startBatch () :void
    {
        requireServer();
        _batching = true;
        _batched = [];
    }

    protected function commitBatch () :void
    {
        requireServer();
        _batching = false;
        _gameCtrl.net.doBatch(function () :void {
            while (_batched.length > 0) {
                (_batched.unshift() as Function)();
            }
        });
    }

    protected function rollBackBatch () :void
    {
        requireServer();
        _batching = false;
        _batched = [];
    }

    protected function setIn (property :String, key :int, value :Object, 
        immediate :Boolean = false) :void
    {
        requireServer();
        if (_properties.indexOf(property) < 0) {
            throw new Error("That property is not managed by this manager! [" + property + "]");
        }

        doNetwork(function () :void {
            _gameCtrl.net.setIn(property, key, value, immediate);
        });
    }

    protected function doNetwork (func :Function) :void
    {
        if (_batching) {
            _batched.push(func);
        } else {
            func();
        }
    }

    protected function requireServer () :void
    {
        if (!_gameCtrl.game.amServerAgent()) {
            throw new Error("Only a server agent may perform that operation!");
        }
    }

    protected function requireClient () :void
    {
        if (_gameCtrl.game.amServerAgent()) {
            throw new Error("Only a client may perform that operation!");
        }
    }

    protected var _eventMgr :EventHandlerManager;
    protected var _properties :Array = [];
    protected var _batching :Boolean = false;
    protected var _batched :Array = [];
}
