//
// $Id$

package ghostbusters.client {

import com.threerings.util.Controller;
import com.threerings.util.Log;

import flash.events.TimerEvent;
import flash.utils.Timer;

import ghostbusters.client.fight.FightPanel;
import ghostbusters.client.fight.MicrogameResult;
import ghostbusters.client.util.PlayerModel;
import ghostbusters.data.Codes;

public class GameController extends Controller
{
    public static const BEGIN_PLAYING :String = "BeginPlaying";
    public static const CHOOSE_AVATAR :String = "ChooseAvatar";
    public static const CHOOSE_WEAPON :String = "ChooseWeapon";
    public static const CLOSE_SPLASH :String = "CloseSplash";
    public static const END_GAME :String = "EndGame";
    public static const GHOST_ATTACKED :String = "GhostAttacked";
    public static const GIMME_DEBUG_PANEL :String = "GimmeDebugPanel";
    public static const HELP :String = "Help";
    public static const PLAYER_ATTACKED :String = "PlayerAttacked";
    public static const REVIVE :String = "Revive";
    public static const TOGGLE_LANTERN :String = "ToggleLantern";
    public static const ZAP_GHOST :String = "ZapGhost";

    public var panel :GamePanel;

    public function GameController ()
    {
        panel = new GamePanel();
        setControlledPanel(panel);
//        panel.seeking = false;
    }

    public function handleEndGame () :void
    {
// TODO: what is the best way to reset the state of a departing AVRG player?
//        setAvatarState(GamePanel.ST_PLAYER_DEFAULT);
        Game.control.player.deactivateGame();
        if( _reviveTimer != null) {
            _reviveTimer.stop();
            _reviveTimer = null;
        }
    }

    public function handleHelp () :void
    {
        log.debug("handleHelp");
        //SKIN
        panel.showSplash(SplashWidget.STATE_HOWTO);
//        panel.showSplash(SplashWidget.STATE_BEGIN);
    }

    public function handleCloseSplash () :void
    {
        log.debug("handleCloseSplash");
        panel.hideSplash();
    }

    public function handleGimmeDebugPanel () :void
    {
        // leave it entirely to the agent to decide if clicking here does anything
        Game.control.agent.sendMessage(Codes.CMSG_DEBUG_REQUEST, Codes.DBG_GIMME_PANEL);
    }

    public function handleToggleLantern () :void
    {
        if (PlayerModel.isDead(Game.ourPlayerId)) {
            // the button is always disabled if you're dead -- revive first!
            log.debug("You can't toggle the lantern, you're dead!");
            return;
        }

        var state :String = Game.state;
        if (state == Codes.STATE_SEEKING) {
            panel.seeking = !panel.seeking;
//            panel.seeking = true;//SKIN we are never seeking

        } else if (state == Codes.STATE_APPEARING) {
            // no effect: you have to watch this bit

        } else if (state == Codes.STATE_FIGHTING) {
            var subPanel :FightPanel = FightPanel(Game.panel.subPanel);
            if (subPanel != null) {
                subPanel.toggleGame();
            }

        } else if (state == Codes.STATE_GHOST_TRIUMPH ||
                   state == Codes.STATE_GHOST_DEFEAT) {
            // no effect: you have to watch this bit

       } else {
            log.debug("Unexpected state in toggleLantern", "state", state);
        }
    }

    public function handleBeginPlaying () :void
    {
        Game.control.agent.sendMessage(Codes.CMSG_BEGIN_PLAYING);       
        if( panel.ghost != null) {//SKIN 
            panel.ghost.visible = true;
        }
    }

    public function handleChooseAvatar (avatar :String) :void
    {
        Game.control.agent.sendMessage(Codes.CMSG_CHOOSE_AVATAR, avatar);
    }

    public function handleChooseWeapon (weapon :int) :void
    {
        // always update the HUD's lantern button
        // TODO: this probably no longer makes much UI sense
        panel.hud.chooseWeapon(weapon);

        if (!(panel.subPanel is FightPanel)) {
            // should not happen, but let's be robust
            log.debug("Eek, subpanel is not FightPanel");
            return;
        }
        FightPanel(panel.subPanel).weaponUpdated();
    }

    public function handleGhostAttacked (weapon :int, result :MicrogameResult) :void
    {
        Game.control.agent.sendMessage(
            Codes.CMSG_MINIGAME_RESULT, [
                weapon,
                result.success == MicrogameResult.SUCCESS,
                result.damageOutput,
                result.healthOutput
            ]);

        if (result.success == MicrogameResult.SUCCESS) {
            Game.control.player.playAvatarAction("Retaliate");
        }
    }

    public function handleZapGhost () :void
    {
        Game.control.agent.sendMessage(Codes.CMSG_GHOST_ZAP, Game.ourPlayerId);
    }

    public function handleRevive () :void
    {
        trace(Game.ourPlayerId + " handleRevive()");
        if (PlayerModel.isDead(Game.ourPlayerId) ) {//&& Game.state != Codes.STATE_FIGHTING) {//SKIN shouldn't we be in STATE_FIGHTING??
            if( _reviveTimer == null) {
                _reviveTimer = new Timer( 10000, 1);
                _reviveTimer.addEventListener( TimerEvent.TIMER, function ( e :TimerEvent ) :void {
                    Game.control.agent.sendMessage(Codes.CMSG_PLAYER_REVIVE);
                    trace(Game.ourPlayerId + " sent revive message to server");
                    _reviveTimer.stop();
                    _reviveTimer = null;
                    });
                _reviveTimer.start();
            }
        }
        else {
            trace("no revive message sent to server");
        }
        panel.removeReviveSplash();
    }
    
    protected var _reviveTimer :Timer;

    protected static const log :Log = Log.getLog(GameController);
}
}
