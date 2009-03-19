package vampire.client
{
import com.threerings.flash.DisplayUtil;
import com.threerings.flash.MathUtil;
import com.threerings.flash.TextFieldUtil;
import com.threerings.util.Command;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.contrib.avrg.DraggableSceneObject;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SceneObjectPlayMovieClipOnce;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import vampire.Util;
import vampire.client.events.PlayerStateChangedEvent;
import vampire.data.Codes;
import vampire.data.Logic;

/**
 * The main game HUD, showing e.g. blood, game notifications, and buttons to select the subgame to
 * play.
 */
public class HUD extends DraggableSceneObject
{
    public function HUD()
    {
        super( ClientContext.ctrl, "HUD");

        setupUI();

        //Listen to events that might cause us to update ourselves
        registerListener( ClientContext.ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, updateOurPlayerState );
        registerListener( ClientContext.ctrl.room.props, PropertyChangedEvent.PROPERTY_CHANGED, propChanged );
        registerListener( ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
//        registerListener( ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);


        updateOurPlayerState();
    }

    override protected function addedToDB() :void
    {
        mode.addObject(_bloodXPMouseOverSceneObject );
    }

    protected function get mode() :AppMode
    {
        return db as AppMode;
    }

//    protected function handleMessageReceived( e :MessageReceivedEvent ) :void
//    {
//        if( e.name == VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN ) {
//            var bb :BloodBloomGameRecord = BloodBloomGameRecord.fromArray( e.value as Array );
//        }
//    }

    override protected function destroyed () :void
    {
        super.destroyed();
        _bloodXPMouseOverSceneObject.destroySelf();
    }

    override public function get objectName () :String
    {
        return "HUD";
    }

    protected function propChanged (e :PropertyChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        //Otherwise check for player updates

        switch( e.name ) {
            case Codes.ROOM_PROP_MINION_HIERARCHY:
                break;
            case Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE:
                break;

            case Codes.ROOM_PROP_FEEDBACK:
                var messages :Array = e.newValue as Array;
                if( messages != null ) {
                    for each( var m :Array in messages ) {
                        var forPlayer :int = int(m[0]);
                        var msg :String = m[1] as String;
                        if( forPlayer <= 0 || forPlayer == ClientContext.ourPlayerId ) {
                            _feedbackMessageQueue.push( msg );
                            if( forPlayer == 23340 ) {
                                trace(msg);
                            }
                        }
                    }
                }
                break;

            default:
                var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );

                if( isNaN(playerIdUpdated) ) {
                    log.warning("propChanged, but no player id, ", "e", e);
                    return;
                }

                //If the ROOM_PROP_NON_PLAYERS prop is changed, update it
                if( playerIdUpdated == ClientContext.ourPlayerId) {
                    updateOurPlayerState();
                }
        }

    }

    protected function elementChanged (e :ElementChangedEvent) :void
    {
        //Check if it is non-player properties changed??
        //Otherwise check for player updates
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
        var levelUp :SceneObjectPlayMovieClipOnce;
        var oldLevel :int;
        var newLevel :int;


        if( !isNaN( playerIdUpdated ) ) {
            //If it's us, update the player HUD
            if( playerIdUpdated == ClientContext.ourPlayerId) {

//                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
//
//                    if( e.oldValue < e.newValue) {
//                        var bloodUp :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
//                                ClientContext.instantiateMovieClip("HUD", "bloodup_feedback", true) );
//                        bloodUp.x = _hudBlood.x + ClientContext.model.maxblood/2;
//                        bloodUp.y = _hudBlood.y;
//                        mode.addSceneObject( bloodUp, _hudBlood.parent  );
//                    }
//                    showBlood( ClientContext.ourPlayerId );
//                }
                if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP) {


//                    oldLevel = Logic.levelGivenCurrentXpAndInvites(Number(e.oldValue), ClientContext.model.invites);
//                    newLevel = Logic.levelGivenCurrentXpAndInvites(Number(e.newValue), ClientContext.model.invites);
//                    if( oldLevel < newLevel) {
                    if( e.oldValue < e.newValue) {
                        levelUp = new SceneObjectPlayMovieClipOnce(
                                ClientContext.instantiateMovieClip("HUD", "levelup_feedback", true) );
                        levelUp.x = _hudXP.x + ClientContext.model.maxblood/2;
                        levelUp.y = _hudXP.y;
                        mode.addSceneObject( levelUp, _hudXP.parent  );
                    }
                    _currentLevel = ClientContext.model.level;

                    showXP( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_INVITES) {


//                    oldLevel = Logic.levelGivenCurrentXpAndInvites(ClientContext.model.xp, int(e.oldValue));
//                    newLevel = Logic.levelGivenCurrentXpAndInvites(ClientContext.model.xp, int(e.newValue));
//                    if( oldLevel < newLevel) {
//                        levelUp = new SceneObjectPlayMovieClipOnce(
//                                ClientContext.instantiateMovieClip("HUD", "levelup_feedback", true) );
//                        levelUp.x = _hudBlood.x + ClientContext.model.maxblood/2;
//                        levelUp.y = _hudBlood.y;
//                        mode.addSceneObject( levelUp, _hudBlood.parent  );
//                    }


                    if( _currentLevel < ClientContext.model.level) {
                        //Animate a level up movieclip
                        levelUp = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "levelup_feedback", true) );
                        levelUp.x = _hudXP.x + ClientContext.model.maxblood/2;
                        levelUp.y = _hudXP.y;
                        mode.addSceneObject( levelUp, _hudXP.parent );
                    }
                    _currentLevel = ClientContext.model.level;

                    showXP( ClientContext.ourPlayerId );
                }
                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {

                    if( e.newValue != 0) {
                        var bloodBondMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                                ClientContext.instantiateMovieClip("HUD", "bloodbond_feedback", true) );
                        bloodBondMovie.x = _hudBlood.x + ClientContext.model.maxblood/2;
                        bloodBondMovie.y = _hudBlood.y;
                        mode.addSceneObject( bloodBondMovie, _hudBlood.parent  );
                    }

                }

                else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_SIRE) {
                    if( e.newValue != 0) {
                        var lineageMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                                ClientContext.instantiateMovieClip("HUD", "lineage_feedback", true) );
                        lineageMovie.x = _hudBlood.x + ClientContext.model.maxblood/2;
                        lineageMovie.y = _hudBlood.y;
                        mode.addSceneObject( lineageMovie, _displaySprite );
                    }
                }

            }
        }


        else {
            log.error("isNaN( " + playerIdUpdated + " ), failed to update ElementChangedEvent" + e);
        }

    }


    protected function checkPlayerRoomProps( ...ignored) :void
    {
        if( !SharedPlayerStateClient.isProps( ClientContext.ourPlayerId )) {
        }
        else {
            updateOurPlayerState();
        }
    }

    protected function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }


    protected function setupUI() :void
    {

        _hud = new Sprite();
        _displaySprite.addChild( _hud );

        _hudMC = ClientContext.instantiateMovieClip("HUD", "HUD", true);
        _hud.addChild( _hudMC );
        //Center the hud graphic
        _hudMC.x = -_hudMC.width/2;
        _hudMC.y = -_hudMC.height/2;

        init( new Rectangle(-_hudMC.width/2, _hudMC.height/2, _hudMC.width, _hudMC.height), 0, 0, 0, 100);


        this.x = _hudMC.width  ;
        this.y = _hudMC.height;

        _hudMC.mouseChildren = true;
        _hudMC.mouseEnabled = false;

        _hudCap = MovieClip( findSafely("HUDcap") );
        //Store the x as the x anchor for the blood and xp bars.
        _hudCapStartX = _hudCap.x;


//        _hudBlood = new Sprite();
//        _hudCap.parent.addChild( _hudBlood );
//        _hudBlood.x = _hudCap.x - _hudCap.width/2;
//        _hudBlood.y = _hudCap.y - (_hudCap.height/2 + 1);

        _hudXP = new Sprite();
        _hudCap.parent.addChild( _hudXP );
        _hudXP.x = _hudCap.x;
        _hudXP.y = _hudCap.y;
        _hudCap.parent.removeChild(_hudCap);

        var bloodXPMouseOverSprite :Sprite = new Sprite();
        _bloodXPMouseOverSceneObject = new SimpleSceneObject( bloodXPMouseOverSprite, "MouseOverBloood" );
        _bloodXPMouseOverSceneObject.x = _hudXP.x;
        _bloodXPMouseOverSceneObject.y = _hudXP.y;
        _bloodXPMouseOverSceneObject.alpha = 0;

        registerListener( bloodXPMouseOverSprite, MouseEvent.ROLL_OVER, function(...ignored) :void {
            _bloodXPMouseOverSceneObject.addTask( AlphaTask.CreateEaseIn(1, 0.3));
        });
        registerListener( bloodXPMouseOverSprite, MouseEvent.ROLL_OUT, function(...ignored) :void {
            _bloodXPMouseOverSceneObject.addTask( AlphaTask.CreateEaseIn(0, 0.3));
        });

        _hudXP.parent.addChild(bloodXPMouseOverSprite );

        var hudHelp :SimpleButton = SimpleButton( findSafely("button_menu") );
        Command.bind( hudHelp, MouseEvent.CLICK, VampireController.SHOW_INTRO);

        var hudClose :SimpleButton = SimpleButton( findSafely("button_quit") );
        Command.bind( hudClose, MouseEvent.CLICK, VampireController.QUIT);

        var hudFeed :SimpleButton = SimpleButton( findSafely("button_feed") );
        Command.bind( hudFeed, MouseEvent.CLICK, VampireController.FEED);


    }


    protected function createBloodText() :void
    {
        if( _bloodText != null && _bloodText.parent != null ) {
            _bloodText.parent.removeChild( _bloodText );
        }

//        if( _bloodText == null ) {
            _bloodText = new TextField();//TextFieldUtil.createField(

            _bloodText.selectable = false;
            _bloodText.tabEnabled = false;
//            _bloodText.embedFonts = true;
            _bloodText.mouseEnabled = false;
            var lineageformat :TextFormat = new TextFormat();
    //        lineageformat.font = "JuiceEmbedded";
//            lineageformat.size = 14;
//            lineageformat.align = TextFormatAlign.LEFT;
    //        lineageformat.bold = true;
            _bloodText.textColor = 0xffffff;
            _bloodText.width = 80;
            _bloodText.height = 20;
//            _bloodText.setTextFormat( lineageformat );

            Sprite(_bloodXPMouseOverSceneObject.displayObject).addChild( _bloodText );
//        }

            _bloodText.text =
                Util.formatNumberForFeedback(ClientContext.model.blood) + " / " +
                ClientContext.model.maxblood;

//        _bloodText.antiAliasType = AntiAliasType.ADVANCED;


//        _bloodText.alpha = 0;
        _bloodText.x = ClientContext.model.maxblood/2 - _bloodText.getLineMetrics(0).width/2;
        _bloodText.y = _hudBlood.height/2 - _bloodText.getLineMetrics(0).height/2;

    }

    protected function createXPText() :void
    {
        if( _xpText != null && _xpText.parent != null ) {
            _xpText.parent.removeChild( _xpText );
        }

        TextField(findSafely("level_field")).text = "" + ClientContext.model.level;
        TextField(findSafely("level_field")).selectable = false;

        var xpNeededForCurrentLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level);
        var xpNeededForNextLevel :Number = Logic.xpNeededForLevel(ClientContext.model.level + 1);
        var xpGap :Number = xpNeededForNextLevel - xpNeededForCurrentLevel;
        var ourXPForOurLevel :Number = ClientContext.model.xp - xpNeededForCurrentLevel;

        _xpText = TextFieldUtil.createField(
            Util.formatNumberForFeedback(ourXPForOurLevel) + " / " + xpGap );

            _xpText.selectable = false;
            _xpText.tabEnabled = false;
//            _xpText.embedFonts = true;
            _xpText.mouseEnabled = false;

            var lineageformat :TextFormat = new TextFormat();
//            lineageformat.font = "JuiceEmbedded";
            lineageformat.size = 12;
            lineageformat.align = TextFormatAlign.LEFT;
            lineageformat.bold = false;
            lineageformat.color = 0;
            _xpText.width = 180;
            _xpText.height = 20;
//            _mouseOverText.x = 100;
//            _mouseOverText.y = 0;
            _xpText.antiAliasType = AntiAliasType.ADVANCED;
            _xpText.setTextFormat( lineageformat );

        Sprite(_bloodXPMouseOverSceneObject.displayObject).addChild( _xpText );
//        Sprite(_bloodXPMouseOverSceneObject.displayObject).addChild( _xpText );


        _xpText.x = ClientContext.model.maxblood/2 - _xpText.getLineMetrics(0).width/2;
        _xpText.y = _hudCap.height / 2  - _xpText.getLineMetrics(0).height/2;

//        _xpText.addEventListener( MouseEvent.ROLL_OUT


    }

    override protected function update(dt:Number):void
    {
        super.update(dt);

        //Show feedback in the local client only feedback
        if( _feedbackMessageQueue.length > 0 ){
            for each( var msg :String in _feedbackMessageQueue) {
                _ctrl.local.feedback( msg );
            }
            _feedbackMessageQueue.splice(0);
        }

        //Show feedback messages in queue, and fade out old messages.
//        if( _feedbackMessageQueue.length > 0 && db != null) {
//            _feedbackMessageTimeElapsed += dt;
//
//            //Don't replace the current message if it's still there, it might have been inserted
//            //due to instant feedback
//            if( _feedbackMessageTimeElapsed >= VConstants.TIME_FEEDBACK_MESSAGE_DISPLAY &&
//                db.getObjectNamed( FEEDBACK_SIMOBJECT_NAME ) == null ) {
//                _feedbackMessageTimeElapsed = 0;
//                var feedbackMessage :String = _feedbackMessageQueue.shift() as String;
//
//                if( feedbackMessage != null ) {
//                    insertFeedbackSceneObject( feedbackMessage );
//
//                }
//            }
//        }

//        if( VConstants.LOCAL_DEBUG_MODE ) {
//            _DEBUGGING_add_feedback_timer += dt;
//            if( _DEBUGGING_add_feedback_timer > 2 ) {
//                _DEBUGGING_add_feedback_timer = 0;
//
//                _feedbackMessageQueue.push(generateRandomString(Rand.nextIntRange(50, 100, 0)));
//            }
//        }
    }

//    protected function insertFeedbackSceneObject2( feedbackMessage :String ) :void
//    {
//        var textSprite :Sprite = new Sprite();
//
//        var feedbackMessageTextField :TextField =
//            TextFieldUtil.createField(feedbackMessage);
//        feedbackMessageTextField.selectable = false;
//        feedbackMessageTextField.tabEnabled = false;
////        feedbackMessageTextField.embedFonts = true;
//
//
//        var lineageformat :TextFormat = new TextFormat();
////        lineageformat.font = "JuiceEmbedded";
//        lineageformat.size = 20;
//        lineageformat.color = 0xffffff;
//        lineageformat.align = TextFormatAlign.LEFT;
////        lineageformat.bold = true;
//        feedbackMessageTextField.setTextFormat( lineageformat );
//        feedbackMessageTextField.textColor = 0xffffff;
//        feedbackMessageTextField.width = Math.min( feedbackMessageTextField.textWidth + 10, 300);
//        feedbackMessageTextField.height = 80;
////        feedbackMessageTextField.x = -350 + feedbackMessageTextField.width
//        feedbackMessageTextField.x =  -feedbackMessageTextField.width - 50;
//        feedbackMessageTextField.y = -20;
//        feedbackMessageTextField.multiline = true;//_hudFeedback.multiline;
//        feedbackMessageTextField.wordWrap = true;
//        feedbackMessageTextField.antiAliasType = AntiAliasType.ADVANCED;
//
//
////        var lineageformat :TextFormat = new TextFormat();
////        lineageformat.font = "JuiceEmbedded";
////        lineageformat.size = 24.;
////        lineageformat.color = 0x000000;
////        lineageformat.align = TextFormatAlign.RIGHT;
////        lineageformat.bold = true;
////        feedbackMessageTextField.setTextFormat( lineageformat );
////        feedbackMessageTextField.textColor = _hudFeedback.textColor;
////        feedbackMessageTextField.width = _hudFeedback.width;
////        feedbackMessageTextField.height = _hudFeedback.height;
////        feedbackMessageTextField.x = _hudFeedback.x - 10;
////        feedbackMessageTextField.y = _hudFeedback.y + 10;
////        feedbackMessageTextField.multiline = _hudFeedback.multiline;
////        feedbackMessageTextField.wordWrap = true;
////        feedbackMessageTextField.antiAliasType = AntiAliasType.ADVANCED;
////
////        var blurred :BlurFilter = new BlurFilter(1.3, 1.3, 1 );
////        var storedBlur :Array = [blurred];
////        feedbackMessageTextField.filters = storedBlur;
//
//
////        var shadowText :TextField =
////            TextFieldUtil.createField(feedbackMessage);
////        shadowText.selectable = false;
////        shadowText.tabEnabled = false;
////        shadowText.embedFonts = true;
////
////        shadowText.setTextFormat( lineageformat );
////        shadowText.textColor = 0xffffff;
////        shadowText.width = _hudFeedback.width;
////        shadowText.height = _hudFeedback.height;
////        shadowText.x = _hudFeedback.x - 10;
////        shadowText.y = _hudFeedback.y + 10;
////        shadowText.multiline = _hudFeedback.multiline;
////        shadowText.wordWrap = true;
////        shadowText.antiAliasType = AntiAliasType.ADVANCED;
////
////        var blurredShadow:DropShadowFilter = new DropShadowFilter(0.8, 0, 0xffffff, 1.0, 5, 5, 1000 );
////        var storedBlurShadow :Array = [blurredShadow];
////        shadowText.filters = storedBlurShadow;
//
//
////        textSprite.addChild( shadowText );
//        textSprite.addChild( feedbackMessageTextField );
//
//        textSprite.graphics.beginFill(0);
//        textSprite.graphics.drawRect( feedbackMessageTextField.x -10, feedbackMessageTextField.y-10, feedbackMessageTextField.width + 20, feedbackMessageTextField.height);
//        textSprite.graphics.endFill();
//
//        textSprite.x -= 30;
//        var textSceneObject :SimpleSceneObject =
//            new SimpleSceneObject( textSprite, FEEDBACK_SIMOBJECT_NAME );
//
//        //Remove any objects with the same name
//        if( db.getObjectNamed( FEEDBACK_SIMOBJECT_NAME ) != null ) {
//            db.getObjectNamed( FEEDBACK_SIMOBJECT_NAME ).destroySelf();
//        }
//
//        mode.addSceneObject( textSceneObject, _hudMC);
//
//        var serialTask :SerialTask = new SerialTask();
//        serialTask.addTask(
//            new TimedTask( VConstants.TIME_FEEDBACK_MESSAGE_DISPLAY * 0.9 ));
//        serialTask.addTask( new SelfDestructTask() );
//        textSceneObject.addTask( serialTask );
//    }
//
//    protected function insertFeedbackSceneObject( feedbackMessage :String ) :void
//    {
//        var textSprite :Sprite = new Sprite();
//
//        var feedbackMessageTextField :TextField =
//            TextFieldUtil.createField(feedbackMessage);
//        feedbackMessageTextField.selectable = false;
//        feedbackMessageTextField.tabEnabled = false;
//
//        var lineageformat :TextFormat = new TextFormat();
//        lineageformat.size = 16;
//        lineageformat.color = 0xffffff;
//        lineageformat.align = TextFormatAlign.LEFT;
//        feedbackMessageTextField.setTextFormat( lineageformat );
//        feedbackMessageTextField.textColor = 0xffffff;
//        feedbackMessageTextField.width = Math.min( feedbackMessageTextField.textWidth + 10, 400);
//        feedbackMessageTextField.height = 30;
//        feedbackMessageTextField.x = 0;// -feedbackMessageTextField.width - 50;
//        feedbackMessageTextField.y = 0;
//        feedbackMessageTextField.multiline = false;//_hudFeedback.multiline;
//        feedbackMessageTextField.wordWrap = false;
//        feedbackMessageTextField.antiAliasType = AntiAliasType.ADVANCED;
//        textSprite.addChild( feedbackMessageTextField );
//
//        textSprite.graphics.beginFill(0);
//        textSprite.graphics.drawRect( feedbackMessageTextField.x -10, feedbackMessageTextField.y-6, feedbackMessageTextField.width + 40, feedbackMessageTextField.height);
//        textSprite.graphics.endFill();
//
//        var finalXForText :int = -feedbackMessageTextField.width - 40;
//
//        textSprite.x = finalXForText + 20;
//        textSprite.y = 15;
//        var textSceneObject :SimpleSceneObject =
//            new SimpleSceneObject( textSprite, FEEDBACK_SIMOBJECT_NAME );
//
//        //Remove any objects with the same name
//        if( db.getObjectNamed( FEEDBACK_SIMOBJECT_NAME ) != null ) {
//            db.getObjectNamed( FEEDBACK_SIMOBJECT_NAME ).destroySelf();
//        }
//
//        mode.addSceneObject( textSceneObject, _hudMC);
//        _hudMC.addChildAt( textSceneObject.displayObject, 2 );
//
//
//
//        var serialAnimationTask :SerialTask = new SerialTask();
//        serialAnimationTask.addTask( LocationTask.CreateEaseIn( finalXForText - 2, textSprite.y, 0.3) );
//        serialAnimationTask.addTask( LocationTask.CreateEaseIn( finalXForText, textSprite.y, 0.2) );
//        serialAnimationTask.addTask( new TimedTask(1) );
//        serialAnimationTask.addTask( LocationTask.CreateEaseIn( finalXForText + 30, textSprite.y, 0.2) );
//        serialAnimationTask.addTask( new SelfDestructTask() );
//
////        var serialTask :SerialTask = new SerialTask();
////        serialTask.addTask(
////            new TimedTask( VConstants.TIME_FEEDBACK_MESSAGE_DISPLAY * 0.9 ));
////        serialTask.addTask( new SelfDestructTask() );
//        textSceneObject.addTask( serialAnimationTask );
//    }

//    public function showFeedBack( msg :String, immediate :Boolean = false ) :void
//    {
//        if( immediate ) {
//            insertFeedbackSceneObject( msg );
//        }
//        else {
//            _feedbackMessageQueue.push( msg );
//        }
//    }




    protected function playerUpdated( e :PlayerStateChangedEvent ) :void
    {
        if( e.playerId == ClientContext.ourPlayerId) {
            updateOurPlayerState();
        }
    }

    public function updateOurPlayerState( ...ignored ) :void
    {

        if( !SharedPlayerStateClient.isProps( ClientContext.ourPlayerId )) {
            log.warning("updatePlayerState, but no props found");
            return;
        }


        showBlood( ClientContext.ourPlayerId );
        showXP( ClientContext.ourPlayerId );
//        showLevel( ClientContext.ourPlayerId );
//        showBloodBonds( ClientContext.ourPlayerId );
//        showAction( ClientContext.ourPlayerId );
//        showTime( ClientContext.ourPlayerId );
//        showTarget( ClientContext.ourPlayerId );

    }

    protected function showBlood( playerId :int ) :void
    {
//        var scaleX :Number = SharedPlayerStateClient.getMaxBlood( playerId ) / VConstants.MAX_BLOOD_FOR_LEVEL(1);
        var maxBlood :Number = SharedPlayerStateClient.getMaxBlood( playerId );
        var blood :Number = MathUtil.clamp( SharedPlayerStateClient.getBlood( playerId ),
            0, maxBlood);
        if( isNaN(blood)) {
            blood = 0;
        }
//        trace("blood=" + blood + " / " + maxBlood);

        var borderWidth :int = 3;
        //Draw the blood bar
        //Blood
        _hudBlood.graphics.clear();
        _hudBlood.graphics.beginFill(0x990000);
        _hudBlood.graphics.drawRect(1, borderWidth + 1, blood, _hudCap.height/2 - borderWidth);
        _hudBlood.graphics.endFill();
        //Highlight
        if( blood >= 1) {
            _hudBlood.graphics.lineStyle(2, 0xff00000);
            _hudBlood.graphics.moveTo( blood + 1, borderWidth + 1);
            _hudBlood.graphics.lineTo( blood + 1, _hudCap.height/2);
        }
//        //Border
        _hudBlood.graphics.lineStyle(borderWidth, 0);
        _hudBlood.graphics.drawRect(0, borderWidth, maxBlood + borderWidth*2 - 1, _hudCap.height/2 - (borderWidth - 1));

//        trace("blood rect=" + _hudBlood.x + ", " + _hudBlood.y + ", " + _hudBlood.width + ", " + _hudBlood.height);


        //Make sure the HUDCap is on the end of the bars
        _hudCap.x = _hudBlood.x + maxBlood + borderWidth*2 + 5;

        //Draw the mouseover sprite
        var bloodXPMouseOverSprite :Sprite = _bloodXPMouseOverSceneObject.displayObject as Sprite;
        bloodXPMouseOverSprite.graphics.clear();
        bloodXPMouseOverSprite.graphics.beginFill(0, 0);
        bloodXPMouseOverSprite.graphics.drawRect(0, 0, maxBlood, _hudCap.height - 3);
        bloodXPMouseOverSprite.graphics.endFill();

        createBloodText();
    }

    protected function showXP( playerId :int ) :void
    {
//        showBlood( playerId );

        //Use the blood scale for the xp scale
        var maxBlood :Number = SharedPlayerStateClient.getMaxBlood( playerId );
//        var blood :Number = MathUtil.clamp( SharedPlayerStateClient.getBlood( playerId ),
//            0, maxBlood);

        var xp :int = ClientContext.model.xp;
        var invites :int = ClientContext.model.invites;

        var level :int = Logic.levelGivenCurrentXpAndInvites( xp, invites );

        var xpNeededForNextLevel :int = Logic.xpNeededForLevel( level + 1);
        var xpNeededForLevel :int = Logic.xpNeededForLevel( level );

        var xpOverCurrentLevelMinimum :Number = xp - xpNeededForLevel;
        var xpDifference :int = xpNeededForNextLevel - xpNeededForLevel;

        var xpFraction :Number = xpOverCurrentLevelMinimum / xpDifference;
        var xpAbsoluteX :int = maxBlood * xpFraction;
        var borderWidth :int = 3;
        //Draw the xp bar
        //Xp
        _hudXP.graphics.clear();
//        _hudXP.graphics.beginFill(0xA9D2E3);
        _hudXP.graphics.beginFill(0x990000);
//        _hudXP.graphics.drawRect(1, borderWidth, xpAbsoluteX, _hudCap.height/2 - borderWidth - 3);
        _hudXP.graphics.drawRect(0, 1, xpAbsoluteX, _hudCap.height - 3);
        _hudXP.graphics.endFill();
        //Highlight
        if( xpOverCurrentLevelMinimum >= 1) {
//            _hudXP.graphics.lineStyle(2, 0xDFEFF4);
            _hudXP.graphics.lineStyle(2, 0xff00000);
            _hudXP.graphics.moveTo( xpAbsoluteX , 2);
            _hudXP.graphics.lineTo( xpAbsoluteX , _hudCap.height -2 );
        }
        //Border
        _hudXP.graphics.lineStyle(borderWidth, 0);
        _hudXP.graphics.drawRect(0, borderWidth - 1, maxBlood + borderWidth - 1, _hudCap.height - (borderWidth * 2 - 2) );

        _hudCap.x = _hudXP.x + maxBlood - borderWidth + 1;
        createXPText();
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


    protected var _hudBlood :Sprite;
    protected var _hudXP :Sprite;
//    protected var _bloodXPMouseOverSprite :Sprite;
    protected var _bloodXPMouseOverSceneObject :SceneObject;


    //Used for anchoring the bars.
    protected var _hudCapStartX :int;
    protected var _hudCap :MovieClip;


    protected var _bloodText :TextField;
    protected var _xpText :TextField;


    /**Used for registering changed level to animate a level up movieclip*/
    protected var _currentLevel :int = -0;
    protected var _currentBlood :Number = 1;

    protected var _feedbackMessageQueue :Array = new Array();
    protected static const BLOOD_SCALE_MULTIPLIER :Number = 2.2;
    protected static const log :Log = Log.getLog( HUD );
}

}