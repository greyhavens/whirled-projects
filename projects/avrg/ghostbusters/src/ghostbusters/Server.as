//
// $Id$

package ghostbusters {

import flash.geom.Rectangle;

import com.whirled.AVRGameControlEvent;

import com.threerings.util.ArrayUtil;

public class Server
{
    public function Server ()
    {
        Game.control.addEventListener(
            AVRGameControlEvent.PLAYER_LEFT, handlePlayerLeft);
        Game.control.state.addEventListener(
            AVRGameControlEvent.MESSAGE_RECEIVED, handleMessage);

        _ppp = new PerPlayerProperties();
    }

    public function newRoom () :void
    {
        if (!Game.control.hasControl()) {
            Game.log.debug("I don't have control -- returning.");
            return;
        }
        maybeSpawnGhost();
    }

    /** Called at the end of the Seek phase when the ghost's appear animation is done. */
    public function ghostFullyAppeared () :void
    {
        if (!Game.control.hasControl()) {
            return;
        }
        if (checkState(GameModel.STATE_APPEARING)) {
            setState(GameModel.STATE_FIGHTING);
        }            
    }

    /** Called at the end of the Fight phase after the ghost's death or triumph animation. */
    public function ghostFullyGone () :void
    {
        if (!Game.control.hasControl()) {
            return;
        }

        if (checkState(GameModel.STATE_GHOST_TRIUMPH, GameModel.STATE_GHOST_DEFEAT)) {
            if (Game.model.state == GameModel.STATE_GHOST_TRIUMPH) {
                // heal ghost
                setGhostHealth(Game.model.ghostMaxHealth);
                setGhostZest(Game.model.ghostMaxZest);

            } else {
                // delete ghost
                setGhostId(null);

                // TODO: popup saying grats u win?
            }

            setState(GameModel.STATE_SEEKING);
        }
    }

    public function doDamagePlayer (playerId :int, damage :int) :Boolean
    {
        if (!Game.control.hasControl()) {
            throw new Error("Internal server function.");
        }
        // perform the attack
        var died :Boolean = damagePlayer(playerId, damage);

        // let all clients know of the attack
        Game.control.state.sendMessage(Codes.MSG_PLAYER_ATTACKED, playerId);

        if (died) {
            // the blow killed the player: let all the clients know that too
            Game.control.state.sendMessage(Codes.MSG_PLAYER_DEATH, playerId);
        }
        return died;
    }

    protected function everySecondTick (tick :int) :void
    {
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
            if (!Game.control.isPlayerHere(playerId)) {
                Game.log.debug("Cleaning: " + playerId + "/" + prop);
                return true;
            }
            Game.log.debug("NOT cleaning: " + playerId + "/" + prop);
            return false;
        });
    }

    protected function seekTick (tick :int) :void
    {
        if (!Game.model.ghostId) {
            // maybe a delay here?
            maybeSpawnGhost();
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

        Game.control.state.setRoomProperty(Codes.PROP_GHOST_POS, [ x, y ]);
    }

    protected function fightTick (tick :int) :void
    {
        if (!Game.model.ghostId) {
            // this should never happen, but let's be robust
            return;
        }

        // if the ghost died, leave fight state and show the ghost's death throes
        // TODO: if the animation-based state transition back to SEEK fails, we should
        // TODO: have a backup timeout using the ticker
        if (Game.model.isGhostDead()) {
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
        var brainTick :Function = Game.model.getGhostData().brain as Function;
        if (brainTick != null) {
            brainTick(tick);
        }
    }

    // if a player leaves, clear their room data
    protected function handlePlayerLeft (evt :AVRGameControlEvent) :void
    {
        if (!Game.control.hasControl()) {
            return;
        }
        var playerId :int = evt.value as int;
        if (_ppp.getRoomProperty(playerId, Codes.PROP_LANTERN_POS) != null) {
            _ppp.setRoomProperty(playerId, Codes.PROP_LANTERN_POS, null);
        }
    }

    protected function handleMessage (event: AVRGameControlEvent) :void
    {
        if (!Game.control.hasControl()) {
            return;
        }
        var msg :String = event.name;
        if (msg == Codes.MSG_TICK) {
            everySecondTick(event.value as int);

        } else if (msg == Codes.MSG_GHOST_ZAP) {
            if (checkState(GameModel.STATE_SEEKING)) {
                setGhostZest(Game.model.ghostZest * 0.9 - 15);
            }

        } else if (msg == Codes.MSG_GHOST_ATTACKED) {
            if (checkState(GameModel.STATE_FIGHTING)) {
                var dmg :int = (event.value as Array)[1];
                damageGhost(dmg);
            }

        } else if (msg == Codes.MSG_PLAYERS_HEALED) {
            if (checkState(GameModel.STATE_FIGHTING)) {
                var heal :int = (event.value as Array)[1];
                doHealPlayers(heal);
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
            var newHealth :int = heal + Game.model.getPlayerHealth(team[ii]);
            Game.log.debug("HEAL :: Awarding " + heal + " pts to player #" + team[ii]);
            setPlayerHealth(team[ii], newHealth);
        }
    }

    protected function maybeSpawnGhost () :void
    {
        if (Game.model.ghostId != null) {
            return;
        }

        // initialize the room with a ghost
        var id :String = Content.GHOSTS[Game.random.nextInt(Content.GHOSTS.length)].id;

        var zest :int = 150 + 100 * Game.random.nextNumber();
        setGhostZest(zest);
        setGhostMaxZest(zest);

        var health :int = 100;
        setGhostHealth(100);
        setGhostMaxHealth(100);

        // set the ghostId last of all, since that triggers loading
        setGhostId(id);
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

    protected function killPlayer (playerId :int) :void
    {
        _ppp.setProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH, -1);
    }

    protected function setPlayerHealth (playerId :int, health :int) :void
    {
        _ppp.setProperty(playerId, Codes.PROP_PLAYER_CUR_HEALTH,
                        Math.max(0, Math.min(health, Game.model.getPlayerMaxHealth(playerId))));
    }

    protected function setGhostId (id :String) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_ID, id);
    }

    protected function setGhostHealth (health :int) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_HEALTH, Math.max(0, health));
    }

    protected function setGhostMaxHealth (health :int) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_HEALTH, Math.max(0, health));
    }

    protected function setGhostZest (zest :Number) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_CUR_ZEST, Math.max(0, zest));
    }

    protected function setGhostMaxZest (zest :Number) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_MAX_ZEST, Math.max(0, zest));
    }

    protected function setState (state :String) :void
    {
        Game.control.state.setRoomProperty(Codes.PROP_STATE, state);
    }

    protected var _ppp :PerPlayerProperties;

}
}
