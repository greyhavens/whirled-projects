package client {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class SelectionShipView extends Sprite
{
    public function SelectionShipView (shipType :int)
    {
        _shipType = shipType;
        var theShipType :ShipType = Constants.getShipType(shipType);
        var shipResources :ShipTypeResources = ClientConstants.getShipResources(shipType);

        var shipMovieParent :Sprite = new Sprite();
        shipMovieParent.scaleX = theShipType.size + 0.1;
        shipMovieParent.scaleY = theShipType.size + 0.1;
        addChild(shipMovieParent);

        _shipMovie = MovieClip(new shipResources.shipAnim());
        _shipMovie.x = -_shipMovie.width * 0.5;
        _shipMovie.y = -_shipMovie.height * 0.5;
        shipMovieParent.addChild(_shipMovie);

        var nameText :TextField = new TextField();
        nameText.autoSize = TextFieldAutoSize.CENTER;
        nameText.selectable = false;
        nameText.x = 0;
        nameText.y = TEXT_OFFSET;

        var format:TextFormat = new TextFormat();
        format.font = GameView.gameFont.fontName;
        format.color = Constants.CYAN;
        format.size = 10;
        format.rightMargin = 3;
        nameText.defaultTextFormat = format;
        nameText.embedFonts = true;
        nameText.antiAliasType = AntiAliasType.ADVANCED;
        nameText.text = theShipType.name;
        addChild(nameText);
    }

    public function set hilite (val :Boolean) :void
    {
        if (val != _hilited) {
            _hilited = val;
            _shipMovie.gotoAndPlay(_hilited ? "select" : "ship");
        }
    }

    public function get shipType () :int
    {
        return _shipType;
    }

    protected var _shipType :int;
    protected var _shipMovie :MovieClip;
    protected var _hilited :Boolean;

    protected static const TEXT_OFFSET :int = 25;
}

}
