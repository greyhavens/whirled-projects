package vampire.client
{
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.filters.GlowFilter;

import vampire.avatar.VampireAvatarHUD;
import vampire.data.VConstants;

/**
 * Tutorial for Vampire.  Add directly to the current mainloop, don't stack it, since it has to
 * work simultaneously with the main game mode.
 *
 * upon the start of each tutorial 'page', call the respective handleMethod.
 * The update loop checks all the pages, if they should transition to another page/chapter.
 *
 * Tutorial text from Jon
 *
 *
 *
 * How's all this sound?



> 1) There's no one here to feed upon, but your "Me" tab has convenient links to friendly players...
>
> //move to a populated room, point out targets
>
> 2) Click "Feed" to see everyone's delicious blood, in all all their varied strains.
>
> //all targets leave
>
> 2b) The herd is skittish.  Try chatting up your feast to make them comfortable with their succulent role.
>
> //targets don't leave
>
> 3) Click the Feed button on some tasty morsel and pull up to your feast.
>
> //game comes up
>
> 4) You can wait for any vampires with you to join in your feast, or just "Start Feeding"
>
> //Feeding closes
>
> 5) Hunt for strains in the blood of the populace.  Click the VW icon to see your status.
>
> //click
>
> 6) The strains you've collected are tallied under "Strains" on the left.  Click it for a look.
>
> //click
>
> 7) Your other driving goal is to build up your Lineage for the coming battles.  Click "Lineage" at the left.
>
> //click
>
> 8) As a newborn, you have no progeny yet.  Click "Build Your Lineage" to find out how to recruit them.
>
> //click
>
> 9) You can see how gathering new recruits will be invaluable down the line.  Click "Recruit!" to invite friends.
>
> //click
> //if already connected, skip ahead
>
> 10) You'll need to fortify your blood to benefit from your progeny.  Click the red back arrow in the upper left.
>
> //click
>
> 11) Only ancient blood can fortify yours.  Click "Strengthen Your Blood" to learn about the power of vampire blood.
>
> //click
>
> 12) Your sire will be your vampiric guide, so shop around before sinking your teeth in.  Click "back".
>
> //click
>
> 13) So get prowling!  Hunt blood strains and recruit progeny for the coming battles of Vampire Whirled!
>


 *
 */
public class TutorialAppMode extends AppMode
{
    public function TutorialAppMode ()
    {
        super();
        _active = true;
        modeSprite.mouseEnabled = true;
        modeSprite.mouseChildren = true;
        _ctrl = ClientContext.ctrl;

        _currentChapter = CHAPTER_LOOKING_FOR_TARGET;
        if (VConstants.LOCAL_DEBUG_MODE) {
            _currentChapter = CHAPTER_NAVIGATING_THE_GUI;
        }

        setPage(PAGE_NOONE_IN_ROOM);
        deactivateTutorial();
    }


    public function deactivateTutorial (...ignored) :void
    {
        ClientContext.gameMode.ctx.mainLoop.removeUpdatable(this);
        if (ClientContext.gameMode.modeSprite.contains(this.modeSprite)) {
            ClientContext.gameMode.modeSprite.removeChild(this.modeSprite);
        }
        resetTargets();
        _active = false;
    }

    public function activateTutorial (...ignored) :void
    {
        ClientContext.gameMode.ctx.mainLoop.addUpdatable(this);
        ClientContext.gameMode.modeSprite.addChild(this.modeSprite);
        _active = true;
        if (_currentChapter == CHAPTER_END) {
            _currentChapter = CHAPTER_LOOKING_FOR_TARGET;
            setPage(PAGE_CLICK_HUD_FEED );
        }
        else {
            setPage(_currentPage);
        }
    }


    override public function update (dt:Number) :void
    {
        super.update(dt);
        trace("update, \n  currentChapter=" + _currentChapter + "\n  currentPage" + _currentPage);
        //Make sure we are always above other windows.
        var parent :DisplayObjectContainer = modeSprite.parent;
        if (parent != null && parent.getChildIndex(modeSprite) < parent.numChildren - 1) {
            parent.addChildAt(modeSprite, parent.numChildren - 1);
        }

        switch (_currentChapter) {

            case CHAPTER_LOOKING_FOR_TARGET:
            chapterLookingForTarget();
            break;

            case CHAPTER_NAVIGATING_THE_GUI:
            chapterGUINavigation();
            break;

            case CHAPTER_END:
            chapterEnd();
            break;

            default:
            break;
        }
    }

    protected function chapterGUINavigation () :void
    {
        switch (_currentPage) {
            case PAGE_CLICK_VW:
            break;

            case PAGE_CLICK_STRAINS:
            updateTargetingRecticleInHelp("to_bloodtype");
            break;

            case PAGE_CLICK_LINEAGE:
            updateTargetingRecticleInHelp("to_default");
            break;

            case PAGE_CLICK_BUILD_LINEAGE:
            updateTargetingRecticleInHelp("link_tolineage");
            if (ClientContext.model != null && ClientContext.model.lineage != null &&
                (ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId) > 0 ||
                ClientContext.model.lineage.isSireExisting(ClientContext.ourPlayerId))) {

                setPage(PAGE_FINALE);
            }

            if (ClientContext.model == null) {
                log.error("chapterGUINavigation", "ClientContext.model", ClientContext.model);
            }

            else if (ClientContext.model.lineage == null) {
                log.error("chapterGUINavigation", "ClientContext.model.lineage", ClientContext.model.lineage);
            }
            else {
                if (ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId) > 0 ||
                ClientContext.model.lineage.isSireExisting(ClientContext.ourPlayerId)) {

                    log.error("chapterGUINavigation", "ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId)", ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId));

                    log.error("chapterGUINavigation", "ClientContext.model.lineage.isSireExisting(ClientContext.ourPlayerId)", ClientContext.model.lineage.isSireExisting(ClientContext.ourPlayerId));
                }
            }

            break;



            case PAGE_CLICK_RECRUIT:
            updateTargetingRecticleInHelp("button_torecruiting");
            break;

            case PAGE_CLICK_BACK:
            updateTargetingRecticleInHelp("help_back");
            if (ClientContext.model != null && ClientContext.model.lineage != null &&
                (ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId) > 0 ||
                ClientContext.model.lineage.isSireExisting(ClientContext.ourPlayerId))) {

                setPage(PAGE_FINALE);
            }
            break;

            case PAGE_CLICK_BLOOD:
            updateTargetingRecticleInHelp("link_tovamps");
            if (ClientContext.model != null && ClientContext.model.lineage != null &&
                (ClientContext.model.lineage.getMinionCount(ClientContext.ourPlayerId) > 0 ||
                ClientContext.model.lineage.isSireExisting(ClientContext.ourPlayerId))) {

                setPage(PAGE_FINALE);
            }
            break;

            case PAGE_CLICK_BACK2:
            updateTargetingRecticleInHelp("help_back");
            break;


            default:
//            log.error("chapterGUINavigation", "_currentPage", _currentPage);
//            setPage(PAGE_CLICK_VW);
        }
    }
    protected function chapterLookingForTarget () :void
    {
        var isAloneInRoom :Boolean = ClientContext.getAvatarIds().length == 1;

        switch (_currentPage) {
            case PAGE_NOONE_IN_ROOM:
            if (!isAloneInRoom) {
                setPage(PAGE_CLICK_HUD_FEED);
                break;
            }
            break;

            case PAGE_CLICK_HUD_FEED:
            //To get to this point, there must have been someone in the room sometime
            if (isAloneInRoom) {
                setPage(PAGE_EVERYONE_LEAVES);
                break;
            }
            break;

            case PAGE_EVERYONE_LEAVES:
            if (!isAloneInRoom) {
                setPage(PAGE_CLICK_HUD_FEED);
                break;
            }
            break;

            case PAGE_CLICK_TARGET_FEED:
            if (isAloneInRoom) {
                setPage(PAGE_EVERYONE_LEAVES);
                break;
            }
            else {
                updateAvatarsWithFeedButtons();
            }
            break;

            case PAGE_LOBBY:
            break;

            default:
            break;
        }
    }

    protected function chapterEnd () :void
    {
        if (_currentPage != PAGE_END) {
            setPage(PAGE_FINALE);
        }
        deactivateTutorial();
    }

    protected function updateTargetingRecticleInHUD (buttonName :String) :void
    {
        resetTargets();

        var sceneObjectName :String = "target: " + buttonName;

        var targetDisplayObject :DisplayObject = ClientContext.hud.findSafely(buttonName);
        var targetReticle :SceneObject = createTargetSceneObject(sceneObjectName);

        var parent :DisplayObjectContainer = targetDisplayObject.parent;
        parent.setChildIndex(targetDisplayObject, parent.numChildren - 1);

        targetDisplayObject.parent.addChildAt(targetReticle.displayObject,
            targetDisplayObject.parent.getChildIndex(targetDisplayObject));

        addObject(targetReticle);

        targetReticle.x = targetDisplayObject.x;
        targetReticle.y = targetDisplayObject.y;
    }

    protected function handleClickHUDFeed () :void
    {
        updateTargetingRecticleInHUD("button_feed");
    }

    protected function handleClickVW () :void
    {
        updateTargetingRecticleInHUD("button_menu");
    }

    protected function handleClickTargetFeed () :void
    {
        updateAvatarsWithFeedButtons();
    }

    protected function updateAvatarsWithFeedButtons () :void
    {
        for each (var avhud :VampireAvatarHUD in ClientContext.avatarOverlay.avatars) {

            var sceneObjectName :String = "target:feed " + avhud.playerId;
            var targetReticle :SceneObject = getObjectNamed(sceneObjectName) as SceneObject;

            var targetDisplayObject :DisplayObject = avhud.targetUI;

            if (avhud.isShowingFeedButton) {
                //If there's no target, add one
                if (targetReticle == null) {
                    targetReticle = createTargetSceneObject(sceneObjectName);

                    targetDisplayObject.parent.addChildAt(targetReticle.displayObject,
                    targetDisplayObject.parent.getChildIndex(targetDisplayObject) );

                    addObject(targetReticle);

                    targetReticle.x = avhud.targetUI.x;
                    targetReticle.y = avhud.targetUI.y;
                }
            }
            else {//IF not, make sure there's so target on the avatar
                if (targetReticle != null) {
                    targetReticle.destroySelf();
                }
            }
        }
    }



    protected function updateTargetingRecticleInHelp (buttonName :String) :void
    {
        var sceneObjectName :String = "target:" + buttonName;
        var targetReticle :SceneObject = getObjectNamed(sceneObjectName) as SceneObject;

        //Is there a help popup?
        if (ClientContext.gameMode.getObjectNamed(HelpPopup.NAME) != null) {
            if (targetReticle == null) {
                targetReticle = createTargetSceneObject(sceneObjectName);

                var help :HelpPopup =
                    ClientContext.gameMode.getObjectNamed(HelpPopup.NAME) as HelpPopup;
                var targetDisplayObject :DisplayObject = help.findSafely(buttonName);

                targetReticle.x = targetDisplayObject.x;
                targetReticle.y = targetDisplayObject.y;

                targetDisplayObject.parent.addChildAt(targetReticle.displayObject,
                    targetDisplayObject.parent.getChildIndex(targetDisplayObject) );

                addObject(targetReticle);
            }
        }
        else {
            trace("updateTargetingRecticleInHelp, there's no help popup, buttonName="+buttonName);
            if (targetReticle != null && targetReticle.isLiveObject) {
                targetReticle.destroySelf();
            }
        }
    }

    protected function handleEnd () :void
    {
        deactivateTutorial();
    }




    /**
    * Remove/reset the visible tutorial targets.
    */
    protected function resetTargets () :void
    {
        for each (var so :SceneObject in _targets) {
            if (so.isLiveObject) {
                so.destroySelf();
            }
        }
        _targets.splice(0);
    }

    protected function createTargetReticle () :MovieClip
    {
        var reticle :MovieClip =
            ClientContext.instantiateMovieClip("HUD", "reticle", true) as MovieClip;

//        var glow :GlowFilter = new GlowFilter(0xD5EBF2);
//        reticle.filters = [glow];

        return reticle;
    }

    protected function createTargetSceneObject (name :String) :SceneObject
    {
        var s :SceneObject = new SimpleSceneObject(createTargetReticle(), name);
        _targets.push(s);
        return s;
    }

    protected function setPage (newPage :String) :void
    {
            resetTargets();
            _currentPage = newPage;
            _pagesSeen.add(newPage);

            if (_active) {

                try {
                    this["handle" + newPage]();
                }
                catch (err :Error) {

                }

                var wasAlreadyTutorial :Boolean = _tutorialPopup != null;

                if (_tutorialPopup != null) {
                    _tutorialPopup.destroySelf();
                }
                _tutorialPopup = new PopupQuery(
                                            "tutorial",
                                            getPageMessage(_currentPage),
                                            [],//["Close tutorial"],
                                            [deactivateTutorial]);


                ClientContext.placeTopRight(_tutorialPopup.displayObject);
                _tutorialPopup.x -= 110;
                _tutorialPopup.y += 100;

                addSceneObject(_tutorialPopup, modeSprite);

                if(!wasAlreadyTutorial) {
                    ClientContext.animateEnlargeFromMouseClick(_tutorialPopup);
                }
            }


    }

    protected function getPageMessage (page :String) :String
    {
        for each (var arr :Array in TUTORIAL_ACTIONS) {
            if (arr[0] == page) {
                return arr[1];
            }
        }
        return "No page message found for " + page;
    }

    public function clickedFeedHUDButton () :void
    {
        if (_currentPage == PAGE_CLICK_HUD_FEED) {
            setPage(PAGE_CLICK_TARGET_FEED);
        }
    }

    public function clickedFeedAvatarButton () :void
    {
        if (_currentPage == PAGE_CLICK_TARGET_FEED) {
            setPage(PAGE_LOBBY);
        }
    }

    public function feedGameOver () :void
    {
        if (_currentChapter == CHAPTER_LOOKING_FOR_TARGET) {
            setPage(PAGE_CLICK_VW);
        }
    }

    public function feedGameStarted () :void
    {
        if (_currentChapter == CHAPTER_LOOKING_FOR_TARGET) {
            setPage(PAGE_LOBBY);
        }
    }

    public function clickedVWButtonOpenHelp () :void
    {
        if (_currentPage == PAGE_CLICK_VW) {
            _currentChapter = CHAPTER_NAVIGATING_THE_GUI;
            setPage(PAGE_CLICK_STRAINS);
        }
    }

    public function clickedVWButtonCloseHelp () :void
    {
        if (_currentChapter == CHAPTER_NAVIGATING_THE_GUI) {
            resetTargets();
            _currentChapter = CHAPTER_END;
            deactivateTutorial();
        }
    }

    public function clickedStrains () :void
    {
        if (_currentPage == PAGE_CLICK_STRAINS) {
            setPage(PAGE_CLICK_LINEAGE);
        }
    }
    public function clickedLineage () :void
    {
        if (_currentPage == PAGE_CLICK_LINEAGE) {
            setPage(PAGE_CLICK_BUILD_LINEAGE);
        }
    }

    public function clickedBuildLineage () :void
    {
        if (_currentPage == PAGE_CLICK_BUILD_LINEAGE) {
            setPage(PAGE_CLICK_RECRUIT);
        }
    }

    public function clickedRecruit () :void
    {
        if (_currentPage == PAGE_CLICK_RECRUIT) {
            setPage(PAGE_CLICK_BACK);
        }
    }

    public function clickedBack () :void
    {
        if (_currentPage == PAGE_CLICK_BACK) {
            setPage(PAGE_CLICK_BLOOD);
        }

        if (_currentPage == PAGE_CLICK_BACK2) {
            setPage(PAGE_FINALE);
        }
    }

    public function clickedBlood () :void
    {
        if (_currentPage == PAGE_CLICK_BLOOD) {
            setPage(PAGE_CLICK_BACK2);
        }
    }

    protected var _active :Boolean;

//    protected var _pageChanged :Boolean = false;

    protected var _pagesSeen :HashSet = new HashSet();

    protected var _targets :Array = [];

//    protected var _currentPageIndex :int;
    protected var _currentChapter :String;
    protected var _currentPage :String;
    protected var _tutorialPopup :PopupQuery;

    protected var _ctrl :AVRGameControl;


    public static const CHAPTER_LOOKING_FOR_TARGET :String = "Chapter: Looking for target";

    public static const PAGE_NOONE_IN_ROOM :String = "NooneInTheRoom";
    public static const PAGE_EVERYONE_LEAVES :String = "EveryoneLeaves";
    public static const PAGE_CLICK_HUD_FEED :String = "ClickHUDFeed";
    public static const PAGE_CLICK_TARGET_FEED :String = "ClickTargetFeed";
    public static const PAGE_LOBBY :String = "Lobby";

    public static const CHAPTER_NAVIGATING_THE_GUI :String = "Chapter: GUI Navigation";

    public static const PAGE_CLICK_VW :String = "ClickVW";
    public static const PAGE_CLICK_STRAINS :String = "ClickStrains";
    public static const PAGE_CLICK_LINEAGE :String = "ClickLineage";
    public static const PAGE_CLICK_BUILD_LINEAGE :String = "ClickBuildLineage";
    public static const PAGE_CLICK_RECRUIT :String = "ClickRecruit";
    public static const PAGE_CLICK_BACK :String = "ClickBack";
    public static const PAGE_CLICK_BLOOD :String = "ClickBlood";
    public static const PAGE_CLICK_BACK2 :String = "ClickBack2";

    public static const CHAPTER_END :String = "Chapter: End";
    public static const PAGE_FINALE :String = "Final";

    public static const PAGE_END :String = "End";

    public static const TUTORIAL_ACTIONS :Array = [
        [PAGE_NOONE_IN_ROOM, "There's no one here to feed upon, but your \"Me\" tab has convenient links to friendly players..."],
        [PAGE_CLICK_HUD_FEED, "Click \"Feed\" to see everyone's delicious blood, in all all their varied strains."],
        [PAGE_EVERYONE_LEAVES, "The herd is skittish.  Try chatting up your feast to make them comfortable with their succulent role."],
        [PAGE_CLICK_TARGET_FEED, "Click the Feed button on some tasty morsel and pull up to your feast."],
        [PAGE_LOBBY, "You can wait for any vampires with you to join in your feast, or just \"Start Feeding\""],
        [PAGE_CLICK_VW, "Hunt for strains in the blood of the populace.  Click the VW icon to see your status."],
        [PAGE_CLICK_STRAINS, "The strains you've collected are tallied under \"Strains\" on the left.  Click it for a look."],
        [PAGE_CLICK_LINEAGE, "Your other driving goal is to build up your Lineage for the coming battles.  Click \"Lineage\" at the left."],
        [PAGE_CLICK_BUILD_LINEAGE, "As a newborn, you have no progeny yet.  Click \"Build Your Lineage\" to find out how to recruit them."],
        [PAGE_CLICK_RECRUIT, "You can see how gathering new recruits will be invaluable down the line.  Click \"Recruit!\" to invite friends."],
        [PAGE_CLICK_BACK, "You'll need to fortify your blood to benefit from your progeny.  Click the red back arrow in the upper left."],
        [PAGE_CLICK_BLOOD, "Only ancient blood can fortify yours.  Click \"Strengthen Your Blood\" to learn about the power of vampire blood."],
        [PAGE_CLICK_BACK2, "Your sire will be your vampiric guide, so shop around before sinking your teeth in.  Click \"back\"."],
        [PAGE_FINALE, "So get prowling!  Hunt blood strains and recruit progeny for the coming battles of Vampire Whirled!"]
    ];

    protected static const log :Log = Log.getLog(TutorialAppMode);
}
}