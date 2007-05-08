//
// $Id$

package com.threerings.betthefarm {

import flash.display.Sprite;

import flash.utils.setInterval;


/**
 * Displays a progress bar. TODO: Not quite sure how to do this yet.
 */
public class ProgressBar extends Sprite
{
    public function ProgressBar (duration :uint)
    {
        super();

        setInterval(updateBar, 50);
    }

    protected function updateBar () :void
    {
    }

    protected var _startTime :uint;
    protected var _endTime :uint;
}
}
