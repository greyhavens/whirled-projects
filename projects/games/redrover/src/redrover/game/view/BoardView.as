package redrover.game.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Matrix;

import redrover.*;
import redrover.game.*;
import redrover.util.*;

public class BoardView extends SceneObject
{
    public function BoardView (board :Board)
    {
        _board = board;
        _sprite = SpriteUtil.createSprite(false, true);

        var bd :BitmapData = new BitmapData(_board.pixelWidth, _board.pixelHeight, false,
                                            TEAM_COLORS[_board.teamId]);
        var grass :Bitmap = getGrass();
        var rock :Bitmap = getRock();
        var gemRedemption :Bitmap = getGemRedemption();

        var cellSize :int = GameCtx.levelData.cellSize;
        var grassScale :Number = cellSize / grass.width;
        var rockScale :Number = (cellSize - 3) / rock.width;
        var grScale :Number = cellSize / gemRedemption.width;

        var mat :Matrix = new Matrix();
        for (var yy :int = 0; yy < _board.rows; ++yy) {
            for (var xx :int = 0; xx < _board.cols; ++xx) {
                var px :Number = xx * cellSize;
                var py :Number = yy * cellSize;

                mat.identity();
                mat.scale(grassScale, grassScale);
                mat.translate(px, py - 5);
                bd.draw(grass, mat, null, null, null, true);

                var cell :BoardCell = _board.getCell(xx, yy);
                if (cell.isObstacle) {
                    mat.identity();
                    mat.scale(rockScale, rockScale);
                    mat.translate(px, py);
                    bd.draw(rock, mat, null, null, null, true);
                }

                if (cell.isGemRedemption) {
                    mat.identity();
                    mat.scale(grScale, grScale);
                    mat.translate(px, py + ((grass.height - 30 - gemRedemption.height) * grScale));
                    bd.draw(gemRedemption, mat, null, null, null, true);
                }
            }
        }

        var bg :Bitmap = new Bitmap(bd);
        _sprite.addChild(bg);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function getGrass () :Bitmap
    {
        if (_grass == null) {
            _grass = ImageResource.instantiateBitmap(ClientCtx.rsrcs, "grass");
        }

        _grass.filters = [ new ColorMatrix().colorize(TEAM_COLORS[_board.teamId]).createFilter() ];

        return _grass;
    }

    protected function getRock () :Bitmap
    {
        if (_rock == null) {
            _rock = ImageResource.instantiateBitmap(ClientCtx.rsrcs, "rock");
        }

        return _rock;
    }

    protected function getGemRedemption () :Bitmap
    {
        if (_gemRedemption == null) {
            _gemRedemption = ImageResource.instantiateBitmap(ClientCtx.rsrcs, "gem_redemption");
        }

        return _gemRedemption;
    }

    protected var _board :Board;
    protected var _sprite :Sprite;

    protected static var _grass :Bitmap;
    protected static var _rock :Bitmap;
    protected static var _gemRedemption :Bitmap;

    protected static const TEAM_COLORS :Array = [ 0xff6c77, 0x88c5ff ];
}

}
