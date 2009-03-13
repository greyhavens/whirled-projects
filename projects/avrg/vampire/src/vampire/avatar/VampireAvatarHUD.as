package vampire.avatar
{
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Command;
    import com.threerings.util.HashSet;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.contrib.EventHandlerManager;
    import com.whirled.contrib.avrg.AvatarHUD;
    import com.whirled.contrib.simplegame.objects.SceneButton;
    import com.whirled.contrib.simplegame.objects.SceneObjectPlayMovieClipOnce;
    import com.whirled.contrib.simplegame.objects.SimpleTimer;
    import com.whirled.contrib.simplegame.tasks.AlphaTask;
    import com.whirled.contrib.simplegame.tasks.FunctionTask;
    import com.whirled.contrib.simplegame.tasks.SerialTask;
    import com.whirled.contrib.simplegame.tasks.TimedTask;
    import com.whirled.net.ElementChangedEvent;
    import com.whirled.net.MessageReceivedEvent;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import vampire.client.ClientContext;
    import vampire.client.VampireController;
    import vampire.client.events.LineageUpdatedEvent;
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
        _roomKey = Codes.ROOM_PROP_PREFIX_PLAYER_DICT + _userId;

        //Listen for changes in blood levels
        registerListener(ClientContext.ctrl.room.props, ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        registerListener(ClientContext.ctrl.room, MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);

        registerListener(ClientContext.model, LineageUpdatedEvent.LINEAGE_UPDATED, updateLineageInfo);

        setupUI();


    }

    protected function updateLineageInfo( e :LineageUpdatedEvent) :void
    {
        var currentMinions :int = e.lineage.getAllMinionsAndSubminions( playerId ).size();
        var currentSire :int = e.lineage.getSireId(playerId);
        if( currentMinions > _localMinionCount || currentSire != _localSire) {
            _localMinionCount = currentMinions;
            _localSire = currentSire;
            updateInfoHud();
        }
    }


    protected function setupUI() :void
    {
        //Set up common UI elements
        _hudSprite = new Sprite();
        _displaySprite.addChild( _hudSprite );

        _blood = ClientContext.instantiateMovieClip("HUD", "target_blood_meter", false);
        _blood.height = 10;
        _hudSprite.addChild( _blood );
        _bloodMouseDetector = new Sprite();
        _hudSprite.addChild( _bloodMouseDetector );


        //Create a mouse over sprite.
        _mouseOverSprite.graphics.beginFill(0, 0);
        _mouseOverSprite.graphics.drawRect( -40, -20, 80, 100);
        _mouseOverSprite.graphics.endFill();


        _target_UI = ClientContext.instantiateMovieClip("HUD", "target_UI", false);

        //Set up UI elements depending if we are the players avatar
        if( playerId == ClientContext.ourPlayerId ) {
            setupUIYourAvatar();
        }
        else {
            setupUITarget();
        }
    }

    protected function glowBloodBarIfValidTarget() :void
    {
        var validTarget :Boolean = false;
        if( isPlayer ) {
            if( SharedPlayerStateClient.getCurrentAction( playerId ) == VConstants.GAME_MODE_BARED
                && SharedPlayerStateClient.getBlood( playerId ) > 1) {

                validTarget = true;
            }
        }
        else {

            if( isChattedEnoughForTargeting && SharedPlayerStateClient.getBlood( playerId ) > 1) {

                validTarget = true;
            }
        }

        if( validTarget || VConstants.LOCAL_DEBUG_MODE ) {
            _blood.filters = [ClientContext.glowFilter];
        }
        else {
            _blood.filters = [];
        }
    }

    protected function get isChattedEnoughForTargeting() :Boolean
    {
        var targets :Array = _ctrl.room.getEntityProperty(
                AvatarGameBridge.ENTITY_PROPERTY_CHAT_TARGETS, ClientContext.ourEntityId) as Array;

        if( targets != null && ArrayUtil.contains( targets, playerId ) ){

            return true;
        }

        return false;
    }



    protected function setupUITarget() :void
    {
        //Detach the bare buttons only used on our own avatar
        for each( var unusedButton :DisplayObject in [_target_UI.button_bare,
            _target_UI.button_revert]) {

            unusedButton.parent.removeChild( unusedButton );
        }

        //Listen for changes in the hierarchy
        registerListener(ClientContext.model, LineageUpdatedEvent.LINEAGE_UPDATED, updateInfoHud);

        _feedButton = new SceneButton(_target_UI.button_feed);
        _frenzyButton = new SceneButton(_target_UI.button_frenzy);


        _feedButton.alpha = 0;
        _frenzyButton.alpha = 0;

        //Move both buttons down a notch
        var yDiffFeedFrenzy :int = _frenzyButton.y - _feedButton.y;
        _feedButton.y = FEED_BUTTON_Y;
        _frenzyButton.y = _feedButton.y + yDiffFeedFrenzy;

        _feedButton.registerButtonListener( MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleSendFeedRequest( playerId, false );
            showBloodBarOnly();
            _isMouseOver = false;
            _feedButton.alpha = 0;
            _frenzyButton.alpha = 0;
        });

        _frenzyButton.registerButtonListener( MouseEvent.CLICK, function (...ignored) :void {
            _feedButton.alpha = 0;
            _frenzyButton.alpha = 0;
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
//            trace("frenzy button clicked, _frenzyDelayRemaining=" + _frenzyDelayRemaining);
            _frenzyButtonClicked = true;
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
        _hierarchyIcon.scaleX = _hierarchyIcon.scaleY = 0.8;
        _bloodBondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", false);

        _preyStrain = ClientContext.instantiateMovieClip("HUD", "prey_strain", false);
        _preyStrain.scaleX = _preyStrain.scaleY = 2;

        //Add a mouse move listener to the blood.  This triggers showing the feed buttons
        var showMenuFunction :Function = function(...ignored) :void {
            _isMouseOver = true;


            if( VConstants.LOCAL_DEBUG_MODE ) {
                _hudSprite.addChildAt(_mouseOverSprite, 0);
                showFeedAndFrenzyButton();
                return;
            }
            var isPlayer :Boolean = ArrayUtil.contains(_ctrl.room.getPlayerIds(), playerId);

            //Only show feed buttons if there is sufficient blood
            if( (!isPlayer && !isChattedEnoughForTargeting) || SharedPlayerStateClient.getBlood( playerId ) <= 1) {
//                trace(" doing nothing because:");
//                trace("   isPlayer=" + isPlayer);
//                trace("   isChattedEnoughForTargeting=" + isChattedEnoughForTargeting);
//                trace("   SharedPlayerStateClient.getBlood( " + playerId + " ) <= 1)=" + (SharedPlayerStateClient.getBlood( playerId ) <= 1));
//                trace("   SharedPlayerStateClient.getBlood( " + playerId + " )=" + SharedPlayerStateClient.getBlood( playerId ));
                return;
            }


            var action :String = SharedPlayerStateClient.getCurrentAction( playerId );
            //Show feed buttons if we are a player in bared mode, or a non-player
            if( !isPlayer || (action != null && action == VConstants.GAME_MODE_BARED)) {

                _hudSprite.addChildAt(_mouseOverSprite, 0);
                //Make sure the frenzy button is only shown if there are more than 2 predators.
                //This misses the case where there are two preds, and a non player, and the preds
                //are feeding from each other.
                if( getPotentialPredatorIds().size() > 1 && ClientContext.avatarNumberInRoom > 2) {
                    showFeedAndFrenzyButton();
                }
                else {
                    showFeedButtonOnly();
                }
            }
            else {
//                trace(" more doing nothing because:");
//                trace("   action=" + action);
            }

        }

        //Make sure that if any part of the menu is moused over, show the action buttons
        registerListener( _blood, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _hierarchyIcon, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _bloodBondIcon, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _preyStrain, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _bloodMouseDetector, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _bloodMouseDetector, MouseEvent.MOUSE_MOVE, showMenuFunction);


        _hudSprite.addChild( _hierarchyIcon );
        _hudSprite.addChild( _bloodBondIcon );

        if( Logic.getPlayerPreferredBloodStrain( ClientContext.ourPlayerId ) == playerId ) {
            _hudSprite.addChild( _preyStrain );
            _preyStrain.y -= 15;
        }

        addGlowFilter( _bloodBondIcon );
        addGlowFilter( _preyStrain );

        //Go to the help page when you click on the icon
        Command.bind( _hierarchyIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "default");
        Command.bind( _bloodBondIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "default");
        Command.bind( _preyStrain, MouseEvent.CLICK, VampireController.SHOW_INTRO, "bloodtype");
        Command.bind( _blood, MouseEvent.CLICK, VampireController.SHOW_INTRO, "feedinggame");


        //Add a glow if we are a valid target
        _glowTimer = new SimpleTimer(1, glowBloodBarIfValidTarget, true);



        updateInfoHud();

    }

    protected function setupUIYourAvatar() :void
    {

        //Detach the bare buttons only used on our own avatar
        for each( var unusedButton :DisplayObject in [_target_UI.button_feed,
            _target_UI.button_frenzy, _target_UI.frenzy_countdown, _target_UI.waiting_sign]) {

            unusedButton.parent.removeChild( unusedButton );
        }



        _bareButton = new SceneButton( _target_UI.button_bare );
        _unbareButton = new SceneButton( _target_UI.button_revert);
        _bareButton.mouseEnabled = true;
        _bareButton.y = FEED_BUTTON_Y;
        _unbareButton.y = _bareButton.y;

        _bareButton.alpha = 0;
        _unbareButton.alpha = 0;


        _bareButton.registerButtonListener( MouseEvent.CLICK, function (...ignored) :void {
            _bareButton.alpha = 0;
            if( _bareButton.button.parent != null ) {
                _bareButton.button.parent.removeChild( _bareButton.button );
            }
            _hudSprite.addChild( _unbareButton.displayObject );
            _unbareButton.alpha = 1;
            ClientContext.controller.handleSwitchMode(VConstants.GAME_MODE_BARED );
        });

        _unbareButton.registerButtonListener( MouseEvent.CLICK, function (...ignored) :void {
            _unbareButton.alpha = 0;
            if( _unbareButton.button.parent != null ) {
                _unbareButton.button.parent.removeChild( _unbareButton.button );
            }
            _hudSprite.addChild( _bareButton.displayObject );
            _bareButton.alpha = 1;
            _ctrl.player.setAvatarState( VConstants.GAME_MODE_NOTHING );
            ClientContext.controller.handleSwitchMode(VConstants.GAME_MODE_NOTHING );
        });

        //Add a mouse move listener to the blood.  This triggers showing the feed buttons

        var showMenuFunction :Function = function(...ignored) :void {
            _isMouseOver = true;
            _hudSprite.addChildAt(_mouseOverSprite, 0);

            if( ClientContext.model.action == VConstants.GAME_MODE_BARED ) {
                showUnBareButton();
            }
            else {
                showBareButton();
            }

        }

        //Make sure that if any part of the menu is moused over, show the action buttons
        registerListener( _blood, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _bloodMouseDetector, MouseEvent.ROLL_OVER, showMenuFunction);
        registerListener( _bloodMouseDetector, MouseEvent.MOUSE_MOVE, showMenuFunction);

        updateBlood();

    }

    protected function addGlowFilter( obj : InteractiveObject ) :void
    {
        registerListener( obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [ClientContext.glowFilter];
        });
        registerListener( obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

    override protected function addedToDB():void
    {
        super.addedToDB();

        if( ClientContext.ourPlayerId == playerId ) {
            db.addObject( _bareButton );
            db.addObject( _unbareButton );
        }
        else {
            db.addObject( _frenzyButton );
            db.addObject( _feedButton );

            db.addObject( _glowTimer );
        }
    }

    override protected function destroyed():void
    {
        var allButtons :Array = [_feedButton, _frenzyButton, _bareButton, _unbareButton];
        for each( var b :SceneButton in allButtons) {
            if( b != null && b.isLiveObject) {
                b.destroySelf()
            }
        }

        if( _glowTimer != null && _glowTimer.isLiveObject) {
            _glowTimer.destroySelf()
        }

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
        var playerIdUpdated :int = SharedPlayerStateClient.parsePlayerIdFromPropertyName( e.name );

        //Some things we update regardless whether they are our attributes or not
//        if( e.name == Codes.ROOM_PROP_MINION_HIERARCHY ) {
//            //Check if we have new minions
//
//            updateInfoHud();
//        }
//        else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {
//            updateInfoHud();
//        }

        //If it's us, update the our HUD
        if( !isNaN( playerIdUpdated ) && playerIdUpdated == playerId) {
            if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD) {
                updateBlood();
                //Animate feedback for blood gain
                if( e.oldValue < e.newValue) {
                    var bloodUp :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "bloodup_feedback", true) );
                    db.addObject( bloodUp, _displaySprite );
                }
            }

            if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_XP) {
                updateBlood();
                //Animate feedback for blood gain
                if( e.oldValue < e.newValue) {

                    var oldLevel :int = Logic.levelGivenCurrentXpAndInvites(Number(e.oldValue), ClientContext.model.invites);
                    var newLevel :int = Logic.levelGivenCurrentXpAndInvites(Number(e.newValue), ClientContext.model.invites);
                    if( oldLevel < newLevel) {
                        var levelUp :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                                ClientContext.instantiateMovieClip("HUD", "levelup_feedback", true) );
                        db.addObject( levelUp, _displaySprite );
                    }
                }
            }

            else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED) {

                if( e.newValue != 0) {
                    var bloodBondMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "bloodbond_feedback", true) );
                    db.addObject( bloodBondMovie, _displaySprite );
                }
                updateInfoHud();
            }

            else if( e.index == Codes.ROOM_PROP_PLAYER_DICT_INDEX_SIRE) {
                if( e.newValue != 0) {
                    var lineageMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                            ClientContext.instantiateMovieClip("HUD", "lineage_feedback", true) );
                    db.addObject( lineageMovie, _displaySprite );
                }
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
        if( isNaN( currentBlood ) || currentBlood == 0) {
            currentBlood = maxBlood;
        }

        _blood.width = maxBlood/2;//BLOOD_BAR_MIN_WIDTH;
        _blood.height = 15;

        _bloodMouseDetector.graphics.clear();
        _bloodMouseDetector.graphics.beginFill(0xffffff, 0);
        _bloodMouseDetector.graphics.drawRect( _blood.x - _blood.width / 2, _blood.y - _blood.height / 2, _blood.width, _blood.height);
        _bloodMouseDetector.graphics.endFill();

//        var scaleY :Number = maxBlood / VConstants.MAX_BLOOD_FOR_LEVEL(1);
        _blood.gotoAndStop(int(currentBlood*100.0/maxBlood) );

    }
    protected function updateInfoHud(...ignored) :void
    {
        //If it's our avatar HUD, don't show any extra details.
        if( ClientContext.ourPlayerId == playerId ) {
            return;
        }

        updateBlood();

        var isHierarch :Boolean = VConstants.LOCAL_DEBUG_MODE
            || (ClientContext.model.lineage != null &&
                ClientContext.model.lineage.isPlayerSireOrMinionOfPlayer( playerId,
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
                        animateHideButton(_feedButton);
                        animateHideButton(_frenzyButton);
                        animateHideButton(_bareButton);
                        animateHideButton(_unbareButton);
                    }));
                    serialTask.addTask( new TimedTask(ANIMATION_TIME));
                    serialTask.addTask( new FunctionTask( function() :void {
                        if( _mouseOverSprite.parent != null ) {
                            _mouseOverSprite.parent.removeChild( _mouseOverSprite );
                        }
                    }));
                    addTask( serialTask );


                }
            }

        }
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
        _displaySprite.addChild( _hudSprite );
        updateBlood();
    }


    protected function animateShowButton( sceneButton :SceneButton ) :void
    {
        _hudSprite.addChild( sceneButton.displayObject);
        sceneButton.mouseEnabled = true;
        sceneButton.addTask( AlphaTask.CreateEaseIn(1, ANIMATION_TIME));
    }

    protected function animateHideButton(sceneButton :SceneButton ) :void
    {
        if( sceneButton == null || sceneButton.displayObject == null ||
            sceneButton.displayObject.parent == null ) {
            return;
        }

        var serialTask :SerialTask = new SerialTask();
        serialTask.addTask( AlphaTask.CreateEaseIn(0, ANIMATION_TIME) );
        serialTask.addTask( new FunctionTask( function() :void {

            if( sceneButton.displayObject.parent == null ) {
                return;
            }

            if( sceneButton.displayObject.parent.contains( sceneButton.displayObject)) {
                sceneButton.displayObject.parent.removeChild( sceneButton.displayObject );
            }
        }));
        sceneButton.addTask( serialTask );
    }



    public function showFeedButtonOnly() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        animateShowButton(_feedButton);
        if( _frenzyButton.displayObject.parent != null &&
            _frenzyButton.displayObject.parent.contains( _frenzyButton.displayObject)) {
            _frenzyButton.displayObject.parent.removeChild( _frenzyButton.displayObject );
        }
    }

    public function showBareButton() :void
    {
        if( playerId != ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        animateShowButton(_bareButton);
    }

    public function showUnBareButton() :void
    {
        if( playerId != ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );

        animateShowButton(_unbareButton);
    }

    public function showFeedAndFrenzyButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );
        animateShowButton(_feedButton);
        animateShowButton(_frenzyButton);

        frenzyCountdown.visible = false;
    }

    public function showFrenzyTimerWithoutButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }

        _displaySprite.addChild( _hudSprite );


        _feedButton.alpha = 0;
        _frenzyButton.alpha = 0;

        _hudSprite.addChild( waitingSign );
        _hudSprite.addChild( frenzyCountdown );
        frenzyCountdown.visible = true;
    }

    public function showFrenzyTimerWithButton() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }
        _displaySprite.addChild( _hudSprite );

        _feedButton.alpha = 0;
        _frenzyButton.alpha = 1;
        frenzyCountdown.visible = true;
    }

    protected function showFrenzyTimerIfCounting() :void
    {
        if( playerId == ClientContext.ourPlayerId) {
            return;
        }
        if( _frenzyDelayRemaining > 0  && ClientContext.model.isVampire()) {

            //fix here target UI

            _displaySprite.addChild( _hudSprite );
            _feedButton.alpha = 0;
            if( !_frenzyButtonClicked ) {
                if( _frenzyButton.hasTasks() ) {
                    _frenzyButton.removeAllTasks();
                }
                _hudSprite.addChild( _frenzyButton.displayObject);
                _frenzyButton.alpha = 1;
            }
            else {
            _frenzyButton.alpha = 0;
            }

            frenzyCountdown.visible = true;
            frenzyCountdown.gotoAndStop( int( 100 - (_frenzyDelayRemaining*100 / VConstants.BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME) ));
        }
        else {
            frenzyCountdown.visible = false;
            _frenzyButtonClicked = false;
        }
    }



    protected var _hudMouseEvents :EventHandlerManager = new EventHandlerManager();

    protected var _hudSprite :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _hierarchyIcon :SimpleButton;
    protected var _blood :MovieClip;
    protected var _bloodMouseDetector :Sprite;
    protected var _preyStrain :MovieClip;

    protected var _roomKey :String;

    protected var _feedButton :SceneButton;
    protected var _frenzyButton :SceneButton;
    protected var _bareButton :SceneButton;
    protected var _unbareButton :SceneButton;


    /**
    * I've had some trouble with ROLL_OUT events.  So instead, we'll activate this when the mouse
    * rolls over the blood bar, and deactivate it when the mouse leaves the sprite defined area.
    */
    protected var _isMouseOver :Boolean = false;
    protected var _mouseOverSprite :Sprite = new Sprite();

    protected var _frenzyDelayRemaining :Number = -1;
    protected var _frenzyButtonClicked :Boolean;

    protected var _glowTimer :SimpleTimer;

    protected var _localMinionCount :int = 0;
    protected var _localSire :int = 0;

    //Store local copies of blood and other stats so we can animate feedback when those values

    protected static const BLOOD_BAR_MIN_WIDTH :int = 50;
    protected static const FEED_BUTTON_Y :int = 22;
    protected static const ANIMATION_TIME :Number = 0.2;

}
}