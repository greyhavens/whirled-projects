//
// $Id$

package display {

import flash.display.Sprite;

/**
 * A layer that is divided into sections which are dynamically added and removed from the display
 * tree depending on what's currently in the view.
 */
public class SectionalLayer extends PieceSpriteLayer
{
    public function SectionalLayer (secWidth :int, secHeight :int)
    {
        _secWidth = secWidth;
        _secHeight = secHeight;
    }

    public override function addPieceSprite (ps :PieceSprite) :void
    {
        var idx :int = getSectionFromTile(ps.getPiece().x, -ps.getPiece().y);
        if (_sections[idx] == null) {
            _sections[idx] = new Sprite();
        }
        _sections[idx].addChild(ps);
    }

    public override function clear () :void
    {
        _sections = new Array();
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        var section :int = getSectionFromCoord(nX, nY);
        if (section != _currentSection) {
            var sx :int = getSectionX(section);
            var sy :int = getSectionY(section);
            if (_currentSection == int.MIN_VALUE) {
                showSections(sx - 1, sy - 1, sx + 1, sy + 1);
            } else if (_currentSection != section) {
                //_ctrl.feedback("Moving to section (" + sx + "," + sy + ")");
                var cx :int = getSectionX(_currentSection);
                var cy :int = getSectionY(_currentSection);
                if (Math.abs(cx - sx) > 1 || Math.abs(cy - sy) > 1) {
                    showSections(cx - 1, cy - 1, cx + 1, cy + 1, false);
                    showSections(sx - 1, sy - 1, sx + 1, sy + 1);
                } else {
                    if (cx < sx) {
                        showSections(cx - 1, cy - 1, cx - 1, cy + 1, false);
                        showSections(sx + 1, sy - 1, sx + 1, sy + 1);
                    } else if (cx > sx) {
                        showSections(cx + 1, cy - 1, cx + 1, cy + 1, false);
                        showSections(sx - 1, sy - 1, sx - 1, sy + 1);
                    }
                    if (cy < sy) {
                        showSections(cx - 1, cy - 1, cx + 1, cy - 1, false);
                        showSections(sx - 1, sy + 1, sx + 1, sy + 1);
                    } else if (cy > sy) {
                        showSections(cx - 1, cy + 1, cx + 1, cy + 1, false);
                        showSections(sx - 1, sy - 1, sx + 1, sy - 1);
                    }
                }
            }
            _currentSection = section;
        }
        super.update(nX, nY);
    }

    protected function getSectionIndex (sx :int, sy :int) :int
    {
        return Math.max(sy, 0) * 1000 + Math.max(sx, 0);
    }

    protected function getSectionX (section :int) :int
    {
        return section % 1000;
    }

    protected function getSectionY (section :int) :int
    {
        return Math.floor(section / 1000);
    }

    protected function getSectionFromTile (tx :int, ty :int) :int
    {
        return getSectionIndex(Math.floor(tx / _secWidth), Math.floor(ty / _secHeight));

    }

    protected function getSectionFromCoord (cx :Number, cy :Number) :int
    {
        return getSectionFromTile(
                Math.floor(cx / Metrics.TILE_SIZE), Math.floor(cy / Metrics.TILE_SIZE));
    }

    protected function showSections (x1 :int, y1 :int, x2 :int, y2 :int, show :Boolean = true) :void
    {
        for (var yy :int = y1; yy <= y2; yy++) {
            if (yy < 0) {
                continue;
            }
            for (var xx :int = x1; xx <= x2; xx++) {
                if (xx < 0) {
                    continue;
                }
                var idx :int = getSectionIndex(xx, yy);
                if (_sections[idx] != null) {
                    if (show) {
                        addChild(_sections[idx]);
                    } else {
                        removeChild(_sections[idx]);
                    }
                }
            }
        }
    }

    /** Our sections. */
    protected var _sections :Array = new Array();

    /** Section dimensions. */
    protected var _secWidth :int;
    protected var _secHeight :int;

    /** The current section we're in. */
    protected var _currentSection :int = int.MIN_VALUE;

}
}
