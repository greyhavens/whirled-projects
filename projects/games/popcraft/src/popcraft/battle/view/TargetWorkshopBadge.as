//
// $Id$

package popcraft.battle.view {

import com.threerings.display.ColorMatrix;
import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.game.*;

public class TargetWorkshopBadge extends SceneObject
{
    public function TargetWorkshopBadge (owningPlayer :PlayerInfo)
    {
        _owningPlayerInfo = owningPlayer;
        _movie = ClientCtx.instantiateMovieClip("workshop", "target_bounce", true, true);

        // recolor
        _movie.filters = [ new ColorMatrix().colorize(_owningPlayerInfo.color).createFilter() ];
    }

    override protected function destroyed () :void
    {
        SwfResource.releaseMovieClip(_movie);
        super.destroyed();
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function removedFromDB () :void
    {
        removeFromWorkshop();
    }

    protected function removeFromWorkshop () :void
    {
        var workshopView :WorkshopView = _workshopViewRef.object as WorkshopView;
        if (workshopView != null) {
            workshopView.removeTargetWorkshopBadge(this);
            _workshopViewRef = GameObjectRef.Null();
        }
    }

    override protected function update (dt :Number) :void
    {
        if (!_owningPlayerInfo.isAlive) {
            destroySelf();
            return;
        }

        var newTargetedEnemy :PlayerInfo = _owningPlayerInfo.targetedEnemy;
        if (newTargetedEnemy != _targetEnemy) {
            removeFromWorkshop();

            _targetEnemy = newTargetedEnemy;
            if (_targetEnemy != null) {
                var workshopView :WorkshopView =
                    WorkshopView.getForPlayer(_targetEnemy.playerIndex);
                if (workshopView != null) {
                    workshopView.addTargetWorkshopBadge(this);
                    _workshopViewRef = workshopView.ref;
                }
            }
        }
    }

    protected var _movie :MovieClip;
    protected var _owningPlayerInfo :PlayerInfo;
    protected var _targetEnemy :PlayerInfo;
    protected var _workshopViewRef :GameObjectRef = GameObjectRef.Null();
}

}
