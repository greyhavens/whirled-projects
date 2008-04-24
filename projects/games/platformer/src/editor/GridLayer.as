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
        x = Math.floor(-nX) % Metrics.TILE_SIZE;
        y = Math.floor(Metrics.DISPLAY_HEIGHT - nY) % Metrics.TILE_SIZE;
    }

    protected function redraw (scale :Number) :void
    {
        graphics.clear();
        graphics.lineStyle(0, 0x000000, 0.5);
        for (var ii :int = 0; ii <= Metrics.WINDOW_WIDTH * scale; ii++) {
            graphics.moveTo(ii * Metrics.TILE_SIZE, Metrics.DISPLAY_HEIGHT * scale);
            graphics.lineTo(ii * Metrics.TILE_SIZE, -Metrics.TILE_SIZE * scale);
        }
        for (ii = 0; ii <= Metrics.WINDOW_HEIGHT * scale; ii++) {
            graphics.moveTo(0, ii * Metrics.TILE_SIZE);
            graphics.lineTo(
                (Metrics.DISPLAY_WIDTH + Metrics.TILE_SIZE) * scale, ii * Metrics.TILE_SIZE);
        }
    }

    protected var _oldScale :Number = 1;
}
}
