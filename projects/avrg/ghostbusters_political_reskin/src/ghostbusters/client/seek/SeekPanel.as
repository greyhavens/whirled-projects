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
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import com.threerings.flash.FrameSprite;
import com.threerings.util.ClassUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.Log;
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
        newLanterns(Dictionary(Game.control.room.props.get(Codes.DICT_LANTERNS)));

        if (Game.state == Codes.STATE_APPEARING) {
            appearGhost();

        } else if (_ghost != null) {
            _ghost.hidden();
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

        Game.control.room.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);
        Game.control.room.props.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED, roomElementChanged);
    }

    override protected function handleRemoved (... ignored) :void
    {
        super.handleRemoved();
        _lanternLoop.stop();

        Game.control.room.removeEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.room.props.removeEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, roomPropertyChanged);
        Game.control.room.props.removeEventListener(
            ElementChangedEvent.ELEMENT_CHANGED, roomElementChanged);
    }

    protected function messageReceived (evt: MessageReceivedEvent) :void
    {
        if (evt.name == Codes.SMSG_GHOST_ZAPPED) {
            _zapping = ZAP_FRAMES;
            Sound(new Content.LANTERN_GHOST_SCREECH()).play();
        }
    }

    protected function roomElementChanged (evt :ElementChangedEvent) :void
    {
        if (evt.name == Codes.DICT_LANTERNS) {
            if (_lanterns != null) {
                if (evt.newValue == null) {
                    // someone turned theirs off
                    playerLanternOff(evt.key);

                } else {
                    lanternUpdateEvent(evt.key, evt.newValue as Array);
                }
            }

        } else if (evt.name == Codes.DICT_GHOST) {
            if (evt.key == Codes.IX_GHOST_POS && _ghost != null) {
                ghostPositionChanged(evt.newValue as Array);
            }
        }
    }

    protected function roomPropertyChanged (evt :PropertyChangedEvent) :void
    {
        // if there's no ghost or it's busy appearing, nothing here to do
        if (_ghost == null || _lanterns == null) {
            return;
        }

        if (evt.name == Codes.DICT_LANTERNS) {
            newLanterns(Dictionary(evt.newValue));

        } else if (evt.name == Codes.PROP_STATE) {
            if (evt.newValue == Codes.STATE_APPEARING) {
                appearGhost();
            }
        }
    }

    // we're initializing our lantern data structure from a dictionary
    protected function newLanterns (lanterns :Dictionary) :void
    {
        var playerId :Object;

        // make sure we have the lanterns we're supposed to have
        for (playerId in lanterns) {
            lanternUpdateEvent(int(playerId), lanterns[playerId]);
        }

        // make sure we don't have some we shouldn't have
        for (playerId in _lanterns) {
            if (lanterns[playerId] == null) {
                playerLanternOff(int(playerId));
            }
        }
    }

    protected function ghostPositionChanged (bits :Array) :void
    {
        // the server sends every client a new (x, y) for the ghost that's in the
        // logical range [0, 1] and each client translates that according to the
        // bounds of the current room. We do not however want the ghost to e.g. fly
        // through the floor, nor disappear at the edges, so use the ghost's known
        // bounds to offset. Admittedly this is a case of mixing apples and oranges
        // (the ghost's bounds and the room's bounds use pixels that may be scaled
        // differently, especially for tall backgrounds) but it's effective enough
        // for the moment.

        var roomBounds :Rectangle = Game.control.room.getRoomBounds();
        if (roomBounds == null) {
            log.warning("Can't get room bounds to move ghost around.");
            return;
        }

        // figure effective movement ranges
        var dX :Number = Math.max(0, roomBounds.width - 2*_ghost.bounds.width);
        var dY :Number = Math.max(0, roomBounds.height - _ghost.bounds.height);

        // place the ghost therein
        var x :Number = _ghost.bounds.width + dX * bits[0];
        var y :Number = dY * bits[1];

        // convert to actual local coordinates and go whee
        var pos :Point = Game.control.local.roomToPaintable(new Point(x, y));
        if (pos == null) {
            log.debug("Failed to convert ghost target to local coordinates", "x", x, "y", y);
            return;
        }

        _ghost.newTarget(this.globalToLocal(pos));
    }

    protected function lanternUpdateEvent (playerId :int, pos :Array) :void
    {
        // ignore our own updates unless we're debugging
        if (playerId == Game.ourPlayerId && !Game.DEBUG) {
            return;
        }

        // someone turned theirs on or moved it
        updateLantern(playerId, Game.control.local.roomToPaintable(new Point(pos[0], pos[1])));
    }

    // FRAME HANDLER
    override protected function handleFrame (... ignored) :void
    {
        var paintable :Rectangle = Game.control.local.getPaintableArea(true);
        if (paintable == null) {
            return;
        }

        var p :Point = new Point(Math.max(0, Math.min(paintable.width, this.mouseX)),
                                 Math.max(0, Math.min(paintable.height, this.mouseY)));
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
                _zapping = ZAP_FRAMES;
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
        _ghost.appear();

        _ghost.newTarget(new Point(600, 100));

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
        pos = this.globalToLocal(pos);
//        log.debug("New lantern update", "pos", pos);
        if (lantern == null) {
            // a new lantern just appears, no splines involved
            lantern = new Lantern(playerId, pos);
            _lanterns[playerId] = lantern;

            _maskLayer.addChild(lantern.mask);
            _lightLayer.addChild(lantern.light);
            _dimness.addChild(lantern.hole);

        } else {
            // just set our aim for p
            lantern.newTarget(pos, 0.5, false);
        }
    }

    protected function transmitLanternPosition (pos :Point) :void
    {
        pos = Game.control.local.paintableToRoom(pos);
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

    protected static const log :Log = Log.getLog(SeekPanel);
}
}
