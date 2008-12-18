package flashmob.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flashmob.GameDataListener;

public class GameDataMode extends AppMode
    implements GameDataListener
{
    public function onMsgReceived (e :MessageReceivedEvent) :void {}
    public function onPropChanged (e :PropertyChangedEvent) :void {}
    public function onElemChanged (e :ElementChangedEvent) :void {}
}

}
