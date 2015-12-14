package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.avrg.RoomDragger;
import com.threerings.flashbang.objects.DraggableObject;
import com.threerings.flashbang.objects.Dragger;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;

import vampire.data.Codes;
import vampire.data.VConstants;
import vampire.net.messages.DebugMsg;
import vampire.net.messages.SendGlobalMsg;
import vampire.net.messages.StatsMsg;
import vampire.quest.client.QuestClient;
import vampire.server.LogicServer;
import vampire.server.PlayerData;
import vampire.server.ServerContext;

public class AdminPanel extends DraggableObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        setup();
        x = 100;
        y = 100;
    }

//    override protected function update (dt:Number) :void
//    {
//        if (VConstants.LOCAL_DEBUG_MODE && _playerData != null) {
//            _playerData.update(dt);
//        }
//    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }


    override protected function get draggableObject () :InteractiveObject
    {
        return _draggableSprite;
    }

    override protected function createDragger () :Dragger
    {
        return new RoomDragger(ClientContext.ctrl, this.draggableObject, this.displayObject);
    }

    protected function setup() :void
    {

        if (VConstants.LOCAL_DEBUG_MODE) {
            _playerData = new PlayerData(ClientContext.ctrl.player);
            ServerContext.server.players.put(_playerData.playerId, _playerData);
        }


        var panelWidth :int = 300;
        _draggableSprite.graphics.beginFill(0xffffff);
        _draggableSprite.graphics.drawRect(0,0,panelWidth,400);
        _draggableSprite.graphics.endFill();
        _displaySprite.addChild(_draggableSprite);


        var closeButton :SimpleTextButton = new SimpleTextButton("Close");
        _menuSprite.addChild(closeButton);
        closeButton.x = panelWidth - closeButton.width;
        closeButton.y = 10;
        registerListener(closeButton, MouseEvent.CLICK, function (...ignored) :void {
            destroySelf();
        });



        var startX :int = 0;
        var startY :int = 50;


        var inputText :TextField = new TextField();
        inputText.type = TextFieldType.INPUT;
        inputText.wordWrap = true;
        inputText.multiline = true;
        inputText.width = 200;
        inputText.height = 50;
        inputText.backgroundColor = 0x000000;
        inputText.x = 25;
        inputText.y = 5;
        inputText.border = true;
        _menuSprite.addChild(inputText);

        var sendMessageButton :SimpleTextButton = new SimpleTextButton("Send global message");
        _menuSprite.addChild(sendMessageButton);
        sendMessageButton.x = inputText.x;
        sendMessageButton.y = inputText.y + inputText.height + 5;
        registerListener(sendMessageButton, MouseEvent.CLICK, function (...ignored) :void {
            if (inputText.text.length > 0) {
                ClientContext.ctrl.agent.sendMessage(SendGlobalMsg.NAME,
                    new SendGlobalMsg(inputText.text).toBytes());
                inputText.text = "";
            }
        });

        var sendPopupButton :SimpleTextButton = new SimpleTextButton("Send global popup");
        _menuSprite.addChild(sendPopupButton);
        sendPopupButton.x = sendMessageButton.x + sendMessageButton.width + 5;
        sendPopupButton.y = inputText.y + inputText.height + 5;
        registerListener(sendPopupButton, MouseEvent.CLICK, function (...ignored) :void {
            if (inputText.text.length > 0) {
                ClientContext.ctrl.agent.sendMessage(SendGlobalMsg.NAME,
                    new SendGlobalMsg(Codes.POPUP_PREFIX + inputText.text).toBytes());
                inputText.text = "";
            }
        });

        var addLevelButton :SimpleTextButton = new SimpleTextButton("+Level");
        addLevelButton.x = startX;
        addLevelButton.y = startY + 50;
        addLevelButton.addEventListener(MouseEvent.CLICK, gainLevel);
        _menuSprite.addChild(addLevelButton);

        var loseLevelButton :SimpleTextButton = new SimpleTextButton("-Level");
        loseLevelButton.x = addLevelButton.x + 50;
        loseLevelButton.y = addLevelButton.y;
        loseLevelButton.addEventListener(MouseEvent.CLICK, loseLevel);
        _menuSprite.addChild(loseLevelButton);

        var addXPButton :SimpleTextButton = new SimpleTextButton("+XP");
        addXPButton.x = startX;;
        addXPButton.y = loseLevelButton.y + 40;
        addXPButton.addEventListener(MouseEvent.CLICK, gainXP);
        _menuSprite.addChild(addXPButton);

        var loseXPButton :SimpleTextButton = new SimpleTextButton("-XP");
        loseXPButton.x = addXPButton.x + 50;
        loseXPButton.y = addXPButton.y;
        loseXPButton.addEventListener(MouseEvent.CLICK, loseXP);
        _menuSprite.addChild(loseXPButton);


        var addInviteButton :SimpleTextButton = new SimpleTextButton("+Invite");
        addInviteButton.x = startX;;
        addInviteButton.y = loseXPButton.y + 40;
        addInviteButton.addEventListener(MouseEvent.CLICK, gainInvite);
        _menuSprite.addChild(addInviteButton);

        var loseInviteButton :SimpleTextButton = new SimpleTextButton("-Invite");
        loseInviteButton.x = addInviteButton.x + 50;
        loseInviteButton.y = addInviteButton.y;
        loseInviteButton.addEventListener(MouseEvent.CLICK, loseInvite);
        _menuSprite.addChild(loseInviteButton);

        var statsButton :SimpleTextButton = new SimpleTextButton("Stats to flashlog");
        statsButton.x = addInviteButton.x;
        statsButton.y = addInviteButton.y + 50;
        statsButton.addEventListener(MouseEvent.CLICK, getStats);
        _menuSprite.addChild(statsButton);

        var resetScoresButton :SimpleTextButton = new SimpleTextButton("Reset scores");
        resetScoresButton.x = statsButton.x;
        resetScoresButton.y = statsButton.y + 50;
        registerListener(resetScoresButton, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.ctrl.agent.sendMessage(
                DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_RESET_HIGH_SCORES).toBytes());
        });
        _menuSprite.addChild(resetScoresButton);

        var getLineageButton :SimpleTextButton = new SimpleTextButton("Lineage to logs");
        getLineageButton.x = resetScoresButton.x;
        getLineageButton.y = resetScoresButton.y + 40;
        registerListener(getLineageButton, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.ctrl.agent.sendMessage(
                DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_GET_TOP_LINEAGE).toBytes());
        });
        _menuSprite.addChild(getLineageButton);

        var questDebugButton :SimpleTextButton = new SimpleTextButton("Quest Debug");
        questDebugButton.x = getLineageButton.x;
        questDebugButton.y = getLineageButton.y + 40;
        registerListener(questDebugButton, MouseEvent.CLICK, function (...ignored) :void {
            QuestClient.showDebugPanel(true);
        });
        _menuSprite.addChild(questDebugButton);

        _displaySprite.addChild(_menuSprite);
    }

    protected function getStats(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(StatsMsg.NAME, new StatsMsg().toBytes());
    }
    protected function gainLevel(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LEVEL_UP).toBytes());

        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.increaseLevel(_playerData);
        }
    }

    protected function loseLevel(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LEVEL_DOWN).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.decreaseLevel(_playerData);
        }
    }

    protected function gainXP(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_GAIN_XP).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.addXP(_playerData.playerId, 5000);
        }
    }

    protected function loseXP(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LOSE_XP).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.addXP(_playerData.playerId, -500);
        }
    }


    protected function gainInvite(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_ADD_INVITE).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            _playerData.addToInviteTally();
        }
    }

    protected function loseInvite(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LOSE_INVITE).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            _playerData.invites = Math.max(0, _playerData.invites - 1);
        }
    }

    protected var _playerData :PlayerData;
    protected var _displaySprite :Sprite = new Sprite();
    protected var _draggableSprite :Sprite = new Sprite();
    protected var _menuSprite :Sprite = new Sprite();
    public static const NAME :String = "IntroHelp";
}
}
