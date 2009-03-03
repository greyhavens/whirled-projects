package vampire.net.messages
{
    import com.threerings.util.ClassUtil;

    import flash.utils.ByteArray;

    public class NonPlayerIdsInRoomMessage extends BaseGameMessage
    {
        public function NonPlayerIdsInRoomMessage(playerId:int = 0, nonPlayerIds :Array = null)
        {
            super(playerId);
            _npIds = nonPlayerIds != null ? nonPlayerIds : new Array();
        }


        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _npIds = new Array();

            var count :int = bytes.readInt();
            while( count > 0 ) {
                _npIds.push( bytes.readInt() );
                count--;
            }

        }

        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);

            bytes.writeInt( _npIds.length );

            for each( var id :int in _npIds ) {
                bytes.writeInt( id );
            }
            return bytes;
        }

        public function get nonPlayerIds () :Array
        {
           return _npIds;
        }

        override public function get name () :String
        {
           return NAME;
        }

        override public function toString() :String
        {
            return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", ids=" + _npIds;
        }

        protected var _npIds :Array;

        public static const NAME :String = "Message: Non-Player Ids";

    }
}