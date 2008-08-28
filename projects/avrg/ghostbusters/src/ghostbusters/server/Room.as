//
// $Id$

package ghostbusters.server {

import flash.geom.Rectangle;
import flash.utils.Dictionary;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.avrg.server.RoomServerSubControl;

import ghostbusters.Codes;
import ghostbusters.util.PlayerModel;

public class Room
{
    public static var log :Log = Log.getLog(Room);

    public function Room (ctrl :RoomServerSubControl)
    {
        _ctrl = ctrl;

        loadOrSpawnGhost();
    }

    public function get roomId () :int
    {
        return _ctrl.getRoomId();
    }

    public function get ctrl () :RoomServerSubControl
    {
        return _ctrl;
    }

    public function get ghost () :Ghost
    {
        return _ghost;
    }

    public function getTeam (excludeDead :Boolean = false) :Array
    {
        var team :Array = new Array();

        for (var p :* in _players) {
            var player :Player = Player(p);
            if (excludeDead && player.isDead()) {
                continue;
            }
            team.unshift(player);
        }
        return team;
    }

    public function playerEntered (player :Player) :void
    {
        _players[player] = true;
    }

    public function playerLeft (player :Player) :void
    {
        delete _players[player];
    }


    // TODO: wire up to a message from the client
    public function ghostFullyAppeared (roomId :int) :void
    {
        if (checkState(Codes.STATE_APPEARING)) {
            setState(Codes.STATE_FIGHTING);
        }            
    }

    // TODO: wire up to a message from the client
    public function ghostFullyGone (roomId :int) :void
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
                terminateGhost();
            }

            // whether the ghost died or the players wiped, clear accumulated fight stats
            _stats = new Dictionary();

            // and go back to seek state
            setState(Codes.STATE_SEEKING);
        }
    }

    public function checkState (... expected) :Boolean
    {
        if (ArrayUtil.contains(expected, _state)) {
            return true;
        }
        log.debug("State mismatch [expected=" + expected + ", actual=" + _state + "]");
        return false;
    }

    public function ghostZap () :void
    {
        if (_ghost != null && checkState(Codes.STATE_SEEKING)) {
            _ghost.zap();
        }
    }

    public function tick (timer :int) :void
    {
        switch(_state) {
        case Codes.STATE_SEEKING:
            seekTick(timer);
            break;

        case Codes.STATE_APPEARING:
            // do nothing
            break;

        case Codes.STATE_FIGHTING:
            fightTick(timer);
            break;

        case Codes.STATE_GHOST_TRIUMPH:
        case Codes.STATE_GHOST_DEFEAT:
            // do nothing
            break;
        }
    }

    // called from Player when a MSG_MINIGAME_RESULT comes in from a client
    public function minigameCompletion (
        player :Player, win :Boolean, damageDone :int, healingDone :int) :void
    {
        // award 3 points for a win, 1 for a lose
        _stats[player.playerId] = int(_stats[player.playerId]) + (win ? 3 : 1);

        if (damageDone > 0) {
            damageGhost(damageDone);
        }
        if (healingDone > 0) {
            doHealPlayers(healingDone);
        }
    }

    internal function updateLanternPos (playerId :int, pos :Array) :void
    {
        _ctrl.props.setIn(Codes.DICT_LANTERNS, playerId, pos);
    }

    internal function updatePlayerHealth (playerId :int, health :int) :void
    {
        _ctrl.props.setIn(Codes.DICT_PFX_PLAYER + playerId,
                          Codes.PROP_PLAYER_CUR_HEALTH, health);
    }

    protected function seekTick (timer :int) :void
    {
        if (_ghost == null) {
            // maybe a delay here?
            loadOrSpawnGhost();
            return;
        }

        // if the ghost has been entirely unveiled, switch to appear phase
        if (_ghost.zest == 0) {
            setState(Codes.STATE_APPEARING);
            return;
        }

        // TODO: we don't have access to the actual media dimensions --- what to use here?
        var ghostBounds :Rectangle = new Rectangle(0, 0, 0, 0);

        // TODO: we don't have access to the room's fucking bounds either! fuck!
        var roomBounds :Rectangle = new Rectangle(0, 0, 500, 500);

        var x :int = Server.random.nextNumber() *
            (roomBounds.width - ghostBounds.width) - ghostBounds.left;
        var y :int = Server.random.nextNumber() *
            (roomBounds.height - ghostBounds.height) - ghostBounds.top;

        _ghost.setPosition(x, y);
    }

    protected function fightTick (timer :int) :void
    {
        if (_ghost == null) {
            log.debug("fightTick() with null _ghost");
            // this should never happen, but let's be robust
            return;
        }

        // if the ghost died, leave fight state and show the ghost's death throes
        // TODO: if the animation-based state transition back to SEEK fails, we should
        // TODO: have a backup timeout using the ticker
        if (_ghost.isDead()) {
            setState(Codes.STATE_GHOST_DEFEAT);
            return;
        }

        // if the players all died, leave fight state and play the ghost's triumph scene
        // TODO: if the animation-based state transition back to SEEK fails, we should
        // TODO: have a backup timeout using the ticker
        if (isEverybodyDead()) {
            setState(Codes.STATE_GHOST_TRIUMPH);
            return;
        }

        // if ghost is alive and at least one player is still up, just do an normal AI tick
        _ghost.tick(timer);
    }

    protected function doHealPlayers (totHeal :int) :void
    {
        var team :Array = getTeam(true);

        // figure out how hurt each party member is, and the total hurt
        var playerDmg :Array = new Array(team.length);
        var totDmg :int = 0;
        for (var ii :int = 0; ii < team.length; ii ++) {
            playerDmg[ii] = team[ii].maxHealth - team[ii].health;
            totDmg += playerDmg[ii];
        }

        log.debug("HEAL :: Total heal = " + totHeal + "; Total team damage = " + totDmg);
        // hand totHeal out proportionally to each player's relative hurtness
        for (ii = 0; ii < team.length; ii ++) {
            var player :Player = team[ii] as Player;
            var heal :int = (totHeal * playerDmg[ii]) / totDmg;
            log.debug("HEAL :: Awarding " + heal + " pts to player #" + player.playerId);
            player.heal(heal);
        }
    }
    
    // The current payout factor for a player is linearly proportional to how many minigame
    // points that player scored relative to the points scored by the whole team. A solo kill
    // against a ghost the player's own level yields a factor of 0.5. Killing a higher level
    // ghost yields a progressive bonus up to 100% and a lower level ghost shrinks the reward
    // commensurately. Finally, the payout is reduced by the square root of the size of the
    // team.
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
    // along the lines of 1+atan(x/2) (http://www.mathsisfun.com/graph/function-grapher.php)
    protected function payout () :void
    {
        if (_stats == null) {
            return;
        }

        var playerArr :Array = new Array();
        var pointsArr :Array = new Array();
        var totPoints :int = 0;

        for (var p :* in _stats) {
            var playerId :int = int(p);

            var player :Player = Server.getPlayer(playerId);
            if (player == null) {
                // they stopped playing, too bad
                continue;
            }

            var points :int = int(_stats[playerId]);
            playerArr.unshift(player);
            pointsArr.unshift(points);
            totPoints += points;
            log.debug("Player #" + playerId + " accrued " + points + " points...");
        }

        if (totPoints == 0) {
            return;
        }

        for (var ii :int = 0; ii < playerArr.length; ii ++) {
            var factor :Number = 0.5 * (pointsArr[ii]  / totPoints);
            if (factor > 0) {
                playerArr[ii].ctrl.completeTask("ghost_defeated", factor);
            }
        }
    }

    protected function healTeam () :void
    {
        for each (var player :Player in getTeam(true)) {
            player.heal(player.maxHealth);
        }
    }

    protected function loadOrSpawnGhost () :void
    {
        var data :Dictionary = Dictionary(_ctrl.props.get(Codes.DICT_GHOST));
        if (data == null) {
            var roomRandom :Random = new Random(this.roomId);

            // the ghost id/model is currently completely random; this will change
            var ghosts :Array = [ "pinchy", "duchess", "widow", "demon" ];
            var names :Array = [ "Mr. Pinchy", "The Duchess", "The Widow", "Soul Crusher" ];
            var ix :int = Server.random.nextInt(ghosts.length);

            // the ghost's level base is (currently) completely determined by the room
            var rnd :Number = roomRandom.nextNumber();

            // the base is in [1, 10] and low level ghosts are more common than high level ones
            var levelBase :int = int(1 + 10*rnd*rnd);

            // the actual level is the base plus a genuinely random tweak of 0, 1 or 2
            var level :int = levelBase + Server.random.nextInt(3);

            data = Ghost.resetGhost(ghosts[ix], names[ix], level);
            _ctrl.props.set(Codes.DICT_GHOST, data);
        }

        _ghost = new Ghost(this, data);
    }

    protected function terminateGhost () :void
    {
        _ctrl.props.set(Codes.DICT_GHOST, null);
        _ghost = null;
    }

    protected function setState (state :String) :void
    {
        _state = state;

        _ctrl.props.set(Codes.PROP_STATE, state);
    }

    // server-specific parts of the model moved here
    protected function damageGhost (damage :int) :Boolean
    {
        var health :int = _ghost.health;
        log.debug("Doing " + damage + " damage to a ghost with health " + health);
        if (damage >= health) {
            _ghost.setHealth(0);
            return true;
        }
        _ghost.setHealth(health - damage);
        return false;
    }

    protected function isEverybodyDead () :Boolean
    {
        return checkTeam(true);
    }

    protected function isEverybodyAlive () :Boolean
    {
        return checkTeam(false);
    }

    protected function checkTeam (dead :Boolean) :Boolean
    {
        for (var p :* in _players) {
            if (dead != Player(p).isDead()) {
                return false;
            }
        }
        return true;
    }

    protected var _ctrl :RoomServerSubControl;

    protected var _state :String;
    protected var _players :Dictionary;

    protected var _ghost :Ghost;

    // each player's contribution to a ghost's eventual defeat is accumulated here, by playerId
    protected var _stats :Dictionary = new Dictionary();
}
}
