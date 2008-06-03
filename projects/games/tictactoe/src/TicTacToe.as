package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

/** The main tic-tac-toe sprite. */    
public class TicTacToe extends Sprite
{
    public static const BOXSIZE :int = 150;

    public function TicTacToe ()
    {
        _ctrl = new GameControl(this);

        _ctrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);

        _ctrl.net.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED, elementChanged);

        _ctrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, turnChanged);

        _ctrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        addEventListener(MouseEvent.CLICK, click);

        graphics.beginFill(0xFFFFFF);
        graphics.drawRect(0, 0, BOXSIZE*3, BOXSIZE*3);
        graphics.endFill();

        graphics.lineStyle(4, 0x000000);

        graphics.moveTo(BOXSIZE, 0);
        graphics.lineTo(BOXSIZE, BOXSIZE * 3);

        graphics.moveTo(BOXSIZE * 2, 0);
        graphics.lineTo(BOXSIZE * 2, BOXSIZE * 3);

        graphics.moveTo(0, BOXSIZE);
        graphics.lineTo(BOXSIZE * 3, BOXSIZE);

        graphics.moveTo(0, BOXSIZE * 2);
        graphics.lineTo(BOXSIZE * 3, BOXSIZE * 2);
    }

    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == Server.BOARD) {
            for (var ii :int = 0; ii < 9; ++ii) {
                update(ii);
            }
        }
    }

    protected function elementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == Server.BOARD) {
            update(event.index);
        }
    }

    protected function turnChanged (event :StateChangedEvent) :void
    {
        if (_ctrl.game.isMyTurn()) {
            _enable = true;
        }
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == Server.THREE_IN_A_ROW) {
            var stripe :Sprite = new Sprite();
            var indices :Array = event.value as Array;

            stripe.graphics.beginFill(0xFFFFFF);
            stripe.graphics.drawRect(0, 0, BOXSIZE*3, BOXSIZE*3);
            stripe.graphics.endFill();

            stripe.graphics.lineStyle(4, 0xFF0000);
            stripe.graphics.moveTo(
                (indices[0] % 3) * BOXSIZE + BOXSIZE/2,
                (indices[0] / 3) * BOXSIZE + BOXSIZE/2);
            stripe.graphics.moveTo(
                (indices[1] % 3) * BOXSIZE + BOXSIZE/2,
                (indices[1] / 3) * BOXSIZE + BOXSIZE/2);

            addChild(stripe);
        }
    }

    protected function update (idx :int) :void
    {
        var x :Number = (idx % 3) * BOXSIZE;
        var y :Number = (idx / 3) * BOXSIZE;
        var symbol :int = _ctrl.net.get(Server.BOARD)[idx];

        graphics.beginFill(0x000000);
        graphics.drawRect(x + 10, y + 10, BOXSIZE - 20, BOXSIZE - 20);
        graphics.endFill();

        if (symbol == 1) {
            graphics.lineStyle(4, 0x000000);
            graphics.moveTo(x + 10, y + 10);
            graphics.lineTo(x + BOXSIZE - 20, y + BOXSIZE - 20);
        }
        else if (symbol == 2) {
            graphics.lineStyle(4, 0x000000);
            graphics.drawCircle(x + BOXSIZE / 2, y + BOXSIZE / 2, BOXSIZE / 2 - 10);
        }
    }

    protected function click (event :MouseEvent) :void
    {
        if (!_enable) {
            return;
        }

        var x :Number = event.localX / BOXSIZE;
        var y :Number = event.localY / BOXSIZE;
        if (x >= 0 && x <= 2 && y >= 0 && y <= 2) {
            graphics.beginFill(0xff0000);
            graphics.drawCircle(
                x * BOXSIZE + BOXSIZE / 2, 
                y * BOXSIZE + BOXSIZE / 2, BOXSIZE / 10);
            graphics.endFill();
            _ctrl.net.sendMessage(Server.MOVE, y * 3 + x, mySymbol);
            _enable = false;
        }
    }

    protected function get mySymbol () :int
    {
        return _ctrl.game.seating.getMyPosition() + 1;
    }

    protected var _ctrl :GameControl;
    protected var _enable :Boolean;
}

}
