package flashmob.client {

import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
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
            _patternView = new PatternView(_spectacle.patterns[0]);
            addObject(_patternView, _modeSprite);

        } else {
            setText("Waiting for the party leader to start the spectacle!");
        }

        // init data bindings
        _dataBindings.bindMessage(Constants.MSG_PLAYNEXTPATTERN, startNextPattern);
        _dataBindings.bindProp(Constants.PROP_SPECTACLE_OFFSET, handleNewSpectacleOffset,
            PatternLoc.fromBytes);
        _dataBindings.processAllProperties(ClientContext.props);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (ClientContext.isPartyLeader && !_placedInitialPattern) {
            _patternView.x = _modeSprite.mouseX - (_patternView.width * 0.5);
            _patternView.y = _modeSprite.mouseY - (_patternView.height * 0.5);
        }
    }

    protected function handleNewSpectacleOffset (newOffset :PatternLoc) :void
    {
        log.info("handleNewSpectacleOffset", "newOffset", newOffset);
        _spectacleOffset = newOffset;

        if (!ClientContext.isPartyLeader) {

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
        _startedPlaying = true;

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
    protected var _placedInitialPattern :Boolean;
    protected var _spectacleOffset :PatternLoc;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
