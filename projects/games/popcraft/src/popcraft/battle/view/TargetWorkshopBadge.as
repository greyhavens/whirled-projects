package popcraft.battle.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import popcraft.*;

public class TargetWorkshopBadge extends SceneObject
{
    public function TargetWorkshopBadge (owningPlayer :PlayerInfo)
    {
        _owningPlayerInfo = owningPlayer;
        _movie = SwfResource.instantiateMovieClip("workshop", "target_bounce");

        // recolor, if this player has other players on his team
        if (GameContext.getTeamSize(owningPlayer.teamId) > 1) {
            _movie.filters =
                [ ColorMatrix.create().colorize(_owningPlayerInfo.color).createFilter() ];
        }
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
            _workshopViewRef = SimObjectRef.Null();
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
    protected var _workshopViewRef :SimObjectRef = SimObjectRef.Null();
}

}
