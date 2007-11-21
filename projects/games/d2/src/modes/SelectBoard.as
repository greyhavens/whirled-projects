package modes {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.MovieClipLoaderAsset;
import mx.controls.Image;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Assert;

import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;

public class SelectBoard extends GameModeCanvas
{
    public function SelectBoard (modes :GameModeStack)
    {
        super(modes);
    }

    // from Canvas
    override protected function createChildren () :void
    {
        super.createChildren();

        _loader = new _screen();
        _loader.addEventListener(Event.COMPLETE, doneLoading);
        
        var bg :Image = new Image();
        bg.source = _loader;
        addChild(bg);
    }

    /**
     * After the board selection background loads, populate it with boards,
     * and hook up the back button.
     */
    protected function doneLoading (event :Event) :void
    {
        _loader.removeEventListener(Event.COMPLETE, doneLoading);

        // todo: scrape board pictures from content packs and display them here
        
        var back :DisplayObject = DisplayUtil.findInHierarchy(_loader, "button_back");
        Assert.isNotNull(back);
        back.addEventListener(MouseEvent.CLICK, goBack);
    }

    /** Called when the user clicked the back button. */
    protected function goBack (event :Event) :void
    {
        trace("GO BACK!");
        getGameModeStack().pop();
    }

        
    /** Loader for the embedded screen selection swf. */
    protected var _loader :MovieClipLoaderAsset;

    /** Screen selection screen. */
    [Embed(source="../../rsrc/selectscreen/selectscreen.swf")]
    protected static const _screen :Class;
}
}
