package com.threerings.defense.ui {

import mx.containers.Grid;
import mx.containers.GridItem;
import mx.containers.GridRow;
import mx.containers.VBox;
import mx.controls.Label;

import com.threerings.defense.tuning.Messages;
import com.threerings.util.StringUtil;

public class ScorePanel extends VBox
{
    public function ScorePanel()
    {
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        
        var header :Label = new Label();
        header.text = Messages.get("score");
        addChild(header);

        _scores = new Grid();
        addChild(_scores);
    }

    public function resetNamesAndScores (names :Array /* of String */) :void
    {
        _scores.removeAllChildren();

        for (var ii :int = 0; ii < names.length; ii++) {
            var row :GridRow = new GridRow();
            var ni :GridItem = new GridItem();
            var name :Label = new Label();
            name.text = StringUtil.truncate(names[ii], 10, "...");
            var si :GridItem = new GridItem();
            var score :Label = new Label();
            score.text = "0";

            ni.addChild(name);
            si.addChild(score);
            row.addChild(ni);
            row.addChild(si);
            _scores.addChild(row);
        }
    }
    
    public function updateScore (player :int, score :Number) :void
    {
        var row :GridRow = _scores.getChildAt(player) as GridRow; // get the player's row
        var item :GridItem = row.getChildAt(1) as GridItem;       // get the score label cell
        var label :Label = item.getChildAt(0) as Label;
        label.text = String(score);        
    }

    protected var _scores :Grid;
}
}
