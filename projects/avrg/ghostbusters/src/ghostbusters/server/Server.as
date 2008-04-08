//
// $Id$

package ghostbusters.server {

import flash.geom.Rectangle;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.util.ArrayUtil;

import ghostbusters.Codes;
import ghostbusters.Game;
import ghostbusters.GameModel;
import ghostbusters.PerPlayerProperties;

public class Server
{
    public function Server (control :AVRGameControl)
    {
        _control = control;

        _control.addEventListener(
            AVRGameControlEvent.PLAYER_LEFT, handlePlayerLeft);
        _control.state.addEventListener(
            AVRGameControlEvent.MESSAGE_RECEIVED, handleMessage);

        _ppp = new PerPlayerProperties();
    }

    public function newRoom () :void
    {
        if (_control.hasControl() && Game.model.ghostId == null) {
            _ghost = Ghost.spawnNewGhost(Game.ourRoomId);

        } else {
            _ghost = Ghost.loadIfPresent();
        }
    }

    /** Called at the end of the Seek phase when the ghost's appear animation is done. */
    public function ghostFullyAppeared () :void
    {
        if (!_control.hasControl()) {
            return;
        }
        if (checkState(GameModel.STATE_APPEARING)) {
            setState(GameModel.STATE_FIGHTING);
        }            
    }

    /** Called at the end of the Fight phase after the ghost's death or triumph animation. */
    public function ghostFullyGone () :void
    {
        if (!_control.hasControl()) {
            return;
        }

        if (_ghost == null) {
            Game.log.warning("Null _ghost in ghostFullyGone()");
            return;
        }
        if (checkState(GameModel.STATE_GHOST_TRIUMPH, GameModel.STATE_GHOST_DEFEAT)) {
            if (Game.model.state == GameModel.STATE_GHOST_TRIUMPH) {
                // heal ghost
                setGhostHealth(Game.model.ghostMaxHealth);
                setGhostZest(Game.model.ghostMaxZest);

            } else {
                // delete ghost
                payout();
                healTeam();
                _ghost.selfTerminate();
                _ghost = null;
            }

            // whether the ghost died or the players wiped, clear accumulated fight stats
            clearStats();

            // and go back to seek state
            setState(GameModel.STATE_SEEKING);
        }
    }

    public function doDamagePlayer (playerId :int, damage :int) :Boolean
    {
        if (!_control.hasControl()) {
            throw new Error("Internal server function.");
        }
        // perform the attack
        var died :Boolean = damagePlayer(playerId, damage);

        // let all clients know of the attack
        _control.state.sendMessage(Codes.MSG_PLAYER_ATTACKED, playerId);

        if (died) {
            // the blow killed the player: let all the clients know that too
            _control.state.sendMessage(Codes.MSG_PLAYER_DEATH, playerId);
        }
        return died;
    }

    protected function everySecondTick (tick :int) :void
    {
        if (Game.ourRoomId == 0) {
            // if we're not yet in a room, don't tick
            return;
        }

        if ((tick % 10) == 0) {
            cleanup();
        }

        if (Game.model.state == GameModel.STATE_SEEKING) {
            seekTick(tick);

        } else if (Game.model.state == GameModel.STATE_APPEARING) {
            // do nothing

        } else if (Game.model.state == GameModel.STATE_FIGHTING) {
            fightTick(tick);

        } else if (Game.model.state == GameModel.STATE_GHOST_TRIUMPH ||
                   Game.model.state == GameModel.STATE_GHOST_DEFEAT) {
            // do nothing
        }
    }

    // called every 10 seconds to do housekeeping stuff
    protected function cleanup () :void
    {
        // delete any per-player room properties associaed with players who have left
        _ppp.deleteRoomProperties(function (playerId :int, prop :String, value :Object) :Boolean {
            if (!_control.isPlayerHere(playerId)) {
                Game.log.debug("Cleaning: " + playerId + "/" + prop);
                return true;
            }
            Game.log.debug("NOT cleaning: " + playerId + "/" + prop);
            return false;
        });
    }

    protected function seekTick (tick :int) :void
    {
        if (_ghost == null) {
            // maybe a delay here?
            _ghost = Ghost.spawnNewGhost(Game.ourRoomId);
            return;
        }

        // if the ghost has been entirely unveiled, switch to appear phase
        if (Game.model.ghostZest == 0) {
            setState(GameModel.STATE_APPEARING);
            return;
        }

        // TODO: if the controlling instance toggles the lantern, this fails - FIX FIX FIX
        if (Game.panel.ghost == null) {
            return;
        }
        var ghostBounds :Rectangle = Game.panel.ghost.getGhostBounds();
        if (ghostBounds == null) {
            return;
        }

        var x :int = Game.random.nextNumber() *
            (Game.roomBounds.width - ghostBounds.width) - ghostBounds.left;
        var y :int = Game.random.nextNumber() *
            (Game.roomBounds.height - ghostBounds.height) - ghostBounds.top;

        _control.state.setRoomProperty(Codes.PROP_GHOST_POS, [ x, y ]);
    }

    protected function fightTick (tick :int) :void
    {
        if (_ghost == null) {
            // this should never happen, but let's be robust
            return;
        }

        // if the ghost died, leave fight state and show the ghost's death throes
        // TODO: if the animation-based state transition back to SEEK fails, we should
        // TODO: have a backup timeout using the ticker
        if (_ghost.isDead()) {
            setState(GameModel.STATE_GHOST_DEFEAT);
            return;
        }

        // if the players all died, leave fight state and play the ghost's triumph scene
        // TODO: if the animation-based state transition back to SEEK fails, we should
        // TODO: have a backup timeout using the ticker
        if (Game.model.isEverybodyDead()) {
            setState(GameModel.STATE_GHOST_TRIUMPH);
            return;
        }

        // if ghost is alive and at least one player is still up, just do an normal AI tick
        _ghost.tick(tick);
    }

    // if a player leaves, clear their room data
    protected function handlePlayerLeft (evt :AVRGameControlEvent) :void
    {
        if (!_control.hasControl()) {
            return;
        }
        var playerId :int = evt.value as int;
        if (_ppp.getRoomProperty(playerId, Codes.PROP_LANTERN_POS) != null) {
            _ppp.setRoomProperty(playerId, Codes.PROP_LANTERN_POS, null);
        }
    }

    protected function handleMessage (event: AVRGameControlEvent) :void
    {
        if (!_control.hasControl()) {
            return;
        }
        var msg :String = event.name;
        var bits :Array;

        if (msg == Codes.MSG_TICK) {
            everySecondTick(event.value as int);

        } else if (msg == Codes.MSG_GHOST_ZAP) {
            if (checkState(GameModel.STATE_SEEKING)) {
                setGhostZest(Game.model.ghostZest * 0.9 - 15);
            }

        } else if (msg == Codes.MSG_MINIGAME_RESULT) {
            if (checkState(GameModel.STATE_FIGHTING)) {
                bits = event.value as Array;
                if (bits != null) {
                    accumulateStats(bits[0] as int, bits[1] as Boolean);
                    if (bits[2] > 0) {
                        damageGhost(bits[2]);
                    }
                    if (bits[3] > 0) {
                        doHealPlayers(bits[3]);
                    }
                }
            }
        }
    }

    protected function doHealPlayers (totHeal :int) :void
    {
        var team :Array = Game.getTeam(true);

        // figure out how hurt each party member is, and the total hurt
        var playerDmg :Array = new Array(team.length);
        var totDmg :int = 0;
        for (var ii :int = 0; ii < team.length; ii ++) {
            playerDmg[ii] = (Game.model.getPlayerMaxHealth(team[ii]) -
                             Game.model.getPlayerHealth(team[ii]));
            totDmg += playerDmg[ii];
        }
        Game.log.debug("HEAL :: Total heal = " + totHeal + "; Total team damage = " + totDmg);
        // hand totHeal out proportionally to each player's relative hurtness
        for (ii = 0; ii < team.length; ii ++) {
            var heal :int = (totHeal * playerDmg[ii]) / totDmg;
            Game.log.debug("HEAL :: Awarding " + heal + " pts to player #" + team[ii]);
            healPlayer(team[ii], heal);
        }
    }

    protected function checkState (... expected) :Boolean
    {
        if (ArrayUtil.contains(expected, Game.model.state)) {
            return true;
        }
        Game.log.debug("State mismatch [expected=" + expected + ", actual=" +
                       Game.model.state + "]");
        return false;
    }

    protected function payout () :void
    {
        var stats :Object = _control.state.getRoomProperty(Codes.PROP_STATS) as Object;
        if (stats == null) {
            stats = { };
        }

        var team :Array = Game.getTeam();
        var points :Array = new Array(team.length);

        var totPoints :int = 0;
        for (var ii :int = 0; ii < team.length; ii ++) {
            points[ii] = int(stats[team[ii]]);
            totPoints += points[ii];
            Game.log.debug("Player #" + team[ii] + " accrued " + points[ii] + " points...");
        }

        if (totPoints == 0) {
            return;
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

        for (ii = 0; ii < team.length; ii ++) {
            var factor :Number = 0.5 * (points[ii]  / totPoints);
            if (factor > 0) {
                _control.state.sendMessage(Codes.MSG_PAYOUT_FACTOR, factor, team[ii]);
            }
        }
    }

    // server-specific parts of the model moved here
    protected function damageGhost (damage :int) :Boolean
    {
        var health :int = Game.model.ghostHealth;
        Game.log.debug("Doing " + damage + " damage to a ghost with health " + health);
        if (damage >= health) {
            setGhostHealth(0);
            return true;
        }
        setGhostHealth(health - damage);
        return false;
    }

    protected function damagePlayer (playerId :int, damage :int) :Boolean
    {
        var health :int = Game.model.getPlayerHealth(playerId);
        Game.log.debug("Doing " + damage + " damage to a player with health " + health);
        if (damage >= health) {
            killPlayer(playerId);
            return true;
        }
        setPlayerHealth(playerId, health - damage);
        return false;
    }

    protected function healTeam () :void
    {
        var team :Array = Game.getTeam(true);
        for (var ii :int = 0; ii < team.length; ii ++) {
            healPlayer(team[ii]);
        }
    }

    protected function healPlayer (playerId :int, amount :int = -1) :void
    {
        var maxHealth :int = Game.model.getPlayerMaxHealth(playerId);
        var newHealth :int;
        if (amount < 0) {
            newHealth = maxHealth;
        } else {
            newHealth = Math.min(maxHealth, amount + Game.model.getPlayerHealth(playerId));
        }
        setPlayerHealth(playerId, newHealth);
    }

    protected function killPlayer (playerId :int) :void
    {
        _ppp.setProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH, -1);
    }

    protected function setPlayerHealth (playerId :int, health :int) :void
    {
        _ppp.setProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH,
                        Math.max(0, Math.min(health, Game.model.getPlayerMaxHealth(playerId))));
    }

    protected function setGhostHealth (health :int) :void
    {
        _control.state.setRoomProperty(Codes.PROP_GHOST_CUR_HEALTH, Math.max(0, health));
    }

    protected function setGhostZest (zest :Number) :void
    {
        _control.state.setRoomProperty(Codes.PROP_GHOST_CUR_ZEST, Math.max(0, zest));
    }

    protected function setState (state :String) :void
    {
        _control.state.setRoomProperty(Codes.PROP_STATE, state);
    }

    protected function accumulateStats (playerId :int, win :Boolean) :void
    {
        var stats :Object = _control.state.getRoomProperty(Codes.PROP_STATS) as Object;
        if (stats == null) {
            stats = { };
        }

        // award 3 points for a win, 1 for a lose
        stats[playerId] = int(stats[playerId]) + (win ? 3 : 1);
        _control.state.setRoomProperty(Codes.PROP_STATS, stats);
    }

    protected function clearStats () :void
    {
        _control.state.setRoomProperty(Codes.PROP_STATS, null);
    }

    protected var _control :AVRGameControl;

    protected var _ppp :PerPlayerProperties;

    protected var _ghost :Ghost;
}
}
