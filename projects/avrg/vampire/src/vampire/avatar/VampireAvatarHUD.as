package vampire.avatar
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Command;
    import com.threerings.util.HashSet;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.contrib.EventHandlerManager;
    import com.whirled.contrib.avrg.AvatarHUD;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.objects.SimpleTimer;
    import com.whirled.contrib.simplegame.tasks.AlphaTask;
    import com.whirled.contrib.simplegame.tasks.FunctionTask;
    import com.whirled.contrib.simplegame.tasks.SerialTask;
    import com.whirled.contrib.simplegame.tasks.TimedTask;
    import com.whirled.net.ElementChangedEvent;
    import com.whirled.net.MessageReceivedEvent;

    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import vampire.Util;
    import vampire.client.ClientContext;
    import vampire.client.VampireController;
    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.data.SharedPlayerStateClient;
    import vampire.data.VConstants;


/**
 * Show the HUD for blood, bloodbond status, targeting info etc all over the avatar in the room,
 * scaled for the avatars position and updated from the room props.
 *
 */
public class VampireAvatarHUD extends AvatarHUD
{
    public function VampireAvatarHUD( ctrl :AVRGameControl, userId:int)
    {
        super(ctrl, userId);
        trace("userId " + userId);
        _roomKey = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + _userId;

        //Listen for changes in blood levels
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        registerListener(ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);

        registerListener(ClientContext.model, HierarchyUpdatedEvent.HIERARCHY_UPDATED, updateInfoHud);

        _hudSprite = new Sprite();
        _displaySprite.addChild( _hudSprite );
//        _hudSprite.y = -10;




        _target_UI = ClientContext.instantiateMovieClip("HUD", "target_UI", true);
        _target_UI.mouseChildren = true;
        _hudSprite.addChild( _target_UI );

        _target_UI.setChildIndex(buttonFeed, 0);
        buttonFeed.alpha = 0;
        buttonFeed.mouseEnabled = false;
        buttonFeed.y = FEED_BUTTON_Y;
        buttonFrenzy.y = buttonFeed.y + 28;

        _feedObject = new SimpleSceneObject(buttonFeed);
        _frenzyObject = new SimpleSceneObject(buttonFrenzy);
        _feedObject.alpha = 0;
        _frenzyObject.alpha = 0;



        registerListener(buttonFeed, MouseEvent.CLICK, function (...ignored) :void {
//            ClientContext.avatarOverlay.setDisplayMode( VampireAvatarHUDOverlay.DISPLAY_MODE_SHOW_FEED_TARGET);
            ClientContext.controller.handleSendFeedRequest( playerId, false );
            showBloodBarOnly();
            _isMouseOver = false;
            buttonFeed.alpha = 0;
            buttonFrenzy.alpha = 0;
        });

        buttonFrenzy.alpha = 0;
        registerListener(buttonFrenzy, MouseEvent.CLICK, function (...ignored) :void {
            buttonFeed.alpha = 0;
            buttonFrenzy.alpha = 0;
            ClientContext.controller.handleSendFeedRequest( playerId, true );

            if( _frenzyDelayRemaining <= 0 ) {
                _frenzyDelayRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
            }
            if( VConstants.LOCAL_DEBUG_MODE) {
                _frenzyDelayRemaining = VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME;
                var t :SimpleTimer = new SimpleTimer(1, function() :void {
                   decrementTime();
                }, true);
                db.addObject( t );
            }
            _frenzyButtonClicked = true;
            buttonFrenzy.alpha = 0;
            showFrenzyTimerWithoutButton();
        });

        frenzyCountdown.visible = false;
        frenzyCountdown.addEventListener(MouseEvent.ROLL_OVER, function(...ignored) :void {
            waitingSign.visible = true;
        });
        frenzyCountdown.addEventListener(MouseEvent.ROLL_OUT, function(...ignored) :void {
            waitingSign.visible = false;
        });
        frenzyCountdown.y += 10;
        waitingSign.visible = false;
        waitingSign.y += 10;


        //HUD bits and bobs
        _hierarchyIcon = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
        _hierarchyIcon.mouseEnabled = true;
        _bloodBondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", false);
        _blood = ClientContext.instantiateMovieClip("HUD", "target_blood_meter", false);
        _blood.height = 10;

        //Create a mouse over sprite.
        _mouseOverSprite.graphics.beginFill(0, 0);
        _mouseOverSprite.graphics.drawRect( -40, -20, 80, 100);
        _mouseOverSprite.graphics.endFill();

        //Add a mouse move listener to the blood.  This triggers showing the feed buttons
        registerListener( _blood, MouseEvent.ROLL_OVER, function(...ignored) :void {
            _isMouseOver = true;
            _hudSprite.addChildAt(_mouseOverSprite, 0);
            if( getPotentialPredatorIds().size() > 1) {
                showFeedAndFrenzyButton();
            }
            else {
                showFeedButtonOnly();
            }
        });

        _preyStrain = ClientContext.instantiateMovieClip("HUD", "prey_strain", false);
        _preyStrain.scaleX = _preyStrain.scaleY = 2;
        _hudSprite.addChild( _blood );
        _hudSprite.addChild( _hierarchyIcon );
        _hudSprite.addChild( _bloodBondIcon );

        //Go to the help page when you click on the icon
//        addGlowFilter( _hierarchyIcon );
        addGlowFilter( _bloodBondIcon );
        addGlowFilter( _preyStrain );
//        addGlowFilter( _blood );

        Command.bind( _hierarchyIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "lineage");
        Command.bind( _bloodBondIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "bloodbond");
        Command.bind( _preyStrain, MouseEvent.CLICK, VampireController.SHOW_INTRO, "bloodtype");
        Command.bind( _blood, MouseEvent.CLICK, VampireController.SHOW_INTRO, "feedinggame");



        if( Logic.getPlayerPreferredBloodStrain( ClientContext.ourPlayerId ) == userId ) {
            _hudSprite.addChild( _preyStrain );
            _preyStrain.y -= 15;
        }

        updateInfoHud();

        showNothing();

        buttonFeed.alpha = 0;





    }

    protected function addGlowFilter( obj : InteractiveObject ) :void
    {
        registerListener( obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [Util.glowFilter];
        });
        registerListener( obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

    override protected function addedToDB():void
    {
        super.addedToDB();

        //Wrap buttons as SceneObjects for easy creation of animation effects.
        _feedObject = new SimpleSceneObject(buttonFeed);
        _frenzyObject = new SimpleSceneObject(buttonFrenzy);

        db.addObject( _feedObject, _hudSprite );
        db.addObject( _frenzyObject, _hudSprite );
    }

    override protected function destroyed():void
    {
        _feedObject.destroySelf();
        _frenzyObject.destroySelf();
    }
    protected function decrementTime() :void
    {
        _frenzyDelayRemaining -= 1;
    }


    protected function getPotentialPredatorIds() :HashSet
    {

        if( VConstants.LOCAL_DEBUG_MODE) {
            var a :HashSet = new HashSet();
            a.add(1);
            a.add(2);
            return a;
        }

        var preds :HashSet = new HashSet();

        var playerIds :Array = _ctrl.room.getPlayerIds();
        for each( var playerId :int in playerIds ) {
            if( SharedPlayerStateClient.isVampire( playerId )
                && SharedPlayerStateClient.getCurrentAction( playerId ) != VConstants.GAME_MODE_BARED ) {
                preds.add( playerId );
            }
        }

        return preds;

    }

    protected function getValidPlayerIdTargets() :HashSet
    {

        if( VConstants.LOCAL_DEBUG_MODE) {
            var a :HashSet = new HashSet();
            a.add(1);
            a.add(2);
            return a;
        }

        var validIds :HashSet = new HashSet();

        if( !ClientContext.model.isVampire() ) {
            return validIds;
        }

        var playerIds :Array = _ctrl.room.getPlayerIds();

        var validCHatTargets :Array = ClientContext.model.validNonPlayerTargetsFromChatting;

        //Add the nonplayers
        validCHatTargets.forEach( function( playerId :int, ...ignored) :void {
            if( !ArrayUtil.contains(playerIds, playerId )) {
                if( isNaN(SharedPlayerStateClient.getBlood( playerId )) || SharedPlayerStateClient.getBlood( playerId ) > 1 ) {
                    validIds.add( playerId );
                }
            }
        });

        //Add players in 'bare' mode
        for each( var playerId :int in playerIds ) {

            if( playerId == _ctrl.player.getPlayerId() ) {
                continue;
            }

            var action :String = SharedPlayerStateClient.getCurrentAction( playerId );
            if( action != null && action == VConstants.GAME_MODE_BARED
                && SharedPlayerStateClient.getBlood( playerId ) > 1 ) {

                validIds.add( playerId );
            }
        }

        return validIds;
    }




    protected function handleElementChanged (e :ElementChangedEvent) :void
    {

        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY ) {
            updateInfoHud();
        }
        else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
            updateInfoHud();
        }
        else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
            var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );
            //If it's us, update the our HUD
            if( !isNaN( playerIdUpdated ) && playerIdUpdated == playerId) {
                updateBlood();
            }
        }
    }

    protected function handleMessageReceived( e :MessageReceivedEvent ) :void
    {
        if( e.name == VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN) {

            var bbData :Array = e.value as Array;
            if( bbData == null) {
                log.error("handleMessageReceived " + VConstants.NAMED_EVENT_BLOODBLOOM_COUNTDOWN + ", but bloodbloodRecord==null" );
                return;
            }

            var currentCountDownSecond :int = bbData[0];
            var preyId :int = bbData[1];
            if( preyId == playerId ) {

                if( currentCountDownSecond >= 1) {
                    if( _frenzyDelayRemaining <= 0) {
                        _frenzyDelayRemaining = currentCountDownSecond;
                    }
                    showFrenzyTimerIfCounting();
                }
                else {
                    _frenzyDelayRemaining = 0;
                    showNothing();
                }
            }
        }
    }




    protected function updateBlood( ...ignored ) :void
    {
        var maxBlood :Number = VConstants.MAX_BLOOD_NONPLAYERS;
        if( isPlayer ) {
            maxBlood = SharedPlayerStateClient.getMaxBlood( playerId );
        }

        var currentBlood :Number = SharedPlayerStateClient.getBlood( playerId );
        if( isNaN( currentBlood ) ) {
            currentBlood = maxBlood;
        }

        _blood.width = BLOOD_BAR_MIN_WIDTH;
        _blood.height = 15;

        var scaleY :Number = maxBlood / VConstants.MAX_BLOOD_FOR_LEVEL(1);
        _blood.gotoAndStop(int(currentBlood*100.0/maxBlood) );

    }
    protected function updateInfoHud(...ignored) :void
    {

        updateBlood();

        var isHierarch :Boolean = VConstants.LOCAL_DEBUG_MODE
            || (ClientContext.model.hierarchy != null &&
                ClientContext.model.hierarchy.isPlayerSireOrMinionOfPlayer( playerId,
                ClientContext.ourPlayerId ));


        var isBloodBond :Boolean = VConstants.LOCAL_DEBUG_MODE ||
            (SharedPlayerStateClient.getBloodBonded( ClientContext.ourPlayerId ) == playerId);

        _hierarchyIcon.visible = isHierarch;
        _bloodBondIcon.visible = isBloodBond;


        _hierarchyIcon.x = 16;
        _bloodBondIcon.x = -16;

    }

    override public function get isPlayer() :Boolean
    {
        return ArrayUtil.contains( ClientContext.ctrl.room.getPlayerIds(), playerId );
    }

    public function setDisplayModeInvisible() :void
    {
        if( _frenzyDelayRemaining ) {
            showFrenzyTimerWithoutButton()
        }
        else {
            showNothing();
        }

    }

    public function setDisplayModeSelectableForFeed( multiplayer :Boolean ) :void
    {
        _displaySprite.addChild( _hudSprite );
//        buttonFeed.visible = true;
//        buttonFrenzy.visible = multiplayer;
    }

    public function setDisplayModeShowInfo() :void
    {
        showBloodBarOnly();
        showFrenzyTimerIfCounting();
    }

    public function setSelectedForFeed( multiplayer :Boolean ) :void
    {
        _displaySprite.addChild( _hudSprite );


        if( multiplayer ) {
            showFeedButtonOnly();
        }
        else {
            showFeedAndFrenzyButton();
        }

        showFrenzyTimerIfCounting();

    }



    override protected function update( dt :Number ) :void
    {
        super.update(dt);

        _frenzyDelayRemaining -= dt;

        _frenzyDelayRemaining = Math.max( _frenzyDelayRemaining, 0 );
        showFrenzyTimerIfCounting();


        if( _isMouseOver ) {

            var localPoint :Point = new Point( _mouseOverSprite.mouseX,_mouseOverSprite.mouseY );
            var globalPoint :Point = _mouseOverSprite.localToGlobal( localPoint );

            if( !_mouseOverSprite.hitTestPoint(globalPoint.x,globalPoint.y)) {
                _isMouseOver = false;
                if( _hudSprite.contains(_mouseOverSprite ) ) {
                    var serialTask :SerialTask = new SerialTask();
                    serialTask.addTask( new TimedTask(ANIMATION_TIME));
                    serialTask.addTask( new FunctionTask( function() :void {
                        animateHideFeedButton();
                        animateHideFrenzyButton();
                    }));
                    serialTask.addTask( new TimedTask(ANIMATION_TIME));
                    serialTask.addTask( new FunctionTask( function() :void {
                        _hudSprite.removeChild(_mouseOverSprite);
                    }));
                    addTask( serialTask );


                }
//                showBloodBarOnly();
            }

        }
    }


    protected function get buttonFeed() :SimpleButton
    {
        return _target_UI.button_feed;
    }
    protected function get buttonFrenzy() :SimpleButton
    {
        return _target_UI.button_frenzy;
    }
    protected function get frenzyCountdown() :MovieClip
    {
        return _target_UI.frenzy_countdown;
    }

    protected function get waitingSign() :MovieClip
    {
        return _target_UI.waiting_sign;
    }

    override protected function drawMouseSelectionGraphics() :void
    {
        super.drawMouseSelectionGraphics();
        //Draw an invisible box to detect mouse movement/clicks


        if( _hudSprite != null && _hotspot != null && hotspot.length >= 2// && !isNaN(_zScaleFactor)
            && !isNaN(hotspot[0]) && !isNaN(hotspot[1]) ) {

            _hudSprite.graphics.clear();
            _hudSprite.graphics.beginFill(0, 0.3);
            _hudSprite.graphics.drawCircle(0, 0, 20 );
            _hudSprite.graphics.endFill();
        }

    }


    public function showBloodBarOnly() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );
        animateHideFeedButton();
        animateHideFrenzyButton();

//        buttonFeed.visible = false;
//        buttonFrenzy.visible = false;
        frenzyCountdown.visible = false;

    }

    protected function animateShowFeedButton() :void
    {
        _hudSprite.addChild( _feedObject.displayObject );
        buttonFeed.mouseEnabled = true;
        _feedObject.addTask( AlphaTask.CreateEaseIn(1, ANIMATION_TIME));
    }

    protected function animateShowFrenzyButton() :void
    {
        _hudSprite.addChild( _frenzyObject.displayObject );
        buttonFrenzy.mouseEnabled = true;
        _frenzyObject.addTask( AlphaTask.CreateEaseIn(1, ANIMATION_TIME));
    }

    protected function animateHideFeedButton() :void
    {
        var serialTask :SerialTask = new SerialTask();
        serialTask.addTask( AlphaTask.CreateEaseOut(0, ANIMATION_TIME) );
        serialTask.addTask( new FunctionTask( function() :void {
            if( _feedObject.displayObject.parent.contains( _feedObject.displayObject)) {
                _feedObject.displayObject.parent.removeChild( _feedObject.displayObject );
            }
        }));
        _feedObject.addTask( serialTask );
    }

    protected function animateHideFrenzyButton() :void
    {
        var serialTask :SerialTask = new SerialTask();
        serialTask.addTask( AlphaTask.CreateEaseOut(0, ANIMATION_TIME) );
        serialTask.addTask( new FunctionTask( function() :void {
            if( _frenzyObject.displayObject.parent.contains( _frenzyObject.displayObject)) {
                _frenzyObject.displayObject.parent.removeChild( _frenzyObject.displayObject );
            }
        }));
        _frenzyObject.addTask( serialTask );
    }

    public function showFeedButtonOnly() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        animateShowFeedButton();

//        buttonFrenzy.visible = false;
//        frenzyCountdown.visible = false;
    }
    public function showFeedAndFrenzyButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );
        animateShowFeedButton();
        animateShowFrenzyButton();
        frenzyCountdown.visible = false;
    }

    public function showFrenzyTimerWithoutButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        buttonFeed.alpha = 0;
        buttonFrenzy.alpha = 0;
        frenzyCountdown.visible = true;
    }

    public function showFrenzyTimerWithButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }
        _displaySprite.addChild( _hudSprite );

        buttonFeed.alpha = 0;
        buttonFrenzy.alpha = 1;
        frenzyCountdown.visible = true;
    }

    protected function showFrenzyTimerIfCounting() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        if( (_frenzyDelayRemaining > 0 ) && ClientContext.model.isVampire()) {

            _displaySprite.addChild( _hudSprite );
            buttonFeed.alpha = 0;
            buttonFrenzy.alpha = _frenzyButtonClicked ? 0 : 1;
            frenzyCountdown.visible = true;
            frenzyCountdown.gotoAndStop( int( 100 - (_frenzyDelayRemaining*100 / VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME) ));
        }
        else {
            frenzyCountdown.visible = false;
            _frenzyButtonClicked = false;
        }
    }

    public function showNothing() :void
    {
        if( _displaySprite.contains( _hudSprite ) ) {
            _displaySprite.removeChild( _hudSprite );
        }
//        buttonFeed.visible = false;
//        buttonFrenzy.visible = false;
//        frenzyCountdown.visible = false;
    }


    protected var _hudMouseEvents :EventHandlerManager = new EventHandlerManager();

    protected var _hudSprite :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _hierarchyIcon :SimpleButton;
    protected var _blood :MovieClip;
    protected var _preyStrain :MovieClip;

    protected var _roomKey :String;

    protected var _feedObject :SceneObject;
    protected var _frenzyObject :SceneObject;


    /**
    * I've had some trouble with ROLL_OUT events.  So instead, we'll activate this when the mouse
    * rolls over the blood bar, and deactivate it when the mouse leaves the sprite defined area.
    */
    protected var _isMouseOver :Boolean = false;
    protected var _mouseOverSprite :Sprite = new Sprite();

    protected var _frenzyDelayRemaining :Number = -1;
    protected var _frenzyButtonClicked :Boolean;

    protected static const BLOOD_BAR_MIN_WIDTH :int = 50;
    protected static const FEED_BUTTON_Y :int = 22;
    protected static const ANIMATION_TIME :Number = 0.3;

}
}