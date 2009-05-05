package vampire.client
{
import com.threerings.flash.DisplayUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.avrg.RoomDragger;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.objects.Dragger;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SceneObjectPlayMovieClipOnce;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import vampire.Util;
import vampire.data.Codes;
import vampire.data.Logic;
import vampire.quest.client.QuestClient;

/**
 * The main game HUD, showing e.g. blood, game notifications, and buttons to select the subgame to
 * play.
 */
public class HUD extends DraggableObject
{
    public function HUD()
    {
//        super(ClientContext.ctrl, "HUD");
        _hudMC = ClientContext.instantiateMovieClip("HUD", "HUD", true);
        _hud = new Sprite();
        _hud.addChild(_hudMC);
        _displaySprite.addChild(_hud);
    }

    override protected function addedToDB() :void
    {
        super.addedToDB();

        setupUI();

        updateOurPlayerState();

        //Listen to events that might cause us to update ourselves
        registerListener(ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, updateOurPlayerState);
        registerListener(ClientContext.ctrl.player.props, PropertyChangedEvent.PROPERTY_CHANGED, handlePlayerPropChanged);
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return findSafely("draggable") as InteractiveObject;
    }

    override protected function createDragger () :Dragger
    {
        return new RoomDragger(ClientContext.ctrl, this.draggableObject, this.displayObject);
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected function handlePlayerPropChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        //Otherwise check for player updates
        var levelUp :SceneObjectPlayMovieClipOnce;
        var xpUp :SceneObjectPlayMovieClipOnce;
        var oldLevel :int;
        var newLevel :int;

        var mode :AppMode = ClientContext.gameMode;

        switch(e.name) {
            case Codes.PLAYER_PROP_XP:

                if (e.oldValue < e.newValue && !(isNaN(Number(e.oldValue)) || e.oldValue == 0)) {
                    xpUp = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "bloodup_feedback", true));
                    xpUp.x = _hudXP.x + ClientContext.model.maxblood/2;
                    xpUp.y = _hudXP.y;
                    mode.addSceneObject(xpUp, _hudXPParent);
                }
                _currentLevel = ClientContext.model.level;//Logic.levelGivenCurrentXpAndInvites(e.newValue, ClientContext.model.invites);

//                Logic.levelFromXp(Number(e.newValue));

                showXP(ClientContext.ourPlayerId);
                oldLevel = Logic.levelGivenCurrentXpAndInvites(Number(e.oldValue), ClientContext.model.invites);
                newLevel = Logic.levelGivenCurrentXpAndInvites(Number(e.newValue), ClientContext.model.invites);

                if (newLevel > oldLevel && newLevel >= 2 && e.oldValue > 0) {
                    ClientContext.controller.handleNewLevel(newLevel);

                    levelUp = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "levelup_feedback", true));
                    levelUp.x = _hudXP.x + ClientContext.model.maxblood/2;
                    levelUp.y = _hudXP.y;
                    mode.addSceneObject(levelUp, _hudXPParent);
                }



                //If we only need invite(s) for the next level, show a popup
                //if we haven't already done so.
                var level1moreXP :int = Logic.levelFromXp(Number(e.newValue) + 1);

                if (level1moreXP > newLevel && Logic.invitesNeededForLevel(level1moreXP) > 0) {

                    var invitesNeeded :int = Logic.invitesNeededForLevel(newLevel + 1);
                    var popup :PopupQuery = new PopupQuery(
                        "NeedInvites",
                        "You need " + Logic.invitesNeededForLevel(newLevel + 1) +
                        " invite" + (invitesNeeded > 1 ? "s" : "") + " for level " +
                        (newLevel + 1),
                        ["Recruit Now", "Recruit Later"],
                        [VampireController.RECRUIT, null]);


                    if (mode.getObjectNamed(popup.objectName) == null) {
                        mode.addSceneObject(popup, mode.modeSprite);
                        ClientContext.centerOnViewableRoom(popup.displayObject);
                        ClientContext.animateEnlargeFromMouseClick(popup);
                    }
                }
                break;


            case Codes.PLAYER_PROP_INVITES:

                if (_currentLevel < ClientContext.model.level) {
                    //Animate a level up movieclip
                    levelUp = new SceneObjectPlayMovieClipOnce(
                        ClientContext.instantiateMovieClip("HUD", "levelup_feedback", true));
                    levelUp.x = _hudXP.x + ClientContext.model.maxblood/2;
                    levelUp.y = _hudXP.y;
                    if (mode != null && _hudXPParent != null) {
                        mode.addSceneObject(levelUp, _hudXPParent);
                    }

                    ClientContext.controller.handleNewLevel(ClientContext.model.level);

                }
                _currentLevel = ClientContext.model.level;
                showXP(ClientContext.ourPlayerId);
                break;

            case Codes.PLAYER_PROP_BLOODBOND:

                if (e.newValue != 0) {
                    var bloodBondMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "bloodbond_feedback", true));
                    bloodBondMovie.x = _hudXP.x + ClientContext.model.maxblood/2;
                    bloodBondMovie.y = _hudXP.y;

                    if (mode != null) {
                        mode.addSceneObject(bloodBondMovie, _hudXPParent);
                    }
                }
                break;


            case Codes.PLAYER_PROP_SIRE:
                if (e.newValue != 0) {
                    var lineageMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "lineage_feedback", true));
                    lineageMovie.x = _hudXP.x + ClientContext.model.maxblood/2;
                    lineageMovie.y = _hudXP.y;
                    if (mode != null) {
                        mode.addSceneObject(lineageMovie, _displaySprite);
                    }
                }
                break;

            default:
        }
    }
//    protected function handleRoomPropChanged (e :PropertyChangedEvent) :void
//    {
//
//    }

    public function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }


    protected function setupUI() :void
    {

        //Center the hud graphic
        _hudMC.x = -_hudMC.width/2;
        _hudMC.y = -_hudMC.height/2;

        //Start the HUD positioned at the top left, making sure nothing is hidden.
        this.x = _hudMC.width / 2 + 60;
        this.y = _hudMC.height / 2 + 50;

        _hudMC.mouseChildren = true;
        _hudMC.mouseEnabled = true;
        _hudXP = new Sprite();

        var splat :DisplayObject = findSafely("splat");
        _hudXPParent = splat.parent;
        _hudXPParent.addChildAt(_hudXP, _hudXPParent.getChildIndex(splat) + 1);

        _hudXP.x = draggableObject.x;
        _hudXP.y = draggableObject.y;

        _bloodXPMouseOverSprite = new Sprite();
        _bloodXPMouseOverSceneObject = new SimpleSceneObject(_bloodXPMouseOverSprite, "MouseOverBlood");
        _bloodXPMouseOverSceneObject.x = _hudXP.x;
        _bloodXPMouseOverSceneObject.y = _hudXP.y;
        _bloodXPMouseOverSceneObject.alpha = 0;

        registerListener(_bloodXPMouseOverSprite, MouseEvent.ROLL_OVER, function(...ignored) :void {
            _bloodXPMouseOverSceneObject.addTask(AlphaTask.CreateEaseIn(1, 0.3));
        });
        registerListener(_bloodXPMouseOverSprite, MouseEvent.ROLL_OUT, function(...ignored) :void {
            _bloodXPMouseOverSceneObject.addTask(AlphaTask.CreateEaseIn(0, 0.3));
        });

        _hudXPParent.addChildAt(_bloodXPMouseOverSprite, _hudXPParent.getChildIndex(_hudXP) + 1);
        db.addObject(_bloodXPMouseOverSceneObject);

        var hudHelp :SimpleButton = SimpleButton(findSafely("button_menu"));
        Command.bind(hudHelp, MouseEvent.CLICK, VampireController.SHOW_INTRO);

        var hudClose :SimpleButton = SimpleButton(findSafely("button_quit"));
        Command.bind(hudClose, MouseEvent.CLICK, VampireController.QUIT_POPUP);

        var hudFeed :SimpleButton = SimpleButton(findSafely("button_feed"));
        Command.bind(hudFeed, MouseEvent.CLICK, VampireController.FEED);

//        var hudQuests :SimpleButton = SimpleButton(findSafely("button_quests"));
//        registerListener(hudQuests, MouseEvent.CLICK, function (...ignored) :void {
//            QuestClient.showQuestPanel();
//        });
    }

    protected function createXPText() :void
    {
        if (_xpText != null && _xpText.parent != null) {
            _xpText.parent.removeChild(_xpText);
        }

        TextField(findSafely("level_field")).text = "" + ClientContext.model.level;

        var xpNeededForCurrentLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level);
        var xpNeededForNextLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level + 1);
        var xpGap :Number = xpNeededForNextLevel - xpNeededForCurrentLevel;
        var ourXPForOurLevel :Number = ClientContext.model.xp - xpNeededForCurrentLevel;

        _xpText = new TextField();
        _xpText.text = Util.formatNumberForFeedback(ourXPForOurLevel) + " / " + xpGap;

            _xpText.selectable = false;
            _xpText.tabEnabled = false;
            _xpText.embedFonts = true;
            _xpText.mouseEnabled = false;

            var lineageformat :TextFormat = new TextFormat();
            lineageformat.font = "ArnoProLight";
            lineageformat.size = 14;
            lineageformat.align = TextFormatAlign.LEFT;
            lineageformat.bold = false;
            lineageformat.color = 0xffffff;
            _xpText.width = 180;
            _xpText.height = 20;
            _xpText.antiAliasType = AntiAliasType.ADVANCED;
            _xpText.setTextFormat(lineageformat);

        _bloodXPMouseOverSprite.addChild(_xpText);


//        _xpText.x = ClientContext.model.maxblood/2 - _xpText.getLineMetrics(0).width/2;
        _xpText.x = 10;
        _xpText.y = 2;

    }

    override protected function update(dt:Number):void
    {
        super.update(dt);
        _timeSinceStart += dt;

    }

    protected function updateOurPlayerState(...ignored) :void
    {
        showXP(ClientContext.ourPlayerId);
    }


    protected function showXP(playerId :int) :void
    {
        //Use the blood scale for the xp scale
        var maxBlood :Number = ClientContext.model.maxblood;
        var xp :int = ClientContext.model.xp;
        var invites :int = ClientContext.model.invites;

        var level :int = Logic.levelGivenCurrentXpAndInvites(xp, invites);

        var xpNeededForNextLevel :int = Logic.xpNeededForLevel(level + 1);
        var xpNeededForLevel :int = Logic.xpNeededForLevel(level);

        var xpOverCurrentLevelMinimum :Number = xp - xpNeededForLevel;
        var xpDifference :int = xpNeededForNextLevel - xpNeededForLevel;

        var xpFraction :Number = xpOverCurrentLevelMinimum / xpDifference;
        var xpAbsoluteX :int = maxBlood * xpFraction;
        var borderWidth :int = 3;
        //Draw the xp bar
        //Xp
        _hudXP.graphics.clear();
        //Draw the background panel
        _hudXP.graphics.beginFill(0x330000, 0.5);
        _hudXP.graphics.drawRect(0, 1, maxBlood + 1, BLOOD_BAR_HEIGHT - 3);

        _hudXP.graphics.beginFill(0x990000);
        _hudXP.graphics.drawRect(0, 1, xpAbsoluteX, BLOOD_BAR_HEIGHT - 3);
        _hudXP.graphics.endFill();
        //Highlight
        if (xpOverCurrentLevelMinimum >= 1) {
            _hudXP.graphics.lineStyle(2, 0xff00000);
            _hudXP.graphics.moveTo(xpAbsoluteX , 2);
            _hudXP.graphics.lineTo(xpAbsoluteX , BLOOD_BAR_HEIGHT -2);
        }
        //Border
        _hudXP.graphics.lineStyle(borderWidth, 0);
        _hudXP.graphics.drawRect(0, borderWidth - 2, maxBlood + borderWidth - 1, BLOOD_BAR_HEIGHT - (borderWidth * 2 - 2));

        //Change mouse click capturing sprite
        _bloodXPMouseOverSprite.graphics.clear();
        _bloodXPMouseOverSprite.graphics.beginFill(0, 0);
        _bloodXPMouseOverSprite.graphics.drawRect(0, 0, _hudXP.width, _hudXP.height);
        _bloodXPMouseOverSprite.graphics.endFill();
        _bloodXPMouseOverSprite.x = _hudXP.x;
        _bloodXPMouseOverSprite.y = _hudXP.y;
        createXPText();

        //Shine
        var shine :MovieClip = findSafely("shine_blood") as MovieClip;
        if (shine != null) {
            shine.width = maxBlood - 20 - _xpText.width;
            shine.x = _xpText.width + 10;
            shine.y = 16;
            _bloodXPMouseOverSprite.parent.addChildAt(shine,
                _bloodXPMouseOverSprite.parent.numChildren - 2);
        }
    }

    //Debugging purposes
    protected static function generateRandomString(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String
    {
        var alphabet:Array = userAlphabet.split("");
        var alphabetLength:int = alphabet.length;
        var randomLetters:String = "";
        for (var i:uint = 0; i < newLength; i++){
            randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
        }
        return randomLetters;
    }

    protected var _hud :Sprite;
    protected var _hudMC :MovieClip;


    protected var _hudXP :Sprite;
    protected var _bloodXPMouseOverSprite :Sprite;
    protected var _bloodXPMouseOverSceneObject :SceneObject;
    protected var _hudXPParent :DisplayObjectContainer;


    //Used for anchoring the bars.
    protected var _hudCapStartX :int;

    protected var _bloodText :TextField;
    protected var _xpText :TextField;

    protected var _displaySprite :Sprite = new Sprite();

    /**Used for registering changed level to animate a level up movieclip*/
    protected var _currentLevel :int = -0;
    protected var _currentBlood :Number = 1;

    protected var _timeSinceStart :Number = 0;

    protected static const BLOOD_SCALE_MULTIPLIER :Number = 2.2;
    protected static const BLOOD_BAR_HEIGHT :int = 51;
    public static const NAME :String = "HUD";
    protected static const log :Log = Log.getLog(HUD);
}

}
