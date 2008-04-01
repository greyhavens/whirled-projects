package spades.graphics {


import flash.display.Sprite;

import com.threerings.flash.Vector2;

import caurina.transitions.Tweener;

/** Represents a team display. Includes a placeholder box and last trick display. 
 *  TODO: names, score and trick totals. */
public class TeamSprite extends Sprite
{
    /** Create a new team sprite. Long names will be truncated with an ellipsis.
     *  @param name1 the first name to appear in the label
     *  @param name2 the second name to appear in the label
     *  @param mainTrickPos the global coordinates of the main trick - used for animating the 
     *  taking of a trick.
     *  @lastTrickPos the relative position of the scaled down last trick icon */
    public function TeamSprite (
        name1 :String, 
        name2 :String, 
        mainTrickPos :Vector2,
        lastTrickPos :Vector2)
    {
        _mainTrickPos = mainTrickPos.clone();
        _lastTrickPos = lastTrickPos.clone();

        _lastTrick = new LastTrickSprite();
        addChild(_lastTrick);

        graphics.clear();
        graphics.beginFill(0x808080);
        graphics.drawRect(-WIDTH / 2, -HEIGHT/2, WIDTH, HEIGHT);
        graphics.endFill();
    }

    /** Take the array of card sprites and animate them to this team's last trick slot. The 
     *  animation includes x,y position and scale. */
    public function takeTrick (cards :Array) :void
    {
        var localStartPos :Vector2 = Vector2.fromPoint(
            globalToLocal(_mainTrickPos.toPoint()));

        _lastTrick.setCards(cards);
        _lastTrick.x = localStartPos.x;
        _lastTrick.y = localStartPos.y;
        _lastTrick.scaleX = 1.0;
        _lastTrick.scaleY = 1.0;

        var tween :Object = {
            x: _lastTrickPos.x,
            y: _lastTrickPos.y,
            scaleX: TRICK_SCALE,
            scaleY: TRICK_SCALE,
            time: TRICK_DURATION
        };

        Tweener.addTween(_lastTrick, tween);
    }

    /** Clear the card sprites. */
    public function clearLastTrick () :void
    {
        _lastTrick.clear();
    }

    /** Sprite for the last trick display */
    protected var _lastTrick :LastTrickSprite;

    /** Position of main trick, in global coordinates */
    protected var _mainTrickPos :Vector2;

    /** Static position of our last trick display */
    protected var _lastTrickPos :Vector2;

    protected static const TRICK_SCALE :Number = 0.5;
    protected static const TRICK_DURATION :int = 1.0;

    protected static const WIDTH :int = 180;
    protected static const HEIGHT :int = 80;
}

}
