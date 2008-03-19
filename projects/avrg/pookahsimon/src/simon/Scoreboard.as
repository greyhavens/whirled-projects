package simon {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class Scoreboard
{
    public function Scoreboard ()
    {
    }

    public function getPlayerScore (name :String) :int
    {
        var index :int = ArrayUtil.indexIf(_scores, function (score :Score) :Boolean { return score.name == name });
        return (index >= 0 ? (_scores[index] as Score).score : 0);
    }

    public function addScore (name :String, score :int, date :Date = null) :void
    {
        if (null == date) {
            date = new Date();
        }

        var scoreObj :Score = this.createOrGetScore(name);
        scoreObj.score = score;
        scoreObj.date = date;

        // sort on score, highest to lowest
        _scores.sort(Score.compare);
    }

    public function incrementScore (name :String, date :Date = null) :void
    {
        if (null == date) {
            date = new Date();
        }

        var scoreObj :Score = this.createOrGetScore(name);
        scoreObj.score += 1;
        scoreObj.date = date;

        // sort on score, highest to lowest
        _scores.sort(Score.compare);
    }

    protected function createOrGetScore (name :String) :Score
    {
        var scoreObj :Score;

        // does this name already have an entry?
        var index :int = ArrayUtil.indexIf(_scores, function (score :Score) :Boolean { return score.name == name });

        if (index >= 0) {
            scoreObj = _scores[index];
        } else {
            scoreObj = new Score(name, 0, new Date());
            _scores.push(scoreObj);
        }

        return scoreObj;
    }

    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();

        for each (var score :Score in _scores) {
            ba.writeUTF(score.name);
            ba.writeInt(score.score);
            ba.writeDouble(score.date.time);
        }

        return ba;
    }

    public static function fromBytes (ba :ByteArray) :Scoreboard
    {
        ba.position = 0;

        var scoreboard :Scoreboard = new Scoreboard();

        while (ba.bytesAvailable > 0) {
            var name :String = ba.readUTF();
            var score :int = ba.readInt();
            var time :Number = ba.readDouble();

            scoreboard.addScore(name, score, new Date(time));
        }

        return scoreboard;
    }

    public function isEqual (rhs :Scoreboard) :Boolean
    {
        var lhsScores :Array = _scores;
        var rhsScores :Array = rhs.scores;

        if (lhsScores.length != rhsScores.length) {
            return false;
        }

        for (var i :int = 0; i < lhsScores.length; ++i) {
            var lhsScore :Score = lhsScores[i];
            var rhsScore :Score = rhsScores[i];

            if (!lhsScore.isEqual(rhsScore)) {
                return false;
            }
        }

        return true;
    }

    public function clone () :Scoreboard
    {
        var cloneScores :Array = [];
        for each (var score :Score in _scores) {
            cloneScores.push(score.clone());
        }

        var theClone :Scoreboard = new Scoreboard();
        theClone._scores = cloneScores;

        return theClone;
    }

    public function get scores () :Array
    {
        return _scores;
    }

    protected var _scores :Array = [];
}

}
