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
import com.threerings.flash.FrameSprite;
import com.whirled.AVRGameAvatar;
import com.threerings.util.CommandEvent;

import ghostbusters.ClipHandler;
import ghostbusters.GameController;

public class HUD extends FrameSprite
{
    public function HUD ()
    {
        _hud = new ClipHandler(ByteArray(new Content.HUD_VISUAL()), handleHUDLoaded);
    }

    public function shutdown () :void
    {
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _hud != null && _hud.hitTestPoint(x, y, shapeFlag);
    }

    public function resized () :void
    {
        if (_hud != null && _hud.parent != null) {
            placeHud();
        }
    }

    protected function handleHUDLoaded (... ignored) :void
    {
        _hud.gotoScene("Scene 1");
        _hud.stop();

        safelyAdd(HELP, helpClick);
        safelyAdd(CLOSE, closeClick);

        _playerHealthBars = new Array();
        _playerNamePanels = new Array();
        for (var ii :int = 1; ii <= 6; ii ++) {
            var bar :DisplayObject = findSafely(PLAYER_HEALTH_BAR + ii);
            if (bar == null) {
                Game.log.warning("Failed to find player health bar #" + ii);
                continue;
            }
            Game.log.debug("bar: " + bar);
            _playerHealthBars.push(bar);

            var panel :DisplayObject = findSafely(PLAYER_NAME_PANEL + ii);
            if (panel == null) {
                Game.log.warning("Failed to find player name panel #" + ii);
                continue;
            }
            Game.log.debug("panel: " + panel);
            _playerNamePanels.push(panel);
        }

        _yourHealthBar = MovieClip(findSafely(YOUR_HEALTH_BAR));
        _ghostHealthBar = MovieClip(findSafely(GHOST_HEALTH_BAR));

        _blasterLoot = SimpleButton(findSafely(LOOT_BLASTER));
        _ouijaLoot = SimpleButton(findSafely(LOOT_OUIJA));
        _healLoot = SimpleButton(findSafely(LOOT_HEAL));
        _lanternLoot = SimpleButton(findSafely(LOOT_LANTERN));

        _loots = [ _lanternLoot, _blasterLoot, _ouijaLoot, _healLoot ];
        _lootIx = 0;

        // hide the bits that we want to keep in the hierarchy solely for swapin/out purposes 
        findSafely(JUNK_BOX).visible = false;

        _visualHud = MovieClip(findSafely(VISUAL_BOX));
    }

    protected function placeHud () :void
    {
        Game.log.debug("Looks like HUD's width is: " + _hud.width);
        Game.log.debug("Looks like Visual HUD's width is: " + _visualHud.width);

        // put the HUD to the right of the visible screen, or flush with the stage edge
        var x :int = Math.max(0, Math.min(Game.scrollSize.width - MARGIN_LEFT - BORDER_LEFT,
                                          Game.stageSize.right - _visualHud.width - MARGIN_LEFT));

        _hud.x = x;
        _hud.y = 0;

        Game.log.debug("Placing hud at (" + x + ", 0)...");

//        var width :int = Game.stageSize.right - Game.scrollSize.right;
//        if (width > 0) {
//            this.graphics.beginFill(0);
//            this.graphics.drawRect(Game.scrollSize.right + 1, 1,
//                                   width, Game.scrollSize.height);
//            this.graphics.endFill();
//        }
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

    override protected function handleFrame (... ignored) :void
    {
        if (_hud.parent == null && _visualHud != null) {
            this.addChild(_hud);
            placeHud();
        }

        var players :Array = Game.control.getPlayerIds();
        if (players == null) {
            // offline mode -- don't flip out
            return;
        }
        var teamIx :int = 0;
        var hudIx :int = 0;
        while (hudIx < 6) {
            var bar :MovieClip = MovieClip(_playerHealthBars[hudIx]);
            var name :TextField = TextField(_playerNamePanels[hudIx]);
            if (teamIx >= players.length) {
                bar.visible = name.visible = false;
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
            bar.visible = name.visible = true;
            bar.gotoAndStop(100 * Game.gameController.model.getRelativeHealth(players[teamIx]));
            name.text = info.name;
            teamIx ++;
            hudIx ++;
        }

        _yourHealthBar.gotoAndStop(
            100 * Game.gameController.model.getRelativeHealth(Game.ourPlayerId));

        // TODO
        _ghostHealthBar.gotoAndStop(30);

        for (var ii :int = 0; ii < _loots.length; ii ++) {
            SimpleButton(_loots[ii]).visible = (ii == _lootIx);
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
        CommandEvent.dispatch(this, GameController.HELP);
    }

//    protected function lootClick (evt :Event) :void
//    {
//        CommandEvent.dispatch(this, GameController.TOGGLE_LOOT);
//    }

    protected var _hud :ClipHandler;
    protected var _visualHud :MovieClip;

    protected var _playerHealthBars :Array;
    protected var _playerNamePanels :Array;

    protected var _ghostHealthBar :MovieClip;
    protected var _yourHealthBar :MovieClip;

    protected var _lanternLoot :SimpleButton;
    protected var _blasterLoot :SimpleButton;
    protected var _ouijaLoot :SimpleButton;
    protected var _healLoot :SimpleButton;
    protected var _loots :Array;
    protected var _lootIx :int;

    protected static const HELP :String = "helpbutton";
    protected static const CLOSE :String = "closeButton";

    protected static const PLAYER_NAME_PANEL :String = "PlayerPanel";
    protected static const PLAYER_HEALTH_BAR :String = "PlayerHealth";
    protected static const YOUR_HEALTH_BAR :String = "YourHealth";
    protected static const GHOST_HEALTH_BAR :String = "GhostHealthBar";

    protected static const VISUAL_BOX :String = "HUDmain";
    protected static const JUNK_BOX :String = "HUDtopbox";

    protected static const LOOT_LANTERN :String = "equipped_lantern";
    protected static const LOOT_BLASTER :String = "equipped_blaster";
    protected static const LOOT_OUIJA :String = "equipped_ouija";
    protected static const LOOT_HEAL :String = "equipped_heal";

    protected static const MARGIN_LEFT :int = 22;
    protected static const BORDER_LEFT :int = 25;
}
}
