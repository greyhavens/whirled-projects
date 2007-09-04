package sprites {

import mx.controls.Image;

import units.Unit;

/**
 * Base class for sprites that display unit objects.
 */
public class UnitSprite extends Image
{
    public function UnitSprite (unit :Unit)
    {
        _unit = unit;
    }

    protected var _unit :Unit;
}
}
