package vampire.server
{
    import com.threerings.flash.MathUtil;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.HashMap;
    import com.threerings.util.HashSet;
    import com.threerings.util.Log;
    import com.threerings.util.StringBuilder;
    import com.whirled.avrg.AVRGameControlEvent;
    import com.whirled.contrib.simplegame.server.SimObjectThane;
    import com.whirled.net.MessageReceivedEvent;

    import flash.utils.Dictionary;

    import vampire.data.Codes;
    import vampire.data.VConstants;
    import vampire.net.messages.NonPlayerIdsInRoomMessage;

public class NonPlayerAvatarsBloodMonitor extends SimObjectThane
{

    public function NonPlayerAvatarsBloodMonitor()
    {
        //When a player starts, we remove them from nonplayers.
        registerListener(ServerContext.ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME,
            function( e:AVRGameControlEvent ) :void {
                _playerIdsThatHavePlayedEver.add( int(e.value ) );
                _nonplayerBlood.remove( int(e.value ) );
                _nonplayer2RoomId.remove( int(e.value ) );
            });

        registerListener(ServerContext.msg, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage );
    }

    protected function handleMessage( e :MessageReceivedEvent ) :void
    {
        if( e.value is NonPlayerIdsInRoomMessage ) {
            var msg :NonPlayerIdsInRoomMessage = e.value as NonPlayerIdsInRoomMessage;
            if( msg != null) {

                var roomId :int = msg.roomId;
                for each( var nonPlayerId :int in msg.nonPlayerIds) {
                    _nonplayer2RoomId.put( nonPlayerId, roomId );
                    if( !_nonplayerBlood.containsKey(nonPlayerId)) {
                        _nonplayerBlood.put(nonPlayerId, maxBloodFromNonPlayer(nonPlayerId))
                    }
                    log.debug("Non player assigned to room=" + roomId);
                    log.debug("players recorded=" + _playerIdsThatHavePlayedEver.toArray());
                }
            }
        }
        log.debug(toString());
    }

    /**
     * Returns the name of this object.
     * Two objects in the same db cannot have the same name.
     * Objects cannot change their names once added to a mode.
     */
    override public function get objectName () :String
    {
        return NAME;
    }

    /**
    * Make sure you have already checked that the user is a non-player.
    */
    public function bloodAvailableFromNonPlayer( userId :int) :Number
    {
        //If a player quits the game, they have 0 blood.  Stops cheats.
        if( _playerIdsThatHavePlayedEver.contains( userId ) ) {
            return 0;
        }

        if( _nonplayerBlood.containsKey( userId )) {
            return _nonplayerBlood.get( userId ) as Number;
        }

        return VConstants.MAX_BLOOD_NONPLAYERS;
    }

    public function maxBloodFromNonPlayer( userId :int) :Number
    {
        return VConstants.MAX_BLOOD_NONPLAYERS;
    }

    public function isNonPlayerCapableOfBeingEaten( userId :int ) :Boolean
    {
        if( _nonplayerBlood.containsKey( userId ) ) {
            return _nonplayerBlood.get( userId ) >= VConstants.BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED;
        }
        return true;
    }

//    public function damageNonPlayer( blood :Number, userId :int) :void
//    {
//        var currentBlood :Number = VConstants.MAX_BLOOD_NONPLAYERS;
//
//        if( _nonplayerBlood.containsKey( userId )) {
//            currentBlood =  _nonplayerBlood.get( userId ) as Number;
//        }
//
//        currentBlood -= blood;
//        currentBlood = Math.max( 0, currentBlood );
//
//        _nonplayerBlood.put( userId, currentBlood );
//    }

//    public function playerFeedsFromNonPlayer( player :Player, victimId :int, bloodLost :int) :void
//    {
//        if( _nonplayerBlood.containsKey( victimId )) {
//            _nonplayerBlood.put( victimId, Math.max( Number(_nonplayerBlood.get(victimId)) - bloodLost, 0));
//        }
//        else {
//            _nonplayerBlood.put( victimId, Constants.MAX_BLOOD_NONPLAYERS - bloodLost);
//        }
//
//        //Update the room location of the nonplayer if necessary
//        if( player.room != null) {
//            if( player.room.hashCode() != _nonplayer2RoomId.get( victimId )) {
//                removeNonPlayerFromAllRooms( victimId );
//            }
//            //Put the nonplayer in the new room
////            player.room.nonPlayerAvatarIds.add( victimId );
//            _nonplayer2RoomId.put( victimId, player.room.hashCode());
//
////            setIntoRoomProperties(player.room);
//        }
//    }

    public function damageNonPlayer( victimId :int, damage :int, roomId :int) :Number
    {
        var currentBlood :Number = _nonplayerBlood.containsKey( victimId ) ?
            _nonplayerBlood.get(victimId) : VConstants.MAX_BLOOD_NONPLAYERS;

        var bloodLost :Number = currentBlood - 1 >= damage ? damage : currentBlood - 1;

        log.debug("nonplayerLosesBlood", "victimId", victimId, "damage", damage,
            "currentBlood", currentBlood, "bloodLost", bloodLost);

        _nonplayerBlood.put( victimId, Math.max( currentBlood - bloodLost, 1));
        log.debug("Putting " + victimId + "=" + _nonplayerBlood.get( victimId ));

        _nonplayer2RoomId.put( victimId, roomId );

        return bloodLost;
//        if( _nonplayerBlood.containsKey( victimId )) {
//            _nonplayerBlood.put( victimId, Math.max( Number(_nonplayerBlood.get(victimId)) - bloodLost, 0));
//        }
//        else {
//            _nonplayerBlood.put( victimId, VConstants.MAX_BLOOD_NONPLAYERS - bloodLost);
//        }

    }

//    protected function setIntoRoomProperties( room :Room ) :void
//    {
//        var data :Array = new Array();
////        room.nonPlayerAvatarIds.forEach( function( nonplayerId :int) :void {
////            if( _nonplayerBlood.containsKey( nonplayerId )) {
////                data.put( nonplayerId);
////                data.put( _nonplayerBlood.get(nonplayerId));
////            }
////        });
//
////        if( !ArrayUtil.equals(room.ctrl.props.get( Codes.ROOM_PROP_BLOOD_NON_PLAYERS ), data)) {
////            room.ctrl.props.get( Codes.ROOM_PROP_BLOOD_NON_PLAYERS, data);
////        }
//
//    }


//    protected function removeNonPlayerFromAllRooms( nonplayerId :int ) :void
//    {
//        //Remove the nonplayer from its old room
////        if( ServerContext.vserver.isRoom( _nonplayer2RoomId.get( nonplayerId ))) {
////            var room :Room = ServerContext.vserver.getRoom( _nonplayer2RoomId.get( nonplayerId ));
////            room.nonPlayerAvatarIds.remove( nonplayerId );
////        }
////        _nonplayer2RoomId.remove( nonplayerId );
//    }

    //Allow the non-players to regenerate blood and update room props
    override protected  function update( dt :Number ) :void
    {
        _bloodUpdateTime += dt;
        if( _bloodUpdateTime < UPDATE_BLOOD_INTERVAL) {
            return;
        }
        _bloodUpdateTime = 0;

        var keys :Array = _nonplayerBlood.keys();
        var userId :int;
        var roomId :int;
        for each( userId in keys) {

            //Update the blood before trying to put it in a room.
            var blood :Number = _nonplayerBlood.get( userId );
            if( isNaN( blood ) ) {
                blood = maxBloodFromNonPlayer(userId);
                _nonplayerBlood.put( userId, blood);
            }

            //Regenerate //if we aren't being eaten.
            blood += VConstants.THRALL_BLOOD_REGENERATION_RATE * dt;
            blood = MathUtil.clamp(blood, 1, VConstants.MAX_BLOOD_NONPLAYERS);

            //If we've played, but are currently offline, our blood is 1, so as to stop
            //players drinking it without our permission.
            if( _playerIdsThatHavePlayedEver.contains(userId) &&
                !ServerContext.vserver.isPlayer(userId)) {

                blood = 1;
            }

            _nonplayerBlood.put( userId, blood );



            //If we're not assigned a room, we can't update the room props.
            if( !_nonplayer2RoomId.containsKey( userId )) {
                continue;
            }

            roomId = _nonplayer2RoomId.get( userId );

            if( !ServerContext.vserver.isRoom( roomId )) {
                continue;
            }

            var room :Room = ServerContext.vserver.getRoom( roomId );

            //Skip if the room is wonky
            if( room == null || room.ctrl == null || !room.ctrl.isConnected() || room.isStale) {
                continue;
            }


            var key :String = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + userId;

            var dict :Dictionary = room.ctrl.props.get(key) as Dictionary;
            if (dict == null) {
                dict = new Dictionary();
            }

            if (dict[Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD] != blood ) {
                room.ctrl.props.setIn(key, Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, blood);
            }

            if( blood >= VConstants.MAX_BLOOD_NONPLAYERS) {//If they have regained all blood, remove from counter.
                _nonplayerBlood.remove( userId );
                _nonplayer2RoomId.remove( userId );
            }
        }
    }

    public function isUserNonPlayer( userId :int ) :Boolean
    {
        return !_playerIdsThatHavePlayedEver.contains( userId );
    }

    public function addNewPlayer( playerId :int ) :void
    {
        _playerIdsThatHavePlayedEver.add( playerId );
    }

    /**
    * Rooms call this when they receive location information
    */
    public function setUserRoom( userId :int, roomId :int ) :void
    {
        _nonplayer2RoomId.put( userId, roomId );
    }

    override public function toString() :String
    {
        var sb :StringBuilder = new StringBuilder(ClassUtil.tinyClassName(this));
        sb.append("\n NP blood: " + _nonplayerBlood.keys() + ":" + _nonplayerBlood.values());
        sb.append("\n NP rooms: " + _nonplayer2RoomId.keys() + ":" + _nonplayer2RoomId.values());
        return sb.toString();
    }


    //Non-players can only be fed occasionally
    protected var _nonplayerBlood :HashMap = new HashMap();
//    protected var _room2NonPlayers :HashMap = new HashMap();
    protected var _nonplayer2RoomId :HashMap = new HashMap();

    //We use this too keep players and non-players seperate, even if a player quits.
    public var _playerIdsThatHavePlayedEver :HashSet = new HashSet();


    protected var _bloodUpdateTime :Number = 0;
    protected static const UPDATE_BLOOD_INTERVAL :Number = 2;

    protected static const NAME :String = "NonAvatarPlayersBloodMonitor";
    protected static const log :Log = Log.getLog( NonPlayerAvatarsBloodMonitor );

}
}