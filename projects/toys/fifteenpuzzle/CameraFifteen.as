//
// $Id$

package {

import flash.events.ActivityEvent;
import flash.events.Event;
import flash.events.StatusEvent;

import flash.display.BitmapData;
import flash.display.Sprite;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.media.Camera;
import flash.media.Video;

[SWF(width="420", height="450")]
public class CameraFifteen extends Fifteen
{
    public function CameraFifteen ()
    {
        super();
    }

    override protected function makeTileSprites () :Array
    {
        var tiles :Array = super.makeTileSprites();

        var camera :Camera = _ctrl.getCamera();
        if (camera != null) {
            camera.addEventListener(ActivityEvent.ACTIVITY, handleCameraActivity);
            camera.addEventListener(StatusEvent.STATUS, handleCameraStatus);

            _video = new Video(BOARD_WIDTH, BOARD_HEIGHT);
            _video.attachCamera(camera);

            // remove the children of the tiles (cuz we're nasty like that)
            for each (var tile :Sprite in tiles) {
                while (tile.numChildren > 0) {
                    tile.removeChildAt(0);
                }
            }

            if (!camera.muted) {
                addEventListener(Event.ENTER_FRAME, handleFrame);
            }
        }

        return tiles;
    }

    protected function handleCameraActivity (event :ActivityEvent) :void
    {
        trace("Camera activity: " + event);
    }

    protected function handleCameraStatus (event :StatusEvent) :void
    {
        if (event.code == "Camera.Unmuted") {
            addEventListener(Event.ENTER_FRAME, handleFrame);

        } else if (event.code == "Camera.Muted") {
            removeEventListener(Event.ENTER_FRAME, handleFrame);
            _bitmapData = null;
        }
    }

    protected function handleFrame (event :Event) :void
    {
        if (_bitmapData == null) {
            _bitmapData = new BitmapData(BOARD_WIDTH, BOARD_HEIGHT, false);
        }

        // render the video into the bitmapData
        _bitmapData.draw(_video);

        for (var ii :int = 0; ii < BLANK_TILE; ii++) {
            var tile :Sprite = _tiles[ii] as Sprite;
            // get the "natural" position of this tile, not it's current position
            var p :Point = computeTilePosition(ii);
            var matrix :Matrix = new Matrix();
            matrix.translate(-p.x, -p.y);
            tile.graphics.clear();
            tile.graphics.beginBitmapFill(_bitmapData, matrix);
            tile.graphics.drawRect(0, 0, TILE_WIDTH, TILE_HEIGHT);
            tile.graphics.endFill();
        }
    }

    protected var _video :Video;

    protected var _bitmapData :BitmapData;
}
}
