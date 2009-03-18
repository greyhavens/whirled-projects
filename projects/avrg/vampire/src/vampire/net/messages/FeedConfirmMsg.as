package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

    public class FeedConfirmMsg extends BaseGameMsg
    {
        public function FeedConfirmMsg(playerId:int = 0, predatorId :int= 0, isAllowedToFeed :Boolean = false)
        {
            super(playerId);
            _isAllowedToFeed = isAllowedToFeed;
            _predId = predatorId;
        }

        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _isAllowedToFeed = bytes.readBoolean();
            _predId = bytes.readInt();
        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeBoolean( _isAllowedToFeed );
            bytes.writeInt( _predId );
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

        override public function get name () :String
        {
           return NAME;
        }

        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": prey=" + _playerId + ", predId=" + _predId + ", allow feeding=" + _isAllowedToFeed;
        }

        protected var _isAllowedToFeed :Boolean;
        protected var _predId :int;

        public static const NAME :String = "PreyFeedingConfirm";
    }
}