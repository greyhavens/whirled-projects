package view {

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;

import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

public class ShipChooser extends Sprite
{
    public function ShipChooser (newGame :Boolean)
    {
        // Partially obscure background.
        var fadeOut :Shape = new Shape();
        fadeOut.alpha = 0.5;
        fadeOut.graphics.beginFill(Codes.BLACK);
        fadeOut.graphics.drawRect(0, 0, Constants.WIDTH, Constants.HEIGHT);
        fadeOut.graphics.endFill();
        addChild(fadeOut);
        _newGame = newGame;

        var bg :Bitmap = Resources.getBitmap("ship_select.png");
        addChild(bg);
        bg.x = (Constants.WIDTH - bg.width) / 2;
        bg.y = (Constants.HEIGHT - bg.height) / 2;

        var format:TextFormat = new TextFormat();
        format.font = GameView.gameFont.fontName;
        format.color = Codes.YELLOW;
        format.size = 16;
        format.bold = true;
        format.rightMargin = 8;

        var selectText :TextField = new TextField();
        selectText.autoSize = TextFieldAutoSize.CENTER;
        selectText.selectable = false;
        selectText.x = Constants.WIDTH/2;
        selectText.y = Constants.HEIGHT/2 - TEXT_SPACING;
        selectText.defaultTextFormat = format;
        selectText.embedFonts = true;
        selectText.antiAliasType = AntiAliasType.ADVANCED;
        selectText.text = "Select Your Ship";
        addChild(selectText);

        for (var ii :int = 0; ii < Codes.SHIP_TYPES.length; ii++) {
            var type :ShipType = Codes.SHIP_TYPES[ii];
            addButton(type, ii, Codes.SHIP_TYPES.length);
        }
    }

    /**
     * Adds a ship button.
     */
    protected function addButton (type :ShipType, idx :int, total :int) :void
    {
        var selection :Sprite = new Sprite();
        var ship :ShipSprite = new ShipSprite(null, null, true, -1, type.name, false);
        ship.pointUp();
        ship.setShipType(idx);
        selection.addChild(ship);
        selection.addEventListener(MouseEvent.CLICK, chooseHandler);
        selection.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
        selection.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

        selection.x = Constants.WIDTH/2 + SPACING * (idx - (total-1)/2.0);
        selection.y = Constants.HEIGHT/2 + 15;
        _buttons.push(selection);

        addChild(selection);
    }

    public function chooseHandler (event :MouseEvent) :void
    {
        var ship :ShipSprite = ShipSprite((event.currentTarget as Sprite).getChildAt(0));
        choose(ship.shipType);

        // prevent NPE on further click event handlers
        event.stopImmediatePropagation();
    }

    public function mouseOverHandler (event :MouseEvent) :void
    {
        var ship :ShipSprite = ShipSprite((event.currentTarget as Sprite).getChildAt(0));
        ship.setAnimMode(ShipSprite.SELECT, false);
        ship.scaleX = HIGHLIGHT_SCALE;
        ship.scaleY = HIGHLIGHT_SCALE;
    }

    public function mouseOutHandler (event :MouseEvent) :void
    {
        var ship :ShipSprite = ShipSprite((event.currentTarget as Sprite).getChildAt(0));
        ship.setAnimMode(ShipSprite.IDLE, false);
        ship.scaleX = 1.0;
        ship.scaleY = 1.0;
    }

    /**
     * Register a user choice of a specific ship.
     */
    public function choose (typeIdx :int) :void
    {
        for each (var selection :Sprite in _buttons) {
            selection.removeEventListener(MouseEvent.CLICK, chooseHandler);
            selection.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
            selection.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
        }
        if (_newGame) {
            AppContext.starfight.chooseShip(typeIdx);
        } else {
            AppContext.starfight.changeShip(typeIdx);
        }
        parent.removeChild(this);
    }

    protected static const SPACING :int = 80;
    protected static const TEXT_SPACING :int = 66;
    protected static const HIGHLIGHT_SCALE :Number = 1.2;

    protected var _newGame :Boolean;
    protected var _buttons :Array = [];
}
}
