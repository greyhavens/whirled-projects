package vampire.server.feeding
{
import com.threerings.util.Map;

import flash.events.Event;

public class FeedingHighScoreEvent extends Event
{
    public function FeedingHighScoreEvent(averageScore :Number, scores :Map)
    {
        super(HIGH_SCORE, false, false);
        _averageScore = averageScore;
        _scores = scores;
    }

    public function get averageScore () :Number
    {
        return _averageScore;
    }

    public function get scores () :Map
    {
        return _scores;
    }

    protected var _averageScore :Number;
    protected var _scores :Map;

    public static const HIGH_SCORE :String = "Feeding High Score";
}
}
