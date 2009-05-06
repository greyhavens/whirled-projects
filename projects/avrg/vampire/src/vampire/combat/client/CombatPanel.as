package vampire.combat.client
{
import com.threerings.flash.SimpleTextButton;
import com.threerings.util.Command;
import com.whirled.contrib.simplegame.objects.Dragger;
import com.whirled.contrib.simplegame.objects.SceneObjectParent;

import flash.display.InteractiveObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;


public class CombatPanel extends SceneObjectParent
{
    public function CombatPanel()
    {
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _displaySprite.addChild(_draggable);

        //Create the arena for showing the positions of units.
        _arena = new Arena();
        _arena.x = 300;
        _arena.y = 100;
        addSimObject(_arena, _displaySprite);

        _dragger = createDragger();
        this.db.addObject(_dragger);

        setupUI();
    }

    protected function setupUI () :void
    {
        var nextButton :SimpleTextButton = new SimpleTextButton("NEXT");
        Command.bind(nextButton, MouseEvent.CLICK, CombatController.NEXT);
        nextButton.x = 500;
        nextButton.y = 10;
        _displaySprite.addChild(nextButton);

        modeLabel = new TextField();
        _displaySprite.addChild(modeLabel);
        modeLabel.width = 200;
        modeLabel.x = nextButton.x + nextButton.width + 10;
        modeLabel.y = nextButton.y;
        modeLabel.text = "Stuff";
    }

    override protected function removedFromDB () :void
    {
        super.removedFromDB();
        _dragger.destroySelf();
    }

    protected function get draggableObject () :InteractiveObject
    {
        return _draggable;
    }

    protected function createDragger () :Dragger
    {
        return new Dragger(this.draggableObject, this.displayObject);
    }


    public function get dragger () :Dragger
    {
        return _dragger;
    }

    public function get arena () :Arena
    {
        return _arena;
    }

    public var modeLabel :TextField;

    protected var _arena :Arena;
    protected var _draggable :Sprite = new Sprite();
    protected var _dragger :Dragger;
}
}