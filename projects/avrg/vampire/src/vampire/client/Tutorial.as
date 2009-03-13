package vampire.client
{
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.avrg.DraggableSceneObject;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;

public class Tutorial extends DraggableSceneObject
{
    public function Tutorial(ctrl:AVRGameControl, parentSprite :DisplayObjectContainer)
    {
        super(ctrl);
        _parent = parentSprite;
        _popupPanel = ClientContext.instantiateMovieClip("HUD", "popup", false);
        _displaySprite.addChild( _popupPanel );

        registerListener( _popupPanel["help_close"], MouseEvent.CLICK,
            function( e :MouseEvent ) :void {
                destroySelf();
            });

        _currentChapter = CHAPTER_LOOKING_FOR_TARGET;
    }

    public function activateTutorial() :void
    {
        _parent.addChild( _displaySprite );
        centerOnViewableRoom();
        //Move to top right
    }

    public function nextAction() :void
    {

    }

    public function tutorialActionDone( action :String ) :void
    {
        switch( action ) {

            case PAGE_NOONE_IN_ROOM:

            break;
        }
    }

    override protected function update(dt:Number):void
    {
        switch( _currentChapter ) {

            case CHAPTER_LOOKING_FOR_TARGET:
            chapterLookingForTarget();
            break;

            default:
            break;
        }
    }

    protected function chapterLookingForTarget() :void
    {
        switch( _currentPage ) {
            case PAGE_NOONE_IN_ROOM:
            
            
            
            break;

            case PAGE_CHAT_UP_TARGET:
            break;

            default:
            break;
        }
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected var _parent :DisplayObjectContainer;
    protected var _popupPanel :MovieClip;
    protected var _currentActionIndex :int;
    protected var _currentChapter :String;
    protected var _currentPage :String;
    protected static const NAME :String = "Tutorial";

    public static const CHAPTER_LOOKING_FOR_TARGET :String = "Chapter: Looking for target";

    public static const PAGE_NOONE_IN_ROOM :String = "Page: No-one in the room";
    public static const PAGE_CHAT_UP_TARGET :String = "Page: Chat up target";

    public static const TUTORIAL_ACTIONS :Array = [
        [PAGE_NOONE_IN_ROOM, "There's no one here to feed upon, but your \"Me\" tab has convenient links to friendly players..."],
        [PAGE_CHAT_UP_TARGET, "Chat up your prey so you don't frighten them off.  Make them comfortable with their fate..."],
    ];
}
}