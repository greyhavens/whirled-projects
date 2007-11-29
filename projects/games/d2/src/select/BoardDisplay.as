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
                                    pack.icon, pack.name, null));
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
                                     board.icon, board.name, board));
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

import flash.display.BitmapData;
import flash.events.MouseEvent;

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
    public var myicon :BitmapData;
    public var myname :String;
    public var arg :Object;
    
    public function BoardButton (
        thunk :Function, myicon :BitmapData, myname :String, arg :Object)
    {
        this.thunk = thunk;
        this.myicon = myicon;
        this.myname = myname;
        this.arg = arg;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        Assert.isNotNull(thunk);
        Assert.isNotNull(myicon);
        
        addEventListener(MouseEvent.CLICK,
                         function (event :MouseEvent) :void { thunk(); },
                         false, 0, true);
        
        this.styleName = "boardSelectionButton";
        
        // make a clickable image for each board
        var img :Image = new Image();
        img.source = new BitmapAsset(myicon);
        img.scaleX = BOARD_WIDTH / myicon.width;
        img.scaleY = BOARD_HEIGHT / myicon.height;
        img.useHandCursor = true;
        addChild(img);
        
        // now add the name
        var name :Text = new Text();
        name.styleName = "boardSelectionLabel";
        name.text = StringUtil.truncate(myname, 20, "...");
        addChild(name);
    }
}

