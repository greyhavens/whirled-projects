//
// $Id$

package com.threerings.betthefarm {

import flash.display.Sprite;
import flash.display.Graphics;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.utils.Timer;
import flash.utils.getTimer;

import com.threerings.flash.ColorUtil;

/**
 * A single chat bubble. This is currently cobbled from internal Whirled code.
 */
public class ChatBubble extends Sprite
{
    public function ChatBubble (msg :String, lifetime :int = 30)
    {
        // set up an expire timer, if needed
        if (lifetime != int.MAX_VALUE) {
            var timer :Timer = new Timer(lifetime, 1);
            timer.addEventListener(TimerEvent.TIMER, handleStartExpire, false, 0, true);
            timer.start();
        }

        var txt :TextField = new TextField();
        txt.multiline = true;
        txt.wordWrap = true;
        txt.selectable = true;
        txt.alwaysShowSelection = true;
        txt.width = 400;
        txt.autoSize = TextFieldAutoSize.CENTER;
        txt.text = msg;
        if (txt.textWidth > MINIMUM_SPLIT_WIDTH && txt.numLines == 1) {
            txt.width = 200;
        }

        txt.autoSize = TextFieldAutoSize.NONE;
        const FUDGE_X :int = 5;
        const FUDGE_Y :int = 4;
        txt.width = txt.textWidth + FUDGE_X;
        txt.height = txt.textHeight + FUDGE_Y;

        addChild(txt);
        var offset :int = drawBubbleShape(graphics, txt.width, txt.height);
        txt.x = offset;
        txt.y = offset;

    }

    /**
     * Draw the specified bubble shape.
     *
     * @return the padding that should be applied to the bubble's label.
     */
    protected function drawBubbleShape (
        g :Graphics, txtWidth :int, txtHeight :int, ageLevel :int = 0) :int
    {
        // this little bit copied from superclass- if we keep: reuse
        var outline :uint = GAME_COLOR;
        var background :uint;
        if (BLACK == outline) {
            background = WHITE;
            if (ageLevel != 0) {
                background = uint(BACKGROUNDS[ageLevel]);
            }
        } else {
            background = ColorUtil.blend(WHITE, outline, .8);
        }

        var padding :int = PAD;
        var width :int = txtWidth + padding * 2;
        var height :int = txtHeight + padding * 2;

        var shapeFunction :Function = drawRoundedBubble;

        // clear any old graphics
        g.clear();
        // fill the shape with the background color
        g.beginFill(background);
        shapeFunction(g, width, height);
        g.endFill();
        // draw the shape with the outline color
        g.lineStyle(1, outline);
        shapeFunction(g, width, height);

        return padding;
    }


    protected function drawRoundedBubble (g :Graphics, w :int, h :int) :void
    {
        g.drawRoundRect(0, 0, w, h, PAD * 4, PAD * 4);
    }

    protected function handleStartExpire (evt :TimerEvent) :void
    {
        if (parent) {
            _deathStamp = getTimer() + FADE_DURATION;
            addEventListener(Event.ENTER_FRAME, handleFadeStep, false, 0, true);
        }
    }

    protected function handleFadeStep (evt :Event) :void
    {
        var left :int = _deathStamp - getTimer();
        if (left > 0) {
            alpha = (left / FADE_DURATION);

        } else {
            removeEventListener(Event.ENTER_FRAME, handleFadeStep);
        }
    }

    /** The time to die, fully. Used during fade. */
    protected var _deathStamp :int;

    protected static const FADE_DURATION :int = 600;

    protected static const MINIMUM_SPLIT_WIDTH :int = 90;

    protected static const PAD :int = 10;

    protected static const BLACK :uint = 0x000000;

    protected static const WHITE :uint = 0xFFFFFF;

    protected static const GAME_COLOR :uint = 0x777777;

    protected static const MAX_BUBBLES :uint = 10;

    /** The background colors to use when drawing bubbles. */
    protected static const BACKGROUNDS :Array = new Array(MAX_BUBBLES);

    private static function staticInit () :void
    {
        var yellowy :uint = 0xdddd6a;
        var blackish :uint = 0xcccccc;

        var steps :Number = (MAX_BUBBLES - 1) / 2;
        var ii :int;
        for (ii = 0; ii < MAX_BUBBLES / 2; ii++) {
            BACKGROUNDS[ii] = ColorUtil.blend(0xFFFFFF, yellowy,
                (steps - ii) / steps);
        }
        for (ii = MAX_BUBBLES / 2; ii < MAX_BUBBLES; ii++) {
            BACKGROUNDS[ii] = ColorUtil.blend(blackish, yellowy,
                (ii - steps) / steps);
        }
    }
    staticInit();
}
}
