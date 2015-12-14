package vampire.combat.client
{
import com.threerings.flashbang.objects.SceneObjectParent;
import com.threerings.ui.SimpleTextButton;
import com.threerings.util.Command;
import com.whirled.contrib.DisplayUtil;

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;


public class CombatPanel extends SceneObjectParent
{
    public function CombatPanel(game :GameInstance)
    {
        _game =  game;
        setupUI();
    }


    override protected function addedToDB () :void
    {
        trace("Panel is added to db");
        super.addedToDB();
    }

    protected function setupUI () :void
    {
        //Place the stats and action chooser on this panel
        _displaySprite.addChild(_unitsMenu);

        _unitsMenu.addChild(_unitsStatsLayer);
        var draggableStatsLayer :SimpleDraggableObject = new SimpleDraggableObject(_unitsMenu);
        addSceneObject(draggableStatsLayer, _displaySprite);
        _unitsMenu.x = 100;
        _unitsMenu.y = 60;

        //Action chooser
        _actionChooser = new ActionChooser();
        addGameObject(_actionChooser);
        _actionChooser.x = -30;
        _actionChooser.y = 50;




        //Create the arena for showing the positions of units.
        _arena = new Arena();
        _arena.x = 250;
        _arena.y = 100;
        trace("here");
        addSceneObject(_arena, _displaySprite);


        //Next mode button
        var nextButton :SimpleTextButton = new SimpleTextButton("GO!");
        Command.bind(nextButton, MouseEvent.CLICK, CombatController.NEXT);
        nextButton.x = 500;
        nextButton.y = 10;
        _displaySprite.addChild(nextButton);

        //Show the current mode
        modeLabel = new TextField();
//        _displaySprite.addChild(modeLabel);
        modeLabel.width = 200;
        modeLabel.x = nextButton.x + nextButton.width + 10;
        modeLabel.y = nextButton.y;
        modeLabel.text = "Stuff";

        //Mouseover target
        _displaySprite.addChild(_mouseOverTarget);
        _mouseOverTarget.x = 820;
        _mouseOverTarget.y = 200;

//        var g :Graphics = _mouseOverTarget.graphics;
//        g.beginFill(0);
//        g.drawCircle(0, 0, 100);
//        g.endFill();
    }

    public function attachActionChooser () :void
    {
        _unitsMenu.addChild(_actionChooser.displayObject);
    }
    public function detachActionChooser () :void
    {
        DisplayUtil.detach(_actionChooser.displayObject);
    }

    public function get arena () :Arena
    {
        return _arena;
    }

    public function get actionChooser () :ActionChooser
    {
        return _actionChooser;
    }

    public function get unitStatsLayer () :Sprite
    {
        return _unitsStatsLayer;
    }

    public function setUnitForRightInfo (unit :UnitRecord) :void
    {
        if (unit == null) {
            DisplayUtil.removeAllChildren(_mouseOverTarget);
        }
        else {
            if (unit != _game.selectedFriendlyUnit) {
                _mouseOverTarget.addChild(unit.displayObject);
                unit.x = 0;
                unit.y = 0;

            }
        }
    }

    protected var _game :GameInstance;
    public var modeLabel :TextField;

    protected var _arena :Arena;
    protected var _unitsStatsLayer :Sprite = new Sprite();
    protected var _unitsMenu :Sprite = new Sprite();
    protected var _mouseOverTarget :Sprite = new Sprite();
    protected var _actionChooser :ActionChooser;

}
}
