package spades.graphics {

import flash.display.Sprite;

/** Graphics for the cards in the last trick. */
public class LastTrickSprite extends Sprite
{
    /** Create a new trick sprite */
    public function LastTrickSprite ()
    {
    }

    public function setCards (cards :Array) :void
    {
        clear();
        cards.forEach(add);
        
        function add (c :CardSprite, i :int, a :Array) :void {
            addChild(c);
            _cards.push(c);
        }
    }

    public function clear () :void
    {
        _cards.forEach(remove);
        _cards.splice(0, _cards.length);
        
        function remove (c :CardSprite, i :int, a :Array) :void {
            removeChild(c);
        }
    }

    protected var _cards :Array = new Array();
}

}
