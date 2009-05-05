package vampire.feeding.client {

import com.whirled.contrib.simplegame.net.Message;

import flash.events.Event;

public class ClientMsgEvent extends Event
{
    public static const MSG_RECEIVED :String = "MsgReceived";

    public var msg :Message;

    public function ClientMsgEvent (msg :Message)
    {
        super(MSG_RECEIVED, false, false);
        this.msg = msg;
    }

}

}
