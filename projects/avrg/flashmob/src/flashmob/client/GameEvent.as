package flashmob.client {

import flash.events.Event;

public class GameEvent extends Event
{
    public static const AVATAR_CHANGED :String = "AvatarChanged"; // data=new avatar ID

    public var data :*;

    public function GameEvent (type :String, data :* = undefined)
    {
        super(type, false, false);
        this.data = data;
    }
}

}
