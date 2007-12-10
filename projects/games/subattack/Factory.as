package {

import flash.display.DisplayObject;

import flash.filters.ColorMatrixFilter;

public class Factory extends BaseSprite
{
    public static const MAX_HITS :int = 3;

    public function Factory (sub :Submarine, board :Board)
    {
        super(sub.getPlayerIndex(), board);
        this.name = "factory";

        addChild(new FACTORY() as DisplayObject);

        _sub = sub;
        _x = sub.getX();
        _y = sub.getY();
        updateLocation();
        updateVisual(MAX_HITS);
    }

    public function updateVisual (strength :int) :void
    {
        var filts :Array = [ _sub.getHueShift() ];
        if (strength < MAX_HITS) {
            var dim :Number = (strength == 2) ? .8 : .6;
            filts.unshift(new ColorMatrixFilter([dim, 0, 0, 0, 0,
                                                 0, dim, 0, 0, 0,
                                                 0, 0, dim, 0, 0,
                                                 0, 0, 0, 1, 0]));
        }
        this.filters = filts;
    }

    /**
     * Tick this factory.
     */
    public function tick () :void
    {
        if (++_ticks % 50 == 0) {
            _board.showPoints(_x, _y, 10);
            _sub.addPoints(10);
        }
    }

    /** Our owning submarine. */
    protected var _sub :Submarine;

    protected var _ticks :int = 0;

    [Embed(source="factory.swf#factory")]
    protected static const FACTORY :Class;
}
}
