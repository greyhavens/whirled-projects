package com.whirled.contrib.avrg.avatar
{
import com.threerings.util.ClassUtil;

import flash.events.Event;

public class AvatarMovedEvent extends Event
{
    public function AvatarMovedEvent(type:String, playerId :int)
    {
        super(type, false, false);
        if (!(type == AVATAR_STARTED_MOVE || type == AVATAR_ENDED_MOVE)) {
            throw new Error(ClassUtil.getClassName(this) + " must be either "
                + AVATAR_STARTED_MOVE + " or " + AVATAR_ENDED_MOVE);
        }
        _playerId = playerId;
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    protected var _playerId :int;

    public static const AVATAR_STARTED_MOVE :String "AvatarStartedMove";
    public static const AVATAR_ENDED_MOVE :String "AvatarEndedMove";
}
}