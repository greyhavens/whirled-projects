package select {

import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Image;
import mx.controls.Text;
import mx.core.BitmapAsset;

import def.BoardDefinition;
import def.Definitions;

public class BoardDisplay extends VBox
{
    public static const BOARD_WIDTH :int = 140;
    public static const BOARD_HEIGHT :int = 100;

    public function BoardDisplay (defs :Definitions)
    {
        _defs = defs;

        this.x = 100;
        this.y = 150;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var makeClickHandler :Function = function (board :BoardDefinition) :Function {
            return function (event :MouseEvent) :void {
                trace("Board selected: " + board);
                // _controller.playerSelectedBoard(board);
            }
        }

        var boards :HBox = new HBox();
        boards.width = 500;
        boards.height = 200;
        boards.styleName = "boardSelectionContainer";
        addChild(boards);
        
        _defs.boards.forEach(function (board :BoardDefinition, ... ignore) :void {

                var box :VBox = new VBox();
                box.addEventListener(MouseEvent.CLICK, makeClickHandler(board), false, 0, true);
                boards.addChild(box);
                
                // make a clickable image for each board
                var icon :Image = new Image();
                icon.source = new BitmapAsset(board.icon);
                icon.scaleX = BOARD_WIDTH / board.icon.width;
                icon.scaleY = BOARD_HEIGHT / board.icon.height;
                icon.useHandCursor = true;
                box.addChild(icon);
        
                // now add the name
                var name :Text = new Text();
                name.styleName = "boardSelectionLabel";
                name.htmlText = board.name;
                box.addChild(name);
                
            });
    }
    
    protected var _defs :Definitions;
}
}
