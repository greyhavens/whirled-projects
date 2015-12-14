package bingo {

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
        var index :int = ArrayUtil.indexIf(_scores, function (score :Score) :Boolean {
            return score.playerId == playerId
        });
        return (index >= 0 ? _scores[index] : null);
    }

    public function addScore (playerId :int, score :int, date :Date) :void
    {
        var scoreObj :Score = this.createOrGetScore(playerId);
        scoreObj.score = score;
        scoreObj.date = date;

        this.trimEntries();
    }

    public function incrementScore (playerId :int, date :Date = null) :void
    {
        var scoreObj :Score = this.createOrGetScore(playerId);
        scoreObj.score += 1;
        scoreObj.date = (date != null ? date : new Date());

        this.trimEntries();
    }

    protected function createOrGetScore (playerId :int) :Score
    {
        var scoreObj :Score = this.getScore(playerId);

        if (null == scoreObj) {
            scoreObj = new Score(playerId, 0, new Date());
            _scores.push(scoreObj);
        }

        return scoreObj;
    }

    protected function trimEntries () :void
    {
        // trim the oldest entries
        if (_maxEntries >= 0 && _scores.length > _maxEntries) {
            _scores.sort(Score.compareAges);
            _scores.splice(_maxEntries);
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

    public function clone () :ScoreTable
    {
        var cloneScores :Array = [];
        for each (var score :Score in _scores) {
            cloneScores.push(score.clone());
        }

        var theClone :ScoreTable = new ScoreTable(_maxEntries);
        theClone._scores = cloneScores;

        return theClone;
    }

    public function get scores () :Array
    {
        return _scores;
    }

    protected var _scores :Array = [];
    protected var _maxEntries :int;
}

}
