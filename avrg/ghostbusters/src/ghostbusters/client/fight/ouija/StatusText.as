package ghostbusters.client.fight.ouija {

import flash.text.*;
import flash.geom.Point;

import ghostbusters.client.fight.common.*;

public class StatusText extends TextField
{
    public function StatusText ()
    {
        // create the progress text display
        this.embedFonts = true;
        this.mouseEnabled = false;

        var format :TextFormat = new TextFormat();
        format.font = Resources.OUIJA_FONT_NAME;
        format.size = TEXT_SIZE;
        format.color = TEXT_COLOR;
        format.align = TextFormatAlign.CENTER;

        this.defaultTextFormat = format;
        this.selectable = false;
        this.wordWrap = false;
        this.multiline = false;
        this.embedFonts = true;
        this.antiAliasType = AntiAliasType.ADVANCED;
        this.autoSize = TextFieldAutoSize.CENTER;

        this.x = TEXT_LOC.x;
        this.y = TEXT_LOC.y;
    }

    protected static const TEXT_LOC :Point = new Point(148, 0);
    protected static const TEXT_COLOR :uint = 0xE58F2F;
    protected static const TEXT_SIZE :int = 20;

}

}
