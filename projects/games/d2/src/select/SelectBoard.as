package select {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.BitmapAsset;
import mx.core.MovieClipLoaderAsset;
import mx.containers.VBox;
import mx.controls.Image;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Assert;

import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;

import def.BoardDefinition;

import modes.GameModeCanvas;

public class SelectBoard extends GameModeCanvas
{
    public function SelectBoard (main :Main)
    {
        super(main);
    }

    // from Canvas
    override protected function createChildren () :void
    {
        super.createChildren();

        var bg :Image = new Image();
        addChild(bg);

        _loader = new _screen();
        _loader.addEventListener(Event.COMPLETE, doneLoading);
        bg.source = _loader;
    }

    // from GameModeCanvas
    override public function pushed () :void
    {
        _controller = new SelectController(_main);
        _controller.init(_main.whirled, boardSelected, allSelected);
    }
    
    // from GameModeCanvas
    override public function popped () :void
    {
        _controller.shutdown();
        _controller = null;
    }

    /**
     * After the board selection background loads, populate it with boards,
     * and hook up the back button.
     */
    protected function doneLoading (event :Event) :void
    {
        _loader.removeEventListener(Event.COMPLETE, doneLoading);

        displayBoardPictures();
        
        var back :DisplayObject = DisplayUtil.findInHierarchy(_loader, "button_back");
        Assert.isNotNull(back);
        back.addEventListener(MouseEvent.CLICK, goBack);
    }

    /** Displays board pictures for all boards, so that players can pick. */
    protected function displayBoardPictures () :void
    {
        Assert.isNotNull(_controller);
        
        _display = new BoardDisplay(_main.defs, _controller);
        addChild(_display);
    }

    /** Called when any user pick the board. */
    protected function boardSelected (playerId :int, board :BoardDefinition) :void
    {
        trace("BOARD SELECTED! " + playerId + ": " + board);
    }

    /** Called when *all* users pick the same board. */
    protected function allSelected (board :BoardDefinition) :void
    {
        trace("ALL SELECTED! " + board);
    }
                                                             
    /** Called when the user clicked the back button. */
    protected function goBack (event :Event) :void
    {
        trace("GO BACK!");
        _main.modes.pop();
    }

        
    /** Loader for the embedded screen selection swf. */
    protected var _loader :MovieClipLoaderAsset;

    /** Controller for player selection clicks. */
    protected var _controller :SelectController;
    
    /** Board selection container. */
    protected var _display :VBox;
    
    /** Screen selection screen. */
    [Embed(source="../../rsrc/selectscreen/selectscreen.swf")]
    protected static const _screen :Class;

    [Embed(source="../../rsrc/placeholder.png")]
    protected static const _placeholder :Class;
}
}
