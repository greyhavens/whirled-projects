package flashmob.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flashmob.DataBindings;
import flashmob.GameDataListener;

public class GameDataMode extends AppMode
    implements GameDataListener
{
    public function onMsgReceived (e :MessageReceivedEvent) :Boolean
    {
        return _dataBindings.onMsgReceived(e);
    }

    public function onPropChanged (e :PropertyChangedEvent) :Boolean
    {
        return _dataBindings.onPropChanged(e);
    }

    public function onElemChanged (e :ElementChangedEvent) :Boolean
    {
        return _dataBindings.onElemChanged(e);
    }

    protected var _dataBindings :DataBindings = new DataBindings();
}

}
