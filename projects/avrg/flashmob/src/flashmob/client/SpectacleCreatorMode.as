package flashmob.client {

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
    }

    override public function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == Constants.MSG_SNAPSHOTACK) {
            _waitingForSnapshotResponse = false;
            _numSnapshots++;
            updateButtons();

        } else if (e.name == Constants.MSG_SNAPSHOTERR) {
            _waitingForSnapshotResponse = false;
            updateButtons();
        }
    }

    protected function get canSnapshot () :Boolean
    {
        if (_numSnapshots >= Constants.MAX_SPECTACLE_PATTERNS) {
            return false;
        } else if (_waitingForSnapshotResponse) {
            return false;
        } else if (_numSnapshots > 0 &&
                   ClientContext.timeNow - _lastSnapshotTime < Constants.MIN_SNAPSHOT_TIME) {
            return false;
        }

        return true;
    }

    protected function get canFinish () :Boolean
    {
        return (!_done && _numSnapshots >= Constants.MIN_SPECTACLE_PATTERNS);
    }

    protected function onSnapshotClicked (...ignored) :void
    {
        ClientContext.sendAgentMsg(Constants.MSG_SNAPSHOT);
        _waitingForSnapshotResponse = true;
        updateButtons();
    }

    protected function onDoneClicked (...ignored) :void
    {
        ClientContext.sendAgentMsg(Constants.MSG_DONECREATING, "A Spectacle!");
        _done = true;
        updateButtons();
    }

    protected function updateButtons () :void
    {
        _doneButton.visible = this.canFinish;
        _snapshotButton.visible = this.canSnapshot;
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

    protected var _startButton :SimpleButton;
    protected var _snapshotButton :SimpleButton;
    protected var _doneButton :SimpleButton;
    protected var _tf :TextField;

    protected var _numSnapshots :int;
    protected var _waitingForSnapshotResponse :Boolean;
    protected var _lastSnapshotTime :Number = 0;

    protected var _done :Boolean;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
