package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

    public class RequestStateChangeMsg extends BaseGameMsg
    {
        public function RequestStateChangeMsg(playerId:int = 0, state :String = null)
        {
            super(playerId);
            _state = state == null ? "" : state;
        }


        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _state = bytes.readUTF();
        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeUTF(_state);
            return bytes;
        }

        public function get state () :String
        {
           return _state;
        }

        override public function get name () :String
        {
           return NAME;
        }

        override public function toString() :String
        {
            return ClassUtil.tinyClassName(this) + ": player=" + _playerId + ", action=" + _state;
        }

        protected var _state :String;

        public static const NAME :String = "Message: Request Action Change";

    }
}
