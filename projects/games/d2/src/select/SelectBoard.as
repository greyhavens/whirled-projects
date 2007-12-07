package select {

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.Event;
import flash.events.MouseEvent;

import mx.core.BitmapAsset;
import mx.core.MovieClipLoaderAsset;
import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Text;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.Assert;
import com.threerings.util.StringUtil;

import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;

import def.BoardDefinition;
import game.Display;
import game.GameLoader;
import modes.GameModeCanvas;


public class SelectBoard extends GameModeCanvas
{
    public function SelectBoard (main :Main)
    {
        super(main);
    }

    // from GameModeCanvas
    override public function pushed () :void
    {
        var bg :Image = new Image();
        addChild(bg);

        _loader = new _screen();
        _loader.addEventListener(Event.COMPLETE, doneLoading);
        bg.source = _loader;

        _controller = new SelectController(_main);
        _controller.init(_main.whirled, boardSelected, allSelected);
        
        // rest of initialization will happen in doneLoading()
    }
    
    /**
     * After the board selection background loads, populate it with boards,
     * and hook up the back button.
     */
    protected function doneLoading (event :Event) :void
    {
        Assert.isNotNull(_controller);
        
        _loader.removeEventListener(Event.COMPLETE, doneLoading);
        _display = new BoardDisplay(_main.defs, _loader, _controller);
        addChild(_display);

        _feedback = new Text();
        _feedback.styleName = "boardSelectionLabel";
        _feedback.x = 250;
        _feedback.y = 420;
        addChild(_feedback);

        var back :DisplayObject = DisplayUtil.findInHierarchy(_loader, "button_back");
        Assert.isNotNull(back);
        back.addEventListener(MouseEvent.CLICK, goBack);
    }

    // from GameModeCanvas
    override public function popped () :void
    {
        _display = null;
        _feedback = null;
        _loader = null;
        
        _controller.shutdown();
        _controller = null;

        removeAllChildren();
    }

    // from interface GameMode
    override public function poppedFrom (mode :GameMode) :void
    {
        _display.refresh();
    }

    /** Called when any user pick the board. */
    protected function boardSelected (playerId :int, boardGuid :String) :void
    {
        var board :BoardDefinition = _main.defs.findBoard(boardGuid);
        trace("BOARD SELECTED! " + playerId + ": " + board);

        if (! _main.isSinglePlayer) {
            var other :BoardDefinition = _main.defs.findBoard(_controller.getOpponentBoardGuid());

            if (other == null) {
                _feedback.htmlText = Messages.get("opponent_needs_board");
            } else {
                _feedback.htmlText = Messages.get("opponent_differs") +
                    StringUtil.truncate(other.name, 20, "...") + "<br>" +
                    Messages.get("please_pick_same");
            }
        }
    }
    
    /** Called when *all* users pick the same board. */
    protected function allSelected (boardGuid :String) :void
    {
        var board :BoardDefinition = _main.defs.findBoard(boardGuid);

        _main.modes.push(new GameLoader(_main, [ board ]));
    }

    /** Called when the user clicked the back button. */
    protected function goBack (event :Event) :void
    {
        _main.modes.pop();
    }
        
    /** Loader for the embedded screen selection swf. */
    protected var _loader :MovieClipLoaderAsset;

    /** Controller for player selection clicks. */
    protected var _controller :SelectController;
    
    /** Board selection container. */
    protected var _display :BoardDisplay;

    /** Board selection feedback label. */
    protected var _feedback :Text;
    
    /** Screen selection screen. */
    [Embed(source="../../rsrc/selectscreen/selectscreen.swf")]
    protected static const _screen :Class;

    [Embed(source="../../rsrc/placeholder.png")]
    protected static const _placeholder :Class;
}
}
