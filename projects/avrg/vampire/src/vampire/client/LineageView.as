package vampire.client
{

import com.threerings.flash.TextFieldUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.tasks.AlphaTask;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.LocationTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import vampire.client.events.LineageUpdatedEvent;
import vampire.data.Lineage;

public class LineageView extends LineageViewBase
{

    public function LineageView ()
    {
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
        }
//        if (_hierarchy.isPlayer(_selectedPlayerIdCenter)) {
            updateLineage(_selectedPlayerIdCenter);
//        }
    }

    protected static const yInc :int = 30;
    public static const NAME :String = "LineageSceneObject";
    protected static const log :Log = Log.getLog(LineageView);

}
}

