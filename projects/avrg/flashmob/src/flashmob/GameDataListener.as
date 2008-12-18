package flashmob {

import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

public interface GameDataListener
{
    function onMsgReceived (e :MessageReceivedEvent) :void;
    function onPropChanged (e :PropertyChangedEvent) :void;
    function onElemChanged (e :ElementChangedEvent) :void;

}

}
