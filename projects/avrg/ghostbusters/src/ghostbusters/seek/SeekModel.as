//
// $Id$

package ghostbusters.seek {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControlEvent;

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.path.HermiteFunc;

import com.threerings.util.CommandEvent;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.StringUtil;
import com.threerings.util.Random;

import ghostbusters.Codes;
import ghostbusters.Game;

public class SeekModel extends Sprite
{
    public function SeekModel ()
    {
        Game.control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        Game.control.state.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        Game.control.state.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);
        Game.control.state.addEventListener(AVRGameControlEvent.ENTERED_ROOM, enteredRoom);

        _ghostRandom = new Random(Game.ourRoomId);
        _ghostZest = _ghostMaxZest = 150 + 100 * _ghostRandom.nextNumber();
    }

    public function init (panel :SeekPanel) :void
    {
        _panel = panel;
    }

    public function shutdown () :void
    {
    }

    public function ghostZapped () :void
    {
        _ghostZest = _ghostZest * 0.8 - 20;
        _panel.ghostZestUpdated();
    }

    public function getGhostZestFraction () :Number
    {
        return _ghostZest / _ghostMaxZest;
    }

    public function getGhostZest () :Number
    {
        return _ghostZest;
    }

    public function getMaxGhostZest () :Number
    {
        return _ghostMaxZest;
    }

    public function calculateGhostSpeed () :Number
    {
        // I still don't know what function this should be of zest, if any.
        return 200;
    }

    public function transmitLanternPosition (pos :Point) :void
    {
        pos = Game.control.stageToRoom(pos);
        if (pos != null) {
            Game.control.state.setProperty(
                Codes.PROP_LANTERN_POS, [ Game.ourPlayerId, pos.x, pos.y ], false);
        }
    }

    public function constructNewGhostPosition (ghostBounds :Rectangle) :void
    {
        // it's our job to send the ghost to a new position, figure out where
        var x :int = Game.random.nextNumber() *
            (Game.roomBounds.width - ghostBounds.width) - ghostBounds.left;
        var y :int = Game.random.nextNumber() *
            (Game.roomBounds.height - ghostBounds.height) - ghostBounds.top;
        Game.control.state.sendMessage(Codes.MSG_GHOST_POS, [ Game.ourRoomId, x, y ]);
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.MSG_GHOST_POS) {
            var bits :Array = event.value as Array;
            if (bits != null) {
                var roomId :int = int(bits[0]);
                if (roomId == Game.ourRoomId) {
                    var pos :Point = Game.control.roomToStage(new Point(bits[1], bits[2]));
                    if (pos != null) {
                        _panel.ghostPositionUpdate(pos);
                    }
                }
            }
        }
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        if (event.name == Codes.PROP_LANTERN_POS) {

            var bits :Array = event.value as Array;
            if (bits != null) {
                var playerId :int = int(bits[0]);

                // ignore our own update, unless we're debugging
                if (playerId == Game.ourPlayerId && !Game.DEBUG) {
                    return;
                }
                if (Game.control.isPlayerHere(playerId)) {
                    // lantern update from a local player
                    if (bits.length == 1) {
                        // someone turned theirs off
                        _panel.playerLanternOff(playerId);

                    } else {
                        // someone turned theirs on or moved it
                        _panel.playerLanternMoved(
                            playerId, Game.control.roomToStage(new Point(bits[1], bits[2])));
                    }
                }
            }
        }
    }

    protected function enteredRoom (event :AVRGameControlEvent) :void
    {
        // TODO
    }

    protected function leftRoom (event :AVRGameControlEvent) :void
    {
        // TODO
    }

    protected var _panel :SeekPanel;

    protected var _ghostRandom :Random;
    protected var _ghostZest :Number;
    protected var _ghostMaxZest :Number;
}
}
