package com.threerings.defense.ui {

import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.VBox;
import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.Text;
import mx.managers.PopUpManager;

import com.threerings.defense.Board;
import com.threerings.defense.tuning.LevelDefinitions;
import com.threerings.defense.tuning.Messages;
import com.threerings.defense.tuning.UnitDefinitions;


public class SpawnSelector extends TitleWindow
{
    public function SpawnSelector (board :Board, changeGroupFn :Function)
    {
        _changeFn = changeGroupFn;
        _level = board.level.number;
        _playerCount = board.getPlayerCount();
        _player = board.getMyPlayerIndex();
        
        this.showCloseButton = false;
        
        addEventListener(MouseEvent.ROLL_OVER, function (event :MouseEvent) :void {
                Mouse.show();
            });
        addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                // don't send to the board - it will try to place a tower!
                event.stopPropagation(); 
            });
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var text :Text = new Text();
        text.width = 300;
        text.htmlText = Messages.get("spawn_choice");
        addChild(text);

        var box :VBox = new VBox();
        addChild(box);

        var waves :Array = LevelDefinitions.getSpawnWaves(_playerCount, _level);
        for (var ii :int = 0; ii < waves.length; ii++) {
            var wave :Array = waves[ii] as Array;
            var desc :String = "";
            for each (var def :Array in wave) {
                var type :int = def[0];
                var count :int = def[1];
                var enemyDef :Object =
                    UnitDefinitions.getValue(UnitDefinitions.ENEMY_DEFINITIONS, type);
                    desc += ((desc != "") ? ", " : "") + count + " x " + enemyDef.name;
            }

            var button :Button = new Button();
            button.label = desc;
            button.addEventListener(MouseEvent.CLICK, makeSelector(ii));
            button.percentWidth = 100;
            box.addChild(button);
        }

        var cancel :Button = new Button();
        cancel.label = Messages.get("cancel");
        cancel.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void { close(); });
        addChild(cancel);
    }

    protected function makeSelector (groupIndex :int) :Function
    {
        return function (event :MouseEvent) :void {
            _changeFn(_player, groupIndex);
            close();
        }
    }

    protected function close () :void
    {
        PopUpManager.removePopUp(this);
    }

    protected var _changeFn :Function;
    protected var _level :int;
    protected var _player :int;
    protected var _playerCount :int;
    
    protected var _title :Text;
}
}
