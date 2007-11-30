package select {

import mx.containers.HBox;
import mx.containers.VBox;

import def.BoardDefinition;
import def.Definitions;
import def.PackDefinition;

import com.threerings.util.ArrayUtil;

public class BoardDisplay extends VBox
{
    public function BoardDisplay (defs :Definitions, controller :SelectController)
    {
        _defs = defs;
        _controller = controller;

        this.x = 100;
        this.y = 150;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        _packs = new HBox();
        _packs.width = 500;
        _packs.height = 100;
        _packs.styleName = "boardSelectionContainer";
        addChild(_packs);

        // make a pack button for each pack
        _defs.packs.forEach(function (pack :PackDefinition, ... ignore) :void {
                _packs.addChild(new BoardButton(
                                    function () :void { packSelected(pack); },
                                    pack.button, pack.name, null));
            });
        
        _boards = new HBox();
        _boards.width = 500;
        _boards.height = 100;
        _boards.styleName = "boardSelectionContainer";
        addChild(_boards);
    }

    /** Called when user clicks on a content pack button. */
    protected function packSelected (pack :PackDefinition) :void
    {
        _boards.removeAllChildren();
        
        // make a board button for each board
        pack.boards.forEach(function (board :BoardDefinition, ... ignore) :void {
                _boards.addChild(new BoardButton(
                                     function () :void { _controller.boardSelected(board); },
                                     board.button, board.name, board));
            });
    }

    protected function findButton (boardGuid :String) :BoardButton
    {
        var children :Array = _boards.getChildren();
        var index :int = ArrayUtil.indexIf(
            children,
            function (elt :*) :Boolean {
                var board :BoardButton = elt.arg as BoardButton;
                return (board != null) && (board.guid == boardGuid);
            });

        return (index >= 0) ? (children[index] as BoardButton) : null;
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

internal class BoardButton extends VBox
{
    public static const BOARD_WIDTH :int = 70;
    public static const BOARD_HEIGHT :int = 50;

    public var thunk :Function;
    public var button :DisplayObject;
    public var myname :String;
    public var arg :Object;
    
    public function BoardButton (
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
        
        addEventListener(MouseEvent.CLICK,
                         function (event :MouseEvent) :void { thunk(); },
                         false, 0, true);
        
        this.styleName = "boardSelectionButton";
        
        // now add the name
        var name :Text = new Text();
        name.styleName = "boardSelectionLabel";
        name.text = StringUtil.truncate(myname, 20, "...");
        addChild(name);
    }
}

