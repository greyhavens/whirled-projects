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
    public function GhostInfoView (ghostInfo :MovieClip)
    {
        _box = ghostInfo;
        _name = findSafely(GHOST_NAME) as TextField;
        _level = findSafely(GHOST_LEVEL) as TextField;

        _portraits = {
          pinchy: findSafely("PincherPortrait"),
          duchess: findSafely("DuchessPortrait"),
          widow: findSafely("WidowPortrait"),
          demon: findSafely("DemonPortrait")
        };
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

    protected function findSafely (name :String) :DisplayObject
    {
        var o :DisplayObject = DisplayUtil.findInHierarchy(_box, name);
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
}
}
