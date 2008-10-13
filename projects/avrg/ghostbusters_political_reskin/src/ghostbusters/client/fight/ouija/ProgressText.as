package ghostbusters.client.fight.ouija {

import flash.text.*;
import flash.geom.Point;

public class ProgressText extends TextField
{
    public function ProgressText (targetText :String)
    {
        _targetText = targetText;

        // create the progress text display
        this.embedFonts = true;
        this.mouseEnabled = false;
        this.selectable = false;
        this.wordWrap = false;
        this.multiline = false;
        this.embedFonts = true;
        this.antiAliasType = AntiAliasType.ADVANCED;
        this.autoSize = TextFieldAutoSize.CENTER;

        this.x = TEXT_LOC.x;
        this.y = TEXT_LOC.y;

        this.progress = 0;
    }

    public function advanceProgress () :void
    {
        this.progress = _progress + 1;
    }

    protected function set progress (val :int) :void
    {
        _progress = Math.min(val, _targetText.length);
        _progress = Math.max(_progress, 0);

        var progressText :String = _targetText.substr(0, _progress);
        var remainingText :String = _targetText.substr(_progress, _targetText.length - _progress);

        var html :String = "<P ALIGN='CENTER'>";

        if (progressText.length > 0) {
            html +=
                "<FONT FACE='" + Content.FONT_GAME_NAME +
                "' SIZE='" + TEXT_SIZE +
                "' COLOR='#" + PROGRESS_COLOR.toString(16) + "'>" +
                progressText +
                "</FONT>";
        }

        if (remainingText.length > 0) {
            html +=
                "<FONT FACE='" + Content.FONT_GAME_NAME +
                "' SIZE='" + TEXT_SIZE +
                "' COLOR='#" + REMAINING_COLOR.toString(16) + "'>" +
                remainingText +
                "</FONT>";
        }

        html += "</P>";

        this.htmlText = html;

    }

    protected var _targetText :String;
    protected var _progress :int;

    protected static const TEXT_LOC :Point = new Point(148, 0);

    protected static const PROGRESS_COLOR :uint = 0xE58F2F;
    protected static const REMAINING_COLOR :uint = 0xDEDEDE;
    protected static const TEXT_SIZE :int = 20;

}

}
