package select {

import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.containers.Canvas;
import mx.core.MovieClipLoaderAsset;
import mx.core.ScrollPolicy;

import def.BoardDefinition;
import def.Definitions;
import def.PackDefinition;

import com.threerings.flash.MathUtil;
import com.threerings.flash.DisplayUtil;
import com.threerings.util.ArrayUtil;

public class BoardDisplay extends Canvas
{
    public function BoardDisplay (
        defs :Definitions, loader :MovieClipLoaderAsset, controller :SelectController)
    {
        _defs = defs;
        _controller = controller;

        DisplayUtil.findInHierarchy(loader, "level_prev").addEventListener(
            MouseEvent.CLICK, function (event :MouseEvent) :void { scroll(_boards, -50); },
            false, 0, true);

        DisplayUtil.findInHierarchy(loader, "level_next").addEventListener(
            MouseEvent.CLICK, function (event :MouseEvent) :void { scroll(_boards, 50); },
            false, 0, true);

        DisplayUtil.findInHierarchy(loader, "pack_prev").addEventListener(
            MouseEvent.CLICK, function (event :MouseEvent) :void { scroll(_packs, -50); },
            false, 0, true);
        
        DisplayUtil.findInHierarchy(loader, "pack_next").addEventListener(
            MouseEvent.CLICK, function (event :MouseEvent) :void { scroll(_packs, 50); },
            false, 0, true);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        _packs = new HBox();
        _packs.x = 80;
        _packs.y = 130;
        _packs.width = 560;
        _packs.height = 130;
        _packs.styleName = "boardSelectionContainer";
        _packs.verticalScrollPolicy = ScrollPolicy.OFF;
        _packs.horizontalScrollPolicy = ScrollPolicy.OFF;
        addChild(_packs);

        showPacks();
        
        _boards = new HBox();
        _boards.x = 80;
        _boards.y = 280;
        _boards.width = 560;
        _boards.height = 130;
        _boards.styleName = "boardSelectionContainer";
        _boards.verticalScrollPolicy = ScrollPolicy.OFF;
        _boards.horizontalScrollPolicy = ScrollPolicy.OFF;
        addChild(_boards);
    }

    /**
     * Called by the select game mode, to refresh all display elements after the mode is
     * reactivated.
     */
    public function refresh () :void
    {
        showPacks();
    }
    
    /** Scrolls the horizontal button containers. */
    protected function scroll (container :HBox, delta :int) :void
    {
        container.horizontalScrollPosition =
            MathUtil.clamp(container.horizontalScrollPosition + delta,
                           0, container.maxHorizontalScrollPosition);
    }

    /** Displays pack buttons. */
    protected function showPacks () :void
    {
        _packs.removeAllChildren();
        
        // make a pack button for each pack
        _defs.packs.forEach(function (pack :PackDefinition, ... ignore) :void {
                _packs.addChild(new Button(
                                    function () :void { packSelected(pack); },
                                    pack.button, pack.name, null));
            });
    }
    
    /** Called when user clicks on a content pack button. */
    protected function packSelected (pack :PackDefinition) :void
    {
        _boards.removeAllChildren();
        
        // make a board button for each board
        pack.boards.forEach(function (board :BoardDefinition, ... ignore) :void {
                _boards.addChild(new Button(
                                     function () :void { _controller.boardSelected(board); },
                                     board.button, board.name, board));
            });
    }

    protected function findButton (boardGuid :String) :Button
    {
        var children :Array = _boards.getChildren();
        var index :int = ArrayUtil.indexIf(
            children,
            function (elt :*) :Boolean {
                var board :Button = elt.arg as Button;
                return (board != null) && (board.guid == boardGuid);
            });

        return (index >= 0) ? (children[index] as Button) : null;
    }

    protected var _packs :HBox, _boards :HBox;
    protected var _controller :SelectController;
    protected var _defs :Definitions;
}
}

/** Helper class that encapsulates a single board button. */

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Text;
import mx.core.BitmapAsset;

import def.BoardDefinition;
import select.SelectController;

import com.threerings.util.StringUtil;
import com.threerings.util.Assert;

internal class Button extends VBox
{
    public static const BOARD_WIDTH :int = 70;
    public static const BOARD_HEIGHT :int = 50;

    public var thunk :Function;
    public var button :DisplayObject;
    public var myname :String;
    public var arg :Object;
    
    public function Button (
        thunk :Function, button :DisplayObject, myname :String, arg :Object)
    {
        this.thunk = thunk;
        this.button = button;
        this.myname = myname;
        this.arg = arg;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        Assert.isNotNull(thunk);
        Assert.isNotNull(button);

        // wrap the button in a canvas, so that we can add it to the flex display tree
        var bc :Canvas = new Canvas();
        bc.rawChildren.addChild(button);
        bc.width = button.width;
        bc.height = button.height;
        addChild(bc);

        // clicking on the entire button should take you places!
        addEventListener(MouseEvent.CLICK,
                         function (event :MouseEvent) :void { thunk(); });
        
        this.toolTip = myname;
        this.styleName = "boardSelectionButton";
    }
}

