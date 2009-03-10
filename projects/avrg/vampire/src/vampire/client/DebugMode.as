package vampire.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.objects.SceneObject;

import fakeavrg.PropertyGetSubControlFake;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.avatar.AvatarGameBridge;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.data.VConstants;

public class DebugMode extends SceneObject
{
    public function DebugMode()
    {
        setup()
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject():DisplayObject
    {
        return modeSprite;
    }

    protected function setup() :void
    {


        var getBloodButton :SimpleTextButton = new SimpleTextButton( "+Blood" );
        getBloodButton.x = 10;
        getBloodButton.y = 50;
        getBloodButton.addEventListener( MouseEvent.CLICK, gainBlood);
        modeSprite.addChild( getBloodButton );

        var loseBloodButton :SimpleTextButton = new SimpleTextButton( "-Blood" );
        loseBloodButton.x = getBloodButton.x + 50;
        loseBloodButton.y = getBloodButton.y;
        loseBloodButton.addEventListener( MouseEvent.CLICK, loseBlood);
        modeSprite.addChild( loseBloodButton );

        var addLevelButton :SimpleTextButton = new SimpleTextButton( "+Level" );
        addLevelButton.x = getBloodButton.x;
        addLevelButton.y = getBloodButton.y + 50;
        addLevelButton.addEventListener( MouseEvent.CLICK, gainLevel);
        modeSprite.addChild( addLevelButton );

        var loseLevelButton :SimpleTextButton = new SimpleTextButton( "-Level" );
        loseLevelButton.x = addLevelButton.x + 50;
        loseLevelButton.y = addLevelButton.y;
        loseLevelButton.addEventListener( MouseEvent.CLICK, loseLevel);
        modeSprite.addChild( loseLevelButton );

        var addXPButton :SimpleTextButton = new SimpleTextButton( "+XP" );
        addXPButton.x = getBloodButton.x;
        addXPButton.y = loseLevelButton.y + 50;
        addXPButton.addEventListener( MouseEvent.CLICK, gainXP);
        modeSprite.addChild( addXPButton );

        var loseXPButton :SimpleTextButton = new SimpleTextButton( "-XP" );
        loseXPButton.x = addXPButton.x + 50;
        loseXPButton.y = addXPButton.y;
        loseXPButton.addEventListener( MouseEvent.CLICK, loseXP);
        modeSprite.addChild( loseXPButton );

    }





    protected function gainBlood( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_BLOOD_UP );
        if( VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentBlood :Number = ClientContext.model.blood;
            if( isNaN( currentBlood )) {
                currentBlood = 0;
            }
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, currentBlood + 20);
        }
    }

    protected function loseBlood( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_BLOOD_DOWN );

        if( VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentBlood :Number = ClientContext.model.blood;
            if( isNaN( currentBlood )) {
                currentBlood = 0;
            }
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD, Math.max(0,currentBlood - 20));
        }
    }

    protected function gainLevel( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_LEVEL_UP );

        if( VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentLevel :Number = ClientContext.model.level;
            trace("currentLevel=" + currentLevel);
            var xpNeededForNextLevel :int = Logic.xpNeededForLevel( currentLevel + 1) - ClientContext.model.xp;
            trace("xpNeededForNextLevel=" + xpNeededForNextLevel);
            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, ClientContext.model.xp + xpNeededForNextLevel);
        }
    }

    protected function loseLevel( ... ignored ) :void
    {
        ClientContext.ctrl.agent.sendMessage( VConstants.NAMED_EVENT_LEVEL_DOWN );

        if( VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentLevel :Number = ClientContext.model.level;
            if( currentLevel > 1) {
                var newXp :int = Logic.xpNeededForLevel( currentLevel - 1 );
                props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, newXp);
            }

        }
    }

    protected function gainXP( ... ignored ) :void
    {

        if( VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentXP:int = ClientContext.model.xp;

            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP + 1000));
            trace("Current xp=" + ClientContext.model.xp);
        }
    }

    protected function loseXP( ... ignored ) :void
    {
        if( VConstants.LOCAL_DEBUG_MODE) {

            var props :PropertyGetSubControlFake = PropertyGetSubControlFake(ClientContext.ctrl.room.props);

            var currentXP:int = ClientContext.model.xp;

            props.setIn( Codes.playerRoomPropKey( ClientContext.ourPlayerId), Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP, Math.max(0,currentXP - 1000));
        }
    }

   protected var modeSprite :Sprite = new Sprite();
   public static const NAME :String = "IntroHelp";
}
}