package flashmob.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class SpectaclePlayerMode extends GameDataMode
{
    override protected function setup () :void
    {
        _spectacle = ClientContext.spectacle;

        _tf = new TextField();
        _modeSprite.addChild(_tf);

        if (ClientContext.isPartyLeader) {
            _startButton = UIBits.createButton("Start!", 1.2);
            registerListener(_startButton, MouseEvent.CLICK, onStartClicked);

            _modeSprite.addChild(_startButton);
        }

        if (ClientContext.isPartyLeader) {
            setText("Drag the spectacle to its starting location, then press start!");
            _patternView = new PatternView(_spectacle.patterns[0], onSpectacleDragged);

            _spectacleOffsetThrottler = new MessageThrottler(Constants.MSG_SET_SPECTACLE_OFFSET);
            addObject(_spectacleOffsetThrottler);

        } else {
            _patternView = new PatternView(_spectacle.patterns[0]);
            setText("Waiting for the party leader to start the spectacle!");
        }

        addObject(_patternView, _modeSprite);

        // init data bindings
        _dataBindings.bindMessage(Constants.MSG_PLAYNEXTPATTERN, startNextPattern);
        _dataBindings.bindProp(Constants.PROP_SPECTACLE_OFFSET, handleNewSpectacleOffset,
            PatternLoc.fromBytes);
        _dataBindings.processAllProperties(ClientContext.props);
    }

    protected function onSpectacleDragged (newX :Number, newY :Number) :void
    {
        var roomLoc :Point =
            ClientContext.gameCtrl.local.paintableToRoom(new Point(newX, newY));

        _spectacleOffsetThrottler.value = (new PatternLoc(roomLoc.x, roomLoc.y).toBytes());
    }

    protected function handleNewSpectacleOffset (newOffset :PatternLoc) :void
    {
        if (!ClientContext.isPartyLeader) {
            log.info("handleNewSpectacleOffset", "newOffset", newOffset);
            _spectacleOffset = newOffset;

            var screenLoc :Point = ClientContext.gameCtrl.local.roomToPaintable(
                new Point(newOffset.x, newOffset.y));

            // smoothly animate to the new location
            _patternView.removeAllTasks();
            _patternView.addTask(LocationTask.CreateSmooth(screenLoc.x, screenLoc.y, 1));
        }
    }

    /*protected function get playersInPosition () :Boolean
    {
        var pattern :Pattern = this.curPattern;
        if (pattern == null) {
            return false;
        }

        var locs :Array = pattern.locs.slice();
        var playerLocs :Array = ClientContext.playerIds.map(
            function (playerId :int, ...ignored) :Point {
                return ClientContext.getPlayerRoomLoc(playerId);
            });

        for each (var playerLoc :Point in playerLocs) {
            var closestLoc :PatternLoc =
        }

        return true;
    }*/

    protected function removePatternView () :void
    {
        if (_patternView != null) {
            _patternView.destroySelf();
            _patternView = null;
        }
    }

    protected function startNextPattern () :void
    {
        if (!_startedPlaying) {
            if (_spectacleOffsetThrottler != null) {
                _spectacleOffsetThrottler.destroySelf();
                _spectacleOffsetThrottler = null;
            }

            _startedPlaying = true;
        }

        ++_patternIndex;

        removePatternView();
        _patternView = new PatternView(this.curPattern);
        addObject(_patternView, _modeSprite);
    }

    protected function onStartClicked (...ignored) :void
    {
        ClientContext.sendAgentMsg(Constants.MSG_STARTPLAYING);
        _startButton.visible = false;
    }

    protected function updateButtons () :void
    {
    }

    protected function setText (text :String) :void
    {
        UIBits.initTextField(_tf, text, 1.2, WIDTH - 10, 0xFFFFFF, TextFormatAlign.LEFT);

        var height :Number = _tf.height + 10 + (_startButton != null ? _startButton.height : 0);
        var g :Graphics = _modeSprite.graphics;
        g.clear();
        g.beginFill(0);
        g.drawRect(0, 0, WIDTH, Math.max(height, MIN_HEIGHT));
        g.endFill();

        _tf.x = (_modeSprite.width - _tf.width) * 0.5;
        _tf.y = (_modeSprite.height - _tf.height) * 0.5;

        if (_startButton != null) {
            _startButton.x = _modeSprite.width - _startButton.width - 10;
            _startButton.y = _modeSprite.height - _startButton.height - 10;
        }
    }

    protected function get curPattern () :Pattern
    {
        return (_patternIndex >= 0 && _patternIndex < _spectacle.numPatterns ?
            _spectacle.patterns[_patternIndex] : null);
    }

    protected static function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _spectacle :Spectacle;
    protected var _startButton :SimpleButton;
    protected var _tf :TextField;
    protected var _patternIndex :int = -1;

    protected var _startedPlaying :Boolean;
    protected var _patternView :SceneObject;
    protected var _spectacleOffset :PatternLoc;
    protected var _spectacleOffsetThrottler :MessageThrottler;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}

import com.whirled.contrib.simplegame.SimObject;
import flashmob.client.ClientContext;

// Throttles an individual type of message
class MessageThrottler extends SimObject
{
    public function MessageThrottler (msgName :String, minUpdateTime :Number = 1)
    {
        _msgName = msgName;
        _minUpdateTime = minUpdateTime;
    }

    public function set value (newValue :*) :void
    {
        _value = newValue;
        _messagePending = true;
        if (_timeTillNextMessage <= 0) {
            sendMessage();
        }
    }

    public function forcePendingMessage () :void
    {
        if (_messagePending) {
            sendMessage();
        }
    }

    protected function sendMessage () :void
    {
        ClientContext.outMsg.sendMessage(_msgName, _value);
        _messagePending = false;
        _timeTillNextMessage = _minUpdateTime;
    }

    override protected function update (dt :Number) :void
    {
        _timeTillNextMessage = Math.max(0, _timeTillNextMessage - dt);
        if (_messagePending && _timeTillNextMessage <= 0) {
            sendMessage();
        }
    }

    protected var _msgName :String;
    protected var _minUpdateTime :Number;

    protected var _value :*;
    protected var _messagePending :Boolean;

    protected var _timeTillNextMessage :Number = 0;
}
