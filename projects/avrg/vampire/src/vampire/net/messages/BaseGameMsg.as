package vampire.net.messages
{
    import com.threerings.util.ClassUtil;
    import com.whirled.contrib.messagemgr.Message;

    import flash.utils.ByteArray;

    public class BaseGameMsg
        implements Message
    {
        public function BaseGameMsg(playerId :int = -1)
        {
            _playerId = playerId;
        }

        public function get name () :String
        {
           throw Error("Abstract class.");
        }

        public function fromBytes (bytes :ByteArray) :void
        {
            bytes.position = 0;
            _playerId = bytes.readInt();
        }

        public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            if(bytes == null) {
                bytes = new ByteArray();
            }
            bytes.writeInt(_playerId);
            return bytes;
        }

        public function get playerId() :int
        {
            return _playerId;
        }

        public function toString() :String
        {
            return ClassUtil.tinyClassName(this) + ": From player " + _playerId + " ";
        }

        protected var _playerId :int;
    }
}
