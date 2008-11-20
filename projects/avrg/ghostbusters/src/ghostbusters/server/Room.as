//
// $Id$

package ghostbusters.server {

import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.avrg.RoomSubControlServer;

import ghostbusters.data.Codes;
import ghostbusters.data.GhostDefinition;
import ghostbusters.server.util.Formulae;

public class Room
    implements Hashable
{
    public static var log :Log = Log.getLog(Room);

    public function Room (roomId :int)
    {
        _roomId = roomId;
        _state = Codes.STATE_SEEKING;

        maybeLoadControl();
    }

    public function get roomId () :int
    {
        return _roomId;
    }

    public function get ctrl () :RoomSubControlServer
    {
        if (_ctrl == null) {
            throw new Error("Aii, no control to hand out in room: " + _roomId);
        }
        return _ctrl;
    }

    public function get ghost () :Ghost
    {
        return _ghost;
    }

    public function get state () :String
    {
        return _state;
    }

    public function get isShutdown () :Boolean
    {
        return _errorCount > 5;
    }

    // from Equalable
    public function equals (other :Object) :Boolean
    {
        if (this == other) {
            return true;
        }
        if (other == null || !ClassUtil.isSameClass(this, other)) {
            return false;
        }
        return Room(other).roomId == this.roomId;
    }

    // from Hashable
    public function hashCode () :int
    {
        return this.roomId;
    }

    public function getMinigameStats (player :Player) :Dictionary
    {
        return _minigames.get(player);
    }

    public function getTeam (excludeDead :Boolean = false) :Array
    {
        var team :Array = new Array();
        _players.forEach(function (player :Player) :void {
            if (player.playing && (!excludeDead || !player.isDead())) {
                team.unshift(player);
            }
        });
        return team;
    }

    public function playerEntered (player :Player) :void
    {
        if (!_players.add(player)) {
            log.warning("Arriving player already existed in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        maybeLoadControl();

        // broadcast the arriving player's data using room properties
        var dict :Dictionary = new Dictionary();
        dict[Codes.IX_PLAYER_CUR_HEALTH] = player.health;
        dict[Codes.IX_PLAYER_MAX_HEALTH] = player.maxHealth;
        dict[Codes.IX_PLAYER_LEVEL] = player.level;
        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, dict, true);

        // see if there's an undefeated ghost here, else make a new one
        maybeSpawnGhost();

        log.debug("Testing: " + new Error("harmless").getStackTrace());
    }

    public function playerLeft (player :Player) :void
    {
        if (!_players.remove(player)) {
            log.warning("Departing player did not exist in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        if (_ctrl == null) {
            log.warning("Null room control", "action", "player departing",
                        "playerId", player.playerId);
            return;
        }

        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, null, true);
    }

    public function checkState (... expected) :Boolean
    {
        if (ArrayUtil.contains(expected, _state)) {
            return true;
        }
        log.debug("State mismatch", "expected", expected, "actual", _state);
        return false;
    }

    public function ghostZap (who :Player) :void
    {
        if (_ghost != null && checkState(Codes.STATE_SEEKING)) {
            if (_ctrl == null) {
                log.warning("Null room control", "action", "ghost zap",
                            "playerId", who.playerId);
                return;
            }

            var timer :int = getTimer();
            if (timer < _nextZap) {
//                log.debug("Ignored too-early zap request", "playerId", who.playerId);
                return;
            }
            // accept up to two zaps a second
            _nextZap = timer + 500;
//            log.debug("Accepting zap request", "playerId", who.playerId);
            Server.control.doBatch(function () :void {
                // let the other people in the room know there was a successful zapping
                _ctrl.sendMessage(Codes.SMSG_GHOST_ZAPPED, who.playerId);

                // then actually zap the ghost (reduce its zest)
                _ghost.zap(who);
            });
        }
    }

    public function tick (frame :int, newSecond :Boolean) :void
    {
        // if we're shut down due to excessive errors, or the room is unloaded, do nothing
        if (isShutdown || _ctrl == null) {
            return;
        }

        try {
            _tick(frame, newSecond);

        } catch (e :Error) {
            log.error("Tick error", e);

            _errorCount ++;
            if (isShutdown) {
                log.info("Giving up on room tick() due to error overflow", "roomId", this.roomId);
                return;
            }
        }
    }

    // called from Player when a MSG_MINIGAME_RESULT comes in from a client
    public function minigameCompletion (
        player :Player, weapon :int, win :Boolean, damageDone :int, healingDone :int) :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "minigame completion",
                        "playerId", player.playerId);
            return;
        }

//        log.debug("Minigame completion", "playerId", player.playerId, "weapon", weapon, "damage",
//                  damageDone, "healing", healingDone);

        // award 3 points for a win, 1 for a lose
        _stats.put(player, int(_stats.get(player.playerId)) + (win ? 3 : 1));

        // record which minigame was used
        var dict :Dictionary = _minigames.get(player);
        if (dict == null) {
            dict = new Dictionary();
        }
        dict[weapon] = int(dict[weapon]) + 1;
        _minigames.put(player, dict);

        try {
            Trophies.handleMinigameCompletion(player, weapon, win);
        } catch (e :Error) {
            log.warning("Error in handleMinigameCompletion", "roomId", this.roomId, "playerId",
                        player.playerId, e);
        }

        // tweak damageDone and healingDone by the player's level
        var tweak :Number = Formulae.quadRamp(player.level);

        // then actually apply the damage or healing
        if (damageDone > 0) {
            damageGhost(damageDone * tweak);
            _ctrl.sendMessage(Codes.SMSG_GHOST_ATTACKED, player.playerId);
        }
        if (healingDone > 0) {
            doHealPlayers(player, healingDone * tweak);
        }
    }

    internal function updateLanternPos (playerId :int, pos :Array) :void
    {
        _lanterns.put(playerId, pos);
        _lanternsDirty = true;
    }

    internal function playerUpdated (player :Player) :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "player update",
                        "playerId", player.playerId);
            return;
        }

        var key :String = Codes.DICT_PFX_PLAYER + player.playerId;
        var dict :Dictionary = _ctrl.props.get(key) as Dictionary;
        if (dict == null) {
            dict = new Dictionary();
        }

        if (dict[Codes.IX_PLAYER_LEVEL] != player.level) {
            _ctrl.props.setIn(key, Codes.IX_PLAYER_LEVEL, player.level);
        }
        if (dict[Codes.IX_PLAYER_MAX_HEALTH] != player.maxHealth) {
            _ctrl.props.setIn(key, Codes.IX_PLAYER_MAX_HEALTH, player.maxHealth);
        }
        if (dict[Codes.IX_PLAYER_CUR_HEALTH] != player.health) {
            _ctrl.props.setIn(key, Codes.IX_PLAYER_CUR_HEALTH, player.health);
        }
    }

    internal function reset () :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "reset");
            return;
        }

        healTeam();
        terminateGhost(false);
        _stats.clear();
        _minigames.clear();
        setState(Codes.STATE_SEEKING);
    }

    internal function setState (state :String) :void
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "state set", "state", state);
            return;
        }

        _state = state;

        _ctrl.props.set(Codes.PROP_STATE, state, true);

        _players.forEach(function (player :Player) :void {
            player.roomStateChanged();
        });
        log.debug("Room state set", "roomId", this.roomId, "state", state);
    }

    // server-specific parts of the model moved here
    internal function damageGhost (damage :int) :Boolean
    {
        if (_ctrl == null) {
            log.warning("Null room control", "action", "ghost damage");
            return false;
        }

        var health :int = _ghost.health;
//        log.debug("Damaging ghost", "roomId", this.roomId, "damage", damage, "health", health);
        if (damage >= health) {
            _ghost.setHealth(0);
            return true;
        }
        _ghost.setHealth(health - damage);
        return false;
    }

    internal function isEverybodyDead () :Boolean
    {
        return checkTeam(true);
    }

    internal function isEverybodyAlive () :Boolean
    {
        return checkTeam(false);
    }

    internal function checkTeam (dead :Boolean) :Boolean
    {
        var team :Array = getTeam();
        for (var ii :int = 0; ii < team.length; ii ++) {
            if (team[ii].isDead != dead) {
                return false;
            }
        }
        return true;
    }

    protected function _tick (frame :int, newSecond :Boolean) :void
    {
        switch(_state) {
        case Codes.STATE_SEEKING:
            seekTick(frame, newSecond);
            break;

        case Codes.STATE_APPEARING:
            if (_transitionFrame == 0) {
                log.warning("In APPEAR without transitionFrame", "id", this.roomId);
            }
            // let's add a 1-second grace period on the transition
            if (frame >= _transitionFrame + Server.FRAMES_PER_SECOND) {
                ghostFullyAppeared();
                _transitionFrame = 0;
            }
            break;

        case Codes.STATE_FIGHTING:
            fightTick(frame, newSecond);
            break;

        case Codes.STATE_GHOST_TRIUMPH:
        case Codes.STATE_GHOST_DEFEAT:
            if (_transitionFrame == 0) {
                log.warning("In TRIUMPH/DEFEAT without transitionFrame", "id", this.roomId);
            }
            // let's add a 1-second grace period on the transition
            if (frame >= _transitionFrame + Server.FRAMES_PER_SECOND) {
                ghostFullyGone();
                _transitionFrame = 0;
            }
            break;
        }
    }

    protected function seekTick (frame :int, newSecond :Boolean) :void
    {
        var now :int = getTimer();

        if (_lanternsDirty && (now - _lanternUpdate) > 200) {
            sendLanterns();
        }

        if (_ghost == null) {
            maybeSpawnGhost();
            return;
        }

        // if the ghost has been entirely unveiled, switch to appear phase
        if (_ghost.zest == 0) {
            setState(Codes.STATE_APPEARING);
            _transitionFrame = frame + _ghost.definition.appearFrames;
            return;
        }

        if (!newSecond) {
            return;
        }

        // tell the ghost to go to a completely random logical position in ([0, 1], [0, 1])
        var x :Number = Server.random.nextNumber();
        var y :Number = Server.random.nextNumber();
        _ghost.setPosition(x, y);

        // do a ghost tick
        _ghost.tick(frame / Server.FRAMES_PER_SECOND);
    }

    protected function fightTick (frame :int, newSecond :Boolean) :void
    {
        if (_ghost == null) {
            log.debug("fightTick() with null _ghost");
            // this should never happen, but let's be robust
            return;
        }

        // if the ghost died, leave fight state and show the ghost's death throes
        if (_ghost.isDead()) {
            try {
                Trophies.handleGhostDefeat(this);
            } catch (e :Error) {
                log.warning("Error in handleGhostDefeat", "roomId", this.roomId, e);
            }

            log.info("Ghost defeated", "ghostLevel", ghost.level, "players",
                     StringUtil.toString(getTeam()));

            setState(Codes.STATE_GHOST_DEFEAT);
            // schedule a transition
            _transitionFrame = frame + _ghost.definition.defeatFrames;
            return;
        }

        // if the players all died, leave fight state and play the ghost's triumph scene
        if (isEverybodyDead()) {
            setState(Codes.STATE_GHOST_TRIUMPH);
            // schedule a transition
            _transitionFrame = frame + _ghost.definition.triumphFrames;
            return;
        }

        if (!newSecond) {
            return;
        }

        // if ghost is alive and at least one player is still up, do a ghost tick
        _ghost.tick(frame);
    }

    protected function ghostFullyAppeared () :void
    {
        if (checkState(Codes.STATE_APPEARING)) {
            setState(Codes.STATE_FIGHTING);

            // when we start fighting, delete the lantern data
            _lanterns.clear();
            _lanternsDirty = true;
        }
    }

    protected function ghostFullyGone () :void
    {
        if (_ghost == null) {
            log.warning("Null _ghost in ghostFullyGone()");
            return;
        }
        if (checkState(Codes.STATE_GHOST_TRIUMPH, Codes.STATE_GHOST_DEFEAT)) {
            if (_state == Codes.STATE_GHOST_TRIUMPH) {
                // heal ghost
                _ghost.heal();

            } else {
                // delete ghost
                payout();
                healTeam();
                terminateGhost(false);
            }

            // whether the ghost died or the players wiped, clear accumulated fight stats
            _stats.clear();
            _minigames.clear();

            // and go back to seek state
            setState(Codes.STATE_SEEKING);
        }
    }

    protected function doHealPlayers (healer :Player, totHeal :int) :void
    {
        var team :Array = getTeam(true);

        // figure out how hurt each party member is, and the total hurt
        var playerDmg :Array = new Array(team.length);
        var totDmg :int = 0;
        for (var ii :int = 0; ii < team.length; ii ++) {
            playerDmg[ii] = team[ii].maxHealth - team[ii].health;
            totDmg += playerDmg[ii];
        }

//        log.debug("HEAL", "totalHeal", totHeal, "totalTeamDamage", totDmg);
        // hand totHeal out proportionally to each player's relative hurtness
        for (ii = 0; ii < team.length; ii ++) {
            var player :Player = Player(team[ii]);
            var amount :int = (totHeal * playerDmg[ii]) / totDmg;
            player.heal(amount);
            try {
                Trophies.handleHeal(healer, player, amount);
            } catch (e :Error) {
                log.warning("Error in handleHeal", "roomId", this.roomId, "targetId",
                            player.playerId, "healerId", healer.playerId, e);
            }
        }
    }

    // The current payout factor for a player is linearly proportional to how many minigame
    // points that player scored relative to the points scored by the whole team. A solo kill
    // against a ghost the player's own level yields a factor of 0.5. Killing a higher level
    // ghost yields a progressive bonus up to 100% and a lower level ghost shrinks the reward
    // commensurately. Finally the payout is boosted slightly depending on the size of the team,
    // a tweak we do not motivate here but which is a common component in existing MMO's.
    //
    // The rationale behind the level tweak is not that strong players should get more coins,
    // but rather to compensate for the fact that a strong player can kill weak ghosts at a
    // more rapid rate and payouts are per-kill compensation.
    //
    //   payoutFactor(player) = 0.5 *
    //      levelAdjustment(level(ghost) - level(player)) *
    //      (minigamePoints(player) / minigamePoints(team))
    //
    // The precise definition of levelAdjustment() is up in the air, but I figure something
    // along the lines of http://tinyurl.com/69xvu5 which is close to linear and centered
    // around 1 (for killing a ghost your own level).
    protected function payout () :void
    {
        var playerArr :Array = new Array();
        var pointsArr :Array = new Array();
        var totPoints :int = 0;

        _stats.forEach(function (player :Player, points :int) :void {
            if (player.room != null && player.room.roomId == this.roomId) {
                playerArr.unshift(player);
                pointsArr.unshift(points);
                totPoints += points;
//            log.debug("Player accrual", "playerId", playerId, "points", points);
            }
        });

        if (totPoints == 0) {
            return;
        }

        // compute the parts of the payout factor that are not player dependent
        var baseFactor :Number = 0.5 * Math.sqrt((playerArr.length+1) / 2) / totPoints;

        for (var ii :int = 0; ii < playerArr.length; ii ++) {
            var player :Player = playerArr[ii];

            // clamp the level difference to [-3, -3]
            var levelDiff :int = Math.max(-6, Math.min(6, _ghost.level - player.level));
            // semi-linearly map this to a factor in [0.35, 1.65]
            var levelFactor :Number = 1 + Math.atan(levelDiff / 4);

            // now figure the payout
            var payout :Number = baseFactor * levelFactor * pointsArr[ii];

            // it takes a L7 player, 7*5 = 35 L7 ghosts to gain L8
            var ghostsToLevel :int = player.level * 5;
            // and there's 100 ectopoints to each level; note this means you get 1 ectopoint
            // per kill even if you're level 9 and the ghost is level 1
            var ectoPoints :int = Math.round((levelFactor * 100) / ghostsToLevel);

            player.ghostDefeated(ectoPoints, payout);
        }
    }

    protected function healTeam () :void
    {
        for each (var player :Player in getTeam(true)) {
            player.heal(player.maxHealth);
        }
    }

    protected function sendLanterns () :void
    {
        _lanterns.forEach(function (playerId :int, pos :Array) :void {
            _ctrl.props.setIn(Codes.DICT_LANTERNS, playerId, pos);
        });
        _lanterns.clear();
        _lanternsDirty = false;
        _lanternUpdate = getTimer();
    }

    protected function maybeSpawnGhost () :void
    {
        var data :Dictionary = Dictionary(_ctrl.props.get(Codes.DICT_GHOST));
        if (data == null || data[Codes.IX_GHOST_ID] == null) {
            // no ghost known in room properties: did we recently kill one?
            if (getTimer() < _nextGhost) {
                // if so, just wait
                return;
            }

            // otherwise we need to spawn a new one!
            var roomRandom :Random = new Random(this.roomId);

            // the ghost id/model is currently completely random; this will change
            var ghosts :Array = GhostDefinition.getGhostIds();
            var ix :int = Server.random.nextInt(ghosts.length);

            // the ghost's level base is (currently) completely determined by the room
            var rnd :Number = roomRandom.nextNumber();

            var levelBase :int;
            if (Trophies.isInLibrary(this.roomId)) {
                // the ghosts in the library are level 1-5
                levelBase = int(1 + 4*rnd*rnd);

            } else {
                // the whirled ghosts spawn in a range of levels 1 to 40
                levelBase = int(1 + 39*rnd*rnd);
            }

            // the actual level is the base plus a random stretch of 0 or 1
            var level :int = levelBase + Server.random.nextInt(2);

            data = Ghost.resetGhost(ghosts[ix], level);
            _ctrl.props.set(Codes.DICT_GHOST, data, true);
        } // else the game just booted up, and the room has a ghost in its properties

        _ghost = new Ghost(this, data);
        _nextGhost = 0;
    }

    protected function terminateGhost (immediateRespawn :Boolean) :void
    {
        _ctrl.props.set(Codes.DICT_GHOST, null, true);
        _ghost = null;
        if (immediateRespawn) {
            _nextGhost = 0;
        } else {
            _nextGhost = getTimer() + 1000 * 60 * GHOST_RESPAWN_MINUTES;
        }
    }

    protected function maybeLoadControl () :void
    {
        if (_ctrl == null) {
            _ctrl = Server.control.getRoom(_roomId);

            log.debug("Export my state to new control", "state", _state);

            // export the room state to room properties
            _ctrl.props.set(Codes.PROP_STATE, _state, true);

            // if there's a ghost in here, re-export it too
            if (_ghost != null) {
                _ghost.reExport();
            }

            var handleUnload :Function;
            handleUnload = function (evt :Event) :void {
                _ctrl.removeEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
                _ctrl = null;

                if (_players.size() != 0) {
                    log.warning("Eek! Room unloading with players still here!",
                                "players", _players.toArray());
                } else {
                    log.debug("Unloaded room", "roomId", roomId);
                }
            };

            _ctrl.addEventListener(AVRGameRoomEvent.ROOM_UNLOADED, handleUnload);
        }
    }

    protected var _roomId :int;
    protected var _ctrl :RoomSubControlServer;

    protected var _state :String;
    protected var _players :HashSet = new HashSet();

    protected var _lanterns :HashMap = new HashMap();
    protected var _lanternsDirty :Boolean;
    protected var _lanternUpdate :int;

    protected var _ghost :Ghost;
    protected var _nextGhost :int;

    protected var _nextZap :int = 0;
    protected var _transitionFrame :int = 0;

    protected var _errorCount :int = 0;

    // each player's contribution to a ghost's eventual defeat is accumulated here, by player
    protected var _stats :HashMap = new HashMap();

    // a dictionary of dictionaries of number of times each minigame was used by each player
    protected var _minigames :HashMap = new HashMap();

    // new ghost every 10 minutes -- force players to actually hunt for ghosts, not slaughter them
    protected static const GHOST_RESPAWN_MINUTES :int = 10;
}
}
