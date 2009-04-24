package vampire.feeding {

import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class FeedingRoundResults
{
    public var scores :HashMap; // Map<playerId, score>
    public var initialPlayerCount :int;

    public function get totalScore () :int
    {
        var score :int;
        scores.forEach(
            function (playerId :int, playerScore :int) :void {
                score += playerScore;
            });
        return score;
    }

    public function get averageScore () :int
    {
        return (initialPlayerCount > 0 ? Math.ceil(totalScore / initialPlayerCount) : 0);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(scores.size());
        scores.forEach(
            function (playerId :int, score :int) :void {
                ba.writeInt(playerId);
                ba.writeInt(score);
            });

        ba.writeByte(initialPlayerCount);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        scores = new HashMap();

        var numScores :int = ba.readByte();
        for (var ii :int = 0; ii < numScores; ++ii) {
            var playerId :int = ba.readInt();
            var score :int = ba.readInt();
            scores.put(playerId, score);
        }

        initialPlayerCount = ba.readByte();
    }
}

}
