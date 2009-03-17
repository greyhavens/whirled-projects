package vampire.net.messages
{
    import flash.utils.ByteArray;

    public class FeedConfirmMsg extends BaseGameMsg
    {
        public function FeedConfirmMsg(playerId:int = 0, isAllowedToFeed :Boolean = false)
        {
            super(playerId);
            _isAllowedToFeed = isAllowedToFeed;
        }

        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _isAllowedToFeed = bytes.readBoolean();
        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeBoolean( _isAllowedToFeed );
            return bytes;
        }

        public function get isAllowedToFeed() :Boolean
        {
            return _isAllowedToFeed;
        }

        override public function get name () :String
        {
           return NAME;
        }

        protected var _isAllowedToFeed :Boolean;

        public static const NAME :String = "PreyFeedingConfirm";
    }
}