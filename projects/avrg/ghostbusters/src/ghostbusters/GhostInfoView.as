//
// $Id$

package ghostbusters {

import ghostbusters.Game;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.text.TextField;

import com.threerings.flash.DisplayUtil;

public class GhostInfoView
{
    public function GhostInfoView (hud :MovieClip)
    {
        _box = MovieClip(findSafely(hud, GHOST_INFO));
        _name = findSafely(_box, GHOST_NAME) as TextField;
        _level = findSafely(_box, GHOST_LEVEL) as TextField;

        _portraits = {
          pinchy: findSafely(hud, "PincherPortrait"),
          duchess: findSafely(hud, "DuchessPortrait"),
          widow: findSafely(hud, "WidowPortrait"),
          demon: findSafely(hud, "DemonPortrait")
        };

        updateGhost();
    }

    public function updateGhost () :void
    {
        var chosen :String = null;

        var data :Object = Game.model.ghostId;
        if (data != null) {
            chosen = data.id;
            _name.text = data.name;
            _level.text = "Level: " + data.level;
            _box.visible = true;

        } else {
            _box.visible = false;
            _name.text = _level.text = "";
        }

        for (var ghost :String in _portraits) {
            (_portraits[ghost] as DisplayObject).visible = (ghost == chosen);
        }
    }

    protected function findSafely (parent :DisplayObjectContainer, name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(parent, name);
        if (o == null) {
            throw new Error("Cannot find object: " + name);
        }
        return o;
    }


    protected var _box :DisplayObjectContainer;
    protected var _name :TextField;
    protected var _level :TextField;

    protected var _portraits :Object;

    protected static const GHOST_PORTRAIT :String = "GhostPortrait";
    protected static const GHOST_NAME :String = "GhostName";
    protected static const GHOST_LEVEL :String = "GhostLvl";

    protected static const GHOST_INFO :String = "GhostInfoBox";
}
}
