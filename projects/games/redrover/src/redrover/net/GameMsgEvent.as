package redrover.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.events.Event;

public class GameMsgEvent extends Event
{
    public static const MESSAGE_RECEIVED :String = "GameMsgReceived";

    public var msg :Message;

    public function GameMsgEvent (msg :Message)
    {
        super(MESSAGE_RECEIVED);
        this.msg = msg;
    }

}

}
