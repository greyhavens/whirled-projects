package flashmob.client {

import com.whirled.contrib.simplegame.Updatable;

import flash.events.EventDispatcher;

public class AvatarMonitor extends EventDispatcher
    implements Updatable
{
    public function AvatarMonitor ()
    {
        _lastAvatarId = this.curAvatarId;
    }

    public function get curAvatarId () :int
    {
        return ClientContext.gameCtrl.player.getAvatarMasterItemId();
    }

    public function update (dt :Number) :void
    {
        var curAvatarId :int = this.curAvatarId;
        if (curAvatarId != _lastAvatarId) {
            _lastAvatarId = curAvatarId;
            dispatchEvent(new GameEvent(GameEvent.AVATAR_CHANGED, curAvatarId));
        }
    }

    protected var _lastAvatarId :int;
}

}
