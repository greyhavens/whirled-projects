//
// $Id$

package editor {

import flash.events.Event;
import flash.events.MouseEvent;

import mx.containers.Canvas;
import mx.controls.Tree;
import mx.controls.AdvancedDataGrid;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

import mx.collections.Sort;
import mx.collections.SortField;
import mx.collections.XMLListCollection;
import mx.collections.HierarchicalData;
import mx.collections.IHierarchicalData;

import mx.events.ListEvent;

import com.threerings.util.ClassUtil;

import piece.PieceFactory;

public class PieceSelector extends Canvas
{
    public function PieceSelector (pfac :PieceFactory)
    {
        _pfac = pfac;
        _adg = new AdvancedDataGrid();
        _adg.width = 400;
        _adg.height = 200;
        _adg.showHeaders = false;
        var columns :Array = new Array();
        var column :AdvancedDataGridColumn = new AdvancedDataGridColumn("Piece");
        column.dataField = "@label";
        columns.push(column);
        column = new AdvancedDataGridColumn("Sprite");
        column.dataField = "@sprite";
        columns.push(column);
        _adg.columns = columns;
        _data = createHD();
        _adg.dataProvider = _data;
        _adg.doubleClickEnabled = true;
        callLater(sort);
        addChild(_adg);
        _adg.addEventListener(ListEvent.CHANGE, handleChange);
        /*
        _adg.addEventListener(MouseEvent.DOUBLE_CLICK, function (event :MouseEvent) :void {
            trace("selector doubleclick");
            dispatchEvent(new MouseEvent(MouseEvent.DOUBLE_CLICK));
        });
        */
        _pfac.addEventListener(PieceFactory.PIECE_ADDED, handlePieceAdded);
        _pfac.addEventListener(PieceFactory.PIECE_REMOVED, handlePieceRemoved);
        _pfac.addEventListener(PieceFactory.PIECE_UPDATED, handlePieceUpdated);
    }

    public function sort () :void
    {
        var field:SortField = new SortField("@label");
        _adg.hierarchicalCollectionView.sort = new Sort();
        _adg.hierarchicalCollectionView.sort.compareFunction = compareNodes;
        _adg.hierarchicalCollectionView.sort.fields = [ field ];
        _adg.hierarchicalCollectionView.refresh();
    }

    protected function compareNodes (data1 :Object, data2 :Object, fields :Array = null) :int
    {
        var parent1 :Boolean = data1.children().length() > 0;
        var parent2 :Boolean = data2.children().length() > 0;

        if (parent1 && !parent2) {
            return -1;
        } else if (parent2 && !parent1) {
            return 1;
        }

        var ret :int = data1.@label.toString().localeCompare(data2.@label.toString());
        if (ret > 0) {
            return 1;
        } else if (ret < 0) {
            return -1;
        }
        return 0;
    }

    public function getSelectedPiece () :String
    {
        return _selected;
    }

    protected function addPiece (pdef :XML, root :XML) :void
    {
        var curNode :XML = root;
        for each (var name :String in pdef.@type.toString().split(".")) {
            var node :XML = <node/>;
            node.@label = name;
            if (curNode.children().length() == 0 ||
                    curNode.node.(@label == name).length() == 0) {
                curNode.appendChild(node);
                curNode = node;
            } else {
                curNode = curNode.node.(@label == name)[0];
            }
        }
        curNode.@sprite = pdef.@sprite;
    }

    protected function createHD () :HierarchicalData
    {
        var root :XML = <node label="pieces"/>;
        for each (var pdef :XML in _pfac.getPieceDefs()) {
            addPiece(pdef, root);
        }
        return new HierarchicalData(root);
    }

    protected function handleChange (event :ListEvent) :void
    {
        var item :XML = _adg.selectedItem as XML;
        if (item != null && item.parent() != null) {
            var type :String = item.@label;
            while (item.parent().parent() != null) {
                item = item.parent();
                type = item.@label + "." + type;
            }
            _selected = type;
        } else {
            _selected = null;
        }
        dispatchEvent(new Event(Event.CHANGE));
    }

    protected function handlePieceAdded (type :String, xmlDef :XML) :void
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :XML = _adg.hierarchicalCollectionView.source.getRoot() as XML;
        var newXML :XML;
        var curXML :XML;
        for each (var name :String in type.split(".")) {
            var nodexml :XML = <node/>;
            nodexml.@label = name;
            if (curXML == null) {
                newXML = nodexml;
            } else {
                curXML.appendChild(nodexml);
            }
            curXML = nodexml;
        }
        curXML.@sprite = xmlDef.@sprite;

        _adg.hierarchicalCollectionView.openNode(root);
        while (newXML != null) {
            name = newXML.@label.toString();
            var node :XML = null;
            for each (node in data.getChildren(root)) {
                if (node.@label.toString() == name) {
                    root = node;
                    break;
                }
            }
            if (root != node) {
                while (root != null && !data.canHaveChildren(root)) {
                    var parent :XML = _adg.hierarchicalCollectionView.getParentItem(root);
                    _adg.hierarchicalCollectionView.removeChild(parent, root);
                    root.appendChild(newXML);
                    newXML = root;
                    root = parent;
                }
                _adg.hierarchicalCollectionView.addChild(root, newXML);
                break;
            }
            newXML = newXML.node[0];
            _adg.hierarchicalCollectionView.openNode(root);
        }
        while (newXML != null) {
            _adg.hierarchicalCollectionView.openNode(newXML);
            newXML = newXML.node[0];
        }
        _adg.selectedItem = curXML;
        handleChange(new ListEvent(Event.CHANGE));
    }

    protected function handlePieceRemoved (type :String, xmlDef :XML) :void
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :Object = _adg.hierarchicalCollectionView.source.getRoot();
        _adg.hierarchicalCollectionView.openNode(root);
        var parents :Array = new Array();
        for each (var name :String in type.split(".")) {
            for each (var node :Object in data.getChildren(root)) {
                if (node.@label.toString() == name) {
                    parents.push(root);
                    root = node;
                    break;
                }
            }
        }
        var parent :Object = root;
        while (parents.length > 0) {
            node = parent;
            parent = parents.pop();
            if (!data.hasChildren(node)) {
                _adg.hierarchicalCollectionView.removeChild(parent, node);
            } else {
                break;
            }
        }
    }

    protected function handlePieceUpdated (type :String, xmlDef :XML) :void
    {
        var data :IHierarchicalData = _adg.hierarchicalCollectionView.source;
        var root :Object = _adg.hierarchicalCollectionView.source.getRoot();
        _adg.hierarchicalCollectionView.openNode(root);
        for each (var name :String in type.split(".")) {
            for each (var node :Object in data.getChildren(root)) {
                if (node.@label.toString() == name) {
                    root = node;
                    break;
                }
            }
        }
        root.@sprite = xmlDef.@sprite;
    }

    protected var _xmlTree :XML = <node label="root"/>;
    protected var _tree :Tree;
    protected var _selected :String;
    protected var _pfac :PieceFactory;
    protected var _adg :AdvancedDataGrid;
    protected var _data :HierarchicalData;
}
}
