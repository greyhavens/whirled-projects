package vampire.server
{
public class LogicRoom
{

    /**
    * If the avatar moves, break off the feeding/baring.
    */
    public static function handleAvatarMoved(userIdMoved :int) :void
    {
        //Moving nullifies any action we are currently doing, except if we are heading to
        //feed.

        switch(action) {

            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_PLAYER:

            case VConstants.GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER:
                break;//Don't change our state if we are moving into position

            case VConstants.GAME_MODE_FEED_FROM_PLAYER:
                var victim :Player = ServerContext.server.getPlayer(targetId);
                if(victim != null) {
                    victim.setAction(VConstants.GAME_MODE_NOTHING);
                }
                else {
                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
                }
                setAction(VConstants.GAME_MODE_NOTHING);
                break;

            case VConstants.GAME_MODE_BARED:
                var predator :Player = ServerContext.server.getPlayer(targetId);
                if(predator != null) {
                    predator.setAction(VConstants.GAME_MODE_NOTHING);
                }
                else {
                    log.error("avatarMoved(), we shoud be breaking off a victim, but there is no victim.");
                }
                setAction(VConstants.GAME_MODE_NOTHING);
                break;


            case VConstants.GAME_MODE_FEED_FROM_NON_PLAYER:
            default :
                setAction(VConstants.GAME_MODE_NOTHING);
                userIdMoved
        }
    }

}
}