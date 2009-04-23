package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.avrg.RoomDragger;
import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.objects.Dragger;

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
import vampire.server.PlayerData;
import vampire.server.ServerContext;
import vampire.server.LogicServer;

public class AdminPanel extends DraggableObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        setup();
        ClientContext.centerOnViewableRoom(displayObject);
    }

    override protected function update (dt:Number) :void
    {
        if (VConstants.LOCAL_DEBUG_MODE && _playerData != null) {
            _playerData.update(dt);
        }
    }

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
        _draggableSprite.graphics.drawRect(0,0,panelWidth,300);
        _draggableSprite.graphics.endFill();
//        _draggableSprite.mouseEnabled = true;
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



//        var getBloodButton :SimpleTextButton = new SimpleTextButton("+Blood");
//        getBloodButton.x = 10;
//        getBloodButton.y = 50;
//        getBloodButton.addEventListener(MouseEvent.CLICK, gainBlood);
//        _menuSprite.addChild(getBloodButton);
//
//        var loseBloodButton :SimpleTextButton = new SimpleTextButton("-Blood");
//        loseBloodButton.x = startX; + 50;
//        loseBloodButton.y = getBloodButton.y;
//        loseBloodButton.addEventListener(MouseEvent.CLICK, loseBlood);
//        _menuSprite.addChild(loseBloodButton);

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
        resetScoresButton.addEventListener(MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.ctrl.agent.sendMessage(
                DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_RESET_HIGH_SCORES).toBytes());
        });
        _menuSprite.addChild(resetScoresButton);


//        var addAllBloodButton :SimpleTextButton = new SimpleTextButton("+20 Blood Room");
//        addAllBloodButton.x = loseInviteButton.x;
//        addAllBloodButton.y = addInviteButton.y + 50;
//        registerListener(addAllBloodButton, MouseEvent.CLICK, function(...ignored) :void {
//            ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_MESSAGE_DEBUG_GIVE_BLOOD_ALL_ROOM);
//        });
//        _menuSprite.addChild(addAllBloodButton);

//        var resetMySireButton :SimpleTextButton = new SimpleTextButton("Reset Sire");
//        resetMySireButton.x = addAllBloodButton.x;
//        resetMySireButton.y = addAllBloodButton.y + 50;
//        registerListener(resetMySireButton, MouseEvent.CLICK, function(...ignored) :void {
//            ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_MESSAGE_DEBUG_RESET_MY_SIRE);
//        });
//        _menuSprite.addChild(resetMySireButton);

//        _menuSprite.x = -_menuSprite.width / 2;
//        _menuSprite.y = -_menuSprite.height / 2;
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
//            var props :PropertySubControlFake = PropertySubControlFake(ClientContext.ctrl.player.props);
//            var currentLevel :Number = ClientContext.model.level;
//            var xpNeededForNextLevel :int = Logic.xpNeededForLevel(currentLevel + 1) - ClientContext.model.xp;
//            var invitesNeededForNextLevel :int = Logic.invitesNeededForLevel(currentLevel + 1);
//            props.set(Codes.PLAYER_PROP_XP, ClientContext.model.xp + xpNeededForNextLevel);
//            props.set(Codes.PLAYER_PROP_INVITES, invitesNeededForNextLevel);
        }
    }

    protected function loseLevel(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LEVEL_DOWN).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.decreaseLevel(_playerData);
//            var props :PropertySubControlFake = PropertySubControlFake(ClientContext.ctrl.player.props);
//            var currentLevel :Number = ClientContext.model.level;
//            if(currentLevel > 1) {
//                var newXp :int = Logic.xpNeededForLevel(currentLevel - 1);
//                props.set(Codes.PLAYER_PROP_XP, newXp);
//            }
        }
    }

    protected function gainXP(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_GAIN_XP).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.addXP(_playerData.playerId, 500);
//            var props :PropertySubControlFake = PropertySubControlFake(ClientContext.ctrl.player.props);
//            var currentXP:int = ClientContext.model.xp;
//            var invites:int = ClientContext.model.invites;
//            currentXP += 500;
//            currentXP = Math.min(currentXP, Logic.maxXPGivenXPAndInvites(currentXP, invites));
//            props.set(Codes.PLAYER_PROP_XP, Math.max(0,currentXP));
        }
    }

    protected function loseXP(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LOSE_XP).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            LogicServer.addXP(_playerData.playerId, -500);
//            var props :PropertySubControlFake = PropertySubControlFake(ClientContext.ctrl.player.props);
//            var currentXP:int = ClientContext.model.xp;
//            var invites:int = ClientContext.model.invites;
//            currentXP -= 500;
//            currentXP = Math.min(currentXP, Logic.maxXPGivenXPAndInvites(currentXP, invites));
//            props.set(Codes.PLAYER_PROP_XP, Math.max(0,currentXP));
        }
    }


    protected function gainInvite(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_ADD_INVITE).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            _playerData.addToInviteTally();
//            ServerLogic.Lo(_playerData.playerId, -500);
//            var props :PropertySubControlFake = PropertySubControlFake(ClientContext.ctrl.player.props);
//            var currentInvites:int = ClientContext.model.invites;
//            props.set(Codes.PLAYER_PROP_INVITES, Math.max(0,currentInvites + 1));
        }
    }

    protected function loseInvite(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(DebugMsg.NAME, new DebugMsg(DebugMsg.DEBUG_LOSE_INVITE).toBytes());
        if(VConstants.LOCAL_DEBUG_MODE) {
            _playerData.invites = Math.max(0, _playerData.invites - 1);
//            var props :PropertySubControlFake = PropertySubControlFake(ClientContext.ctrl.player.props);
//            var currentInvites:int = ClientContext.model.invites;
//            props.set(Codes.PLAYER_PROP_INVITES, Math.max(0,currentInvites + 1));
        }
    }

    protected var _playerData :PlayerData;
    protected var _displaySprite :Sprite = new Sprite();
    protected var _draggableSprite :Sprite = new Sprite();
    protected var _menuSprite :Sprite = new Sprite();
    public static const NAME :String = "IntroHelp";
}
}