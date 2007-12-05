package ui {

import flash.events.MouseEvent;
import flash.ui.Mouse;

import mx.containers.VBox;
import mx.containers.TitleWindow;
import mx.controls.Button;
import mx.controls.Text;
import mx.managers.PopUpManager;

import game.Board;
import def.EnemyDefinition;
import def.WaveElementDefinition;

import com.threerings.util.Assert;

public class SpawnSelector extends TitleWindow
{
    public function SpawnSelector (board :Board, changeGroupFn :Function)
    {
        _changeFn = changeGroupFn;
        _board = board;
        _playerCount = board.main.playerCount;
        _player = board.main.myIndex;
        
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

        var waves :Array = _board.allies;
        for (var ii :int = 0; ii < waves.length; ii++) {
            var wave :Array = waves[ii] as Array;
            var desc :String = "";
            for each (var elt :WaveElementDefinition in wave) {
                    var enemy :EnemyDefinition = _board.main.defs.findEnemy(elt.typeName);
                    Assert.isNotNull(enemy);
                    desc += ((desc != "") ? ", " : "") + elt.count + " x " + enemy.name;
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
    protected var _board :Board;
    protected var _player :int;
    protected var _playerCount :int;
    
    protected var _title :Text;
}
}
