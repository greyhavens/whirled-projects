package com.threerings.defense.ui {

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

import com.threerings.defense.Board;
import com.threerings.defense.Display;
import com.threerings.defense.Game;
import com.threerings.defense.tuning.Messages;
import com.threerings.defense.tuning.UnitDefinitions;

public class TowerPanel extends TitleWindow
{
    public function TowerPanel (display :Display)
    {
        _display = display;
        
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
    }

    /** Called after the level was loaded, will reset tower icons on the UI. */
    public function init (board :Board, game :Game) :void
    {
        _board = board;
        _game = game;
        
        UnitDefinitions.TOWER_DEFINITIONS.forEach(function(def :Object, i :*, a :*) :void {
                var b :Button = new Button();
                b.styleName = def.value.styleName;
                b.id = def.key;
                b.addEventListener(MouseEvent.MOUSE_OVER, makeDescriptionFn(def.value));
                b.addEventListener(MouseEvent.MOUSE_OUT, makeDescriptionFn(null));
                b.addEventListener(MouseEvent.CLICK, handleTowerClick);
                _buttons.addChild(b);
            });

    }

    /** Called with the player's current money amount, disables buttons for unaffordable towers. */
    public function updateAvailability (money :int) :void
    {
        _buttons.getChildren().forEach(function (obj :DisplayObject, i :*, a :*) :void {
                var b :Button = obj as Button;
                if (b != null && b.id != null && isFinite(int(b.id))) {
                    var def :Object = UnitDefinitions.getTowerDefinition(int(b.id));
                    b.enabled = (def.cost <= money);
                }
            });
    }                        
    
    public function handleUnload (event :Event) :void
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
        _game.setCursorType(event.target.id);
    }

    /** Makes a mouse over handler that will display an appropriate tower description. */
    protected function makeDescriptionFn (def :Object) :Function
    {
        return function (event :MouseEvent) :void {
            if (def != null) {
                _title.text = def.name;
                _desc.htmlText =
                    def.description + "<br><br>" +
                    Messages.get("cost") + def.cost;
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

    

    
