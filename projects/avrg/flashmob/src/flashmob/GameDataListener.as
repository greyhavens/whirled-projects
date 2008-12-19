package flashmob {

import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

public interface GameDataListener
{
    function onMsgReceived (e :MessageReceivedEvent) :Boolean;
    function onPropChanged (e :PropertyChangedEvent) :Boolean;
    function onElemChanged (e :ElementChangedEvent) :Boolean;

}

}
