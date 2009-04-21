package vampire.server
{
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.SimObject;

/**
 * Builds statistics of player data and player patterns
 */
public class Analyser extends SimObject
{

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _timeStarted = new Date().time;
    }

    override protected function update (dt:Number) :void
    {
        super.update(dt);
    }

    protected var _timeStarted :Number;
    protected var _playTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _feedingGames :int = 0;
    protected var _progenyPayout :HashMap = new HashMap();//playerId to payout


//    public static const MSG_

}
}