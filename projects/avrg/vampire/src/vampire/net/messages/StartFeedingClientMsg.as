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
        bytes.writeInt(_gameId);
        bytes.writeInt(_highScoresDaily.length);
        for (var ii :int = 0; ii < _highScoresDaily.length; ++ii) {
            bytes.writeInt(_highScoresDaily[ii][0]);
            bytes.writeUTF(_highScoresDaily[ii][1]);
        }

        bytes.writeInt(_highScoresMonthly.length);
        for (ii = 0; ii < _highScoresMonthly.length; ++ii) {
            bytes.writeInt(_highScoresMonthly[ii][0]);
            bytes.writeUTF(_highScoresMonthly[ii][1]);
        }
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        var score :int;
        var names :String;
        var ii :int;

        _gameId = bytes.readInt();
        var length :int = bytes.readInt();
        _highScoresDaily = [];
        for (ii = 0; ii < length; ++ii) {
            score = bytes.readInt();
            names = bytes.readUTF();
            _highScoresDaily.push([score, names]);
        }

        length = bytes.readInt();
        _highScoresMonthly = [];
        for (ii = 0; ii < length; ++ii) {
            score = bytes.readInt();
            names = bytes.readUTF();
            _highScoresMonthly.push([score, names]);
        }
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName(this) + ": player=" + _playerId
            + ", scores daily=" + _highScoresDaily
            + ", scores monthly=" + _highScoresMonthly;
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

    protected var _gameId :int;
    protected var _highScoresDaily :Array;
    protected var _highScoresMonthly :Array;

    public static const NAME :String = "Message: Start Feeding Client";

}
}