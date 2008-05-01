//
// $Id$

package editor {

import display.Layer;
import display.Metrics;

/**
 * A layer that displays the tile grid.
 */
public class GridLayer extends Layer
{
    public function GridLayer ()
    {
        redraw(_oldScale);
        mouseEnabled = false;
        mouseChildren = false;
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        if (scale != _oldScale) {
            redraw(scale);
            _oldScale = scale;
        }
        x = Math.floor(-nX);
        if (x < 0) {
            x %= Metrics.TILE_SIZE;
        }
        y = Math.floor(-nY);
        if (nY < 0) {
            y %= Metrics.TILE_SIZE;
        }
    }

    protected function redraw (scale :Number) :void
    {
        graphics.clear();
        graphics.lineStyle(0, 0x000000, 0.5);
        for (var ii :int = 0; ii <= Metrics.WINDOW_WIDTH * scale; ii++) {
            graphics.moveTo(ii * Metrics.TILE_SIZE / scale, Metrics.DISPLAY_HEIGHT);
            graphics.lineTo(ii * Metrics.TILE_SIZE / scale, -Metrics.TILE_SIZE);
        }
        for (ii = 0; ii <= Metrics.WINDOW_HEIGHT * scale; ii++) {
            graphics.moveTo(0, ii * Metrics.TILE_SIZE / scale);
            graphics.lineTo(
                (Metrics.DISPLAY_WIDTH + Metrics.TILE_SIZE), ii * Metrics.TILE_SIZE / scale);
        }
    }

    protected var _oldScale :Number = 1;
}
}
