package simon.data {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class ScoreTable
{
    public function ScoreTable (maxEntries :int)
    {
        _maxEntries = maxEntries;
    }

    public function getScore (playerId :int) :Score
    {
        var index :int = ArrayUtil.indexIf(_scores, function (score :Score) :Boolean { return score.playerId == playerId });
        return (index >= 0 ? _scores[index] : null);
    }

    public function addScore (playerId :int, score :int, date :Date) :void
    {
        var scoreObj :Score = this.createOrGetScore(playerId);
        scoreObj.score = score;
        scoreObj.date = date;

        this.trimEntries();

        _isSorted = false;
    }

    public function incrementScore (playerId :int, date :Date) :void
    {
        var scoreObj :Score = this.createOrGetScore(playerId);
        scoreObj.score += 1;
        scoreObj.date = date;

        this.trimEntries();

        _isSorted = false;
    }

    protected function createOrGetScore (playerId :int) :Score
    {
        var scoreObj :Score = this.getScore(playerId);

        if (null == scoreObj) {
            scoreObj = new Score(playerId, 0, new Date());
            _scores.push(scoreObj);
        }

        _isSorted = false;

        return scoreObj;
    }

    protected function trimEntries () :void
    {
        // trim the oldest entries
        if (_maxEntries >= 0 && _scores.length > _maxEntries) {
            _scores.sort(Score.compareAges);
            _scores.splice(_maxEntries);
            _isSorted = false;
        }
    }

    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();

        for each (var score :Score in _scores) {
            ba.writeInt(score.playerId);
            ba.writeInt(score.score);
            ba.writeDouble(score.date.time);
        }

        ba.compress();

        return ba;
    }

    public static function fromBytes (ba :ByteArray, maxEntries :int) :ScoreTable
    {
        var table :ScoreTable = new ScoreTable(maxEntries);

        try {
            ba.uncompress();
            ba.position = 0;

            while (ba.bytesAvailable > 0) {
                var playerId :int = ba.readInt();
                var score :int = ba.readInt();
                var time :Number = ba.readDouble();

                table.addScore(playerId, score, new Date(time));
            }
        } catch (err :Error) {
            return new ScoreTable(maxEntries);
        }

        return table;
    }

    public function isEqual (rhs :ScoreTable) :Boolean
    {
        var lhsScores :Array = _scores;
        var rhsScores :Array = rhs.scores;

        if (lhsScores.length != rhsScores.length) {
            return false;
        }

        this.sortScores();
        rhs.sortScores();

        for (var i :int = 0; i < lhsScores.length; ++i) {
            var lhsScore :Score = lhsScores[i];
            var rhsScore :Score = rhsScores[i];

            if (!lhsScore.isEqual(rhsScore)) {
                return false;
            }
        }

        return true;
    }

    public function clone () :ScoreTable
    {
        var cloneScores :Array = [];
        for each (var score :Score in _scores) {
            cloneScores.push(score.clone());
        }

        var theClone :ScoreTable = new ScoreTable(_maxEntries);
        theClone._scores = cloneScores;
        theClone._isSorted = _isSorted;

        return theClone;
    }

    public function sortScores () :void
    {
        if (!_isSorted) {
            _scores.sort(Score.compareScores);
            _isSorted = true;
        }
    }

    public function get scores () :Array
    {
        return _scores;
    }

    protected var _scores :Array = [];
    protected var _maxEntries :int;
    protected var _isSorted :Boolean;
}

}
