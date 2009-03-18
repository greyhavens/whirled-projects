package vampire.feeding.net {

import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.events.EventDispatcher;

/**
 * Dispatched when a property has changed in the shared game state. This event is a result
 * of calling set() or testAndSet().
 *
 * @eventType com.whirled.game.PropertyChangedEvent.PROPERTY_CHANGED
 */
[Event(name="PropChanged", type="com.whirled.net.PropertyChangedEvent")]

/**
 * Dispatched when an element inside a property has changed in the shared game state.
 * This event is a result of calling setIn() or setAt().
 *
 * @eventType com.whirled.game.ElementChangedEvent.ELEMENT_CHANGED
 */
[Event(name="ElemChanged", type="com.whirled.net.ElementChangedEvent")]

public class GamePropGetControl extends EventDispatcher
    implements PropertyGetSubControl
{
    public function GamePropGetControl (gameId :int, propGetCtrl :PropertyGetSubControl)
    {
        _gameId = gameId;
        _nameUtil = new NameUtil(_gameId);
        _propGetCtrl = propGetCtrl;

        _propGetCtrl.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _propGetCtrl.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
    }

    public function shutdown () :void
    {
        _propGetCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _propGetCtrl.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);
    }

    public function get gameId () :int
    {
        return _gameId;
    }

    public function get (propName :String) :Object
    {
        return _propGetCtrl.get(_nameUtil.encodeName(propName));
    }

    public function getPropertyNames (prefix :String = "") :Array
    {
        var propNames :Array = _propGetCtrl.getPropertyNames(_nameUtil.encodeName(prefix));
        return propNames.map(
            function (name :String, index :int, arr :Array) :String {
                return _nameUtil.decodeName(name);
            });
    }

    public function getTargetId () :int
    {
        return _propGetCtrl.getTargetId();
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (_nameUtil.isForGame(e.name)) {
            dispatchEvent(new PropertyChangedEvent(
                PropertyChangedEvent.PROPERTY_CHANGED,
                _nameUtil.decodeName(e.name),
                e.newValue,
                e.oldValue));
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (!_nameUtil.isForGame(e.name)) {
            dispatchEvent(new ElementChangedEvent(
                ElementChangedEvent.ELEMENT_CHANGED,
                _nameUtil.decodeName(e.name),
                e.newValue,
                e.oldValue,
                e.key));
        }
    }

    protected var _gameId :int;
    protected var _nameUtil :NameUtil;
    protected var _propGetCtrl :PropertyGetSubControl;
}

}
