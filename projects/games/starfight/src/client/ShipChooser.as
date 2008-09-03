package client {

public class ShipChooser
{
    public static function show (newGame :Boolean) :void
    {
        if (_instance == null) {
            _instance = new ShipChooserWindow(newGame);
            ClientContext.gameView.popupLayer.addChild(_instance);
        }
    }

    public static function hide () :void
    {
        if (_instance != null) {
            _instance.parent.removeChild(_instance);
            _instance = null;
        }
    }

    public static function get isShowing () :Boolean
    {
        return (_instance != null);
    }

    protected static var _instance :ShipChooserWindow;
}

}

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import client.*;

class ShipChooserWindow extends Sprite
{
    public function ShipChooserWindow (newGame :Boolean)
    {
        // Partially obscure background.
        var fadeOut :Shape = new Shape();
        fadeOut.alpha = 0.5;
        fadeOut.graphics.beginFill(Codes.BLACK);
        fadeOut.graphics.drawRect(0, 0, Codes.GAME_WIDTH, Codes.GAME_HEIGHT);
        fadeOut.graphics.endFill();
        addChild(fadeOut);
        _newGame = newGame;

        var bg :Bitmap = Resources.getBitmap("ship_select.png");
        addChild(bg);
        bg.x = (Codes.GAME_WIDTH - bg.width) / 2;
        bg.y = (Codes.GAME_HEIGHT - bg.height) / 2;

        var format:TextFormat = new TextFormat();
        format.font = GameView.gameFont.fontName;
        format.color = Codes.YELLOW;
        format.size = 16;
        format.bold = true;
        format.rightMargin = 8;

        var selectText :TextField = new TextField();
        selectText.autoSize = TextFieldAutoSize.CENTER;
        selectText.selectable = false;
        selectText.x = Codes.GAME_WIDTH/2;
        selectText.y = Codes.GAME_HEIGHT/2 - TEXT_SPACING;
        selectText.defaultTextFormat = format;
        selectText.embedFonts = true;
        selectText.antiAliasType = AntiAliasType.ADVANCED;
        selectText.text = "Select Your Ship";
        addChild(selectText);

        var numShipTypes :int = Codes.SHIP_TYPE_CLASSES.length;
        for (var ii :int = 0; ii < numShipTypes; ii++) {
            addShipButton(ii, numShipTypes);
        }
    }

    /**
     * Adds a ship button.
     */
    protected function addShipButton (idx :int, total :int) :void
    {
        var selection :Sprite = new Sprite();
        selection.mouseChildren = false;
        selection.addChild(new SelectionShipView(idx));
        selection.addEventListener(MouseEvent.CLICK, chooseHandler);
        selection.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        selection.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

        selection.x = Codes.GAME_WIDTH/2 + SPACING * (idx - (total-1)/2.0);
        selection.y = Codes.GAME_HEIGHT/2 + 15;
        _buttons.push(selection);

        addChild(selection);
    }

    protected function chooseHandler (event :MouseEvent) :void
    {
        var ship :SelectionShipView =
            SelectionShipView((event.currentTarget as Sprite).getChildAt(0));
        choose(ship.shipType);

        // prevent NPE on further click event handlers
        event.stopImmediatePropagation();
    }

    protected function mouseOverHandler (event :MouseEvent) :void
    {
        var ship :SelectionShipView =
            SelectionShipView((event.currentTarget as Sprite).getChildAt(0));
        ship.hilite = true;
        ship.scaleX = HIGHLIGHT_SCALE;
        ship.scaleY = HIGHLIGHT_SCALE;
    }

    protected function mouseOutHandler (event :MouseEvent) :void
    {
        var ship :SelectionShipView =
            SelectionShipView((event.currentTarget as Sprite).getChildAt(0));
        ship.hilite = false;
        ship.scaleX = 1.0;
        ship.scaleY = 1.0;
    }

    /**
     * Register a user choice of a specific ship.
     */
    protected function choose (typeIdx :int) :void
    {
        for each (var selection :Sprite in _buttons) {
            selection.removeEventListener(MouseEvent.CLICK, chooseHandler);
            selection.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            selection.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        }
        if (_newGame) {
            AppContext.game.playerChoseShip(typeIdx);
        } else {
            AppContext.game.changeShip(typeIdx);
        }

        ShipChooser.hide();
    }

    protected static const SPACING :int = 80;
    protected static const TEXT_SPACING :int = 66;
    protected static const HIGHLIGHT_SCALE :Number = 1.2;

    protected var _newGame :Boolean;
    protected var _buttons :Array = [];

}
