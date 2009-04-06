package vampire.client
{

import com.threerings.flash.TextFieldUtil;
import com.threerings.flash.Vector2;
import com.threerings.util.Command;
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

import vampire.client.events.LineageUpdatedEvent;
import vampire.data.Lineage;
import vampire.data.VConstants;

public class LineageView extends SceneObjectParent
{

    public function LineageView ()
    {
        _hierarchyTree = new Sprite();

        _displaySprite.addChild(_hierarchyTree);
        _selfReference = this;


        _selectedPlayerIdCenter = ClientContext.ourPlayerId;
        _hierarchy = ClientContext.model.lineage;
        if (_hierarchy != null) {
            updateHierarchy(_selectedPlayerIdCenter);
        }
        else if (false && VConstants.LOCAL_DEBUG_MODE) {
            trace("SHowing test hierarchy");
            _hierarchy = new Lineage();
            _hierarchy.setPlayerSire(1, 2);
            _hierarchy.setPlayerSire(3, 1);
            _hierarchy.setPlayerSire(4, 1);
            _hierarchy.setPlayerSire(5, 1);
            _hierarchy.setPlayerSire(6, 5);
            _hierarchy.setPlayerSire(7, 6);
            _hierarchy.setPlayerSire(8, 6);
            _hierarchy.setPlayerSire(9, 1);
            _hierarchy.setPlayerSire(10, 1);
            _hierarchy.setPlayerSire(11, 1);
            _hierarchy.setPlayerSire(12, 1);
            _hierarchy.setPlayerSire(13, 1);
            _hierarchy.setPlayerSire(14, 1);
            updateHierarchy(3);
        }

        _events.registerListener(ClientContext.model, LineageUpdatedEvent.LINEAGE_UPDATED, updateHierarchyEvent);


    }

    override public function get objectName () :String
    {
        return NAME;
    }

    public function get displaySprite () :Sprite
    {
        return _displaySprite;
    }


    protected function updateHierarchyEvent(e :LineageUpdatedEvent) :void
    {
        log.debug(VConstants.DEBUG_MINION + " updateHierarchyEvent", "e", e);
        _hierarchy = e.lineage;
        if (_hierarchy == null) {
            log.error("updateHierarchyEvent(), but hierarchy is null :-(");
        }
//        if (_hierarchy.isPlayer(_selectedPlayerIdCenter)) {
            updateHierarchy(_selectedPlayerIdCenter);
//        }
    }

    public function updateHierarchy (playerIdToCenter :int) :void
    {
        if (_isLayoutMoving) {
            return;
        }
        else {
            centerLinageOnPlayer(playerIdToCenter);
        }
//        _selectedPlayerIdList.unshift(playerIdToCenter);
    }

    override protected function update (dt:Number) :void
    {
        super.update(dt);

//        while (_selectedPlayerIdList.length > 0) {
//            centerLinageOnPlayer(_selectedPlayerIdList.pop());
//        }
    }
    protected function centerLinageOnPlayer (playerIdToCenter :int) :void
    {
//        trace("centerLinageOnPlayer, centerLinageOnPlayer=" + centerLinageOnPlayer +
//            ", _hierarchy=" + _hierarchy);


        if (_hierarchy == null) {
            _hierarchy = new Lineage();
            _hierarchy.setPlayerSire(playerIdToCenter, 0);
        }



//        if (_selectedPlayerIdCenter == playerIdToCenter
//            && _previousHierarchyPage == _hierarchyPage) {
////            _hierarchy.getMinionCount(playerIdToCenter) <= 5) {
//
//            trace("  doing nothing");
//            return;
//        }


//        _player2Drop.forEach(function (playerId :int, so :DropSceneObject) :void {
//            if (so.isLiveObject) {
//                so.destroySelf();
//            }
//        });
//        _player2Drop.clear();


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

//        while (_hierarchyTree.numChildren > 0) {_hierarchyTree.removeChildAt(0);}




        //Record which player droplets are shown, so we can animate them better.
        _visiblePlayers.clear();
//        _visiblePlayers.add(playerIdToCenter);
//        for each (var minionId :int in _hierarchy.getMinionIds(playerIdToCenter).toArray()) {
//            _visiblePlayers.add(minionId);
//        }
        //Add max two sires up the sire chain.
//        if (_hierarchy.isSireExisting(playerIdToCenter)) {
//            _visiblePlayers.add(_hierarchy.getSireId(playerIdToCenter));
//
//            if (_hierarchy.isSireExisting(_hierarchy.getSireId(playerIdToCenter))) {
//                _visiblePlayers.add(_hierarchy.getSireId(_hierarchy.getSireId(playerIdToCenter)));
//            }
//        }




        //Draw links
        recursivelyDrawSires(_hierarchyTree, playerIdToCenter, playerX, playerY, true, 0);
        drawMinions(_hierarchyTree, playerIdToCenter, playerX, playerY, true, 0);

        //Draw labels
        recursivelyDrawSires(_hierarchyTree, playerIdToCenter, playerX, playerY, false, 0);
        drawMinions(_hierarchyTree, playerIdToCenter, playerX, playerY, false, 0);


//        _visiblePlayers.forEach(function (playerId :int) :void {
//            var so :DropSceneObject = _player2Drop.get(playerId) as DropSceneObject;
//            if (so != null) {
////                so.removeAllTasks();
////                so.enableMouseListeners();
////                so.addTask(AlphaTask.CreateEaseIn(0, 0.3));
//            }
//        });

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

         //Assume all the drops fade out.  This can be changed later
//        _player2Drop.forEach(function (playerId :int, so :DropSceneObject) :void {
//            so.removeAllTasks();
//            so.disableMouseListeners();
//            so.addTask(AlphaTask.CreateEaseIn(0, 0.3));
//        });


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
            var sireId :int = _hierarchy.getSireId(playerId);
            recursivelyDrawSires(s, sireId, startX, startY - yInc, linkOnly, depth, !left);
        }
        else {
            if (linkOnly) {
//                    drawLineFrom(s, startX, startY, startX, startY - yInc);
            }
            else {
                var grandSireCount :int = _hierarchy.getSireProgressionCount(playerId);

                var sireTextSO :SceneObject = new SimpleSceneObject(
                    getTextFieldCenteredOn((1 + grandSireCount) + " Superior GrandSire" +
                    (grandSireCount > 2 ? "s" : ""), startX, startY, false, !left));
                _volatileUIComponents.push(sireTextSO);
                addSceneObject(sireTextSO, s);

//                s.addChild();
            }
        }

    }

    protected function drawMinions (s :Sprite, playerId :int, startX :int, startY :int, linkOnly :Boolean, depth :int, left :Boolean = false) :void
    {
        var i :int;

        if (playerId < 1) {
            return;
        }

        var minionIds :Array = _hierarchy.isHavingMinions(playerId) ? _hierarchy.getMinionIds(playerId).toArray() : [];

        var minionCount :int = minionIds.length;

        var startMinionViewIndex :int = 0;

        if (minionCount > MAX_MINIONS_SHOWN) {
            startMinionViewIndex = _hierarchyPage * MAX_MINIONS_SHOWN;

            //Delete minions after the last entry in the 'page'
            minionIds.splice(startMinionViewIndex + MAX_MINIONS_SHOWN);


            //Delete minions before the first entry in the 'page'
            minionIds = minionIds.slice(startMinionViewIndex);

        }
        var locations :Array = computeMinionLocations(startX, startY, minionIds.length);

        //Draw the page left/right buttons.
        if (startMinionViewIndex > 0) {
            //The button
            var button_page_left :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
            var buttonLeftSO :SceneObject = new SimpleSceneObject(button_page_left);
            addSceneObject(buttonLeftSO, s);
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
            addSceneObject(textLeftSO, s);
//            s.addChild(textPageLeft);
            registerListener(textPageLeft, MouseEvent.CLICK, showPreviousPage);
//            Command.bind(textPageLeft, MouseEvent.CLICK, showPreviousPage);
            addGlowFilter(textPageLeft);
        }
        //Show the more sub minions button
        if (startMinionViewIndex + MAX_MINIONS_SHOWN < minionCount) {
            var button_page_right :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
            var buttonRightSO :SceneObject = new SimpleSceneObject(button_page_right);
            buttonRightSO.x = locations[locations.length - 1].x + 25;
            buttonRightSO.y = startY + yInc;
            addSceneObject(buttonRightSO, s);
            _volatileUIComponents.push(buttonRightSO);
//            s.addChild(button_page_right);
            registerListener(button_page_right, MouseEvent.CLICK, showNextPage);
//            Command.bind(button_page_right, MouseEvent.CLICK, showNextPage);
            addGlowFilter(button_page_right);
            //The text
            var textPageRight :TextField = getTextFieldCenteredOn("More", locations[locations.length - 1].x + 25, startY + yInc - 40, true, left);
            var textRightSO :SceneObject = new SimpleSceneObject(textPageRight);
            _volatileUIComponents.push(textRightSO);
            addSceneObject(textRightSO, s);
            textPageRight.mouseEnabled = true;
//            s.addChild(textPageRight);
            registerListener(textPageRight, MouseEvent.CLICK, showNextPage);
//            Command.bind(textPageRight, MouseEvent.CLICK, showNextPage);
            addGlowFilter(textPageRight);
        }



            var horizontalBarY :int = startY + yInc;

            if (minionIds.length > 1) {

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

            if (minionIds.length >= 1) {
                s.graphics.moveTo(startX, startY);
                s.graphics.lineTo(startX, horizontalBarY);
            }


            for(i = 0; i < locations.length; i++) {

                drawPlayerWithSireLink(s, minionIds[i], locations[i].x, locations[i].y, locations[i].x, horizontalBarY, linkOnly, true, left);

                var subminionCount :int = _hierarchy.getAllMinionsAndSubminions(minionIds[i]).size();
                if (subminionCount) {
                    if (linkOnly) {
                        drawLineFrom(s, locations[i].x, locations[i].y, locations[i].x, locations[i].y - yInc);
                    }
                    else {
                        var button_hiararchy :SimpleButton = ClientContext.instantiateButton("HUD", "button_hierarchy_no_mouse");
                        var buttonDownSO :SceneObject = new SimpleSceneObject(button_hiararchy);

                        buttonDownSO.x = locations[i].x - button_hiararchy.width;
                        buttonDownSO.y = locations[i].y + yInc + buttonDownSO.width / 2 + 12;
                        addSceneObject(buttonDownSO, s);
                        _volatileUIComponents.push(buttonDownSO);
//                        s.addChild(button_hiararchy);
                        Command.bind(button_hiararchy, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
//                        registerListener(button_hiararchy, MouseEvent.CLICK, function () :void {
//                            ClientContext.controller.handleHierarchyCenterSelected(minionIds[i], _selfReference);
//                        });

//                        VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
                        addGlowFilter(button_hiararchy);

                        var subminionTextField :TextField = getTextFieldCenteredOn(subminionCount + "", locations[i].x + 4, locations[i].y +1*yInc, true, left);
                        var subminionTextSO :SceneObject = new SimpleSceneObject(subminionTextField);
                        subminionTextField.mouseEnabled = true;
                        addSceneObject(subminionTextSO, s);
//                        s.addChild(subminionTextField);
                        _volatileUIComponents.push(subminionTextSO);
//                        registerListener(subminionTextField, MouseEvent.CLICK, function () :void {
//                            ClientContext.controller.handleHierarchyCenterSelected(minionIds[i], _selfReference);
//                        });
                        Command.bind(subminionTextField, MouseEvent.CLICK, VampireController.HIERARCHY_CENTER_SELECTED, [minionIds[i], this]);
                        addGlowFilter(subminionTextField);
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

    protected function computeMinionLocations (myX :int, myY:int, minions :int) :Array
    {
        var maxWidth :int = LINEAGE_PANEL_WIDTH - 160;
        var locations :Array = new Array();
        if (minions == 0) {
            return locations;
        }
        else if (minions == 1) {
            locations.push(new Vector2(myX ,  myY + yInc));
            return locations;
        }

        var xStart :int = myX - maxWidth / 2;
        var xInc :int = maxWidth / (minions - 1);
        for(var i :int = 0; i < minions; i++) {
            locations.push(new Vector2(xStart + i * (maxWidth / (minions - 1)) ,  myY + 2*yInc));
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
        if (linkOnly && _hierarchy.getSireProgressionCount(playerId) > 0) {
            drawLineFrom(s, playerX, playerY, sireX, sireY);

//            //Experiemental, draw a horizontal line if the player has minions, no matter where they are,
//            if (!below && _selectedPlayerIdCenter != playerId && _hierarchy.getMinionCount(playerId) > 1) {
//
//
//
//
//                s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
//                s.graphics.moveTo(playerX - 20, playerY);
//                s.graphics.lineTo(playerX + 20, playerY);
//            }
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
            if (_hierarchy._playerId2Name.containsKey(playerId)) {
                playerName = _hierarchy._playerId2Name.get(playerId) as String;
            }
            if (playerName == null || playerName.length == 0) {
                playerName = ClientContext.getPlayerName(playerId);
            }

            playerName = playerName.substring(0, MAX_NAME_CHARS);

            drop = new DropSceneObject(playerId, playerName, updateHierarchy);

            addSceneObject(drop);
            drop.alpha = 0;
            _player2Drop.put(playerId, drop);
//            trace("Creating drop for " + playerId);
        }
        drop = _player2Drop.get(playerId) as DropSceneObject;

        //Experiemental, draw a horizontal line if the player has minions, no matter where they are,
            if (!below && _selectedPlayerIdCenter != playerId && _hierarchy.getMinionCount(playerId) > 1) {
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
        var addListenersAfterAPause :SerialTask = new SerialTask();
        addListenersAfterAPause.addTask(new TimedTask(0.6));
        addListenersAfterAPause.addTask(new FunctionTask(function () :void {
//            trace("enabling listeners for " + playerId);
            drop.enableMouseListeners();
        }));
        drop.addTask(addListenersAfterAPause);
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
        s.graphics.lineStyle(BLOOD_LINEAGE_LINK_THICKNESS, BLOOD_LINEAGE_LINK_COLOR);
        s.graphics.moveTo(x1, y1);
        s.graphics.lineTo(x2, y2);
    }


    protected function showNextPage (...ignored) :void
    {
        _hierarchyPage++;
        updateHierarchy(_selectedPlayerIdCenter);
    }

    protected function showPreviousPage (...ignored) :void
    {
        _hierarchyPage--;
        updateHierarchy(_selectedPlayerIdCenter);
    }


    protected var _hierarchyTree :Sprite;
    protected var _hierarchy :Lineage;

    protected var _selectedPlayerIdCenter :int;
    protected var _selectedPlayerIdList :Array = new Array();
    protected var _isLayoutMoving :Boolean = false;

    protected var _hierarchyPage :int = 0;//If there are too many minions, scroll by 'pages'
//    protected var _previousHierarchyPage :int = 0;//For unnecessary updating
    protected var _selfReference :LineageView;

    protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);
    protected var _player2Drop :HashMap = new HashMap();
    protected var _player2Text :HashMap = new HashMap();

    /**
    * Every time the lineage is recentered, these elements are destroyed.
    */
    protected var _volatileUIComponents :Array = new Array();
    protected var _visiblePlayers :HashSet = new HashSet();


    public static const BLOOD_LINEAGE_LINK_COLOR :int = 0xcc0000;
    public static const BLOOD_LINEAGE_LINK_THICKNESS :int = 3;

    protected static const MAX_MINIONS_SHOWN :int = 5;
    public static const MAX_NAME_CHARS :int = 10;

    protected static const yInc :int = 30;
    protected static const LINEAGE_PANEL_WIDTH :int = 490;
    protected static const LINEAGE_PANEL_HEIGHT :int = 350;

    public static const NAME :String = "HierarchySceneObject";
    protected static const log :Log = Log.getLog(LineageView);

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
import vampire.client.LineageView;
import flash.filters.GlowFilter;
import flash.display.InteractiveObject;
import vampire.client.ClientContext;
import flash.display.Shape;

class DropSceneObject extends SceneObject
{
    public function DropSceneObject (playerId :int, playerName :String,
        centerLineage :Function)
    {
        _playerId = playerId;
        _centerLineageFunction = centerLineage;

        playerName = playerName.substring(0, LineageView.MAX_NAME_CHARS);

        _nameText = getTextFieldCenteredOn(playerName, 0, 0);
        _displaySprite.addChild(_nameText);

//        addGlowFilter(_nameText);

        _drop = ClientContext.instantiateMovieClip("HUD", "droplet", true);
        _displaySprite.addChild(_drop);

//        registerListener(_drop, MouseEvent.MOUSE_MOVE, function (...ignored) :void {
////            trace("moveed over drop " + _playerId);
//        });

//        addGlowFilter(_drop);
        _drop.mouseEnabled = true;

        _hBar = new Shape();
        _hBar.graphics.lineStyle(LineageView.BLOOD_LINEAGE_LINK_THICKNESS, LineageView.BLOOD_LINEAGE_LINK_COLOR);
        _hBar.graphics.moveTo(- 20, 0);
        _hBar.graphics.lineTo(20, 0);


        setNameTextBelowDrop();//Default to below

//        enableMouseListeners();
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
//        trace("disabling listeners for " + _playerId);
//        _events.freeAllHandlers();
        unregisterListener(_drop, MouseEvent.ROLL_OVER, centerLineageOnThis);
        unregisterListener(_drop, MouseEvent.MOUSE_MOVE, centerLineageOnThis);
        unregisterListener(_drop, MouseEvent.ROLL_OVER, addGlowFilter);
        unregisterListener(_drop, MouseEvent.ROLL_OUT, removeGlowFilter)
//        unregisterListener(_nameText, MouseEvent.ROLL_OVER, centerLineageOnThis);
    }
    public function enableMouseListeners () :void
    {
        registerListener(_drop, MouseEvent.ROLL_OVER, centerLineageOnThis);
        registerListener(_drop, MouseEvent.MOUSE_MOVE, centerLineageOnThis);
        registerListener(_drop, MouseEvent.ROLL_OVER, addGlowFilter);
        registerListener(_drop, MouseEvent.ROLL_OUT, removeGlowFilter)

//        addGlowFilter(_drop);
//        registerListener(_nameText, MouseEvent.ROLL_OVER, centerLineageOnThis);
    }

    protected static function getTextFieldCenteredOn (text :String, centerX :int, centerY :int) :TextField
    {
        var tf :TextField = TextFieldUtil.createField(text);
        tf.selectable = false;
        tf.mouseEnabled= false;
        tf.tabEnabled = false;
        tf.textColor = 0xffffff;
        tf.embedFonts = true;

        tf.setTextFormat(LineageView.getDefaultFormat());

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
//        _drop.scaleX = 2.5;
//        _drop.scaleY = 2.5;
//        _nameText.x = -(10 + _nameText.width);
//        _nameText.y = - _nameText.height / 2;
    }
    public function setNameTextRightOfDrop () :void
    {
        _drop.scaleX = -2.5;
        _drop.scaleY = 2.5;
        _nameText.x = 5;//(10 + _nameText.width/2);
        _nameText.y = - _nameText.height / 2;
    }

//    protected function addGlowFilter (obj : InteractiveObject) :void
//    {
//        registerListener(obj, MouseEvent.ROLL_OVER, function(...ignored) :void {
//            obj.filters = [_glowFilter];
//        });
//        registerListener(obj, MouseEvent.ROLL_OUT, function(...ignored) :void {
//            obj.filters = [];
//        })
//    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected var _playerId :int;
    protected var _drop :MovieClip;
    protected var _hBar :Shape;
    protected var _nameText :TextField;
    protected var _centerLineageFunction :Function;
    protected var _displaySprite :Sprite = new Sprite();
    protected var _glowFilter :GlowFilter = new GlowFilter(0xffffff);
}
