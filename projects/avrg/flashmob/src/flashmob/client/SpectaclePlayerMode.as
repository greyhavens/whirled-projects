package flashmob.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.net.MessageReceivedEvent;

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
        _tf = new TextField();
        _modeSprite.addChild(_tf);

        if (ClientContext.isLocalPlayerPartyLeader) {
            _startButton = UIBits.createButton("Start!", 1.2);
            registerListener(_startButton, MouseEvent.CLICK, onStartClicked);

            _modeSprite.addChild(_startButton);
        }

        setText("Get ready to pose!");
    }

    override public function onMsgReceived (e :MessageReceivedEvent) :void
    {
        switch (e.name) {
        case Constants.MSG_PLAYNEXTPATTERN:
            startNextPattern();
            break;
        }
    }

    protected function removePatternView () :void
    {
        if (_patternView != null) {
            _patternView.destroySelf();
            _patternView = null;
        }
    }

    protected function startNextPattern () :void
    {
        removePatternView();

        var pattern :Pattern = ClientContext.spectacle.patterns[++_patternIndex];
        _patternView = new PatternView(pattern);
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

    protected var _startButton :SimpleButton;
    protected var _tf :TextField;
    protected var _patternIndex :int = -1;

    protected var _patternView :SceneObject;

    protected static const WIDTH :Number = 400;
    protected static const MIN_HEIGHT :Number = 200;
}

}
