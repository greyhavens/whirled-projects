package org.papervision3d.core.effects.objects
{
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.geom.Pixels;
	import org.papervision3d.core.geom.renderables.Pixel3D;
	import org.papervision3d.core.geom.renderables.Triangle3D;
	import org.papervision3d.core.geom.renderables.Vertex3D;
	import org.papervision3d.core.layers.BitmapEffectLayer;
	import org.papervision3d.core.math.NumberUV;
	
	public class PixelModeler
	{
		
		private var faces:Array;
		private var vertices:Array;
		
		public function PixelModeler()
		{
				
		}
		
		public function createPixelModel(layer:BitmapEffectLayer, faces:Array, subdivisions:Number = 0, quarterFaces:Number = 0, color:uint = 0xFFFF00FF):Pixels{
			
			this.faces = faces;
			this.vertices = new Array();
			
			for each(var tri:Triangle3D in this.faces){
				this.vertices.push(tri.v0);
				this.vertices.push(tri.v1);
				this.vertices.push(tri.v2);
			}
			
			for(var j:Number = 0;j<quarterFaces;j++){
				this.quarterFaces();
			}
			
			for(var i:Number = 0;i<subdivisions;i++){
				subdivide();
			}
			
			
			
			var pixels:Pixels = new Pixels(layer);
			var p:Pixel3D;
			
			for each (var t:Vertex3D in this.vertices){
				p = new Pixel3D(color, t.x, t.y, t.z);
				pixels.addPixel3D(p);
			}
			
			return pixels;
			
		}
		
		public function subdivide():void{
			
			var newverts:Array = new Array();
			var newfaces:Array = new Array();
			var faces:Array = this.faces;
			var face:Triangle3D;
			var i:int = faces.length;
			
			while( face = faces[--i] )
			{
				var v0:Vertex3D = face.v0;
				var v1:Vertex3D = face.v1;
				var v2:Vertex3D = face.v2;
				
				var mid:Vertex3D = new Vertex3D((v0.x+v1.x+v2.x)/3, (v0.y + v1.y+ v2.y)/3, (v0.z+v1.z+v2.z)/3);
				
				this.vertices.push(mid);
				var t0:NumberUV = face.uv[0];
				
				
				var f0:Triangle3D = new Triangle3D(null, [v0, mid, v1], face.material, [t0, t0, t0]);
				var f1:Triangle3D = new Triangle3D(null, [v1, mid, v2], face.material, [t0, t0, t0]);
				var f2:Triangle3D = new Triangle3D(null, [v2, mid, v0], face.material, [t0, t0, t0]);
				
				newfaces.push(f0, f1, f2);
			}
			
			this.faces = newfaces;
			
		}
		
		
		/**
		 * Divides all faces into 4.
		 */
		public function quarterFaces():void
		{
			var newverts:Array = new Array();
			var newfaces:Array = new Array();
			var faces:Array = this.faces;
			var face:Triangle3D;
			var i:int = faces.length;
			
			while( face = faces[--i] )
			{
				var v0:Vertex3D = face.v0;
				var v1:Vertex3D = face.v1;
				var v2:Vertex3D = face.v2;
				
				var v01:Vertex3D = new Vertex3D((v0.x+v1.x)/2, (v0.y+v1.y)/2, (v0.z+v1.z)/2);
				var v12:Vertex3D = new Vertex3D((v1.x+v2.x)/2, (v1.y+v2.y)/2, (v1.z+v2.z)/2);
				var v20:Vertex3D = new Vertex3D((v2.x+v0.x)/2, (v2.y+v0.y)/2, (v2.z+v0.z)/2);
				
				this.vertices.push(v01, v12, v20);
				
				var t0:NumberUV = face.uv[0];
				var t1:NumberUV = face.uv[1];
				var t2:NumberUV = face.uv[2];
				
				var t01:NumberUV = new NumberUV((t0.u+t1.u)/2, (t0.v+t1.v)/2);
				var t12:NumberUV = new NumberUV((t1.u+t2.u)/2, (t1.v+t2.v)/2);
				var t20:NumberUV = new NumberUV((t2.u+t0.u)/2, (t2.v+t0.v)/2);
				
				var f0:Triangle3D = new Triangle3D(null, [v0, v01, v20], face.material, [t0, t01, t20]);
				var f1:Triangle3D = new Triangle3D(null, [v01, v1, v12], face.material, [t01, t1, t12]);
				var f2:Triangle3D = new Triangle3D(null, [v20, v12, v2], face.material, [t20, t12, t2]);
				var f3:Triangle3D = new Triangle3D(null, [v01, v12, v20], face.material, [t01, t12, t20]);
			
				newfaces.push(f0, f1, f2, f3);
			}
			
			this.faces = newfaces;
			this.mergeVertices();

		}
		
		/**
		* Merges duplicated vertices.
		*/
		public function mergeVertices():void
		{
			var uniqueDic  :Dictionary = new Dictionary(),
				uniqueList :Array = new Array();
	
			// Find unique vertices
			for each( var v:Vertex3D in this.vertices )
			{
				for each( var vu:Vertex3D in uniqueDic )
				{
					if( v.x == vu.x && v.y == vu.y && v.z == vu.z )
					{
						uniqueDic[ v ] = vu;
						break;
					}
				}
				
				if( ! uniqueDic[ v ] )
				{
					uniqueDic[ v ] = v;
					uniqueList.push( v );
				}
			}
	
			// Use unique vertices list
			this.vertices = uniqueList;
	
			// Update faces
			for each( var f:Triangle3D in this.faces )
			{
				f.v0 = uniqueDic[ f.v0 ];
				f.v1 = uniqueDic[ f.v1 ];
				f.v2 = uniqueDic[ f.v2 ];
			}
		}

	}
}