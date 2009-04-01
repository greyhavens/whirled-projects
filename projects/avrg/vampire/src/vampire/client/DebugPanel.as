package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.avrg.DraggableSceneObject;

import fakeavrg.PropertyGetSubControlFake;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;

public class DebugPanel extends DraggableSceneObject
{
    public function DebugPanel()
    {
        super(ClientContext.ctrl);
        setup();
        init(new Rectangle(0,0,0,0), 0,0,0,0);
        centerOnViewableRoom();
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject():DisplayObject
    {
        return _displaySprite;
    }

    protected function setup() :void
    {
        _displaySprite.graphics.beginFill(0xffffff, 0.3);
        _displaySprite.graphics.drawRect(-50,-50,100,100);
        _displaySprite.graphics.endFill();

        var getBloodButton :SimpleTextButton = new SimpleTextButton("+Blood");
        getBloodButton.x = 10;
        getBloodButton.y = 50;
        getBloodButton.addEventListener(MouseEvent.CLICK, gainBlood);
        _menuSprite.addChild(getBloodButton);

        var loseBloodButton :SimpleTextButton = new SimpleTextButton("-Blood");
        loseBloodButton.x = getBloodButton.x + 50;
        loseBloodButton.y = getBloodButton.y;
        loseBloodButton.addEventListener(MouseEvent.CLICK, loseBlood);
        _menuSprite.addChild(loseBloodButton);

        var addLevelButton :SimpleTextButton = new SimpleTextButton("+Level");
        addLevelButton.x = getBloodButton.x;
        addLevelButton.y = getBloodButton.y + 50;
        addLevelButton.addEventListener(MouseEvent.CLICK, gainLevel);
        _menuSprite.addChild(addLevelButton);

        var loseLevelButton :SimpleTextButton = new SimpleTextButton("-Level");
        loseLevelButton.x = addLevelButton.x + 50;
        loseLevelButton.y = addLevelButton.y;
        loseLevelButton.addEventListener(MouseEvent.CLICK, loseLevel);
        _menuSprite.addChild(loseLevelButton);

        var addXPButton :SimpleTextButton = new SimpleTextButton("+XP");
        addXPButton.x = getBloodButton.x;
        addXPButton.y = loseLevelButton.y + 50;
        addXPButton.addEventListener(MouseEvent.CLICK, gainXP);
        _menuSprite.addChild(addXPButton);

        var loseXPButton :SimpleTextButton = new SimpleTextButton("-XP");
        loseXPButton.x = addXPButton.x + 50;
        loseXPButton.y = addXPButton.y;
        loseXPButton.addEventListener(MouseEvent.CLICK, loseXP);
        _menuSprite.addChild(loseXPButton);


        var addInviteButton :SimpleTextButton = new SimpleTextButton("+Invite");
        addInviteButton.x = getBloodButton.x;
        addInviteButton.y = loseXPButton.y + 50;
        addInviteButton.addEventListener(MouseEvent.CLICK, gainInvite);
        _menuSprite.addChild(addInviteButton);

        var loseInviteButton :SimpleTextButton = new SimpleTextButton("-Invite");
        loseInviteButton.x = addInviteButton.x + 50;
        loseInviteButton.y = addInviteButton.y;
        loseInviteButton.addEventListener(MouseEvent.CLICK, loseInvite);
        _menuSprite.addChild(loseInviteButton);


        var addAllBloodButton :SimpleTextButton = new SimpleTextButton("+20 Blood Room");
        addAllBloodButton.x = loseInviteButton.x;
        addAllBloodButton.y = addInviteButton.y + 50;
        registerListener(addAllBloodButton, MouseEvent.CLICK, function(...ignored) :void {
            ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_MESSAGE_DEBUG_GIVE_BLOOD_ALL_ROOM);
        });
        _menuSprite.addChild(addAllBloodButton);

        var resetMySireButton :SimpleTextButton = new SimpleTextButton("Reset Sire");
        resetMySireButton.x = addAllBloodButton.x;
        resetMySireButton.y = addAllBloodButton.y + 50;
        registerListener(resetMySireButton, MouseEvent.CLICK, function(...ignored) :void {
            ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_MESSAGE_DEBUG_RESET_MY_SIRE);
        });
        _menuSprite.addChild(resetMySireButton);

        _menuSprite.x = -_menuSprite.width / 2;
        _menuSprite.y = -_menuSprite.height / 2;
        _displaySprite.addChild(_menuSprite);
    }





    protected function gainBlood(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_BLOOD_UP);
        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentBlood :Number = ClientContext.model.blood;
            if(isNaN(currentBlood)) {
                currentBlood = 0;
            }
            currentBlood = Math.min(currentBlood + 10, ClientContext.model.maxblood);
            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, currentBlood);
        }
    }

    protected function loseBlood(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_BLOOD_DOWN);

        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentBlood :Number = ClientContext.model.blood;
            if(isNaN(currentBlood)) {
                currentBlood = 0;
            }
            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, Math.max(0,currentBlood - 10));
        }
    }

    protected function gainLevel(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_LEVEL_UP);

        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentLevel :Number = ClientContext.model.level;
            trace("currentLevel=" + currentLevel);
            var xpNeededForNextLevel :int = Logic.xpNeededForLevel(currentLevel + 1) - ClientContext.model.xp;
            trace("xpNeededForNextLevel=" + xpNeededForNextLevel);
            var invitesNeededForNextLevel :int = Logic.invitesNeededForLevel(currentLevel + 1);
            trace("invitesNeededForNextLevel=" + invitesNeededForNextLevel);
            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES, invitesNeededForNextLevel);
            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, ClientContext.model.xp + xpNeededForNextLevel);
        }
    }

    protected function loseLevel(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_LEVEL_DOWN);

        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentLevel :Number = ClientContext.model.level;
            if(currentLevel > 1) {
                var newXp :int = Logic.xpNeededForLevel(currentLevel - 1);
                props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, newXp);
            }

        }
    }

    protected function gainXP(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_ADD_XP);
        if(VConstants.LOCAL_DEBUG_MODE) {
            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);
            var currentXP:int = ClientContext.model.xp;
            var invites:int = ClientContext.model.invites;
            currentXP += 500;

            currentXP = Math.min(currentXP, Logic.maxXPGivenXPAndInvites(currentXP, invites));

            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP));
        }
    }

    protected function loseXP(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_LOSE_XP);
        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentXP:int = ClientContext.model.xp;
            var invites:int = ClientContext.model.invites;
            currentXP -= 500;

            currentXP = Math.min(currentXP, Logic.maxXPGivenXPAndInvites(currentXP, invites));

            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP));
        }
    }


    protected function gainInvite(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_ADD_INVITE);

        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentInvites:int = ClientContext.model.invites;

            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES, Math.max(0,currentInvites + 1));
            trace("Current invites=" + ClientContext.model.invites);
        }
    }

    protected function loseInvite(... ignored) :void
    {
        ClientContext.ctrl.agent.sendMessage(VConstants.NAMED_EVENT_LOSE_INVITE);
        if(VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentInvites:int = ClientContext.model.invites;

            props.setIn(Codes.playerRoomPropKey(ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES, Math.max(0,currentInvites - 1));
            trace("Current invites=" + ClientContext.model.invites);
        }
    }

    protected var _menuSprite :Sprite = new Sprite();
    public static const NAME :String = "IntroHelp";
}
}