package popcraft.ui {

import com.threerings.util.RingBuffer;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import popcraft.*;

public class DebugDataView extends SceneObject
{
    public static function get instance () :DebugDataView
    {
        return MainLoop.instance.topMode.getObjectNamed(NAME) as DebugDataView;
    }

    public function DebugDataView ()
    {
        var format :TextFormat = new TextFormat();
        format.color = 0xFF0000;
        format.size = 12;

        _text = new TextField();

        _text.background = true;
        _text.backgroundColor = 0xFFFFFF;
        _text.border = true;
        _text.borderColor = 0x000000;

        _text.defaultTextFormat = format;

        _text.autoSize = TextFieldAutoSize.LEFT;
        _text.multiline = true;
        _text.wordWrap = true;
        _text.selectable = false;

        //_text.x = TEXT_MARGIN.x;
        //_text.y = TEXT_MARGIN.y;

        this.updateText();
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override public function get displayObject () :DisplayObject
    {
        return _text;
    }

    override protected function update (dt :Number) :void
    {
        if (this.visible) {
            this.updateText();
        }
    }

    protected function updateText () :void
    {
        var thisFps :Number = MainLoop.instance.fps;

        // calculate fps average

        _fpsBuffer.push(thisFps);

        var sumFps :Number = 0;
        _fpsBuffer.forEach(function (num :Number) :void { sumFps += num; });
        var avgFps :Number = sumFps / _fpsBuffer.length;

        _text.text =
            "Player ID: " + GameContext.localPlayerId + "\n" +
            "FPS avg: " + Math.round(avgFps) + " cur: " + Math.round(thisFps) + "\n" +
            "GameObjects: " + GameContext.gameMode.objectCount + "\n" +
            "NetObjects: " + GameContext.netObjects.objectCount;
    }

    protected var _text :TextField;
    protected var _fpsBuffer :RingBuffer = new RingBuffer(30);

    protected static const TEXT_MARGIN :Point = new Point(2, 2);

    protected static const NAME :String = "DebugDataView";

}
}
