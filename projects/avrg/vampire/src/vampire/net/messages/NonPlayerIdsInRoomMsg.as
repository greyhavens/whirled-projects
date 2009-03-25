package vampire.net.messages
{
import com.threerings.util.ClassUtil;

import flash.utils.ByteArray;

/**
 * This is currently not used, since we no longer monitor non-players blood on the server anymore.
 * We'll keep it around in case we upgrade the game.
 */
public class NonPlayerIdsInRoomMsg extends BaseGameMsg
{
    public function NonPlayerIdsInRoomMsg(playerId:int = 0, nonPlayerIds :Array = null, roomId :int = 0)
    {
        super(playerId);
        _npIds = nonPlayerIds != null ? nonPlayerIds : new Array();
        _roomId = roomId;
    }


    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);

        _roomId = bytes.readInt();

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

        bytes.writeInt( _roomId );

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

    public function get roomId () :int
    {
       return _roomId;
    }

    override public function get name () :String
    {
       return NAME;
    }

    override public function toString() :String
    {
        return ClassUtil.tinyClassName( this ) + ": player=" + _playerId + ", ids=" + _npIds + ", room=" + _roomId;
    }

    protected var _npIds :Array;
    protected var _roomId :int;

    public static const NAME :String = "Message: Non-Player Ids";

}
}