package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

public class StartFeedingClientMsg extends BaseGameMsg
{
    public function StartFeedingClientMsg(playerId:int = 0, gameId :int = 0, scoresDay :Array = null,
        scoresMonth :Array = null)
    {
        super(playerId);
        _gameId = gameId;
        _highScoresDaily = scoresDay == null ? [] : scoresDay;
        _highScoresMonthly = scoresMonth == null ? [] : scoresMonth;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        var bytes :ByteArray = super.toBytes(bytes);
        var ii :int;
        bytes.writeInt(_gameId);

        function writeScoreArray (bytes :ByteArray, scores :Array) :void {

            bytes.writeInt(scores.length);
            for (var ii :int = 0; ii < scores.length; ++ii) {
                if (scores[ii] as Array == null ||
                    (scores[ii] as Array).length < 2) {
                        bytes.writeInt(0);
                        bytes.writeUTF("");
                    }
                else {
                    bytes.writeInt(scores[ii][0]);
                    bytes.writeUTF(scores[ii][1] == null ? "" : scores[ii][1]);
                }
            }
        }
        writeScoreArray(bytes, _highScoresDaily);
        writeScoreArray(bytes, _highScoresMonthly);

        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        _gameId = bytes.readInt();

        function readScoreArray (bytes :ByteArray) :Array {
            var length :int = bytes.readInt();
            var scores :Array = [];
            for (var ii :int = 0; ii < length; ++ii) {
                var score :int = bytes.readInt();
                var names :String = bytes.readUTF();
                scores.push([score, names]);
            }
            return scores;
        }

        _highScoresDaily = readScoreArray(bytes);
        _highScoresMonthly = readScoreArray(bytes);
    }

    public function get scoresDaily () :Array
    {
       return _highScoresDaily;
    }
    public function get scoresMonthly () :Array
    {
       return _highScoresMonthly;
    }

    public function get gameId () :int
    {
       return _gameId;
    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString () :String
    {
        return ClassUtil.tinyClassName(this)
            + "gameId=" + _gameId
            + ", scoresDaily=" + scoresDaily
            + ", scoresMonthly=" + scoresMonthly;
    }

    protected var _gameId :int;
    protected var _highScoresDaily :Array;
    protected var _highScoresMonthly :Array;

    public static const NAME :String = "Message: Start Feeding Client";

}
}