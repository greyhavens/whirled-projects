package {

import flash.events.Event;

public class ButtonEvent extends Event
{
    public static const CLICK :String = "button.click";

    public function ButtonEvent (type :String, action :String)
    {
        super(type);
        _action = action;
    }

    public function get action () :String
    {
        return _action;
    }

    override public function toString () :String
    {
        return formatToString("ButtonClickEvent", "type", "bubbles", 
            "cancelable", "action");
    }

    protected var _action :String;
}

}
