package bingo {

import bingo.client.ClientContext;

public class Score
{
    public var playerId :int;
    public var score :int;
    public var date :Date;

    public function Score (playerId :int, score :int, date :Date)
    {
        this.playerId = playerId;
        this.score = score;
        this.date = date;
    }

    public static function compareScores (a :Score, b :Score) :int
    {
        // compare scores. higher scores come before lower
        if (a.score > b.score) {
            return -1;
        } else if (a.score < b.score) {
            return 1;
        }

        // compare dates. newer dates come before older
        var aTime :Number = a.date.time;
        var bTime :Number = b.date.time;

        if (aTime > bTime) {
            return -1;
        } else if (aTime < bTime) {
            return 1;
        }

        // compare names. A comes before Z
        var aName :String = ClientContext.getPlayerName(a.playerId);
        var bName :String = ClientContext.getPlayerName(b.playerId);

        return aName.localeCompare(bName);
    }

    public static function compareAges (a :Score, b :Score) :int
    {
        // compare dates. newer dates come before older
        var aTime :Number = a.date.time;
        var bTime :Number = b.date.time;

        if (aTime > bTime) {
            return -1;
        } else if (aTime < bTime) {
            return 1;
        }

        // compare scores. higher scores come before lower
        if (a.score > b.score) {
            return -1;
        } else if (a.score < b.score) {
            return 1;
        }

        // compare names. A comes before Z
        var aName :String = ClientContext.getPlayerName(a.playerId);
        var bName :String = ClientContext.getPlayerName(b.playerId);

        return aName.localeCompare(bName);
    }

    public function isEqual (rhs :Score) :Boolean
    {
        return (this.playerId == rhs.playerId && this.score == rhs.score && this.date.time == rhs.date.time);
    }

    public function clone () :Score
    {
        return new Score(playerId, score, date);
    }
}

}
