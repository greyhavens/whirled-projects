//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.text.TextField;
import flash.geom.Point;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;
import flash.utils.setTimeout;

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.MathUtil;
import com.threerings.util.CommandEvent;

import ghostbusters.ClipHandler;
import ghostbusters.GameController;

import com.whirled.AVRGameAvatar;
import com.whirled.AVRGameControlEvent;

public class HUD extends Sprite
{
    public static const LOOT_LANTERN :int = 0;
    public static const LOOT_BLASTER :int = 1;
    public static const LOOT_OUIJA :int = 2;
    public static const LOOT_POTIONS :int = 3;

    public function HUD ()
    {
        _hud = new ClipHandler(ByteArray(new Content.HUD_VISUAL()), handleHUDLoaded);

        Game.control.addEventListener(AVRGameControlEvent.PLAYER_ENTERED,
                                      function (... ignored) :void { teamUpdated(); });
        Game.control.addEventListener(AVRGameControlEvent.PLAYER_LEFT,
                                      function (... ignored) :void { teamUpdated(); });

        Game.control.state.addEventListener(
            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);

        _ppp = new PerPlayerProperties(playerPropertyChanged);
    }

    public function shutdown () :void
    {
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _hud != null && _hud.hitTestPoint(x, y, shapeFlag);
    }

    public function reloadView () :void
    {
        if (_hud.parent != null) {
            placeHud();
            teamUpdated();
        }
    }

    public function getRightEdge () :int
    {
        if (Game.scrollSize == null) {
            Game.log.debug("getRightEdge: scrollSize == null");
        } else if (Game.stageSize == null) {
            Game.log.debug("getRightEdge: stageSize == null");
        } else if (_visualHud == null) {
            Game.log.debug("getRightEdge: visualHud == null");
        } else {
            // put the HUD to the right of the visible screen, or flush with the stage edge
            return Math.max(0, Math.min(Game.scrollSize.width - MARGIN_LEFT - BORDER_LEFT,
                                        Game.stageSize.right - _visualHud.width - MARGIN_LEFT));
        }
        // wild guess while debugging
        return 700;
    }

    public function getWeaponType () :int
    {
        return _lootIx;
    }

    public function teamUpdated () :void
    {
        if (this.stage == null || _hud.parent == null || _visualHud == null) {
            // not ready yet
            return;
        }
        if (Game.control.getAvatarInfo(Game.ourPlayerId) == null) {
            setTimeout(teamUpdated, 100);
            return;
        }

        var players :Array = Game.getTeam();
        var teamIx :int = 0;
        var hudIx :int = 0;
        while (hudIx < 6) {
            var panel :PlayerPanel = _playerPanels[hudIx] as PlayerPanel;

            if (teamIx >= players.length) {
                panel.healthBar.visible = panel.namePlate.visible = false;
                panel.id = 0;
                hudIx ++;
                continue;
            }
//            if (players[teamIx] == Game.ourPlayerId) {
//                teamIx ++;
//                continue;
//            }
            var info :AVRGameAvatar = Game.control.getAvatarInfo(players[teamIx]);
            if (info == null) {
                // most likely explanation: they are not in our room
                teamIx ++;
                continue;
            }
            setPlayerHealth(teamIx, Game.model.getPlayerRelativeHealth(players[teamIx]),
                            players[teamIx] == Game.ourPlayerId);
            panel.namePlate.visible = true;
            panel.namePlate.text = info.name;
            panel.id = players[teamIx];
            teamIx ++;
            hudIx ++;
        }
    }

    protected function handleHUDLoaded (... ignored) :void
    {
        safelyAdd(HELP, helpClick);
        safelyAdd(CLOSE, closeClick);

        _playerPanels = new Array();

        for (var ii :int = 1; ii <= 6; ii ++) {
            var panel :PlayerPanel = new PlayerPanel();

            var bar :MovieClip = findSafely(PLAYER_HEALTH_BAR + ii) as MovieClip;
            if (bar == null) {
                Game.log.warning("Failed to find player health bar #" + ii);
                continue;
            }
            panel.healthBar = bar;

            var plate :TextField = findSafely(PLAYER_NAME_PLATE + ii) as TextField;
            if (plate == null) {
                Game.log.warning("Failed to find player name plate #" + ii);
                continue;
            }
            panel.namePlate = plate;

            _playerPanels.push(panel);
        }

        _yourHealthBar = MovieClip(findSafely(YOUR_HEALTH_BAR));
        _ghostHealthBar = MovieClip(findSafely(GHOST_HEALTH_BAR));
        _ghostCaptureBar = MovieClip(findSafely(GHOST_CAPTURE_BAR));

        _lanternLoot = SimpleButton(findSafely(EQP_LANTERN));
        _lanternLoot.addEventListener(MouseEvent.CLICK, lanternClick);

        _blasterLoot = SimpleButton(findSafely(EQP_BLASTER));
        _blasterLoot.addEventListener(MouseEvent.CLICK, lanternClick);

        _ouijaLoot = SimpleButton(findSafely(EQP_OUIJA));
        _ouijaLoot.addEventListener(MouseEvent.CLICK, lanternClick);

        _potionsLoot = SimpleButton(findSafely(EQP_POTIONS));
        _potionsLoot.addEventListener(MouseEvent.CLICK, lanternClick);

        _loots = [ _lanternLoot, _blasterLoot, _ouijaLoot, _potionsLoot ];
        _lootIx = 0;

        _inventory = MovieClip(findSafely(INVENTORY));
        _inventory.visible = false;

        _ghostInfo = new GhostInfoView(MovieClip(findSafely(GHOST_INFO)));

        safelyAdd(CHOOSE_LANTERN, pickLoot);
        safelyAdd(CHOOSE_BLASTER, pickLoot);
        safelyAdd(CHOOSE_OUIJA, pickLoot);
        safelyAdd(CHOOSE_POTIONS, pickLoot);

        _visualHud = MovieClip(findSafely(VISUAL_BOX));

        this.addChild(_hud);
        placeHud();
        teamUpdated();

        updateGhostHealth();
        updateLootState();
    }

    protected function pickLoot (evt :MouseEvent) :void
    {
        var button :SimpleButton = evt.target as SimpleButton;
        if (button == null) {
            Game.log.debug("Clicky is not SimpleButton: " + evt.target);
            return;
        }

        if (button.name == CHOOSE_LANTERN) {
            _lootIx = 0;
        } else if (button.name == CHOOSE_BLASTER) {
            _lootIx = 1;
        } else if (button.name == CHOOSE_OUIJA) {
            _lootIx = 2;
        } else if (button.name == CHOOSE_POTIONS) {
            _lootIx = 3;
        } else {
            Game.log.debug("Eeek, unknown target: " + button.name);
            return;
        }

        updateLootState();
    }

    protected function updateLootState () :void
    {
        for (var ii :int = 0; ii < _loots.length; ii ++) {
            SimpleButton(_loots[ii]).visible = (ii == _lootIx);
        }
    }

    protected function placeHud () :void
    {
        Game.log.debug("Looks like HUD's width is: " + _hud.width);
        Game.log.debug("Looks like Visual HUD's width is: " + _visualHud.width);

        _hud.x = getRightEdge();
        _hud.y = 0;

        Game.log.debug("Placing hud at (" + x + ", 0)...");
    }

    protected function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_hud, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    protected function safelyAdd (name :String, callback :Function) :void
    {
        findSafely(name).addEventListener(MouseEvent.CLICK, callback);
    }

    protected function playerHealthUpdated (id :int) :void
    {
        setPlayerHealth(findPlayerIx(id),
                        Game.model.getPlayerRelativeHealth(id),
                        id == Game.ourPlayerId);
    }

    protected function roomPropertyChanged (evt :AVRGameControlEvent) :void
    {
        var name :String = evt.name;
        if (name == Codes.PROP_GHOST_CUR_HEALTH || name == Codes.PROP_GHOST_MAX_HEALTH ||
            name == Codes.PROP_GHOST_CUR_ZEST || name == Codes.PROP_GHOST_MAX_ZEST ||
            name == Codes.PROP_STATE) {
            updateGhostHealth();

        } else if (name == Codes.PROP_GHOST_ID) {
            _ghostInfo.updateGhost();
        }
    }

    protected function playerPropertyChanged (memberId :int, name :String, value :Object) :void
    {
        if (name == Codes.PROP_PLAYER_CUR_HEALTH || name == Codes.PROP_PLAYER_MAX_HEALTH) {
            playerHealthUpdated(memberId);
        }
    }

    protected function lanternClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.TOGGLE_LANTERN);
    }

    protected function closeClick (evt :Event) :void
    {
        CommandEvent.dispatch(this, GameController.END_GAME);
    }

    protected function helpClick (evt :Event) :void
    {
//        CommandEvent.dispatch(this, GameController.HELP);
        var panel :Sprite = new DebugPanel();

        this.addChild(panel);
        panel.x = 200;
        panel.y = 600;
    }

    protected function updateGhostHealth () :void
    {
        if (_ghostHealthBar == null || _ghostCaptureBar == null) {
            return;
        }

        var bar :MovieClip;
        var other :MovieClip;
        var health :Number;

        if (Game.model.state == GameModel.STATE_SEEKING ||
            Game.model.state == GameModel.STATE_APPEARING) {
            health = Game.model.ghostRelativeZest;
            bar = _ghostCaptureBar;
            other = _ghostHealthBar;

        } else {
            health = Game.model.ghostRelativeHealth;
            bar = _ghostHealthBar;
            other = _ghostCaptureBar;
        }
        bar.visible = true;
        other.visible = false;

        // TODO: make use of all 100 frames!
        var frame :int = 76 - 75 * MathUtil.clamp(health, 0, 1);
        bar.gotoAndStop(frame);
        Game.log.debug("Moved " + bar.name + " to frame #" + frame);

        reallyStop(bar);
        reallyStop(other);
    }

    protected function findPlayerIx (id :int) :int
    {
        if (_playerPanels != null) {
            for (var ii :int = 0; ii < 6; ii ++) {
                if (_playerPanels[ii].id == id) {
                    return ii;
                }
            }
        }
        return -1;
    }

    protected function setPlayerHealth (ix :int, health :Number, us :Boolean) :void
    {
        if (ix < 0 || _playerPanels == null) {
            return;
        }
        // TODO: make use of all 100 frames!
        var frame :int = 99 - 98 * MathUtil.clamp(health, 0, 1);

        if (us) {
            bar = _yourHealthBar;
            bar.gotoAndStop(frame);
            Game.log.debug("Moved " + bar.name + " to frame #" + frame);
            reallyStop(bar);
        }
        var bar :MovieClip = _playerPanels[ix].healthBar;
        bar.visible = true;
        bar.gotoAndStop(frame);
        Game.log.debug("Moved " + bar.name + " to frame #" + frame);
        reallyStop(bar);
    }

    protected function reallyStop (obj :DisplayObject) :void
    {
        DisplayUtil.applyToHierarchy(obj, function (disp :DisplayObject) :void {
            if (disp is MovieClip) {
                MovieClip(disp).stop();
            }
        });
    }


    protected var _ppp :PerPlayerProperties;

    protected var _hud :ClipHandler;
    protected var _visualHud :MovieClip;

    protected var _playerPanels :Array;

    protected var _ghostHealthBar :MovieClip;
    protected var _ghostCaptureBar :MovieClip;
    protected var _yourHealthBar :MovieClip;

    protected var _lanternLoot :SimpleButton;
    protected var _blasterLoot :SimpleButton;
    protected var _ouijaLoot :SimpleButton;
    protected var _potionsLoot :SimpleButton;
    protected var _loots :Array;
    protected var _lootIx :int;

    protected var _inventory :MovieClip;
    protected var _ghostInfo :GhostInfoView;
//    protected var _weaponDisplay :MovieClip;

    protected static const HELP :String = "helpbutton";
    protected static const CLOSE :String = "closeButton";

    protected static const PLAYER_NAME_PLATE :String = "PlayerPanel";
    protected static const PLAYER_HEALTH_BAR :String = "PlayerHealth";
    protected static const YOUR_HEALTH_BAR :String = "YourHealth";

    protected static const GHOST_HEALTH_BAR :String = "GhostHealthBar";
    protected static const GHOST_CAPTURE_BAR :String = "GhostCaptureBar";

    protected static const VISUAL_BOX :String = "HUDmain";
    protected static const JUNK_BOX :String = "HUDtopbox";

    protected static const EQP_LANTERN :String = "equipped_lantern";
    protected static const EQP_BLASTER :String = "equipped_blaster";
    protected static const EQP_OUIJA :String = "equipped_ouija";
    protected static const EQP_POTIONS :String = "equipped_heal";

    protected static const INVENTORY :String = "inventory1";
    protected static const GHOST_INFO :String = "GhostInfoBox";

//    protected static const WEAPON_DISPLAY :String = "WeaponDisplay";

    protected static const CHOOSE_LANTERN :String = "choose_lantern";
    protected static const CHOOSE_BLASTER :String = "choose_blaster";
    protected static const CHOOSE_OUIJA :String = "choose_ouija";
    protected static const CHOOSE_POTIONS :String = "choose_heal";

    protected static const MARGIN_LEFT :int = 22;
    protected static const BORDER_LEFT :int = 33;

}
}

import flash.display.MovieClip;
import flash.text.TextField;

class PlayerPanel
{
    public var id :int;
    public var healthBar :MovieClip;
    public var namePlate :TextField;
}
