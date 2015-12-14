package vampire.quest.client {

import com.threerings.flashbang.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.MovieClip;

public class StatusPanel extends SceneObject
{
    public function StatusPanel ()
    {
        _movie = ClientCtx.instantiateMovieClip("quest", "status_panel");
        _questListController = new QuestListController(_movie);
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function destroyed () :void
    {
        _questListController.shutdown();
        _questListController = null;
    }

    protected var _movie :MovieClip;
    protected var _questListController :QuestListController;
}

}
