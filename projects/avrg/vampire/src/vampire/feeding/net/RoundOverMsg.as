package vampire.feeding.net {

import com.threerings.util.HashMap;
import com.whirled.contrib.messagemgr.Message;

import vampire.feeding.FeedingRoundResults;

public class RoundOverMsg extends FeedingRoundResults
    implements Message
{
    public static const NAME :String = "RoundOver";

    public static function create (scores :HashMap, initialPlayerCount :int) :RoundOverMsg
    {
        var msg :RoundOverMsg = new RoundOverMsg();
        msg.scores = scores;
        msg.initialPlayerCount = initialPlayerCount;

        return msg;
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
