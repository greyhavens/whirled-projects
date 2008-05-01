//
// $Id$

package editor {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import display.Metrics;
import display.PieceSprite;
import display.PieceSpriteLayer;

import piece.Piece;

public class EditorPieceSpriteLayer extends PieceSpriteLayer
{
    public override function addPieceSprite (ps :PieceSprite) :void
    {
    }

    public function addEditorPieceSprite (es :EditorPieceSprite, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        container.addChild(es);
        _esprites.push(es);
    }

    public function pieceUpdated (p :Piece, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(p.id.toString());
        if (sprite != null) {
            (sprite as PieceSprite).update();
        }
    }

    public function addContainer (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var next :Sprite = new Sprite();
        next.name = name;
        container.addChild(next);
    }

    public function removeSprite (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite != null) {
            container.removeChild(sprite);
        }
    }

    public function moveSpriteForward (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite == null) {
            return;
        }
        var index :int = container.getChildIndex(sprite);
        if (index < container.numChildren - 1) {
            container.removeChildAt(index);
            container.addChildAt(sprite, index + 1);
        }
    }

    public function moveSpriteBack (name :String, tree :String) :void
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite == null) {
            return;
        }
        var index :int = container.getChildIndex(sprite);
        if (index > 0) {
            container.removeChildAt(index);
            container.addChildAt(sprite, index - 1);
        }
    }

    public function forEachPiece (func :Function) :void
    {
        _esprites.forEach(func);
    }

    public override function clear () :void
    {
        super.clear();
        _esprites = new Array();
    }

    public function getSprite (tree :String, name :String) :EditorPieceSprite
    {
        var container :DisplayObjectContainer = getContainer(tree);
        var sprite :DisplayObject = container.getChildByName(name);
        if (sprite is EditorPieceSprite) {
            return sprite as EditorPieceSprite;
        }
        return null;
    }

    public function getTree (sprite :DisplayObject) :String
    {
        sprite = sprite.parent;
        var tree :String = sprite.name;
        while (sprite.parent != this) {
            sprite = sprite.parent;
            tree = sprite.name + "." + tree;
        }
        return tree;
    }

    public override function update (nX :Number, nY :Number, scale :Number = 1) :void
    {
        scaleX = 1 / scale;
        scaleY = 1 / scale;
        x = Math.floor(-nX);
        y = Math.floor(Metrics.DISPLAY_HEIGHT - nY);
    }

    protected function getContainer (tree :String) :DisplayObjectContainer
    {
        var container :DisplayObjectContainer = this;
        for each (var name :String in tree.split(".")) {
            var next :DisplayObject = container.getChildByName(name);
            if (next == null) {
                next = new Sprite();
                next.name = name;
                container.addChild(next);
                container = next as DisplayObjectContainer;
            } else {
                container = next as DisplayObjectContainer;
            }
        }
        return container;
    }

    protected var _esprites :Array = new Array();
}
}
