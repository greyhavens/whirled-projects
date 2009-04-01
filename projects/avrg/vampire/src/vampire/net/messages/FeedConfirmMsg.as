package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

    public class FeedConfirmMsg extends BaseGameMsg
    {
        public function FeedConfirmMsg(playerId:int = 0, preyName :String = null, predatorId :int= 0, isAllowedToFeed :Boolean = false)
        {
            super(playerId);
            _isAllowedToFeed = isAllowedToFeed;
            _predId = predatorId;
            _preyName = preyName == null ? "" : preyName;
        }

        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _isAllowedToFeed = bytes.readBoolean();
            _predId = bytes.readInt();
            _preyName = bytes.readUTF();
        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeBoolean(_isAllowedToFeed);
            bytes.writeInt(_predId);
            bytes.writeUTF(_preyName);
            return bytes;
        }

        public function get isAllowedToFeed() :Boolean
        {
            return _isAllowedToFeed;
        }

        public function get predatorId() :int
        {
            return _predId;
        }

        public function get preyName () :String
        {
           return _preyName;
        }

        override public function get name () :String
        {
           return NAME;
        }

        override public function toString() :String
        {
            return ClassUtil.tinyClassName(this) + ": prey="
                + _playerId
                + ", predId=" + predatorId
                + ", preyName=" + preyName
                + ", allow feeding=" + isAllowedToFeed;
        }

        protected var _preyName :String;
        protected var _isAllowedToFeed :Boolean;
        protected var _predId :int;

        public static const NAME :String = "PreyFeedingConfirm";
    }
}