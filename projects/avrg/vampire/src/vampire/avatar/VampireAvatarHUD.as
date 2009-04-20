package vampire.avatar
{
    import com.threerings.flash.DisplayUtil;
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.Command;
    import com.whirled.avrg.AVRGameControl;
    import com.whirled.contrib.EventHandlerManager;
    import com.whirled.contrib.avrg.AvatarHUD;
    import com.whirled.contrib.simplegame.objects.SceneButton;
    import com.whirled.contrib.simplegame.objects.SceneObject;
    import com.whirled.contrib.simplegame.objects.SceneObjectPlayMovieClipOnce;
    import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
    import com.whirled.contrib.simplegame.tasks.AlphaTask;
    import com.whirled.contrib.simplegame.tasks.FunctionTask;
    import com.whirled.contrib.simplegame.tasks.SerialTask;
    import com.whirled.net.PropertyChangedEvent;

    import flash.display.DisplayObject;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.geom.Point;

    import vampire.client.ClientContext;
    import vampire.client.VampireController;
    import vampire.client.events.PlayersFeedingEvent;
    import vampire.data.Codes;
    import vampire.data.Logic;
    import vampire.feeding.PlayerFeedingData;


/**
 * Show the HUD for blood, bloodbond status, targeting info etc all over the avatar in the room,
 * scaled for the avatars position and updated from the room props.
 *
 */
public class VampireAvatarHUD extends AvatarHUD
{
    public function VampireAvatarHUD(ctrl :AVRGameControl, userId:int)
    {
        super(ctrl, userId);
        registerListener(ClientContext.ctrl.player.props, PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);
        //Set up common UI elements
        _hudSprite = new Sprite();
        _displaySprite.addChild(_hudSprite);

        if (ClientContext.model.bloodbond == userId) {
            addBloodBondIcon();
        }

    }

    protected function addBloodBondIcon () :void
    {
        if (_bloodBondIcon == null) {
            _bloodBondIcon = ClientContext.instantiateMovieClip("HUD", "bond_icon", false);
            _bloodBondIcon.scaleX = _bloodBondIcon.scaleY = 2;
            addGlowFilter(_bloodBondIcon);
            //Go to the help page when you click on the icon
            Command.bind(_bloodBondIcon, MouseEvent.CLICK, VampireController.SHOW_INTRO, "default");
        }
        if (ClientContext.ourPlayerId != playerId) {
            _displaySprite.addChild(_bloodBondIcon);
        }

    }

    protected function removeBloodbondIcon () :void
    {
        if (_bloodBondIcon != null) {
            if (_bloodBondIcon.parent != null) {
                _bloodBondIcon.parent.removeChild(_bloodBondIcon);
            }
        }
    }

    protected function setupUI () :void
    {
        _target_UI = ClientContext.instantiateMovieClip("HUD", "target_UI", false);
        _target_UI.alpha = 0;
        _targetUIScene = new SimpleSceneObject(_target_UI);
        db.addObject(_targetUIScene);

        //Set up UI elements depending if we are the players avatar
        if(playerId == ClientContext.ourPlayerId) {
//            setupUIYourAvatar();
        }
        else {
            setupUITarget();
        }
    }

    public function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_displaySprite, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }

    protected function setupUITarget() :void
    {
        _hudSprite.addChild(_target_UI);

        //Listen for changes in the hierarchy
        registerListener(ClientContext.model, PlayersFeedingEvent.PLAYERS_FEEDING,
            handleUnavailablePlayerListChanged);

        _feedButton = new SceneButton(_target_UI.button_feed);

        _feedButton.registerButtonListener(MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleSendFeedRequest(playerId);

            ClientContext.gameMode.avatarOverlay.setDisplayMode(VampireAvatarHUDOverlay.DISPLAY_MODE_OFF);
        });


        var buttonFresh :SimpleButton = _target_UI["button_fresh"] as SimpleButton;
        var buttonJoin :SimpleButton = _target_UI["button_join"] as SimpleButton;
        var buttonLineage :SimpleButton = _target_UI["button_lineage"] as SimpleButton;

        registerListener(buttonFresh, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowIntro("lineage");
        });

        registerListener(buttonJoin, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowPreyLineage(playerId);
        });

        registerListener(buttonLineage, MouseEvent.CLICK, function (...ignored) :void {
            ClientContext.controller.handleShowPreyLineage(playerId);
        })

        Command.bind(MovieClip(_target_UI["strain"]), MouseEvent.CLICK,
            VampireController.SHOW_INTRO, "bloodtype");

        addGlowFilter(MovieClip(_target_UI["strain"]));
    }

    /**
    * If we are in the list, sent from the server, of players currently feeding, or predators
    * in a lobby, make sure we are not available for feeding.
    */
    protected function handleUnavailablePlayerListChanged (e :PlayersFeedingEvent) :void
    {
        if (ArrayUtil.contains(e.playersFeeding, playerId)) {
            setDisplayModeInvisible();
        }
    }


    protected function addGlowFilter(obj : InteractiveObject) :void
    {
        registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [ClientContext.glowFilter];
        });
        registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

    override protected function addedToDB():void
    {
        super.addedToDB();
        setupUI();
        setDisplayModeInvisible();

    }

    protected function handlePropertyChanged (e :PropertyChangedEvent) :void
    {
        var oldLevel :int;
        var newLevel :int;

        switch (e.name) {
            case Codes.PLAYER_PROP_XP:
            if (e.newValue > e.oldValue && ClientContext.ourPlayerId == playerId) {
                var levelUp :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                    ClientContext.instantiateMovieClip("HUD", "bloodup_feedback", true));
                if (mode != null && levelUp != null) {
                    mode.addSceneObject(levelUp, _displaySprite);
                }
            }
            break;

            case Codes.PLAYER_PROP_BLOODBOND:
            removeBloodbondIcon();
            if(e.newValue == playerId) {
                var bloodBondMovie :SceneObjectPlayMovieClipOnce = new SceneObjectPlayMovieClipOnce(
                        ClientContext.instantiateMovieClip("HUD", "bloodbond_feedback", true));
                mode.addSceneObject(bloodBondMovie, _displaySprite);
                addBloodBondIcon();
            }
            break;
            default:
            break;
        }
    }

    override public function get isPlayer () :Boolean
    {
        return ArrayUtil.contains(ClientContext.ctrl.room.getPlayerIds(), playerId);
    }

    override protected function update (dt :Number) :void
    {
        try {
            super.update(dt);

            if (hotspot != null
                    && hotspot.length > 1
                    && _ctrl != null
                    && _ctrl.isConnected()
                    && _ctrl.local.getRoomBounds() != null
                    && _ctrl.local.getRoomBounds().length > 1) {

                var heightLogical :Number = hotspot[1]/_ctrl.local.getRoomBounds()[1];
                var p1 :Point = _ctrl.local.locationToPaintable(_location[0], _location[1], _location[2]);
                var p2 :Point = _ctrl.local.locationToPaintable(_location[0], heightLogical, _location[2]);

                var absoluteHeight :Number = Math.abs(p2.y - p1.y);
                _target_UI.y = absoluteHeight / 2;

            }

        }
        catch (err :Error) {
            log.error(err.getStackTrace());
        }
    }

    protected function get frenzyCountdown () :MovieClip
    {
        return _target_UI.frenzy_countdown;
    }

    protected function get waitingSign () :MovieClip
    {
        return _target_UI.waiting_sign;
    }

    protected function drawMouseSelectionGraphics () :void
    {
        //Draw an invisible box to detect mouse movement/clicks
        if(_hudSprite != null && _hotspot != null && hotspot.length >= 2// && !isNaN(_zScaleFactor)
            && !isNaN(hotspot[0]) && !isNaN(hotspot[1])) {

            _hudSprite.graphics.clear();
            _hudSprite.graphics.beginFill(0, 0.3);
            _hudSprite.graphics.drawCircle(0, 0, 20);
            _hudSprite.graphics.endFill();
        }
    }

    protected function animateShowSceneObject (sceneButton :SceneObject) :void
    {
        _hudSprite.addChild(sceneButton.displayObject);
        sceneButton.addTask(AlphaTask.CreateEaseIn(1, ANIMATION_TIME));
    }

    protected function animateHideSceneObject (sceneButton :SceneObject) :void
    {
        if(sceneButton == null || sceneButton.displayObject == null ||
            sceneButton.displayObject.parent == null) {
            return;
        }

        var serialTask :SerialTask = new SerialTask();
        serialTask.addTask(AlphaTask.CreateEaseIn(0, ANIMATION_TIME));
        serialTask.addTask(new FunctionTask(function() :void {

            if(sceneButton.displayObject.parent == null) {
                return;
            }

            if(sceneButton.displayObject.parent.contains(sceneButton.displayObject)) {
                sceneButton.displayObject.parent.removeChild(sceneButton.displayObject);
            }
        }));
        sceneButton.addTask(serialTask);
    }

    public function setDisplayModeSelectableForFeed () :void
    {
        _displaySprite.addChild(_hudSprite);
        _hudSprite.addChild(_target_UI);
        animateShowSceneObject(_targetUIScene);

        //Show relevant strain info
        var bloodType :MovieClip = _target_UI["strain"] as MovieClip;
        bloodType.gotoAndStop(Logic.getPlayerBloodStrain(playerId) + 1);
        var pdf :PlayerFeedingData = ClientContext.model.playerFeedingData;
        if (pdf.canCollectStrainFromPlayer(Logic.getPlayerBloodStrain(playerId), playerId)){
            bloodType.visible = true;
            bloodType.mouseEnabled = true;
        }
        else {
            bloodType.visible = false;
            bloodType.mouseEnabled = false;
        }
        _isShowingFeedButton = true;


        //Show the appropriate button
        //First detach them all
        var buttonFresh :SimpleButton = _target_UI["button_fresh"] as SimpleButton;
        var buttonJoin :SimpleButton = _target_UI["button_join"] as SimpleButton;
        var buttonLineage :SimpleButton = _target_UI["button_lineage"] as SimpleButton;

        for each (var d :DisplayObject in [buttonFresh, buttonJoin, buttonLineage]) {
            if (d != null && d.parent != null) {
                d.parent.removeChild(d);
            }
        }

        var isPlayerPartOfLineage :Boolean =
            ClientContext.model.lineage.isMemberOfLineage(ClientContext.ourPlayerId) ||
            ClientContext.model.lineage.isConnectedToLilith;

        var isAvatarPartOfLineage :Boolean =
            ClientContext.gameMode.roomModel.getLineage(playerId) != null &&
            ClientContext.gameMode.roomModel.getLineage(playerId).isConnectedToLilith;
            //ClientContext.model.lineage.isMemberOfLineage(playerId);

        var avatarHasNoSire :Boolean =
            ClientContext.gameMode.roomModel.getLineage(playerId) == null ||
            !ClientContext.gameMode.roomModel.getLineage(playerId).isSireExisting(playerId);

        if (isPlayerPartOfLineage) {
            if (avatarHasNoSire) {
                _target_UI.addChild(buttonFresh);
            }
            else {
                _target_UI.addChild(buttonLineage);
            }
        }
        else {
            if (isAvatarPartOfLineage && ClientContext.model.isPlayer(playerId)) {
                _target_UI.addChild(buttonJoin);
            }
            else {
                _target_UI.addChild(buttonLineage);
            }
        }
    }

    public function setDisplayModeInvisible() :void
    {
        _hudSprite.graphics.clear();
        animateHideSceneObject(_targetUIScene);
        _isShowingFeedButton = false;
    }

    public function get isShowingFeedButton () :Boolean
    {
        return _isShowingFeedButton;
    }

    /**
    * Accessed by the tutorial for fixing a targeting movieclip.
    */
    public function get targetUI () :MovieClip
    {
        return _target_UI;
    }

    /**
    * Monitored by the tutorial.  The tutorial can anchor a targeting sprite
    * to the hud.
    */
    protected var _isShowingFeedButton :Boolean;

    protected var _hudMouseEvents :EventHandlerManager = new EventHandlerManager();

    protected var _hudSprite :Sprite;
    protected var _target_UI :MovieClip;
    protected var _bloodBondIcon :MovieClip;
    protected var _preyStrain :MovieClip;
    protected var _feedButton :SceneButton;
    protected var _targetUIScene :SceneObject;


    protected static const ANIMATION_TIME :Number = 0.2;

}
}