package vampire.client
{
import com.threerings.flash.TextFieldUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SceneObjectParent;
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

import vampire.data.Lineage;
import vampire.data.VConstants;

/**
 * ClientContext.instantiateMovieClip("HUD", "droplet", true);
 * ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
 */
public class LineageViewBase extends SceneObjectParent
{

    public function LineageViewBase (dropCreation :Function,
                                     lineageIconCreation :Function,
                                     lineage :Lineage = null,
                                     centerPlayerId :int = 0)
    {
        _dropCreation = dropCreation;
        _lineageIconCreation = lineageIconCreation;
        _lineage = lineage;
        _hierarchyTree = new Sprite();

        _displaySprite.addChild(_hierarchyTree);
        _selfReference = this;


        _selectedPlayerIdCenter = centerPlayerId;

        _lilith = new Sprite();
        _lilith.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR, 1);
        _lilith.graphics.moveTo(0, 0);
        _lilith.graphics.lineTo(0, 120);
        var drop :MovieClip = dropCreation() as MovieClip;
        drop.scaleX = drop.scaleY = 3.0;
        _lilith.addChild(drop);
        _lilith.addChild(DropSceneObject.getTextFieldCenteredOn("Lilith", 40, 0));
        _lilith.y = -100;
        if (_lineage != null && _lineage.isConnectedToLilith
            && !_lineage.isPlayer(VConstants.UBER_VAMP_ID)) {
            _displaySprite.addChild(_lilith);
        }


        if (_lineage != null) {
            updateLineage(_selectedPlayerIdCenter);
        }
    }

    override public function get objectName () :String
    {
        return null;
    }

    public function get displaySprite () :Sprite
    {
        return _displaySprite;
    }

    public function updateLineage (playerIdToCenter :int) :void
    {
        if (_isLayoutMoving) {
            return;
        }
        else {
            centerLinageOnPlayer(playerIdToCenter);
        }
    }

    protected function centerLinageOnPlayer (playerIdToCenter :int) :void
    {
        if (_lineage == null) {
            _lineage = new Lineage();
            _lineage.setPlayerSire(playerIdToCenter, 0);
        }

        _isLayoutMoving = true;
        for each (var ui :SceneObject in _volatileUIComponents) {
            if (ui.isLiveObject) {
                ui.destroySelf();
            }
        }

        //If we change the player to center, revert to page 0;
        if (_selectedPlayerIdCenter != playerIdToCenter) {
            _hierarchyPage = 0;
        }

//        _previousHierarchyPage = _hierarchyPage;

        _selectedPlayerIdCenter = playerIdToCenter;

        var playerX :int = 0;//150;
        var playerY :int = 0;//150;

        _hierarchyTree.graphics.clear();

        //Record which player droplets are shown, so we can animate them better.
        _visiblePlayers.clear();

        //Draw links
        recursivelyDrawSires(_hierarchyTree, playerIdToCenter, playerX, playerY, true, 0);
        drawProgeny(_hierarchyTree, playerIdToCenter, playerX, playerY, true, 0);

        //Draw labels
        recursivelyDrawSires(_hierarchyTree, playerIdToCenter, playerX, playerY, false, 0);
        drawProgeny(_hierarchyTree, playerIdToCenter, playerX, playerY, false, 0);

        //Move the invisible drops away
        _player2Drop.forEach(function (playerId :int, so :DropSceneObject) :void {

//            if (so.isLiveObject) {
//                so.destroySelf();
//            }

            if (!_visiblePlayers.contains(playerId)) {
                so.disableMouseListeners();
                so.removeAllTasks();
                so.x = -150;
                so.y = 0;
                so.alpha = 0;

                if (so.displayObject.parent != null) {
                    so.displayObject.parent.setChildIndex(so.displayObject, 0);
                }
            }
        });

        _isLayoutMoving = false;
    }

    protected function recursivelyDrawSires (s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int, left :Boolean = false) :void
    {
        depth++;
        if (playerId < 1) {
            return;
        }

        if (depth < 4) {
            drawPlayerWithSireLink(s, playerId, startX, startY, startX, startY - yInc, linkOnly, false, left);
            var sireId :int = _lineage.getSireId(playerId);
            recursivelyDrawSires(s, sireId, startX, startY - yInc, linkOnly, depth, !left);
        }
        else {
            if (linkOnly) {
//                    drawLineFrom(s, startX, startY, startX, startY - yInc);
            }
            else {
                var grandSireCount :int = _lineage.getNumberOfSiresAbove(playerId);

                var sireTextSO :SceneObject = new SimpleSceneObject(
                    getTextFieldCenteredOn((1 + grandSireCount) + " Superior GrandSire" +
                    (grandSireCount > 2 ? "s" : ""), startX, startY, false, !left));
                _volatileUIComponents.push(sireTextSO);
                addSimObject(sireTextSO, s);

//                s.addChild();
            }
        }

    }

    protected function drawProgeny (s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int, left :Boolean = false) :void
    {
       var i :int;

        if (playerId < 1) {
            return;
        }

        var progenyIds :Array = _lineage.isPossessingProgeny(playerId) ? _lineage.getProgenyIds(playerId) : [];

        var progenyCount :int = progenyIds.length;

        var startProgenyViewIndex :int = 0;

        if (progenyCount > MAX_PROGENY_SHOWN) {
            startProgenyViewIndex = _hierarchyPage * MAX_PROGENY_SHOWN;

            //Delete progenys after the last entry in the 'page'
            progenyIds.splice(startProgenyViewIndex + MAX_PROGENY_SHOWN);


            //Delete progenys before the first entry in the 'page'
            progenyIds = progenyIds.slice(startProgenyViewIndex);

        }
        var locations :Array = computeProgenyLocations(startX, startY, progenyIds.length);

        //Draw the page left/right buttons.
        if (startProgenyViewIndex > 0) {
            //The button
            var button_page_left :SimpleButton = _lineageIconCreation() as SimpleButton;
            var buttonLeftSO :SceneObject = new SimpleSceneObject(button_page_left);
            addSimObject(buttonLeftSO, s);
            _volatileUIComponents.push(buttonLeftSO);
            buttonLeftSO.x = locations[0].x - 25;
            buttonLeftSO.y = startY + yInc;
//            s.addChild(button_page_left);
            registerListener(button_page_left, MouseEvent.CLICK, showPreviousPage);
            addGlowFilter(button_page_left);


//            Command.bind(button_page_left, MouseEvent.CLICK, showPreviousPage);
            //The text
            var textPageLeft :TextField = getTextFieldCenteredOn("More", locations[0].x - 25, startY + yInc - 40, true, left);
            textPageLeft.mouseEnabled = true;
            var textLeftSO :SceneObject = new SimpleSceneObject(textPageLeft);
            _volatileUIComponents.push(textLeftSO);
            addSimObject(textLeftSO, s);
//            s.addChild(textPageLeft);
            registerListener(textPageLeft, MouseEvent.CLICK, showPreviousPage);
//            Command.bind(textPageLeft, MouseEvent.CLICK, showPreviousPage);
            addGlowFilter(textPageLeft);
        }
        //Show the more sub progeny button
        if (startProgenyViewIndex + MAX_PROGENY_SHOWN < progenyCount) {
            var button_page_right :SimpleButton = _lineageIconCreation() as SimpleButton;
            var buttonRightSO :SceneObject = new SimpleSceneObject(button_page_right);
            buttonRightSO.x = locations[locations.length - 1].x + 25;
            buttonRightSO.y = startY + yInc;
            addSimObject(buttonRightSO, s);
            _volatileUIComponents.push(buttonRightSO);
//            s.addChild(button_page_right);
            registerListener(button_page_right, MouseEvent.CLICK, showNextPage);
//            Command.bind(button_page_right, MouseEvent.CLICK, showNextPage);
            addGlowFilter(button_page_right);
            //The text
            var textPageRight :TextField = getTextFieldCenteredOn("More", locations[locations.length - 1].x + 25, startY + yInc - 40, true, left);
            var textRightSO :SceneObject = new SimpleSceneObject(textPageRight);
            _volatileUIComponents.push(textRightSO);
            addSimObject(textRightSO, s);
            textPageRight.mouseEnabled = true;
//            s.addChild(textPageRight);
            registerListener(textPageRight, MouseEvent.CLICK, showNextPage);
//            Command.bind(textPageRight, MouseEvent.CLICK, showNextPage);
            addGlowFilter(textPageRight);
        }



        var horizontalBarY :int = startY + yInc;

        if (progenyIds.length > 1) {

            var minX :Number = Number.MAX_VALUE;
            var maxX :Number = Number.MIN_VALUE;
            for(i = 0; i < locations.length; i++) {
                minX = Math.min(minX, locations[i].x);
                maxX = Math.max(maxX, locations[i].x);
            }
            s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
            s.graphics.moveTo(minX, horizontalBarY);
            s.graphics.lineTo(maxX, horizontalBarY);

        }

        if (progenyIds.length >= 1) {
            s.graphics.moveTo(startX, startY);
            s.graphics.lineTo(startX, horizontalBarY);
        }


        for(i = 0; i < locations.length; i++) {

            drawPlayerWithSireLink(s, progenyIds[i], locations[i].x, locations[i].y, locations[i].x, horizontalBarY, linkOnly, true, left);
            var subProgenyCount :int = _lineage.getAllDescendentsCount(progenyIds[i]);
            if (subProgenyCount > 0) {
                if (linkOnly) {
                    drawLineFrom(s, locations[i].x, locations[i].y, locations[i].x, locations[i].y - yInc);
                }
                else {
                    var button_hiararchy :SimpleButton = _lineageIconCreation() as SimpleButton;
                    var buttonDownSO :SceneObject = new SimpleSceneObject(button_hiararchy);

                    buttonDownSO.x = locations[i].x - button_hiararchy.width;
                    buttonDownSO.y = locations[i].y + yInc + buttonDownSO.width / 2 + 12;
                    addSimObject(buttonDownSO, s);
                    _volatileUIComponents.push(buttonDownSO);

                    var centerId :int;

                    if (!_lineage.isLeaf(progenyIds[i])) {
                        centerId = progenyIds[i];
                        registerListener(button_hiararchy, MouseEvent.CLICK, function (...ignored) :void {
                            function centerOn () :void {
                                centerLinageOnPlayer(centerId);
                            }
                            centerOn();
                        });
                        addGlowFilter(button_hiararchy);
                    }

                    var subProgenyTextField :TextField = getTextFieldCenteredOn(subProgenyCount + "", locations[i].x + 4, locations[i].y +1*yInc, true, left);
                    var subProgenyTextSO :SceneObject = new SimpleSceneObject(subProgenyTextField);
                    subProgenyTextField.mouseEnabled = true;
                    addSimObject(subProgenyTextSO, s);
                    _volatileUIComponents.push(subProgenyTextSO);
                    if (!_lineage.isLeaf(progenyIds[i])) {
                        centerId = progenyIds[i];
                        registerListener(subProgenyTextField, MouseEvent.CLICK, function (...ignored) :void {
                            function centerOn () :void {
                                centerLinageOnPlayer(centerId);
                            }
                            centerOn();
                        });
                        addGlowFilter(subProgenyTextField);
                    }
                }
            }
        }
    }

    protected function addGlowFilter (obj : InteractiveObject) :void
    {
        registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
            obj.filters = [_glowFilter];
        });
        registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
            obj.filters = [];
        })
    }

    protected function computeProgenyLocations (myX :int, myY:int, progenys :int) :Array
    {
        var maxWidth :int = LINEAGE_PANEL_WIDTH - 160;
        var locations :Array = new Array();
        if (progenys == 0) {
            return locations;
        }
        else if (progenys == 1) {
            locations.push(new Vector2(myX ,  myY + yInc));
            return locations;
        }

        var xStart :int = myX - maxWidth / 2;
        var xInc :int = maxWidth / (progenys - 1);
        for(var i :int = 0; i < progenys; i++) {
            locations.push(new Vector2(xStart + i * (maxWidth / (progenys - 1)) ,  myY + 2*yInc));
        }
        return locations;
    }

    protected function drawPlayerWithSireLink (s :Sprite,
                                               playerId :int,
                                               playerX :int,
                                               playerY :int,
                                               sireX :int,
                                               sireY :int,
                                               linkOnly :Boolean,
                                               below :Boolean,
                                               left :Boolean) :void
    {
        if (linkOnly && _lineage.getNumberOfSiresAbove(playerId) > 0) {
            drawLineFrom(s, playerX, playerY, sireX, sireY);
        }
        else {
            drawPlayerNameCenteredOn(s, playerId, playerX, playerY, below, left);
        }
    }

    protected function drawPlayerNameCenteredOn (s :Sprite, playerId :int, centerX :int, centerY :int, below :Boolean, left :Boolean) :void
    {
        var drop :DropSceneObject;

        //Create the scene object if it doesn't exist
        if (!_player2Drop.containsKey(playerId)) {

            var playerName :String = null;
            if (_lineage._playerId2Name.containsKey(playerId)) {
                playerName = _lineage._playerId2Name.get(playerId) as String;
            }

            if (playerName == null || playerName.length == 0) {
                playerName = "Player " + playerId;
            }

            playerName = playerName.substring(0, VConstants.MAX_CHARS_IN_LINEAGE_NAME);

            drop = new DropSceneObject(_dropCreation, playerId, playerName, updateLineage);

            addSimObject(drop);
            drop.alpha = 0;
            _player2Drop.put(playerId, drop);
//            trace("Creating drop for " + playerId);
        }
        drop = _player2Drop.get(playerId) as DropSceneObject;

        //Experiemental, draw a horizontal line if the player has progenys, no matter where they are,
            if (!below && _selectedPlayerIdCenter != playerId && _lineage.getProgenyCount(playerId) > 1) {
                drop.showHBar();
//                s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
//                s.graphics.moveTo(playerX - 20, playerY);
//                s.graphics.lineTo(playerX + 20, playerY);
            }
            else {
                drop.hideHBar();
            }




        //Add to visible players list
        _visiblePlayers.add(playerId);

        if (below) {
            drop.setNameTextBelowDrop();
        }
        else {
            if (left) {
                drop.setNameTextLeftOfDrop();
            }
            else {
                drop.setNameTextRightOfDrop();
            }
        }
        if (drop.alpha == 0) {
            drop.x = centerX;
            drop.y = centerY;
        }
        else {
        }
        drop.removeAllTasks();
        drop.addTask(LocationTask.CreateEaseIn(centerX, centerY, 0.5));
//        drop.disableMouseListeners();
        drop.addTask(AlphaTask.CreateEaseIn(1.0, 0.4));

//            _displaySprite.addChild(drop.displayObject);
//        if (!_lineage.isLeaf(playerId)) {
            var addListenersAfterAPause :SerialTask = new SerialTask();
            addListenersAfterAPause.addTask(new TimedTask(0.6));
            addListenersAfterAPause.addTask(new FunctionTask(function () :void {
    //            trace("enabling listeners for " + playerId);
                drop.enableMouseListeners();
            }));
            drop.addTask(addListenersAfterAPause);
//        }
        if (drop.displayObject.parent != null) {
            drop.displayObject.parent.setChildIndex(drop.displayObject,
                drop.displayObject.parent.numChildren - 1);
        }

    }

    protected static function getTextFieldCenteredOn (text :String, centerX :int, centerY :int, below :Boolean, left :Boolean) :TextField
    {
        var tf :TextField = TextFieldUtil.createField(text);
        tf.selectable = false;
        tf.tabEnabled = false;
        tf.textColor = 0xffffff;
        tf.embedFonts = true;

        tf.setTextFormat(getDefaultFormat());

        tf.antiAliasType = AntiAliasType.ADVANCED;

        tf.width = tf.textWidth + 5;
        tf.height = tf.textHeight  + 5;


        tf.x = centerX - tf.width / 2;
        tf.y = centerY - tf.height / 2;

        if (below) {
            tf.y += 20;
        }
        else {
            tf.x += (left ? -(10 + tf.width/2) : (10 + tf.width/2));
        }

        return tf;
    }

    public static function getDefaultFormat () :TextFormat
    {
        var format :TextFormat = new TextFormat();
        format.font = "JuiceEmbedded";
        format.size = 26;
        format.color = 0xffffff;
        format.align = TextFormatAlign.CENTER;
        format.bold = true;
        return format;
    }

    protected static function drawLineFrom (s :Sprite, x1 :int, y1 :int, x2 :int, y2 :int) :void
    {
//        s.graphics.lineGradientStyle(GradientType.LINEAR, [BLOOD_LINEAGE_LINK_COLOR, BLOOD_LINEAGE_LINK_COLOR],
//            [1, 0], [255, 255]);
        s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
        s.graphics.moveTo(x1, y1);
        s.graphics.lineTo(x2, y2);
    }


    protected function showNextPage (...ignored) :void
    {
        _hierarchyPage++;
        updateLineage(_selectedPlayerIdCenter);
    }

    protected function showPreviousPage (...ignored) :void
    {
        _hierarchyPage--;
        updateLineage(_selectedPlayerIdCenter);
    }

    public function set lineage (lin :Lineage) :void
    {
        _lineage = lin;
        if (_lineage != null && _lineage.isConnectedToLilith
            && !_lineage.isPlayer(VConstants.UBER_VAMP_ID)) {
            _displaySprite.addChild(_lilith);
        }
        else {
            ClientUtil.detach(_lilith);
        }
        centerLinageOnPlayer(_selectedPlayerIdCenter);
    }

    public function get lineage () :Lineage
    {
        return _lineage;
    }

    protected var _lilith :Sprite;

    protected var _hierarchyTree :Sprite;
    protected var _lineage :Lineage;

    protected var _selectedPlayerIdCenter :int;
    protected var _selectedPlayerIdList :Array = new Array();
    protected var _isLayoutMoving :Boolean = false;

    protected var _hierarchyPage :int = 0;//If there are too many progenys, scroll by 'pages'
//    protected var _previousHierarchyPage :int = 0;//For unnecessary updating
    protected var _selfReference :LineageViewBase;

    protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);
    protected var _player2Drop :HashMap = new HashMap();
    protected var _player2Text :HashMap = new HashMap();

    /**
    * Every time the lineage is recentered, these elements are destroyed.
    */
    protected var _volatileUIComponents :Array = new Array();
    protected var _visiblePlayers :HashSet = new HashSet();

    protected var _dropCreation :Function;
    protected var _lineageIconCreation :Function;


    public static const BLOOD_LINEAGE_LINK_COLOR :int = 0xcc0000;
    public static const BLOOD_LINEAGE_LINK_THICKNESS :int = 3;

    protected static const MAX_PROGENY_SHOWN :int = 5;
//    public static const MAX_NAME_CHARS :int = 10;

    protected static const yInc :int = 30;
    protected static const LINEAGE_PANEL_WIDTH :int = 490;
    protected static const LINEAGE_PANEL_HEIGHT :int = 350;

    public static const NAME :String = "LineageSceneObjectBase";
    protected static const log :Log = Log.getLog(LineageViewBase);

}
}

import com.whirled.contrib.simplegame.objects.SceneObject;
import vampire.client.VampireController;
import flash.events.MouseEvent;
import com.threerings.util.Command;
import flash.display.MovieClip;
import flash.text.TextField;
import com.threerings.flash.TextFieldUtil;
import flash.text.AntiAliasType;
import flash.display.DisplayObject;
import flash.display.Sprite;
import vampire.client.LineageViewBase;
import flash.filters.GlowFilter;
import flash.display.InteractiveObject;
import flash.display.Shape;
import vampire.data.Lineage;
import vampire.data.VConstants;

class DropSceneObject extends SceneObject
{
    public function DropSceneObject (dropCreation :Function, playerId :int, playerName :String,
        centerLineage :Function)
    {
        _dropCreation = dropCreation;
        _playerId = playerId;
        _centerLineageFunction = centerLineage;

        playerName = playerName.substring(0, VConstants.MAX_CHARS_IN_LINEAGE_NAME);

        _nameText = getTextFieldCenteredOn(playerName, 0, 0);
        _displaySprite.addChild(_nameText);

        try {
            _drop = dropCreation() as MovieClip;
        }
        catch(e :Error) {
            _drop = new MovieClip();
            _drop.graphics.beginFill(0xff0000);
            _drop.graphics.drawCircle(0, 0, 20);
            _drop.graphics.endFill();
        }
        _displaySprite.addChild(_drop);

        _drop.mouseEnabled = true;

        _hBar = new Shape();
        _hBar.graphics.lineStyle(LineageViewBase.BLOOD_LINEAGE_LINK_THICKNESS, LineageViewBase.BLOOD_LINEAGE_LINK_COLOR);
        _hBar.graphics.moveTo(- 20, 0);
        _hBar.graphics.lineTo(20, 0);


        setNameTextBelowDrop();//Default to below

    }

    public function showHBar () :void
    {
        _displaySprite.addChildAt(_hBar, 0);
    }

    public function hideHBar () :void
    {
        if (_hBar.parent != null) {
            _hBar.parent.removeChild(_hBar);
        }
    }

    protected function centerLineageOnThis (...ignored) :void
    {
        _centerLineageFunction(_playerId);
    }

    protected function addGlowFilter (...ignored) :void
    {
        _displaySprite.filters = [_glowFilter];
    }
    protected function removeGlowFilter (...ignored) :void
    {
        _displaySprite.filters = [];
    }

    public function disableMouseListeners () :void
    {
        unregisterListener(_drop, MouseEvent.ROLL_OVER, centerLineageOnThis);
        unregisterListener(_drop, MouseEvent.MOUSE_MOVE, centerLineageOnThis);
        unregisterListener(_drop, MouseEvent.ROLL_OVER, addGlowFilter);
        unregisterListener(_drop, MouseEvent.ROLL_OUT, removeGlowFilter)
    }
    public function enableMouseListeners () :void
    {
        registerListener(_drop, MouseEvent.ROLL_OVER, centerLineageOnThis);
        registerListener(_drop, MouseEvent.MOUSE_MOVE, centerLineageOnThis);
        registerListener(_drop, MouseEvent.ROLL_OVER, addGlowFilter);
        registerListener(_drop, MouseEvent.ROLL_OUT, removeGlowFilter)
    }

    public static function getTextFieldCenteredOn (text :String, centerX :int, centerY :int) :TextField
    {
        var tf :TextField = TextFieldUtil.createField(text);
        tf.selectable = false;
        tf.mouseEnabled= false;
        tf.tabEnabled = false;
        tf.textColor = 0xffffff;
        tf.embedFonts = true;

        tf.setTextFormat(LineageViewBase.getDefaultFormat());

        tf.antiAliasType = AntiAliasType.ADVANCED;

        tf.width = tf.textWidth + 40;
        tf.height = tf.textHeight + 10;


        tf.x = centerX - tf.width / 2;
        tf.y = centerY - tf.height / 2;
        return tf;
    }

    public function setNameTextBelowDrop () :void
    {
        _drop.scaleX = _drop.scaleY = 2;
        _nameText.x = - _nameText.width / 2;
        _nameText.y = 25 - _nameText.height / 2;
    }
    public function setNameTextLeftOfDrop () :void
    {
        setNameTextRightOfDrop();
    }
    public function setNameTextRightOfDrop () :void
    {
        _drop.scaleX = -2.5;
        _drop.scaleY = 2.5;
        _nameText.x = 5;//(10 + _nameText.width/2);
        _nameText.y = - _nameText.height / 2;
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        _centerLineageFunction = null;
    }



    protected var _playerId :int;
    protected var _drop :MovieClip;
    protected var _hBar :Shape;
    protected var _nameText :TextField;
    protected var _centerLineageFunction :Function;
    protected var _displaySprite :Sprite = new Sprite();
    protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);
    protected var _dropCreation :Function;


}