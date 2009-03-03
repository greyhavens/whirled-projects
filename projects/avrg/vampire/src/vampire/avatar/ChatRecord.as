package vampire.avatar
{
    import com.threerings.util.HashMap;

    import flash.utils.ByteArray;


/**
 * The avatar records recent chat occurances, and parcels them up to send to the server.
 *
 */
public class ChatRecord
{

    public function playerChatted( playerId :int ) :void
    {
        var currentChats :int = int(chats.get( playerId ));
        currentChats++;
        chats.put( playerId, currentChats );
    }

    public function toBytes() :ByteArray
    {
        var bytes :ByteArray = new ByteArray();
        bytes.writeInt( chats.size() );
        chats.forEach( function( playerId :int, chatCount :int ) :void
        {
            bytes.writeInt( playerId );
            bytes.writeInt( chatCount );
        });
        return bytes;
    }

    public static function fromBytes( bytes :ByteArray ) :ChatRecord
    {
        var chatRecord :ChatRecord = new ChatRecord();
        var count :int = bytes.readInt();

        for( var i :int = 0; i < count; i++) {
            var playerId :int = bytes.readInt();
            var chatCount :int = bytes.readInt();
            chatRecord.chats.put( playerId, chatCount );
        }
        return chatRecord;
    }

    public var chats :HashMap = new HashMap();

}
}