package vampire.avatar
{
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;

    import flash.utils.getTimer;

    import vampire.data.VConstants;


/**
 * The avatar records recent chat occurances so that valid avatars can be targeting for
 * feeding based on the frequency of chatting.
 *
 */
public class ChatRecord
{

    public function playerChatted( playerId :int, time :int = -1) :void
    {
        var currentTime :int = time != -1 ? time : getTimer();
        _chats.put( currentTime, playerId );
    }

    public function update(dt :Number = - 1) :void
    {
        var currentTime :int = dt != -1 ? dt : getTimer();
        var timeCutoff :int = currentTime - VConstants.CHAT_FEEDING_TIME_INTERVAL_MILLISECS;
        for each( var time :int in _chats.keys() ) {

            if( time <= timeCutoff) {
                _chats.remove( time );
            }
        }


//        _lastUpdateTime = currentTime;
    }

    public function get validPlayerIds() :Array
    {
        var talkativePlayerIds :Array = _chats.values();

        var validChatTargets :HashSet = new HashSet();
        var invalidChatTargets :HashSet = new HashSet();

        for each( var playerId :int in talkativePlayerIds ) {
            if( !(validChatTargets.contains( playerId ) ||
                invalidChatTargets.contains( playerId )) ) {

                    if( countChats(talkativePlayerIds, playerId) >= VConstants.CHAT_FEEDING_MIN_CHATS_PER_TIME_INTERVAL) {
                        validChatTargets.add( playerId );
                    }
                    else {
                        invalidChatTargets.add( playerId );
                    }
                }
        }

        return validChatTargets.toArray();
    }

    protected function countChats( arr :Array, playerId :int ) :int
    {
        var count :int = 0;
        for each( var p :int in arr) {
            if( p == playerId ) {
                count++;
            }
        }
        return count;
    }

    public static function test() :void
    {
        var c :ChatRecord = new ChatRecord();
        c.update(1000);
        c.playerChatted( 1, 1000 );
        c.playerChatted( 2, 2000 );
        c.playerChatted( 2, 3000 );
        c.playerChatted( 2, 4000 );
        trace("At 2s, valid players=" + c.validPlayerIds);
        c.update(VConstants.CHAT_FEEDING_TIME_INTERVAL_MILLISECS + 2000);
        trace("At 62s, valid players=" + c.validPlayerIds);
    }

//    protected var _currentTime :Number = 0;
    protected var _chats :HashMap = new HashMap();

}
}