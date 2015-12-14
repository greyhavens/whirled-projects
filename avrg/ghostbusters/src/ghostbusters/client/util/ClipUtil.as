//
// $Id: $

package ghostbusters.client.util {

import flash.display.MovieClip;

import flash.display.DisplayObject;

import com.threerings.flash.DisplayUtil;

public class ClipUtil
{
    public static function reallyStop (obj :DisplayObject) :void
    {
        DisplayUtil.applyToHierarchy(obj, function (disp :DisplayObject) :void {
            if (disp is MovieClip) {
                MovieClip(disp).stop();
            }
        });
    }
}
}
