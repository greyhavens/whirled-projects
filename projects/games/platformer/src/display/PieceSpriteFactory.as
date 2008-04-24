//
// $Id$

package display {

import flash.display.DisplayObject;
import flash.display.GradientType;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.geom.Matrix;
import flash.system.ApplicationDomain;

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.threerings.util.MultiLoader;

import piece.Piece;
import piece.BoundedPiece;

import Logger;

/**
 * Generates a piece sprite from the supplied piece.
 */
public class PieceSpriteFactory
{
    public static function init (source :String, onReady :Function) :void
    {
        MultiLoader.getLoaders(source, function (result :Object) :void {
            onReady();
        }, false, _contentDomain);
        addPieceClass(new BoundedPieceSprite(new BoundedPiece()));
    }

    public static function addPieceClass (ps :PieceSprite) :void
    {
        _spriteMap.put(ClassUtil.getClassName(ps.getPiece()), ClassUtil.getClassName(ps));
    }

    public static function getPieceSprite (p :Piece) :PieceSprite
    {
        var className :String = _spriteMap.get(ClassUtil.getClassName(p));
        if (className == null || !ApplicationDomain.currentDomain.hasDefinition(className)) {
            className = "display.PieceSprite";
        }
        var cdef :Class = ApplicationDomain.currentDomain.getDefinition(className) as Class;

        return new cdef(p, instantiateClip(p)) as PieceSprite;
    }

    public static function blockShape (w :int, h :int) :MovieClip
    {
        var block :MovieClip = new MovieClip();
        var bMatrix :Matrix = new Matrix();
        bMatrix.createGradientBox(w*Metrics.TILE_SIZE, h*Metrics.TILE_SIZE, Math.PI / 4);
        block.graphics.beginGradientFill(
                GradientType.LINEAR, [0xCC0000, 0x330000], [1, 1], [0x00, 0xFF], bMatrix);
        block.graphics.lineStyle(0, 0x888888);
        block.graphics.drawRect(0, 0, w*Metrics.TILE_SIZE, -h*Metrics.TILE_SIZE);
        block.graphics.endFill();
        return block;
    }

    public static function instantiateClip (p :Piece) :DisplayObject
    {
        if (p.sprite == null || p.sprite == "") {
            return null;
        }
        try {
            var symbolClass :Class = _contentDomain.getDefinition(p.sprite) as Class;
            return MovieClip(new symbolClass());
        } catch (e :Error) {
        }
        return blockShape(p.width, p.height);
    }

    protected static var _spriteMap :HashMap = new HashMap();

    protected static var _contentDomain :ApplicationDomain = new ApplicationDomain(null);

    [Embed(source="../../rsrc/props_TEST.swf", mimeType="application/octet-stream")]
    protected static var PROPS :Class;
}
}
