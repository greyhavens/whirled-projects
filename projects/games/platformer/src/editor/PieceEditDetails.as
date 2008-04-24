//
// $Id$

package editor {

import flash.display.Sprite
import flash.display.Shape;

import flash.system.ApplicationDomain;

import mx.core.FlexSprite;
import mx.controls.Button;
import mx.controls.ComboBox;
import mx.controls.HRule;
import mx.controls.Label;
import mx.controls.TextInput;
import mx.containers.VBox;
import mx.containers.HBox;
import mx.containers.Canvas;

import mx.events.FlexEvent;

import com.threerings.util.HashMap;

import piece.Piece;
import piece.PieceFactory;

import display.Metrics;

public class PieceEditDetails extends Canvas
{
    public function PieceEditDetails (pfac :PieceFactory)
    {
        initDetails();
        _pfac = pfac;
        width = 200;
        height = Metrics.DISPLAY_HEIGHT;
        var vbox :VBox = new VBox();
        var hbox :HBox = new HBox();
        var label :Label = new Label();
        label.text = "Type:";
        hbox.addChild(label);
        _createType = new TextInput();
        _createType.width = 150;
        hbox.addChild(_createType);
        vbox.addChild(hbox);
        hbox = new HBox();
        label = new Label();
        label.text = "Class:";
        hbox.addChild(label);
        _createClass = new ComboBox();
        _createClass.width = 150;
        _createClass.dataProvider = pfac.getPieceClasses();
        hbox.addChild(_createClass);
        vbox.addChild(hbox);
        var button :Button = new Button();
        button.label = "Create";
        button.addEventListener(FlexEvent.BUTTON_DOWN, createPiece);
        vbox.addChild(button);
        vbox.addChild(new HRule());
        vbox.addChild(_detailsBox = new VBox());
        addChild(vbox);
        vbox.x = 0;
        vbox.y = 0;
    }

    public function setPiece (type :String, p :Piece = null) :void
    {
        if (type != null) {
            _createType.text = type;
        }
        _p = p;
        _detailsBox.removeAllChildren();
        if (p != null) {
            _details = new Array();
            var xmlDef :XML = p.xmlDef();
            for each (var attr :XML in xmlDef.attributes()) {
                var dfunc :Function = _detailTypes.get(attr.name().toString());
                var detail :Detail = (dfunc == null ? new TextDetail(attr) : new dfunc(attr));
                _details.push(detail);
                _detailsBox.addChild(detail.createBox());
            }
            for each (var child :XML in xmlDef.children()) {
                dfunc = _detailTypes.get(child.name().toString());
                detail = (dfunc == null ? new TextDetail(child) : new dfunc(child));
                _details.push(detail);
                _detailsBox.addChild(detail.createBox());
            }
            var button :Button = new Button();
            button.label = "Update";
            button.addEventListener(FlexEvent.BUTTON_DOWN, updatePiece);
            _detailsBox.addChild(button);
        }
    }

    protected function createPiece (event :FlexEvent) :void
    {
        if (!ApplicationDomain.currentDomain.hasDefinition(_createClass.selectedLabel)) {
            return;
        }
        var cdef :Class =
                ApplicationDomain.currentDomain.getDefinition(_createClass.selectedLabel) as Class;
        var p :Piece = new cdef() as Piece;
        p.type = _createType.text;
        _pfac.newPiece(p);
    }

    protected function updatePiece (event :FlexEvent) :void
    {
        var defxml :XML = <piecedef/>;
        for each (var detail :Detail in _details) {
            detail.setData(defxml);
        }
        var cname :String = defxml.@cname;
        if (cname == null || !ApplicationDomain.currentDomain.hasDefinition(cname)) {
            return;
        }
        var cdef :Class = ApplicationDomain.currentDomain.getDefinition(cname) as Class;
        var p :Piece = new cdef(defxml) as Piece;
        _pfac.updatePiece(_p, p);
    }

    protected function initDetails () :void
    {
        if (_detailTypes != null) {
            return;
        }
        _detailTypes = new HashMap();
        _detailTypes.put("cname", function (attr :XML) :Detail {
            return new ComboDetail(attr, _pfac.getPieceClasses());
        });
        _detailTypes.put("bounds", function (attr :XML) :Detail {
            return new BoundsDetail(attr);
        });
    }

    protected var _createType :TextInput;
    protected var _createClass :ComboBox;

    protected var _detailsBox :VBox;

    protected var _details :Array;

    protected var _pfac :PieceFactory;

    protected var _p :Piece;

    protected static var _detailTypes :HashMap;
}
}
