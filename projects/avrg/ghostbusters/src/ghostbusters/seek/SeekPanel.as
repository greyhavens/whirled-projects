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

import ghostbusters.*;

public class SeekPanel extends FrameSprite
{
    public function SeekPanel (ghost :Ghost)
    {
        _ghost = ghost;

        _dimness = new Dimness(0.9, true);
        this.addChild(_dimness);

        _lightLayer = new Sprite();
        this.addChild(_lightLayer);

        _maskLayer = new Sprite();
        if (_ghost != null) {
            this.addChild(_ghost);
            this.addChild(_maskLayer);
            _ghost.mask = _maskLayer;
        }

        _lanterns = new Dictionary();

        Game.control.state.addEventListener(
            AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.state.addEventListener(
            AVRGameControlEvent.ROOM_PROPERTY_CHANGED, roomPropertyChanged);

        _ppp = new PerPlayerProperties(playerPropertyUpdate);

        if (Game.model.state == GameModel.STATE_APPEARING) {
            appearGhost();
        }
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _ghost != null && _ghost.hitTestPoint(x, y, shapeFlag);
    }

    override protected function handleAdded (... ignored) :void
    {
        super.handleAdded();
        _lanternLoop = Sound(new Content.LANTERN_LOOP_AUDIO()).play();
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        _lanternLoop.stop();
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.MSG_GHOST_ZAP) {
            _zapping = ZAP_FRAMES;
            Sound(new Content.LANTERN_GHOST_SCREECH()).play();
        }
    }

    protected function playerPropertyUpdate (playerId :int, prop :String, value :Object) :void
    {
        // if the ghost is appearing, ignore network events
        if (_lanterns == null) {
            return;
        }

        if (prop == Codes.PROP_LANTERN_POS) {
            // ignore our own updates unless we're debugging
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
                    updateLantern(playerId, Game.control.roomToStage(new Point(bits[0], bits[1])));
                }
            }
        }
    }

    protected function roomPropertyChanged (evt :AVRGameControlEvent) :void
    {
        // if there's no ghost or it's busy appearing, nothing here to do
        if (_ghost == null || _lanterns == null) {
            return;
        }

        if (evt.name == Codes.PROP_STATE) {
            if (evt.value == GameModel.STATE_APPEARING) {
                appearGhost();
            }

        } else if (evt.name == Codes.PROP_GHOST_POS) {
            var bits :Array = (evt.value as Array);
            if (bits != null) {
                var pos :Point = Game.control.roomToStage(new Point(bits[0], bits[1]));
                if (pos != null) {
                    _ghost.newTarget(this.globalToLocal(pos));
                }
            }
        }
    }

    // FRAME HANDLER

    override protected function handleFrame (... ignored) :void
    {
        var p :Point = new Point(Math.max(0, Math.min(Game.stageSize.width, this.mouseX)),
                                 Math.max(0, Math.min(Game.stageSize.height, this.mouseY)));
        p = this.localToGlobal(p);

        if (_ghost != null) {
            _ghost.nextFrame();

            if (_zapping > 0) {
                // sawtooth from 1 to 4 down to 1 again
                var alpha :Number = 1 + 3*(1 - Math.abs((2.0*_zapping)/ZAP_FRAMES - 1));
                _ghost.transform.colorTransform = new ColorTransform(alpha, alpha, alpha);

                _zapping --;
            }

            if (_lanterns != null && _zapping == 0 && _ghost.hitTestPoint(p.x, p.y, true)) {
                // the player is hovering right over the ghost!
                CommandEvent.dispatch(this, GameController.ZAP_GHOST);
            }
        }

        // this is our test to see if we're in the appear phase, when lanterns are off
        if (_lanterns == null) {
            return;
        }

        // else animate the lanterns we know about
        for each (var lantern :Lantern in _lanterns) {
            if (Game.control.isPlayerHere(lantern.playerId)) {
                lantern.nextFrame();

            } else {
                // this should only happen briefly until the server catches up
                playerLanternOff(lantern.playerId);
            }
        }

        // update our own lantern directly, nobody wants to watch roundtrip lag in action
        if (!Game.DEBUG) {
            updateLantern(Game.ourPlayerId, p);
        }

        // see if it's time to send a network update on our position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        transmitLanternPosition(p);
    }

    // GHOST MANAGEMENT
    protected function appearGhost () :void
    {
        for each (var lantern :Lantern in _lanterns) {
            lanternOff(lantern);
        }
        _lanterns = null;
        _ghost.appear(function () :void {
            Game.server.ghostFullyAppeared();
        });
        var x :int = Game.panel.hud.getRightEdge() - _ghost.getGhostBounds().width/2;
        _ghost.newTarget(new Point(x, 100));

        _ghost.mask = null;
        this.removeChild(_maskLayer);
    }

    // LANTERN MANAGEMENT

    protected function playerLanternOff (playerId :int) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (lantern) {
            lanternOff(lantern);
            delete _lanterns[playerId];
        }
    }

    protected function lanternOff (lantern :Lantern) :void
    {
        _dimness.removeChild(lantern.hole);
        _lightLayer.removeChild(lantern.light);
        _maskLayer.removeChild(lantern.mask);
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

    protected function transmitLanternPosition (pos :Point) :void
    {
        pos = Game.control.stageToRoom(pos);
        if (pos != null) {
            _ppp.setRoomProperty(Game.ourPlayerId, Codes.PROP_LANTERN_POS, [ pos.x, pos.y ]);
        }
    }

    protected var _ppp :PerPlayerProperties;

    protected var _lanterns :Dictionary;

    protected var _ghost :Ghost;

    protected var _zapping :int;

    protected var _ticker :int;

    protected var _dimness :Dimness;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected var _lanternLoop :SoundChannel;

    protected static const FRAMES_PER_UPDATE :int = 6;
    protected static const ZAP_FRAMES :int = 30;
}
}
