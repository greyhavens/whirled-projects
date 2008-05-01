//
// $Id$

package editor {

import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.KeyboardEvent;

import com.threerings.util.KeyboardCodes;

import display.Layer;
import display.Metrics;
import display.PieceSprite;
import display.PieceSpriteFactory;

import board.Board;

import piece.Piece;

public class BoardEditSprite extends EditSprite
{
    public function BoardEditSprite (ev :EditView)
    {
        super();
        focusRect = false;
        _ev = ev;
    }

    public function setBoard (board :Board) :void
    {
        if (_board != null) {
            _board.removeEventListener(Board.PIECE_ADDED, pieceAdded);
            clearDisplay();
        }
        _board = board;
        initDisplay();
        _board.addEventListener(Board.PIECE_ADDED, pieceAdded);
        _board.addEventListener(Board.PIECE_UPDATED, _layers[LEVEL_LAYER].pieceUpdated);
        _board.addEventListener(Board.GROUP_ADDED, _layers[LEVEL_LAYER].addContainer);
        _board.addEventListener(Board.ITEM_REMOVED, _layers[LEVEL_LAYER].removeSprite);
        _board.addEventListener(Board.ITEM_FORWARD, _layers[LEVEL_LAYER].moveSpriteForward);
        _board.addEventListener(Board.ITEM_BACK, _layers[LEVEL_LAYER].moveSpriteBack);
        addEventListener(MouseEvent.CLICK, onClick);
        addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    public function setSelected (sprite :EditorPieceSprite, updateView :Boolean = true) :void
    {
        _layers[LEVEL_LAYER].forEachPiece(function (eps :*, index :int, array :Array) :void {
            eps.setSelected(eps == sprite);
        });
        if (sprite != null) {
            if (updateView) {
                _ev.selectPiece(_layers[LEVEL_LAYER].getTree(sprite), sprite.name);
            } else {
                ensureOnScreen(sprite);
            }
        }
    }

    public function selectSprite (tree :String, name :String) :void
    {
        var sprite :EditorPieceSprite = _layers[LEVEL_LAYER].getSprite(tree, name);
        if (sprite != null) {
            setSelected(sprite, false);
        }
    }

    public override function getMouseX () :int
    {
        return Math.floor((_bX + mouseX) / Metrics.TILE_SIZE * _scale);
    }

    public override function getMouseY () :int
    {
        return Math.floor(((Metrics.DISPLAY_HEIGHT - mouseY) - _bY) / Metrics.TILE_SIZE * _scale);
    }

    public function changeScale (delta :int) :void
    {
        if (_scale + delta > 0 && _scale + delta <= 8) {
            _scale += delta;
            updateDisplay();
        }
    }

    public function toggleGrid () :void
    {
        _layers[GRID_LAYER].alpha = _layers[GRID_LAYER].alpha > 0 ? 0 : 0.5;
        updateDisplay();
    }

    protected function onAddedToStage (event :Event) :void
    {
        addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
    }

    protected function onClick (event :MouseEvent) :void
    {
        stage.focus = this;
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (event.keyCode == KeyboardCodes.D) {
            moveViewTile(1 * _scale, 0);
        } else if (event.keyCode == KeyboardCodes.S) {
            moveViewTile(0, 1 * _scale);
        } else if (event.keyCode == KeyboardCodes.A) {
            moveViewTile(-1 * _scale, 0);
        } else if (event.keyCode == KeyboardCodes.W) {
            moveViewTile(0, -1 * _scale);
        }
    }

    protected override function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        mask = masker;
        addChild(masker);
        masker = new Shape();
        masker.graphics.beginFill(0xEEEEEE);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        addChild(masker);
        addChild(_layerPoint = new Sprite());
        _layers[LEVEL_LAYER] = new EditorPieceSpriteLayer();
        _layerPoint.addChild(_layers[LEVEL_LAYER]);
        _layerPoint.addChild(_layers[GRID_LAYER] = new GridLayer());
        _layers[GRID_LAYER].alpha = 0.5;
        initPieceLayer();

        super.initDisplay();
    }

    protected function pieceAdded (p :Piece, tree :String) :void
    {
        _layers[LEVEL_LAYER].addEditorPieceSprite(new EditorPieceSprite(
                PieceSpriteFactory.getPieceSprite(p), this), tree);
    }

    protected function initPieceLayer () :void
    {
        _layers[LEVEL_LAYER].clear();
        var pieceTree :Array = _board.getPieces();
        addPieces(pieceTree, pieceTree[0]);
    }

    protected function addPieces (pieces :Array, tree :String) :void
    {
        for each (var node :Object in pieces) {
            if (node is Array) {
                addPieces(node as Array, tree + "." + node[0]);
            } else if (node is Piece) {
                _layers[LEVEL_LAYER].addEditorPieceSprite(new EditorPieceSprite(
                    PieceSpriteFactory.getPieceSprite(node as Piece), this), tree);
            }
        }
    }

    protected function ensureOnScreen (sprite :PieceSprite) :void
    {
        var p :Piece = sprite.getPiece();
        if (p.x + p.width <= getX() || p.x >= getX() + Metrics.WINDOW_WIDTH * _scale ||
            p.y + p.height <= getY() || p.y >= getY() + Metrics.WINDOW_HEIGHT * _scale) {
            positionViewTile(p.x - (Metrics.WINDOW_WIDTH * _scale - p.width) / 2,
                    - p.y + (Metrics.WINDOW_HEIGHT * _scale - p.height) / 2);
        }
    }

    protected override function updateDisplay () :void
    {
        for each (var layer :Layer in _layers) {
            if (layer != null) {
                layer.update(_bX / _scale, _bY / _scale, _scale);
            }
        }
    }

    protected override function tileChanged (newX :int, newY :int) :void
    {
        //trace("mouseMove (" + newX + ", " + newY + ")");
        _layers[LEVEL_LAYER].forEachPiece(function (eps :*, index :int, array :Array) :void {
            eps.mouseMove(newX, newY);
        });
    }

    protected override function clearDrag () :void
    {
        _layers[LEVEL_LAYER].forEachPiece(function (eps :*, index :int, array :Array) :void {
            eps.clearDrag();
        });
    }

    /** The board layers. */
    protected var _layers :Array = new Array();

    protected var _board :Board;

    protected var _layerPoint :Sprite;

    protected var _ev :EditView;

    protected var _scale :Number = 2;

    protected static const LEVEL_LAYER :int = 1;
    protected static const GRID_LAYER :int = 10;
}
}
