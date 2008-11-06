//
// $Id$

package ghostbusters.server {

import flash.utils.Dictionary;
import flash.utils.getTimer;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.avrg.RoomSubControlServer;

import ghostbusters.data.Codes;
import ghostbusters.data.GhostDefinition;
import ghostbusters.server.util.Formulae;

public class Room
{
    public static var log :Log = Log.getLog(Room);

    public function Room (ctrl :RoomSubControlServer)
    {
        _ctrl = ctrl;

        // no matter how the room shut down, we cold-start it in seek mode
        setState(Codes.STATE_SEEKING);

        // see if there's an undefeated (persistent) ghost here, else make a new one
        loadOrSpawnGhost();
    }

    public function get roomId () :int
    {
        return _ctrl.getRoomId();
    }

    public function get ctrl () :RoomSubControlServer
    {
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
        return _errorCount > 20;
    }

    public function getMinigameStats (playerId :int) :Dictionary
    {
        return _minigames[playerId];
    }

    public function getTeam (excludeDead :Boolean = false) :Array
    {
        var team :Array = new Array();

        for (var p :* in _players) {
            var player :Player = Player(p);

            /* TODO: BEGIN SANITY CHECK */
            var subctrl :PlayerSubControlServer = Server.control.getPlayer(player.playerId);
            if (subctrl == null || subctrl.getRoomId() != roomId) {
                if (subctrl == null) {
                    log.warning("Removing unknown player in getTeam()", "teamRoomId", roomId,
                                "playerId", player.playerId);
                } else {
                    log.warning("Removing misfiled player in getTeam()", "teamRoomId", roomId,
                                "playerId", player.playerId, "playerRoomId", subctrl.getRoomId);
                }
                delete _players[player];
                continue;
            }
            /* TODO: END SANITY CHECK */

            if (!player.playing) {
                continue;
            }
            if (excludeDead && player.isDead()) {
                continue;
            }
            team.unshift(player);
        }
        return team;
    }

    public function playerEntered (player :Player) :void
    {
        log.debug("Copying player dictionary into room", "payerId", player.playerId,
                  "roomId", roomId, "health", player.health, "maxHealth", player.maxHealth,
                  "level", player.level);

        // broadcast the arriving player's data using room properties
        var dict :Dictionary = new Dictionary();
        dict[Codes.IX_PLAYER_CUR_HEALTH] = player.health;
        dict[Codes.IX_PLAYER_MAX_HEALTH] = player.maxHealth;
        dict[Codes.IX_PLAYER_LEVEL] = player.level;

        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, dict, true);

        _players[player] = true;
    }

    public function playerLeft (player :Player) :void
    {
        // erase the departing player's data from the room properties
        log.debug("Erasing player dictionary from room", "playerId", player.playerId,
                  "roomId", roomId);
        _ctrl.props.set(Codes.DICT_PFX_PLAYER + player.playerId, null, true);

        delete _players[player];
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
            var timer :int = getTimer();
            if (timer < _nextZap) {
                log.debug("Ignored too-early zap request", "playerId", who.playerId);
                return;
            }
            // accept up to two zaps a second
            _nextZap = timer + 500;
            log.debug("Accepting zap request", "playerId", who.playerId);
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
        // if we're shut down due to excessive errors, do nothing
        if (isShutdown) {
            return;
        }

        // if there are no players in this room, we cannot assume it's loaded, so do nothing
//        if (_ctrl.getPlayerIds().length == 0) {
//            return;
//        }

    	try {
    	    // if there are no players in this room, we cannot assume it's loaded, so do nothing
            if (_ctrl.getPlayerIds().length == 0) {
                return;
            }
        
            _tick(frame, newSecond);

        } catch (e :Error) {
            log.error("Tick error", e);

            _errorCount ++;
            if (isShutdown) {
                log.info("Giving up on room tick() due to error overflow", "roomId", roomId);
                return;
            }
        }
	
//        switch(_state) {
//        case Codes.STATE_SEEKING:
//            if( !isEverybodyDead()) {
//                seekTick(frame, newSecond);
//            }
//            break;
//
//        case Codes.STATE_APPEARING:
//            // let's add a 2-second grace period on the transition
//            if (frame >= _transitionFrame + Server.FRAMES_PER_SECOND * 2) {
//                if (_transitionFrame == 0) {
//                    log.warning("In APPEAR without transitionFrame", "id", roomId);
//                }
//                ghostFullyAppeared();
//                _transitionFrame = 0;
//            }
//            break;
//
//        case Codes.STATE_FIGHTING:
//            fightTick(frame, newSecond);
//            break;
//
//        case Codes.STATE_GHOST_TRIUMPH:
//        case Codes.STATE_GHOST_DEFEAT:
//            // let's add a 2-second grace period on the transition
//            if (frame >= _transitionFrame + Server.FRAMES_PER_SECOND * 2) {
//                if (_transitionFrame == 0) {
//                    log.warning("In TRIUMPH/DEFEAT without transitionFrame", "id", roomId);
//                }
//                ghostFullyGone();
//                _transitionFrame = 0;
//            }
//            break;
//        }

    }

    // called from Player when a MSG_MINIGAME_RESULT comes in from a client
    public function minigameCompletion (
        player :Player, weapon :int, win :Boolean, damageDone :int, healingDone :int) :void
    {
        log.debug("Minigame completion", "playerId", player.playerId, "weapon", weapon, "damage",
                  damageDone, "healing", healingDone);

        // award 3 points for a win, 1 for a lose
        _stats[player.playerId] = int(_stats[player.playerId]) + (win ? 3 : 1);

        // record which minigame was used
        var dict :Dictionary = _minigames[player.playerId];
        if (dict == null) {
            dict = new Dictionary();
        }
        dict[weapon] = int(dict[weapon]) + 1;
        _minigames[player.playerId] = dict;

        try {
            Trophies.handleMinigameCompletion(player, weapon, win);
        } catch (e :Error) {
            log.warning("Error in handleMinigameCompletion", "roomId", roomId, "playerId",
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
        _lanterns[playerId] = pos;
        _lanternsDirty = true;
    }

    internal function playerUpdated (player :Player) :void
    {
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
        healTeam();
        terminateGhost(false);
        _stats = new Dictionary();
        _minigames = new Dictionary();
        setState(Codes.STATE_SEEKING);
    }

    internal function setState (state :String) :void
    {
        log.debug("setState( " + state + ")");
        _state = state;

        _ctrl.props.set(Codes.PROP_STATE, state, true);

        for (var p :* in _players) {
            Player(p).roomStateChanged();
        }
        log.debug("Room state set", "roomId", roomId, "state", state);
    }

    // server-specific parts of the model moved here
    internal function damageGhost (damage :int) :Boolean
    {
        var health :int = _ghost.health;
        log.debug("Damaging ghost", "roomId", roomId, "damage", damage, "health", health);
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
        for (var p :* in _players) {
            if (dead != Player(p).isDead()) {
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
                log.warning("In APPEAR without transitionFrame", "id", roomId);
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
                log.warning("In TRIUMPH/DEFEAT without transitionFrame", "id", roomId);
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
        //SKIN moved up.  zest is always zero.
        // if the ghost has been entirely unveiled, switch to appear phase
        if (_ghost == null) {
            if (now > _nextGhost) {
                loadOrSpawnGhost();
            }
            return;
        }
        
        if (_ghost.zest == 0) {
            setState(Codes.STATE_APPEARING);
            _transitionFrame = frame + _ghost.definition.appearFrames;
            return;
        }
        return;
        
        var now :int = getTimer();

        if (_lanternsDirty && (now - _lanternUpdate) > 200) {
            sendLanterns();
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
        //_ghost.tick(frame / Server.FRAMES_PER_SECOND);//SKIN
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
                log.warning("Error in handleGhostDefeat", "roomId", roomId, e);
            }
	    
            setState(Codes.STATE_GHOST_DEFEAT);
            // schedule a transition
            _transitionFrame = frame + _ghost.definition.defeatFrames;
            return;
        }

        // if the players all died, leave fight state and play the ghost's triumph scene
        if (isEverybodyDead()) {
            setState(Codes.STATE_GHOST_TRIUMPH);
            // schedule a transition
            _transitionFrame = frame + _ghost.definition.triumphFrames;//SKIN we are not seeing the triumph scenes
            return;
        }

        if (!newSecond) {
            return;
        }

        // if ghost is alive and at least one player is still up, do a ghost tick
        //_ghost.tick(frame / Server.FRAMES_PER_SECOND);
	   _ghost.tick(frame);

    }

    protected function ghostFullyAppeared () :void
    {
        if (checkState(Codes.STATE_APPEARING)) {
            setState(Codes.STATE_FIGHTING);

            // when we start fighting, delete the lantern data
            _lanterns = new Dictionary();
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
                log.debug( "healing ghost");

            } else {
                // delete ghost
                payout();
                healTeam();
                terminateGhost(false);
            }

            // whether the ghost died or the players wiped, clear accumulated fight stats
            _stats = new Dictionary();
            _minigames = new Dictionary();

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

        log.debug("HEAL", "totalHeal", totHeal, "totalTeamDamage", totDmg);
        // hand totHeal out proportionally to each player's relative hurtness
        for (ii = 0; ii < team.length; ii ++) {
            var player :Player = Player(team[ii]);
            var amount :int = (totHeal * playerDmg[ii]) / totDmg;
            player.heal(amount);
            try {
                Trophies.handleHeal(healer, player, amount);
            } catch (e :Error) {
                log.warning("Error in handleHeal", "roomId", roomId, "targetId",
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

        for (var p :* in _stats) {
            var playerId :int = int(p);

            var player :Player = Server.getPlayer(playerId);
            if (player == null || player.room == null || player.room.roomId != this.roomId) {
                // for the time being, you only get credit if you're present when the ghost dies
                continue;
            }

            var points :int = int(_stats[playerId]);
            playerArr.unshift(player);
            pointsArr.unshift(points);
            totPoints += points;
            log.debug("Player accrual", "playerId", playerId, "points", points);
        }

        if (totPoints == 0) {
            return;
        }

        // compute the parts of the payout factor that are not player dependent
        var baseFactor :Number = 0.5 * Math.sqrt((playerArr.length+1) / 2) / totPoints;

        for (var ii :int = 0; ii < playerArr.length; ii ++) {
            player = playerArr[ii];

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
        trace("healing, team=" + getTeam(true));
        for each (var player :Player in getTeam(true)) {
            player.heal(player.maxHealth);
        }
    }

    protected function sendLanterns () :void
    {
        for (var p :* in _lanterns) {
            var playerId :int = int(p);
            _ctrl.props.setIn(Codes.DICT_LANTERNS, int(p), _lanterns[p]);
        }
        _lanterns = new Dictionary();
        _lanternsDirty = false;
        _lanternUpdate = getTimer();
    }

    protected function loadOrSpawnGhost () :void
    {
        var data :Dictionary = Dictionary(_ctrl.props.get(Codes.DICT_GHOST));
        if (data == null || data[Codes.IX_GHOST_ID] == null) {
            var roomRandom :Random = new Random(this.roomId);


            //SKIN TODO
            //The mutant mccain appears less often
            // the ghost id/model is currently completely random; this will change
            
            var ghosts :Array = [GhostDefinition.GHOST_MCCAIN, GhostDefinition.GHOST_PALIN, GhostDefinition.GHOST_MUTANT];
            
            var ix :int = Server.random.nextInt(ghosts.length);
//            if(isBossRoom()) {
//                ix = ghosts.length - 1;
//            }
            //the boss has a smaller p of appearing
//            if(Server.random.nextNumber() <= 0.16) {
//                ix = ghosts.length - 1;
//            }
            
            
            //If any player killed more than x ghosts, make the next a boss
//            log.debug("loadOrSpawnGhost(), checking if ghost should be boss");
//            log.debug("getTeam()=" + getTeam());
//            log.debug("_players=" + _players);
//            
//            for each (var player :Player in getTeam()) {
//                if(player != null) {
//                    log.debug("player " + player.playerId + " ghost kill vount=" + player.killedGhosts); 
//                    if( player.killedGhosts % 2 == 0 && player.killedGhosts >= 1){
//                        ix = ghosts.length - 1;
//                        break;
//                    }
//                }
//                else { log.debug("player is null")}
//            }
            // the ghost's level base is (currently) completely determined by the room
            var rnd :Number = roomRandom.nextNumber();

            // the base is in [1, 5] and low level ghosts are more common than high level ones
            var levelBase :int = int(1 + 9*rnd*rnd);
            
            //If it's a boss, make it tougher
//            if( ix == ghosts.length - 1) {
//                levelBase++;
//            }

            // the actual level is the base plus a random stretch of 0 or 1
            var level :int = levelBase + Server.random.nextInt(2);
            
            //If it's the starting room, make it an easy foe
            
            if( this.roomId == 60191) {
                level = 1;
            }
//            if( ghosts[ix] == GhostDefinition.GHOST_MUTANT

            data = Ghost.resetGhost(ghosts[ix], level);
            _ctrl.props.set(Codes.DICT_GHOST, data, true);
        }

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
        _nextGhost = getTimer() + 1000 * GHOST_RESPAWN_SECONDS;
	}
    }    

    protected var _ctrl :RoomSubControlServer;

    protected var _state :String;
    protected var _players :Dictionary = new Dictionary();

    protected var _lanterns :Dictionary = new Dictionary();
    protected var _lanternsDirty :Boolean;
    protected var _lanternUpdate :int;

    protected var _ghost :Ghost;
    protected var _nextGhost :int;

    protected var _nextZap :int = 0;
    protected var _transitionFrame :int = 0;
    
    protected var _errorCount :int = 0;

    // each player's contribution to a ghost's eventual defeat is accumulated here, by playerId
    protected var _stats :Dictionary = new Dictionary();

    // a dictionary of dictionaries of number of times each minigame was used by each player
    protected var _minigames :Dictionary = new Dictionary();

    // new ghost every 10 minutes -- force players to actually hunt for ghosts, not slaughter them
    public static const GHOST_RESPAWN_SECONDS :int = 30 * 1;
    
//    protected var _nextGhostIsBoss :Boolean = false;
}
}
