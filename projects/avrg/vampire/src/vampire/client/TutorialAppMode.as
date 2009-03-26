package vampire.client
{
import com.threerings.util.HashSet;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import vampire.avatar.VampireAvatarHUD;

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


        setPage(PAGE_NOONE_IN_ROOM);
    }

    /**
    * Recomputes the tutorial state given the current state
    *
    */
    public function nextAction () :void
    {

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
        setPage(_currentPage);
        _active = true;
    }



    public function tutorialActionDone (action :String) :void
    {
        switch( action ) {

            case PAGE_NOONE_IN_ROOM:

            break;
        }
    }

    override public function update (dt:Number) :void
    {
        super.update(dt);
        switch( _currentChapter ) {

            case CHAPTER_LOOKING_FOR_TARGET:
            chapterLookingForTarget();
            break;

            case CHAPTER_NAVIGATING_THE_GUI:
            chapterGUINavigation();
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

            default:
            break;
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

    protected function handleNooneInTheRoom () :void
    {
    }
    protected function handleClickHUDFeed () :void
    {
        resetTargets();

        var target :DisplayObject = ClientContext.hud.findSafely("button_feed");
        var targetOverlay :SceneObject = createTargetSceneObject("target:HUD feed");
        addSceneObject(targetOverlay, target.parent);
        targetOverlay.x = target.x;
        targetOverlay.y = target.y;
    }

    protected function handleClickVW () :void
    {
        var target :DisplayObject = ClientContext.hud.findSafely("button_menu");
        var targetOverlay :SceneObject = createTargetSceneObject("target:VW");
        addSceneObject(targetOverlay, target.parent);
        targetOverlay.x = target.x;
        targetOverlay.y = target.y;
    }

    protected function handleClickStrains () :void
    {
        var target :DisplayObject = ClientContext.hud.findSafely("button_menu");
        var targetOverlay :SceneObject = createTargetSceneObject("target:Strains");
        addSceneObject(targetOverlay, target.parent);
        targetOverlay.x = target.x;
        targetOverlay.y = target.y;
    }

    protected function handleClickLineage () :void
    {
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

            if (avhud.isShowingFeedButton) {
                //If there's no target, add one
                if (targetReticle == null) {
                    targetReticle = createTargetSceneObject(sceneObjectName);
                    addSceneObject(targetReticle, avhud.targetUI.parent);
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

    protected function handleEveryoneLeaves () :void
    {
    }

    protected function handleLobby () :void
    {
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
        return ClientContext.instantiateMovieClip("HUD", "reticle", true) as MovieClip;
    }

    protected function createTargetSceneObject (name :String) :SceneObject
    {
        var s :SceneObject = new SimpleSceneObject(createTargetReticle(), name);
        _targets.push(s);
        return s;
    }

    protected function setPage (newPage :String) :void
    {
//        if (newPage != _currentPage) {
            resetTargets();
            _currentPage = newPage;
//            _pageChanged = true;
            _pagesSeen.add(newPage);

            if (_active) {

                this["handle" + newPage]();

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
                _tutorialPopup.x -= 130;
                _tutorialPopup.y += 120;

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
            _currentChapter == CHAPTER_NAVIGATING_THE_GUI;
            setPage(PAGE_CLICK_VW);
        }
    }

    public function clickedVWButton () :void
    {
        if (_currentPage == PAGE_CLICK_VW) {
            setPage(PAGE_CLICK_STRAINS);
        }
    }

    public function clickedStrains () :void
    {
        if (_currentPage == PAGE_CLICK_STRAINS) {
            setPage(PAGE_CLICK_LINEAGE);
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

    public static const CHAPTER_END :String = "Chapter: End";

    public static const TUTORIAL_ACTIONS :Array = [
        [PAGE_NOONE_IN_ROOM, "There's no one here to feed upon, but your \"Me\" tab has convenient links to friendly players..."],
        [PAGE_CLICK_HUD_FEED, "Click \"Feed\" to see everyone's delicious blood, in all all their varied strains."],
        [PAGE_EVERYONE_LEAVES, "The herd is skittish.  Try chatting up your feast to make them comfortable with their succulent role."],
        [PAGE_CLICK_TARGET_FEED, "Click the Feed button on some tasty morsel and pull up to your feast."],
        [PAGE_LOBBY, "You can wait for any vampires with you to join in your feast, or just \"Start Feeding\""],
        [PAGE_CLICK_VW, "Hunt for strains in the blood of the populace.  Click the VW icon to see your status."],
        [PAGE_CLICK_STRAINS, "The strains you've collected are tallied under \"Strains\" on the left.  Click it for a look."],
        [PAGE_CLICK_LINEAGE, "Your other driving goal is to build up your Lineage for the coming battles.  Click \"Lineage\" at the left."],



    ];
}
}