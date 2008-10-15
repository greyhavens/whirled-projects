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
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;

public class GhostInfoView
{
    public function GhostInfoView (hud :MovieClip)
    {
        _box = MovieClip(findSafely(hud, GHOST_INFO));
        _name = TextField(findSafely(_box, GHOST_NAME));
        _level = TextField(findSafely(_box, GHOST_LEVEL));

        _abilities = [
            TextField(findSafely(_box, GHOST_ABILITY_1)),
            TextField(findSafely(_box, GHOST_ABILITY_2)),
            TextField(findSafely(_box, GHOST_ABILITY_3)),
                ];

        _portraits = {//SKIN
//          pinchy: findSafely(hud, "PincherPortrait"),
//          duchess: findSafely(hud, "McCainPortrait")
	  mccain: findSafely(hud, "McCainPortrait"),
          palin: findSafely(hud, "PalinPortrait")
//          demon: findSafely(hud, "DemonPortrait")
        };

        Game.control.room.props.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);

        Game.control.player.addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);

        updateGhost();
    }

    public function get ghostBox () :MovieClip
    {
        return _box;
    }

    protected function propertyChanged (evt :PropertyChangedEvent) :void
    {
        if (evt.name == Codes.DICT_GHOST) {
            updateGhost();
        }
    }

    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        updateGhost();
    }

    protected function updateGhost () :void
    {
        var chosen :String = GhostModel.getId();

        if (chosen != null) {
            _name.htmlText = GhostModel.getName();
            _name.text = GhostModel.getName();
            _level.text = "Level: " + GhostModel.getLevel();

//            TextField(_abilities[0]).text = "Lethal Embrace";
//            TextField(_abilities[1]).text = "Slime Rain";
//            TextField(_abilities[2]).text = "";

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

    protected var _box :MovieClip;
    protected var _name :TextField;
    protected var _level :TextField;

    protected var _abilities :Array;
    protected var _portraits :Object;

    protected static const GHOST_PORTRAIT :String = "GhostPortrait";
    protected static const GHOST_NAME :String = "GhostName";
    protected static const GHOST_LEVEL :String = "GhostLvl";

    protected static const GHOST_ABILITY_1 :String = "GhostAbility1";
    protected static const GHOST_ABILITY_2 :String = "GhostAbility2";
    protected static const GHOST_ABILITY_3 :String = "GhostAbility3";

    protected static const GHOST_INFO :String = "GhostInfoBox";
}
}
