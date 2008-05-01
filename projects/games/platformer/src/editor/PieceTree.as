//
// $Id$

package editor {

import flash.events.Event;
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Tree;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;
import mx.controls.TextInput;
import mx.controls.Button;

import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.collections.HierarchicalData;
import mx.collections.IHierarchicalData;

import mx.events.FlexEvent;
import mx.events.ListEvent;

import com.threerings.util.ClassUtil;

import board.Board;

import piece.Piece;

public class PieceTree extends Canvas
{
    public function PieceTree (b :Board)
    {
        _board = b;
        _adg = new AdvancedDataGrid();
        _adg.width = 240;
        _adg.height = 400;
        _adg.showHeaders = false;
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Piece");
        column.dataField = "@label";
        _adg.columns = [ column ];
        _adg.dataProvider = createHD();
        _adg.addEventListener(ListEvent.CHANGE, handleChange);
        addChild(_adg);
        callLater(postinit);
        _box = new VBox();
        _box.y = 400;
        var hbox :HBox = new HBox();
        hbox.addChild(EditView.makeButton("Delete", function () :void {
            deleteSelected();
        }));
        hbox.addChild(EditView.makeButton("-", function () :void {
            moveSelectedBack();
        }));
        hbox.addChild(EditView.makeButton("+", function () :void {
            moveSelectedForward();
        }));
        hbox.addChild(EditView.makeButton("flip", function () :void {
            flipSelected();
        }));
        _box.addChild(hbox);
        hbox = new HBox();
        var input :TextInput = new TextInput();
        input.width = 100;
        hbox.addChild(input);
        hbox.addChild(EditView.makeButton("AddGroup", function () :void {
            if (input.text != "") {
                addGroup(input.text);
            }
        }));
        _box.addChild(hbox);
        addChild(_box);
    }

    protected function postinit () :void
    {
        _adg.hierarchicalCollectionView.filterFunction = function (item :Object) :Boolean {
            return item.nodeKind() != "text";
        };
        handleChange(new ListEvent(Event.CHANGE))
    }

    protected function createHD () :HierarchicalData
    {
        return new HierarchicalData(convertPiecenode(_board.getPieceTreeXML()));
    }

    protected function convertPiecenode (piecenode :XML) :XML
    {
        var group :XML = <node>group</node>;
        group.@label = piecenode.@name;
        group.@name = piecenode.@name;
        for each (var node :XML in piecenode.children()) {
            if (node.localName() == "piece") {
                var xml :XML = <piece/>;
                xml.@label = node.@type.substr(node.@type.lastIndexOf(".") + 1);
                xml.@name = node.@id;
                group.appendChild(xml);
            } else {
                group.appendChild(convertPiecenode(node));
            }
        }
        return group;
    }

    public function getTree () :String
    {
        return _tree;
    }

    public function getSelected () :String
    {
        return (_adg.selectedItem == null ? null : _adg.selectedItem.@name);
    }

    public function selectPiece (tree :String, name :String) :void
    {
        var root :XML = _adg.hierarchicalCollectionView.source.getRoot() as XML;
        tree = tree.replace(/root(\.)*/, "");
        if (tree != "") {
            for each (var node :String in tree.split(".")) {
                _adg.hierarchicalCollectionView.openNode(root);
                root = root.node.(@name == node)[0];
            }
        }
        _adg.hierarchicalCollectionView.openNode(root);
        _adg.selectedItem = root.piece.(@name == name)[0];
        handleChange(null);
    }

    public function addPiece (p :Piece) :void
    {
        var xml :XML = <piece/>;
        xml.@label = p.type.substr(p.type.lastIndexOf(".") + 1);
        xml.@name = p.id;
        if (addXML(xml) != null) {
            _board.addPiece(p, _tree);
            _adg.selectedItem = xml;
            handleChange(null);
        }
    }

    public function addGroup (name :String) :void
    {
        var xml :XML = <node>group</node>;
        xml.@label = name;
        xml.@name = name;
        var oldTree :String = _tree;
        if (addXML(xml) != null) {
            _board.addPieceGroup(oldTree, name);
        }
    }

    protected function deleteSelected () :void
    {
        if (_adg.selectedItem == null || _adg.selectedItem.parent() == null) {
            return;
        }
        var selected :XML = _adg.selectedItem as XML;
        var name :String = selected.@name.toString();
        _adg.selectedItem = selected.parent();
        handleChange(null);
        _adg.hierarchicalCollectionView.removeChild(_group, selected);
        _board.removeItem(name, _tree);
    }

    protected function moveSelectedForward () :void
    {
        if (_adg.selectedItem == null || _adg.selectedItem.parent() == null) {
            return;
        }
        var selected :XML = _adg.selectedItem as XML;
        var group :XML = _group;
        if (group == selected) {
            group = group.parent();
        }
        var index :int = selected.childIndex();
        if (index >= group.children().length() - 1) {
            return;
        }

        _adg.hierarchicalCollectionView.removeChild(group, selected);
        _adg.hierarchicalCollectionView.addChildAt(group, selected, index);
        _adg.selectedItem = selected;
        handleChange(null);
        _board.moveItemForward(selected.@name, findTree(group));
    }

    protected function moveSelectedBack () :void
    {
        if (_adg.selectedItem == null || _adg.selectedItem.parent() == null) {
            return;
        }
        var selected :XML = _adg.selectedItem as XML;
        var group :XML = _group;
        if (group == selected) {
            group = group.parent();
        }
        var index :int = selected.childIndex();
        if (index <= 1) {
            return;
        }
        _adg.hierarchicalCollectionView.removeChild(group, selected);
        _adg.hierarchicalCollectionView.addChildAt(group, selected, index - 2);
        _adg.selectedItem = selected;
        handleChange(null);
        _board.moveItemBack(selected.@name, findTree(group));
    }

    protected function flipSelected () :void
    {
        if (_adg.selectedItem == null || _adg.selectedItem == _group) {
            return;
        }
        _board.flipPiece(_adg.selectedItem.@name, _tree);
    }

    public function addXML (xml :XML) :String
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :XML = _group;
        if (!data.canHaveChildren(_group) || _group.node.(@name == xml.@name).length() > 0) {
            return null;
        }
        _adg.hierarchicalCollectionView.addChild(root, xml);
        _adg.hierarchicalCollectionView.openNode(_group);
        _adg.selectedItem = _group;
        handleChange(null);
        return _tree;
    }

    protected function handleChange (event :ListEvent) :void
    {
        var item :XML = _adg.selectedItem as XML;
        if (item == null) {
            _group = _adg.hierarchicalCollectionView.source.getRoot() as XML;
            _tree = "root";
            return;
        }
        if (item.children().length() == 0) {
            _group = item = item.parent();
        } else {
            _group = item;
        }
        _tree = findTree(item);
        dispatchEvent(new ListEvent(ListEvent.CHANGE));
    }

    protected function findTree (item :XML) :String
    {
        var tree :String = item.@name;
        while (item.parent() != null) {
            item = item.parent();
            tree = item.@name + "." + tree;
        }
        return tree;
    }

    protected var _adg :AdvancedDataGrid;
    protected var _board :Board;
    protected var _tree :String;
    protected var _group :XML;
    protected var _box :VBox;
}
}
