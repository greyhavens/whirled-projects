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
import popcraft.game.*;

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

        _text.defaultTextFormat = format;

        _text.autoSize = TextFieldAutoSize.LEFT;
        _text.multiline = true;
        _text.wordWrap = true;
        _text.selectable = false;

        _text.y = 335;

        updateText();
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
            updateText();
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

        _text.textColor = (avgFps > SLOW_FPS ? DEFAULT_COLOR : SLOW_COLOR);

        _text.text =
            "Day: " + GameContext.diurnalCycle.dayCount + "\n" +
            "Player ID: " + GameContext.localPlayerIndex + "\n" +
            "FPS avg: " + Math.round(avgFps) + " cur: " + Math.round(thisFps) + "\n" +
            "GameObjects: " + GameContext.gameMode.objectCount + "\n" +
            "NetObjects: " + GameContext.netObjects.objectCount;
    }

    protected var _text :TextField;
    protected var _fpsBuffer :RingBuffer = new RingBuffer(30);

    protected static const TEXT_MARGIN :Point = new Point(2, 2);

    protected static const NAME :String = "DebugDataView";

    protected static const SLOW_FPS :Number = 19;
    protected static const DEFAULT_COLOR :uint = 0x00FF00;
    protected static const SLOW_COLOR :uint = 0xFF0000;

}
}
