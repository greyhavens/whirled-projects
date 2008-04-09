package popcraft.net {

import com.whirled.contrib.simplegame.net.Message;
import com.whirled.contrib.simplegame.net.MessageFactory;

public interface PopcraftMessageFactory extends MessageFactory
{
    function serializeForFile (message :Message) :String;
    function deserializeFromFile (msgString :String) :Message;
}

}
