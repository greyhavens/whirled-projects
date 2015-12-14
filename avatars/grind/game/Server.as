package {

import flash.utils.Dictionary;

import com.whirled.avrg.*;
import com.whirled.net.*;
import com.whirled.*;

public class Server extends ServerObject
{
    public function Server ()
    {
        _ctrl = new AVRServerGameControl(this);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerJoin);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, handlePlayerQuit);
    }

    public function echo (player :PlayerSubControlServer, text :String) :void
    {
        player.sendMessage("echo", text);
        trace("Echo: " + text);
    }

    public function handlePlayerJoin (event :AVRGameControlEvent) :void
    {
        var player :PlayerSubControlServer = _ctrl.getPlayer(event.value as int);

        player.addEventListener(AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        player.addEventListener(AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);
    }

    public function handlePlayerQuit (event :AVRGameControlEvent) :void
    {
        var playerId :int = event.value as int;

        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);
    }

    protected function handleRoomEntry (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = event.value as int;

        delete _playerToRoom[playerId];
        _roomToPopulation[roomId] = int(_roomToPopulation[roomId]) + 1;
        if (_roomToPopulation[roomId] == 1) {
            _ctrl.getRoom(roomId).addEventListener(AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignal);
        }
    }

    protected function handleRoomExit (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = _playerToRoom[playerId] as int;

        _playerToRoom[playerId] = roomId;
        _roomToPopulation[roomId] = int(_roomToPopulation[roomId]) - 1;
        if (_roomToPopulation[roomId] == 0) {
            _ctrl.getRoom(roomId).removeEventListener(AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignal);
        }
    }

    protected function handleSignal (event :AVRGameRoomEvent) :void
    {
        if (event.name == QuestConstants.KILL_SIGNAL) {
            var data :Array = event.value as Array;
            var killerId :int = data[0];
            var victimId :int = data[1];
            var level :int = data[2];
            var mode :int = data[3];

            // TODO: Enable
            //if (killerId != victimId) { // Can't earn credit in your own dungeon
            if (true) {
                try {
                    // A hero should be awarded
                    if (mode == QuestConstants.PLAYER_KILLED_MONSTER ||
                        mode == QuestConstants.PLAYER_KILLED_PLAYER) {
                        var player :PlayerSubControlServer = _ctrl.getPlayer(killerId);
                        var heroStat :String = Codes.HERO+mode;

                        player.completeTask("hero"+mode, level/150); // TODO: Tweak
                        player.props.set(heroStat, int(player.props.get(heroStat))+1);
                        echo(player, "Well done, " + heroStat + " = " + player.props.get(heroStat));
                    }

                    // Award the dungeon keeper
                    if (mode == QuestConstants.PLAYER_KILLED_MONSTER ||
                        mode == QuestConstants.MONSTER_KILLED_PLAYER) {
                        var keeperId :int =
                            (mode == QuestConstants.PLAYER_KILLED_MONSTER) ? victimId : killerId;
                        var keeperStat :String = Codes.KEEPER+mode;

                        _ctrl.loadOfflinePlayer(keeperId,
                            function (props :OfflinePlayerPropertyControl) :void {
                                props.set(Codes.CREDITS, int(props.get(Codes.CREDITS))+level);
                                props.set(keeperStat, int(props.get(keeperStat))+1);
                                trace("Keepstat " + keeperStat + " = " + props.get(keeperStat));
                                trace("credit = " + props.get(Codes.CREDITS));
                            },
                            function (... _) :void {
                                trace("This should hardly ever happen");
                            }
                        );
                    }
                } catch (error :Error) {
                    trace("Someone is playing outside the AVRG!");
                    // It's possible that they're hacking away while not in the AVRG
                }
            }
        }
    }

    /** Maps player ID to scene ID. */
    protected var _playerToRoom :Dictionary = new Dictionary();

    /** Maps scene ID to occupant count. */
    protected var _roomToPopulation :Dictionary = new Dictionary();

    protected var _ctrl :AVRServerGameControl;
}

}
