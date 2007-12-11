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

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.path.HermiteFunc;

import com.threerings.util.CommandEvent;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Random;
import com.threerings.util.StringUtil;

import ghostbusters.Game;

public class SeekModel extends Sprite
{
    public function SeekModel (control :AVRGameControl)
    {
        _control = control;

        _control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        _control.state.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _control.state.addEventListener(AVRGameControlEvent.LEFT_ROOM, leftRoom);
        _control.state.addEventListener(AVRGameControlEvent.ENTERED_ROOM, enteredRoom);

        _myId = _control.getPlayerId();
        _roomId = _control.getRoomId();
        _room = _control.getRoomBounds();

        _random = new Random();

        _ghostRandom = new Random(_roomId);
        _ghostSpeed = 150 + 100 * _ghostRandom.nextNumber();
    }

    public function init (panel :SeekPanel) :void
    {
        _panel = panel;
    }

    public function shutdown () :void
    {
    }

    public function getGhostSpeed () :Number
    {
        return _ghostSpeed;
    }

    public function transmitGhostSpawn () :void
    {
        _control.state.sendMessage("gs", null);
    }

    public function transmitGhostClick () :void
    {
        _control.state.sendMessage("gc", _myId);
    }

    public function transmitLanternPosition (pos :Point) :void
    {
        pos = _control.stageToRoom(pos);
        if (pos != null) {
            _control.state.setProperty("fl", [ _myId, pos.x, pos.y ], false);
        }
    }

    public function constructNewGhostPosition (ghostBounds :Rectangle) :void
    {
        // it's our job to send the ghost to a new position, figure out where
        var x :int = _random.nextNumber() * (_room.width - ghostBounds.width) - ghostBounds.left;
        var y :int = _random.nextNumber() * (_room.height - ghostBounds.height) - ghostBounds.top;
        _control.state.sendMessage("gp", [ _roomId, x, y ]);
    }

    public function getRoomId () :int
    {
        return _roomId;
    }

    public function getMyId () :int
    {
        return _myId;
    }

    protected function messageReceived (event: AVRGameControlEvent) :void
    {
        if (event.name == "gp") {
            var bits :Array = event.value as Array;
            if (bits != null) {
                var roomId :int = int(bits[0]);
                if (roomId == _roomId) {
                    var pos :Point = _control.roomToStage(new Point(bits[1], bits[2]));
                    if (pos != null) {
                        _panel.ghostPositionUpdate(pos);
                    }
                }
            }

        } else if (event.name == "gs") {
            _control.spawnMob("ghost");

        } else if (event.name == "gc") {
            _ghostSpeed = _ghostSpeed * 0.8 - 20;
            _panel.ghostSpeedUpdated();
        }
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        if (event.name == "fl") {
            var bits :Array = event.value as Array;
            if (bits != null) {
                var playerId :int = int(bits[0]);
                // ignore our own update, unless we're debugging
                if (playerId == _myId && !Game.DEBUG) {
                    return;
                }
                if (_control.isPlayerHere(playerId)) {
                    // lantern update from a local player
                    if (bits.length == 1) {
                        // someone turned theirs off
                        _panel.playerLanternOff(playerId);

                    } else {
                        // someone turned theirs on or moved it
                        _panel.playerLanternMoved(
                            playerId, _control.roomToStage(new Point(bits[1], bits[2])));
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

    protected var _control :AVRGameControl;
    protected var _panel :SeekPanel;

    protected var _myId :int;
    protected var _roomId :int;
    protected var _room :Rectangle;

    protected var _random :Random;

    protected var _ghostRandom :Random;
    protected var _ghostSpeed :Number;
}
}
