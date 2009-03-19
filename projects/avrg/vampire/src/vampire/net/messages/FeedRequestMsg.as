package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

    public class FeedRequestMsg extends BaseGameMsg
    {
        public function FeedRequestMsg(playerId :int = 0,
                                            targetPlayerId :int = 0,
                                            targetLocationX :Number = 0,
                                            targetLocationY :Number = 0,
                                            targetLocationZ :Number = 0
                                            )
        {
            super(playerId);
            _targetPlayerId = targetPlayerId;
            _targetX = targetLocationX;
            _targetY = targetLocationY;
            _targetZ = targetLocationZ;
        }

        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _targetPlayerId = bytes.readInt();
            _targetX = bytes.readFloat();
            _targetY = bytes.readFloat();
            _targetZ = bytes.readFloat();
        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt( _targetPlayerId );
            bytes.writeFloat( _targetX );
            bytes.writeFloat( _targetY );
            bytes.writeFloat( _targetZ );
            return bytes;
        }

        public function get targetPlayer () :int
        {
           return _targetPlayerId;
        }

        override public function get name () :String
        {
           return NAME;
        }

        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", eating " + targetPlayer;
        }

        public function get targetX () :Number
        {
           return _targetX;
        }
        public function get targetY () :Number
        {
           return _targetY;
        }
        public function get targetZ () :Number
        {
           return _targetZ;
        }


        protected var _targetPlayerId :int;
        protected var _targetX :Number;
        protected var _targetY :Number;
        protected var _targetZ :Number;
        protected var _allowMultiplePredators :Boolean;

        public static const NAME :String = "Message: Request Feed";

    }
}