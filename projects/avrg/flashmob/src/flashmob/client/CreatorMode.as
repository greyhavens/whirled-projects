package flashmob.client {

import com.threerings.util.Log;
import com.whirled.avrg.*;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;
import flashmob.util.SpriteUtil;

public class CreatorMode extends GameDataMode
{
    override protected function setup () :void
    {
        _sprite = SpriteUtil.createSprite(true);
        _modeSprite.addChild(_sprite);

        _bg = SpriteUtil.createSprite(false, true);
        _sprite.addChild(_bg);
        addObject(new Dragger(_bg, _sprite));

        _tf = new TextField();
        _sprite.addChild(_tf);

        if (ClientContext.isPartyLeader) {
            _startButton = UIBits.createButton("Start!", 1.2);
            _snapshotButton = UIBits.createButton("Snapshot!", 1.2);
            _doneButton = UIBits.createButton("Done!", 1.2);

            registerListener(_startButton, MouseEvent.CLICK, onSnapshotClicked);
            registerListener(_snapshotButton, MouseEvent.CLICK, onSnapshotClicked);
            registerListener(_doneButton, MouseEvent.CLICK, onDoneClicked);

            _sprite.addChild(_snapshotButton);
            _sprite.addChild(_doneButton);

            _spectacle = new Spectacle();
            _spectacle.numPlayers = ClientContext.playerIds.length;
            _spectacle.creatingPartyId = ClientContext.partyId;
            _spectacle.avatarId = ClientContext.gameCtrl.player.getAvatarMasterItemId();
        }

        setText("Everybody! Arrange yourselves.");
        updateButtons();
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
        updateButtons();
    }

    protected function get canSnapshot () :Boolean
    {
        if (ClientContext.waitingForPlayers) {
            return false;
        } else if (_spectacle.numPatterns >= Constants.MAX_SPECTACLE_PATTERNS) {
            return false;
        } else if (_spectacle.numPatterns > 0 &&
                   ClientContext.timeNow - _lastSnapshotTime < Constants.MIN_SNAPSHOT_TIME) {
            return false;
        }

        return true;
    }

    protected function get canFinish () :Boolean
    {
        return (!_done && _spectacle.numPatterns >= Constants.MIN_SPECTACLE_PATTERNS);
    }

    protected function onSnapshotClicked (...ignored) :void
    {
        if (!this.canSnapshot) {
            return;
        }

        if (_timerView == null) {
            _timerView = new TimerView(0, true);
            _timerView.x = 300;
            _timerView.y = 20;
            addObject(_timerView, _modeSprite);
        }

        _timerView.time = 0;

        var now :Number = ClientContext.timeNow;
        var dt :Number = now - _lastSnapshotTime;

        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        pattern.timeLimit = (_spectacle.numPatterns == 0 ? 0 : Math.ceil(dt));
        for each (var playerId :int in ClientContext.playerIds) {
            var roomLoc :Point = ClientContext.getPlayerRoomLoc(playerId);
            pattern.locs.push(new PatternLoc(roomLoc.x, roomLoc.y));
        }

        _spectacle.patterns.push(pattern);
        _lastSnapshotTime = now;

        updateButtons();
    }

    protected function onDoneClicked (...ignored) :void
    {
        if (!this.canFinish) {
            return;
        }

        _doneButton.parent.removeChild(_doneButton);
        _doneButton = null;

        _snapshotButton.parent.removeChild(_snapshotButton);
        _snapshotButton = null;

        var namer :SpectacleNamer = new SpectacleNamer(onSpectacleNamed);
        var bounds :Rectangle = ClientContext.gameCtrl.local.getPaintableArea(false);
        namer.x = (bounds.width - namer.width) * 0.5;
        namer.y = (bounds.height - namer.height) * 0.5;
        addObject(namer, _modeSprite);

        function onSpectacleNamed (name :String) :void {
            namer.destroySelf();
            _spectacle.name = name;
            _spectacle.normalize();
            ClientContext.sendAgentMsg(Constants.MSG_C_DONECREATING, _spectacle.toBytes());
            _done = true;
            updateButtons();
        }
    }

    protected function updateButtons () :void
    {
        if (_doneButton != null) {
            _doneButton.visible = this.canFinish;
        }

        if (_snapshotButton != null) {
            _snapshotButton.visible = this.canSnapshot;
        }
    }

    protected function setText (text :String) :void
    {
        UIBits.initTextField(_tf, text, 1.2, WIDTH - 10, 0xFFFFFF, TextFormatAlign.LEFT);

        var height :Number =
            _tf.height + 10 + (_snapshotButton != null ? _snapshotButton.height : 0);

        var g :Graphics = _bg.graphics;
        g.clear();
        g.lineStyle(2, 0);
        g.beginFill(0, 0.7);
        g.drawRoundRect(0, 0, WIDTH, Math.max(height, MIN_HEIGHT), 15, 15);
        g.endFill();

        _tf.x = (_bg.width - _tf.width) * 0.5;
        _tf.y = (_bg.height - _tf.height) * 0.5;

        if (_snapshotButton != null && _doneButton != null) {
            _snapshotButton.x = _bg.width - _snapshotButton.width - 10;
            _snapshotButton.y = _bg.height - _snapshotButton.height - 10;
            _doneButton.x = _snapshotButton.x - _doneButton.width - 5;
            _doneButton.y = _bg.height - _doneButton.height - 10;
        }
    }

    protected function get log () :Log
    {
        return FlashMobClient.log;
    }

    protected var _sprite :Sprite;
    protected var _bg :Sprite;
    protected var _startButton :SimpleButton;
    protected var _snapshotButton :SimpleButton;
    protected var _doneButton :SimpleButton;
    protected var _tf :TextField;
    protected var _timerView :TimerView;

    protected var _spectacle :Spectacle;
    protected var _lastSnapshotTime :Number = 0;

    protected var _done :Boolean;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
