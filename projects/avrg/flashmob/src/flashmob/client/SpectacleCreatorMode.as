package flashmob.client {

import com.whirled.avrg.AVRGameAvatar;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import flashmob.*;
import flashmob.client.view.*;
import flashmob.data.*;

public class SpectacleCreatorMode extends AppMode
{
    override protected function setup () :void
    {
        _tf = new TextField();
        _modeSprite.addChild(_tf);

        if (ClientContext.isLocalPlayerPartyLeader) {
            _snapshotButton = UIBits.createButton("Snapshot!", 1.2);
            _doneButton = UIBits.createButton("Done!", 1.2);

            registerListener(_snapshotButton, MouseEvent.CLICK, onSnapshotClicked);
            registerListener(_doneButton, MouseEvent.CLICK, onDoneClicked);

            _modeSprite.addChild(_snapshotButton);
            _modeSprite.addChild(_doneButton);
        }

        setText("Everybody! Arrange yourselves.");
        updateButtons();
    }

    protected function onSnapshotClicked (...ignored) :void
    {
        // capture the locations of all the players
        var pattern :Pattern = new Pattern();
        for each (var playerId :int in ClientContext.playerIds) {
            var info :AVRGameAvatar = ClientContext.gameCtrl.room.getAvatarInfo(playerId);
            pattern.locs.push(new PatternLoc(info.x, info.y, info.z));
        }

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
    protected var _snapshotButton :SimpleButton;
    protected var _doneButton :SimpleButton;
    protected var _tf :TextField;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
