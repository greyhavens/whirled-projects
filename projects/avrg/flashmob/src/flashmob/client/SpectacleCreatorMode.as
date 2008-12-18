package flashmob.client {

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class SpectacleCreatorMode extends GameDataMode
{
    override protected function setup () :void
    {
        _tf = new TextField();
        _modeSprite.addChild(_tf);

        if (ClientContext.isLocalPlayerPartyLeader) {
            _startButton = UIBits.createButton("Start!", 1.2);
            _snapshotButton = UIBits.createButton("Snapshot!", 1.2);
            _doneButton = UIBits.createButton("Done!", 1.2);

            registerListener(_startButton, MouseEvent.CLICK, onSnapshotClicked);
            registerListener(_snapshotButton, MouseEvent.CLICK, onSnapshotClicked);
            registerListener(_doneButton, MouseEvent.CLICK, onDoneClicked);

            _modeSprite.addChild(_snapshotButton);
            _modeSprite.addChild(_doneButton);
        }

        setText("Everybody! Arrange yourselves.");
        updateButtons();

        _timeCounter = new TimeCounter();
        addObject(_timeCounter);
    }

    override public function onMsgReceived (e :MessageReceivedEvent) :void
    {

    }

    protected function onSnapshotClicked (...ignored) :void
    {
        ClientContext.sendAgentMsg(Constants.MSG_SNAPSHOT);
        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        for each (var playerId :int in ClientContext.playerIds) {
            var info :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo(playerId);
            pattern.locs.push(new PatternLoc(info.x, info.y, info.z));
        }
        pattern.timeLimit = _timeCounter.time;
        _spectacle.patterns.push(pattern);

        updateButtons();
    }

    protected function onDoneClicked (...ignored) :void
    {

    }

    protected function updateButtons () :void
    {
        _doneButton.visible = _spectacle.numPatterns >= Constants.MIN_SPECTACLE_PATTERNS;
        _snapshotButton.visible = _spectacle.numPatterns < Constants.MAX_SPECTACLE_PATTERNS;
    }

    protected function setText (text :String) :void
    {
        UIBits.initTextField(_tf, text, 1.2, WIDTH - 10, 0xFFFFFF, TextFormatAlign.LEFT);

        var g :Graphics = _modeSprite.graphics;
        g.clear();
        g.beginFill(0);
        g.drawRect(0, 0, WIDTH, Math.max(_tf.height + _snapshotButton.height + 10, MIN_HEIGHT));
        g.endFill();

        _tf.x = (_modeSprite.width - _tf.width) * 0.5;
        _tf.y = (_modeSprite.height - _tf.height) * 0.5;

        if (_snapshotButton != null && _doneButton != null) {
            _snapshotButton.x = _modeSprite.width - _snapshotButton.width - 10;
            _snapshotButton.y = _modeSprite.height - _snapshotButton.height - 10;
            _doneButton.x = _snapshotButton.x - _doneButton.width - 5;
            _doneButton.y = _modeSprite.height - _doneButton.height - 10;
        }
    }

    protected var _spectacle :Spectacle = new Spectacle();
    protected var _startButton :SimpleButton;
    protected var _snapshotButton :SimpleButton;
    protected var _doneButton :SimpleButton;
    protected var _tf :TextField;
    protected var _timeCounter :TimeCounter;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}

import com.whirled.contrib.simplegame.SimObject;

class TimeCounter extends SimObject
{
    public function reset () :void
    {
        _time = 0;
    }

    public function start () :void
    {
        _running = true;
    }

    public function stop () :void
    {
        _running = false;
    }

    public function get time () :Number
    {
        return _time;
    }

    override protected function update (dt :Number) :void
    {
        if (_running) {
            _time += dt;
        }
    }

    protected var _time :Number = 0;
    protected var _running :Boolean;
}
