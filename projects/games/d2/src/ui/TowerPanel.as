package ui {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.BoxDirection;
import mx.containers.Tile;
import mx.containers.TitleWindow;
import mx.containers.HBox;
import mx.controls.Button;
import mx.controls.Label;
import mx.controls.Text;
import mx.events.ItemClickEvent;

import game.Board;
import game.Display;
import game.Game;

import def.TowerDefinition;


public class TowerPanel extends TitleWindow
    implements UnloadListener
{
    public function TowerPanel (display :Display, board :Board, game :Game)
    {
        _display = display;
        _board = board;
        _game = game;
        
        this.title = Messages.get("menu_title");
        this.showCloseButton = false;
        this.x = 800;
        this.y = 10;
    }
        
    override protected function createChildren () :void
    {
        super.createChildren();
        
        _buttons = new Tile();
        _buttons.width = 110;
        addChild(_buttons);

        var titlebar :HBox = new HBox();
        titlebar.styleName = "towerNameBox";
        addChild(titlebar);

        _title = new Label();
        _title.width = 110;
        titlebar.addChild(_title);
        
        _desc = new Text();
        _desc.width = 110;
        addChild(_desc);
        
        addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);

        var towers :Array = _board.getAvailableTowers();
        towers.forEach(function(tdef :TowerDefinition, i :int, a :Array) :void {
                var b :Button = new Button();
                b.styleName = tdef.buttonStyleName;
                b.id = String(i);
                b.addEventListener(MouseEvent.MOUSE_OVER, makeDescriptionFn(tdef));
                b.addEventListener(MouseEvent.MOUSE_OUT, makeDescriptionFn(null));
                b.addEventListener(MouseEvent.CLICK, handleTowerClick);
                _buttons.addChild(b);
            });

    }

    /** Called with the player's current money amount, disables buttons for unaffordable towers. */
    public function updateAvailability (money :int) :void
    {
        var updateFn :Function = function () :void {
            var towers :Array = _board.getAvailableTowers();
            _buttons.getChildren().forEach(function (obj :DisplayObject, i :*, a :*) :void {
                    var b :Button = obj as Button;
                    if (b != null && b.id != null && isFinite(int(b.id))) {
                        var tdef :TowerDefinition = towers[b.id];
                        b.enabled = (tdef.cost <= money);
                    }
                });
        };

        if (_buttons == null) {
            callLater(updateFn);
        } else {
            updateFn();
        }
    }                        
    
    public function handleUnload () :void
    {
        removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
    }

    protected function handleMouseOver (event :MouseEvent) :void
    {
        Mouse.show();
    }

    protected function handleMouseOut (event :MouseEvent) :void
    {
    }
    
    protected function handleTowerClick (event :MouseEvent) :void
    {
        var tdef :TowerDefinition = _board.getAvailableTowers()[int(event.target.id)];
        _game.setCursorType(tdef.typeName);
    }

    /** Makes a mouse over handler that will display an appropriate tower description. */
    protected function makeDescriptionFn (tdef :TowerDefinition) :Function
    {
        return function (event :MouseEvent) :void {
            if (tdef != null) {
                _title.text = tdef.typeName;
                _desc.htmlText =
                    tdef.description + "<br><br>" +
                    Messages.get("cost") + tdef.cost;
            } else {
                _title.text = _desc.text = "";
            }
        }
    }
    
    protected var _board :Board;
    protected var _game :Game;
    protected var _display :Display;
    protected var _buttons :Tile;
    protected var _title :Label;
    protected var _desc :Text;
}
}
