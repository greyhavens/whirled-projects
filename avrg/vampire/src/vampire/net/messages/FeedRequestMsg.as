package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

    public class FeedRequestMsg extends BaseGameMsg
    {
        public function FeedRequestMsg(playerId :int = 0,
                                            predId :int = 0,
                                            targetPlayerId :int = 0,
                                            targetPlayerName :String = null,
                                            targetLocationX :Number = 0,
                                            targetLocationY :Number = 0,
                                            targetLocationZ :Number = 0,
                                            targetLocationAngle :Number = 0)
        {
            super(playerId);
            _predId = predId;
            _targetPlayerId = targetPlayerId;
            _targetPlayerName = targetPlayerName == null ? "" : targetPlayerName;
            _targetX = targetLocationX;
            _targetY = targetLocationY;
            _targetZ = targetLocationZ;
            _targetAngle = targetLocationAngle;
        }

        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _predId = bytes.readInt();
            _targetPlayerId = bytes.readInt();
            _targetPlayerName = bytes.readUTF();
            _targetX = bytes.readFloat();
            _targetY = bytes.readFloat();
            _targetZ = bytes.readFloat();
            _targetAngle = bytes.readFloat();
        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeInt(_predId);
            bytes.writeInt(_targetPlayerId);
            bytes.writeUTF(_targetPlayerName);
            bytes.writeFloat(_targetX);
            bytes.writeFloat(_targetY);
            bytes.writeFloat(_targetZ);
            bytes.writeFloat(_targetAngle);
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
            return ClassUtil.tinyClassName(this)
                + ": player=" + _playerId
                + ", targetPlayerId=" + _targetPlayerId;
                + ", eating=" + targetName;
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
        public function get targetAngle () :Number
        {
           return _targetAngle;
        }

        public function get targetName () :String
        {
           return _targetPlayerName;
        }

        public function get predId () :int
        {
           return _predId;
        }

        protected var _predId :int;
        protected var _targetPlayerId :int;
        protected var _targetPlayerName :String;
        protected var _targetX :Number;
        protected var _targetY :Number;
        protected var _targetZ :Number;
        protected var _targetAngle :Number;

        public static const NAME :String = "Message: Request Feed";

    }
}
