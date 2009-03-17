package vampire.feeding.client {

import com.adobe.utils.DictionaryUtil;
import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.utils.Dictionary;

import vampire.feeding.net.CloseLobbyMsg;
import vampire.feeding.net.Props;

public class LobbyMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, 400, 300);
        g.endFill();

        _startButton = new SimpleTextButton("Start");
        registerListener(_startButton, MouseEvent.CLICK,
            function (...ignored) :void {
                if (_startButton.visible) {
                    ClientCtx.msgMgr.sendMessage(new CloseLobbyMsg());
                }
            });

        _startButton.x = 5;
        _startButton.y = 5;
        _modeSprite.addChild(_startButton);

        _tf = new TextField();
        _tf.x = 5;
        _tf.y = _startButton.y + _startButton.height + 5;

        registerListener(ClientCtx.props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        registerListener(ClientCtx.props, ElementChangedEvent.ELEMENT_CHANGED, onPropChanged);
    }

    protected function updateButton () :void
    {
        _startButton.visible =
            (ClientCtx.props.get(Props.LOBBY_LEADER) != null &&
             ClientCtx.props.get(Props.LOBBY_LEADER == ClientCtx.localPlayerId);
    }

    protected function updateText () :void
    {
        var playersText :String = "";
        var players :Dictionary = ClientCtx.props.get(Props.PLAYERS);
        if (players != null) {
            var needsBreak :Boolean;
            for each (var playerId :int in DictionaryUtil.getKeys(players)) {
                if (needsBreak) {
                    playersText += "\n";
                }

                playersText += ClientCtx.getPlayerName(playerId);
                needsBreak = true;
            }
        }

        TextBits.initTextField(_tf, playersText, 1.2, 250);
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (e.name == Props.PLAYERS) {
            updateText();
        } else if (e.name == Props.LOBBY_LEADER) {
            updateButton();
        }
    }

    protected var _tf :TextField;
    protected var _startButton :SimpleButton;

}

}
