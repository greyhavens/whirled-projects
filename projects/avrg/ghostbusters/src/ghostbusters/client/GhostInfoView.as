//
// $Id$

package ghostbusters.client {

import ghostbusters.client.Game;
import ghostbusters.data.Codes;
import ghostbusters.client.util.GhostModel;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.text.TextField;

import com.threerings.flash.DisplayUtil;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

public class GhostInfoView
{
    public function GhostInfoView (hud :MovieClip)
    {
        _box = MovieClip(findSafely(hud, GHOST_INFO));
        _name = TextField(findSafely(_box, GHOST_NAME));
        _level = TextField(findSafely(_box, GHOST_LEVEL));

        _portraits = {
          pinchy: findSafely(hud, "PincherPortrait"),
          duchess: findSafely(hud, "DuchessPortrait"),
          widow: findSafely(hud, "WidowPortrait"),
          demon: findSafely(hud, "DemonPortrait")
        };

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        Game.control.room.props.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED, propertyChanged);

        updateGhost();
    }

    protected function propertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.DICT_GHOST) {
            updateGhost();
        }
    }

    protected function updateGhost () :void
    {
        var chosen :String = GhostModel.getId();

        if (chosen != null && Game.state != Codes.STATE_SEEKING) {
            _name.htmlText = GhostModel.getName();
            _name.text = GhostModel.getName();
            _level.text = "Level: " + GhostModel.getLevel();
            _box.visible = true;

        } else {
            _box.visible = false;
            _name.text = _level.text = "";
        }

        for (var ghost :String in _portraits) {
            DisplayObject(_portraits[ghost]).visible = (ghost == chosen);
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
