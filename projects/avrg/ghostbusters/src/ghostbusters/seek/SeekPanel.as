//
// $Id$

package ghostbusters.seek {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.flash.FrameSprite;
import com.threerings.util.ClassUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Random;

import ghostbusters.Codes;
import ghostbusters.Content;
import ghostbusters.Dimness;
import ghostbusters.GameController;
import ghostbusters.Game;
import ghostbusters.PerPlayerProperties;

public class SeekPanel extends FrameSprite
{
    public function SeekPanel ()
    {
        buildUI();

        Game.control.state.addEventListener(
            AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.state.addEventListener(
            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);

        Game.control.addEventListener(AVRGameControlEvent.PLAYER_LEFT, playerLeft);

        _ppp = new PerPlayerProperties(playerPropertyUpdate);
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _ghost && _ghost.hitTestPoint(x, y, shapeFlag);
    }

    public function newRoom () :void
    {
        updateGhost();
    }

    public function ghostPositionUpdate (pos :Point) :void
    {
        Game.log.debug("Whee new target: " + pos);
        _ghost.newTarget(this.globalToLocal(pos));
    }

    public function playerLanternOff (playerId :int) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (lantern) {
            lanternOff(lantern);
            delete _lanterns[playerId];
        }
    }

    public function playerLanternMoved (playerId :int, pos :Point) :void
    {
        updateLantern(playerId, pos);
    }

    public function ghostZapped () :void
    {
        zapStart();
    }

    public function appearGhost () :void
    {
        for each (var lantern :Lantern in _lanterns) {
            lanternOff(lantern);
        }
        _lanterns = null;
        _ghost.appear(spawnGhost);
        _ghost.newTarget(new Point(Game.stageSize.width - 250, 100));
        unmaskGhost();
    }

    // we've been added or removed or entered a new room or the ghost has changed,
    // either way it's fine to just reset the ghost, since it's pretty much stateless
    protected function updateGhost () :void
    {
        if (_ghost != null) {
            unmaskGhost();
            if (_ghost.parent != null) {
                this.removeChild(_ghost);
            }
        }

        if (this.parent != null && Game.model.ghostId != null) {
            _ghost = new HidingGhost(200);
            this.addChild(_ghost);
            maskGhost();
        }
    }

    protected function lanternOff (lantern :Lantern) :void
    {
        _dimness.removeChild(lantern.hole);
        _lightLayer.removeChild(lantern.light);
        _maskLayer.removeChild(lantern.mask);
    }

    protected function spawnGhost () :void
    {
        CommandEvent.dispatch(this, GameController.SPAWN_GHOST);
    }

    override protected function handleAdded (... ignored) :void
    {
        super.handleAdded();
        _lanternLoop = Sound(new Content.LANTERN_LOOP_AUDIO()).play();
        updateGhost();
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        updateGhost();
        _lanternLoop.stop();
    }

    protected function updateLantern (playerId :int, pos :Point) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (lantern == null) {
            // a new lantern just appears, no splines involved
            lantern = new Lantern(playerId, pos);
            _lanterns[playerId] = lantern;

            _maskLayer.addChild(lantern.mask);
            _lightLayer.addChild(lantern.light);
            _dimness.addChild(lantern.hole);

        } else {
            // just set our aim for p
            lantern.newTarget(this.globalToLocal(pos), 0.5, false);
        }
    }

    protected var counter :int;

    override protected function handleFrame (... ignored) :void
    {
        if (--counter < 0) {
            counter = Game.FRAMES_PER_REPORT;
            Game.log.debug("Frame handler running: " + this);
        }

        var p :Point = new Point(Math.max(0, Math.min(Game.stageSize.width, this.mouseX)),
                                 Math.max(0, Math.min(Game.stageSize.height, this.mouseY)));
        p = this.localToGlobal(p);

        if (_ghost != null) {
            _ghost.nextFrame();

            if (_zapping > 0) {
                _zapping -= 1;
                if (_zapping == 0) {
                    zapStop();
                }
            }

            if (_lanterns != null && _zapping == 0 && _ghost.hitTestPoint(p.x, p.y, true)) {
                // the player is hovering right over the ghost!
                CommandEvent.dispatch(this, SeekController.ZAP_GHOST);
            }
        }

        if (_lanterns == null) {
            return;
        }

        animateLanterns();

        // bow to reality: nobody wants to watch roundtrip lag in action
        if (!Game.DEBUG) {
            updateLantern(Game.ourPlayerId, p);
        }

        // see if it's time to send an update on our own position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        transmitLanternPosition(p);

        if (_ghost != null && _ghost.isIdle() && Game.control.hasControl()) {
            constructNewGhostPosition(_ghost.getGhostBounds());
        }
    }

    protected function zapStart () :void
    {
        _zapping = 30;
        Sound(new Content.LANTERN_GHOST_SCREECH()).play();

        // as a temporary visual effect, brighten the ghost by 50%
        _ghost.transform.colorTransform = new ColorTransform(1.5, 1.5, 1.5);
    }

    protected function zapStop () :void
    {
        _ghost.transform.colorTransform = new ColorTransform();
        if (Game.model.ghostZest == 0) {
            appearGhost();
        }            
    }

    protected function animateLanterns () :void
    {
        for each (var lantern :Lantern in _lanterns) {
            if (Game.control.isPlayerHere(lantern.playerId)) {
                lantern.nextFrame();

            } else {
                // this should only happen briefly until the server catches up
                playerLanternOff(lantern.playerId);
            }
        }
    }

    protected function buildUI () :void
    {
        _dimness = new Dimness(0.9, true);
        this.addChild(_dimness);

        _lightLayer = new Sprite();
        this.addChild(_lightLayer);

        _maskLayer = new Sprite();
    }

    protected function transmitLanternPosition (pos :Point) :void
    {
        pos = Game.control.stageToRoom(pos);
        if (pos != null) {
            _ppp.setRoomProperty(Game.ourPlayerId, Codes.PROP_LANTERN_POS, [ pos.x, pos.y ]);
        }
    }

    protected function constructNewGhostPosition (ghostBounds :Rectangle) :void
    {
        // it's our job to send the ghost to a new position, figure out where
        var x :int = Game.random.nextNumber() *
            (Game.roomBounds.width - ghostBounds.width) - ghostBounds.left;
        var y :int = Game.random.nextNumber() *
            (Game.roomBounds.height - ghostBounds.height) - ghostBounds.top;
        Game.control.state.setRoomProperty(Codes.PROP_GHOST_POS, [ x, y ]);
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.MSG_GHOST_ZAP) {
            ghostZapped();
        }
    }

    protected function playerPropertyUpdate (playerId :int, prop :String, value :Object) :void
    {
        if (prop == Codes.PROP_LANTERN_POS) {
            if (playerId == Game.ourPlayerId && !Game.DEBUG) {
                return;
            }
            if (value == null) {
                // someone turned theirs off
                playerLanternOff(playerId);

            } else {
                var bits :Array = (value as Array);
                if (bits != null) {
                    // someone turned theirs on or moved it
                    playerLanternMoved(
                        playerId, Game.control.roomToStage(new Point(bits[0], bits[1])));
                }
            }
        }
    }

    protected function roomPropertyChanged (evt :AVRGameControlEvent) :void
    {
        if (evt.name == Codes.PROP_GHOST_ID) {
            updateGhost();

        } else if (evt.name == Codes.PROP_GHOST_POS) {
            var bits :Array = (evt.value as Array);
            if (bits != null) {
                var pos :Point = Game.control.roomToStage(new Point(bits[0], bits[1]));
                if (pos != null) {
                    ghostPositionUpdate(pos);
                }
            }
        }
    }

    // if another player leaves, it may be our job to clear them out
    protected function playerLeft (evt :AVRGameControlEvent) :void
    {
        if (Game.control.hasControl()) {
            _ppp.setRoomProperty(evt.value as int, Codes.PROP_LANTERN_POS, null);            
        }
    }

    protected function maskGhost () :void
    {
        if (_ghost != null) {
            if (_maskLayer.parent == null) {
                this.addChild(_maskLayer);
            }
            _ghost.mask = _maskLayer;
        }
    }

    protected function unmaskGhost () :void
    {
        if (_ghost != null) {
            if (_maskLayer.parent != null) {
                this.removeChild(_maskLayer);
            }
            _ghost.mask = null;
        }
    }

    protected var _ppp :PerPlayerProperties;

    protected var _lanterns :Dictionary = new Dictionary();

    protected var _ghost :HidingGhost;

    protected var _zapping :int;

    protected var _appearing :Boolean;

    protected var _ticker :int;

    protected var _dimness :Dimness;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected var _lanternLoop :SoundChannel;

    protected static const FRAMES_PER_UPDATE :int = 6;
}
}
