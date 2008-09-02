//
// $Id$

package ghostbusters.client.seek {

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

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import com.threerings.flash.FrameSprite;
import com.threerings.util.ClassUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Random;

import ghostbusters.client.*;
import ghostbusters.data.Codes;

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

        Game.control.room.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);
        Game.control.room.props.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED, roomElementChanged);

        if (Game.state == Codes.STATE_APPEARING) {
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

    protected function messageReceived (event: MessageReceivedEvent) :void
    {
        if (event.name == Codes.SMSG_GHOST_ZAPPED) {
            _zapping = ZAP_FRAMES;
            Sound(new Content.LANTERN_GHOST_SCREECH()).play();
        }
    }

    protected function roomElementChanged (evt :ElementChangedEvent) :void
    {
        // if the ghost is appearing, ignore network events
        if (_lanterns == null) {
            return;
        }

        var bits :Array;

        if (evt.name == Codes.DICT_LANTERNS) {
            var playerId :int = evt.key;

            // ignore our own updates unless we're debugging
            if (playerId == Game.ourPlayerId && !Game.DEBUG) {
                return;
            }

            if (evt.newValue == null) {
                // someone turned theirs off
                playerLanternOff(playerId);

            } else {
                bits = (evt.newValue as Array);
                if (bits != null) {
                    // someone turned theirs on or moved it
                    updateLantern(
                        playerId, Game.control.local.roomToStage(new Point(bits[0], bits[1])));
                }
            }

        } else if (evt.name == Codes.DICT_GHOST && evt.key == Codes.IX_GHOST_POS) {
            bits = (evt.newValue as Array);
            if (bits != null) {
                var pos :Point = Game.control.local.roomToStage(new Point(bits[0], bits[1]));
                if (pos != null) {
                    _ghost.newTarget(this.globalToLocal(pos));
                }
            }
        }

    }

    protected function roomPropertyChanged (evt :PropertyChangedEvent) :void
    {
        // if there's no ghost or it's busy appearing, nothing here to do
        if (_ghost == null || _lanterns == null) {
            return;
        }

        if (evt.name == Codes.PROP_STATE) {
            if (evt.newValue == Codes.STATE_APPEARING) {
                appearGhost();
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
            if (Game.control.room.isPlayerHere(lantern.playerId)) {
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
            // TODO: send a message (ugh)? keep a per-ghost timeout on the server?
            // Game.server.ghostFullyAppeared();
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
        pos = Game.control.local.stageToRoom(pos);
        if (pos != null) {
            Game.control.agent.sendMessage(Codes.CMSG_LANTERN_POS, [ pos.x, pos.y ]);
        }
    }

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