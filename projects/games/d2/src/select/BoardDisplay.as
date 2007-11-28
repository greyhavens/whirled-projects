package select {

import mx.containers.HBox;
import mx.containers.VBox;

import def.BoardDefinition;
import def.Definitions;

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

        _boards = new HBox();
        _boards.width = 500;
        _boards.height = 200;
        _boards.styleName = "boardSelectionContainer";
        addChild(_boards);

        // make a board button for each board
        _defs.boards.forEach(function (board :BoardDefinition, ... ignore) :void {
                _boards.addChild(new BoardButton(_controller, board));                
            });
    }

    protected function findButton (boardGuid :String) :BoardButton
    {
        var children :Array = _boards.getChildren();
        var index :int = ArrayUtil.indexIf(
            children,
            function (elt :*) :Boolean {
                return (elt is BoardButton) && (elt as BoardButton).board.guid == boardGuid;
            });

        return (index >= 0) ? (children[index] as BoardButton) : null;
    }
        
    protected var _boards :HBox;
    protected var _controller :SelectController;
    protected var _defs :Definitions;
}
}

/** Helper class that encapsulates a single board button. */

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
    public static const BOARD_WIDTH :int = 140;
    public static const BOARD_HEIGHT :int = 100;

    public var controller :SelectController;
    public var board :BoardDefinition;
    
    public function BoardButton (controller :SelectController, board :BoardDefinition)
    {
        this.controller = controller;
        this.board = board;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        Assert.isNotNull(controller);
        Assert.isNotNull(board);
        
        addEventListener(MouseEvent.CLICK,
                         function (event :MouseEvent) :void {
                             controller.handleClick(board);
                         },
                         false, 0, true);
        
        this.styleName = "boardSelectionButton";
        
        // make a clickable image for each board
        var icon :Image = new Image();
        icon.source = new BitmapAsset(board.icon);
        icon.scaleX = BOARD_WIDTH / board.icon.width;
        icon.scaleY = BOARD_HEIGHT / board.icon.height;
        icon.useHandCursor = true;
        addChild(icon);
        
        // now add the name
        var name :Text = new Text();
        name.styleName = "boardSelectionLabel";
        name.text = StringUtil.truncate(board.name, 20, "...");
        addChild(name);
    }
}

