package {

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

public class ShipChooser extends Sprite
{
    public function ShipChooser(game :StarFight, newGame :Boolean)
    {

        // Partially obscure background.
        var fadeOut :Shape = new Shape();
        fadeOut.alpha = 0.5;
        fadeOut.graphics.beginFill(Codes.BLACK);
        fadeOut.graphics.drawRect(0, 0, StarFight.WIDTH, StarFight.HEIGHT);
        fadeOut.graphics.endFill();
        addChild(fadeOut);
        //graphics.lineStyle(2, Codes.CYAN);
        //graphics.drawRoundRect((StarFight.WIDTH - SPACING * (Codes.SHIP_TYPES.length+1))/2,
        //    StarFight.HEIGHT/2 - SPACING, SPACING * (Codes.SHIP_TYPES.length+1), 2 * SPACING, 10.0, 10.0);
        _game = game;
        _newGame = newGame;

        var bg :Bitmap = Resources.getBitmap("ship_select.png");
        addChild(bg);
        bg.x = (StarFight.WIDTH - bg.width) / 2;
        bg.y = (StarFight.HEIGHT - bg.height) / 2;

        var format:TextFormat = new TextFormat();
        format.font = StarFight.gameFont.fontName;
        format.color = Codes.YELLOW;
        format.size = 16;
        format.bold = true;
        format.rightMargin = 8;

        var selectText :TextField = new TextField();
        selectText.autoSize = TextFieldAutoSize.CENTER;
        selectText.selectable = false;
        selectText.x = StarFight.WIDTH/2;
        selectText.y = StarFight.HEIGHT/2 - TEXT_SPACING;
        selectText.defaultTextFormat = format;
        selectText.embedFonts = true;
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

        selection.x = StarFight.WIDTH/2 + SPACING * (idx - (total-1)/2.0);
        selection.y = StarFight.HEIGHT/2 + 15;

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
        event.currentTarget.scaleX = HIGHLIGHT_SCALE;
        event.currentTarget.scaleY = HIGHLIGHT_SCALE;
    }

    public function mouseOutHandler (event :MouseEvent) :void
    {
        var ship :ShipSprite = ShipSprite((event.currentTarget as Sprite).getChildAt(0));
        ship.setAnimMode(ShipSprite.IDLE, false);
        event.currentTarget.scaleX = 1.0;
        event.currentTarget.scaleY = 1.0;
    }

    /**
     * Register a user choice of a specific ship.
     */
    public function choose (typeIdx :int) :void
    {
        if (_newGame) {
            _game.chooseShip(typeIdx);
        } else {
            _game.changeShip(typeIdx);
        }
        _game.removeChild(this);
    }

    protected static const SPACING :int = 80;
    protected static const TEXT_SPACING :int = 66;
    protected static const HIGHLIGHT_SCALE :Number = 1.2;

    protected var _game :StarFight;
    protected var _newGame :Boolean;
}
}
