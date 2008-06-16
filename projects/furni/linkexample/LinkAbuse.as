//
//

package {

import flash.display.Sprite;

import flash.events.TimerEvent;

import flash.net.URLRequest;

import flash.utils.Timer;

/**
 * Demonstrates annoying abuse behavior. This could be done by an avatar.
 */
[SWF(width="50", height="50")]
public class LinkAbuse extends Sprite
{
    public function LinkAbuse ()
    {
        _t = new Timer(500);
        _t.addEventListener(TimerEvent.TIMER, handleTimer);
        _t.start();
    }

    protected function handleTimer (event :TimerEvent) :void
    {
        flash.net.navigateToURL(new URLRequest("http://google.com"));
    }

    // NOTE: this doesn't even properly unload

    protected var _t :Timer;
}
}
