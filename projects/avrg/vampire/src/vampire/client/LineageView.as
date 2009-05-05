package vampire.client
{

import com.threerings.util.Log;

import flash.display.MovieClip;
import flash.display.SimpleButton;

import vampire.client.events.LineageUpdatedEvent;

public class LineageView extends LineageViewBase
{

    public function LineageView ()
    {
        super(
        function () :MovieClip {
            return ClientContext.instantiateMovieClip("HUD", "droplet", true);
        },
        function () :SimpleButton {
            return ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
        });



        _selectedPlayerIdCenter = ClientContext.ourPlayerId;
        if (ClientContext.model != null) {
            _lineage = ClientContext.model.lineage;
            _events.registerListener(ClientContext.model, LineageUpdatedEvent.LINEAGE_UPDATED, updateLineageEvent);
        }
        if (_lineage != null) {
            updateLineage(_selectedPlayerIdCenter);
        }
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected function updateLineageEvent (e :LineageUpdatedEvent) :void
    {
        _lineage = e.lineage;
        log.debug(" updateLineageEvent", "e", e, "_lineage", _lineage);
        if (_lineage == null) {
            log.error("updateHierarchyEvent(), but hierarchy is null :-(");
            return;
        }
        updateLineage(_selectedPlayerIdCenter);
    }

    public static const NAME :String = "LineageSceneObject";
    protected static const log :Log = Log.getLog(LineageView);

}
}

