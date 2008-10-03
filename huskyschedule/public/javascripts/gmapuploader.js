function GmapUploaderBug(){}

GmapUploaderBug.prototype = new GControl();

GmapUploaderBug.prototype.initialize = function(a) {
	var b = document.createElement("div");
	b.id = 'GmapUploaderBug';
  	b.style.zIndex = 25500;
  	b.innerHTML = '+ <a href="http://gmapuploader.com" style="display: inline; font: 12px arial; text-decoration: none; padding: 4px; border: 1px dotted black; color: black;">GmapUploader</a>';
  	a.getContainer().appendChild(b);
  	var c = 1;
  	var d = document.getElementById(b.id);
  	if(typeof(d.style.filter)=='string') {
		d.style.filter='alpha(opacity:'+c*100+')';
	}
  	if(typeof(d.style.KHTMLOpacity)=='string') {
		d.style.KHTMLOpacity=c;
	}
  	if(typeof(d.style.MozOpacity)=='string') {
		d.style.MozOpacity=c;
	}
  	if(typeof(d.style.opacity)=='string'){
		d.style.opacity=c;
	}
  	a.GmapUploaderBugged=1;
	a.getContainer().appendChild(b);
  	return b;
}

GmapUploaderBug.prototype.getDefaultPosition = function() {
	return new GControlPosition(G_ANCHOR_BOTTOM_LEFT, new GSize(65, 5));
}

GmapUploaderMapType.prototype.addBug=function(a){
	if(!a.GmapUploaderBugged){
    	a.addControl(new GmapUploaderBug());
  	}
}

function GmapUploaderMapType(a, baseUrl, ext, levels){
	this.addBug(a);
	var copyCollection = new GCopyrightCollection('UW Campus');
    var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, "");
    copyCollection.addCopyright(copyright);
    var tilelayers = [new GTileLayer(copyCollection, 0, levels-1)];
    tilelayers[0].getTileUrl = CustomTiles(baseUrl, ext, levels);
   	return new GMapType(tilelayers, new EuclideanProjection(18), "UW", {errorMessage:"No image here, sorry"});
}

GmapUploaderMultiMapType.prototype.addBug=function(a){
  	if(!a.GmapUploaderBugged){
		a.addControl(new GmapUploaderBug());
  	}
}

function GmapUploaderMultiMapType(a, baseUrl, mapIds, ext, tilesPerSide, levels){
	this.addBug(a);
    var copyCollection = new GCopyrightCollection('GmapUploader');
    var copyright = new GCopyright(1, new GLatLngBounds(new GLatLng(-90, -180), new GLatLng(90, 180)), 0, "");
    copyCollection.addCopyright(copyright);
    var tilelayers = [new GTileLayer(copyCollection, 0, levels+2)];
    tilelayers[0].getTileUrl = MultiCustomTiles(baseUrl, mapIds, ext, tilesPerSide, levels);
    return new GMapType(tilelayers, new EuclideanProjection(18), "GmapUploader", {errorMessage:"No image here, sorry"});
}

function CustomTiles(baseUrl, ext, levels){
	function CustomGetTileUrl(tile,zoom) {
		var tilesPerSide = Math.pow(2, zoom);
		if(zoom >= 0 && zoom < levels && tile.x >= 0 && tile.y >= 0 && tile.x < tilesPerSide && tile.y < tilesPerSide){
			var n = tile.y * tilesPerSide + tile.x;
			var newBaseUrl = baseUrl.replace(/http:\/\/mt.gmapuploader.com\//, "http://mt" + n % 3 + ".gmapuploader.com/");
			return newBaseUrl + "/tile-" + zoom + "-" + n + "." + ext;
		}
		else {
			return "http://maps.google.com/mapfiles/transparent.gif";
		}
	};
	return CustomGetTileUrl;
}

function MultiCustomTiles(baseUrl, mapIds, ext, tilesPerSide, levels){
	function MultiCustomGetTileUrl(tile,zoom) {
		var newTilesPerSide = Math.pow(2, zoom-3);
        if(zoom >= 0 && zoom < levels + 3 && tile.x >= 0 && tile.y >= 0 && tile.x < tilesPerSide*newTilesPerSide && tile.y < tilesPerSide*newTilesPerSide){
			zoom -= 3;
           	var n = Math.floor(tile.y/newTilesPerSide) * tilesPerSide + Math.floor(tile.x/newTilesPerSide);
			var mapId = mapIds[n];
			var CustomGetTileUrl = CustomTiles(baseUrl + '/' + mapId, ext, levels);
			tile.x -= newTilesPerSide*Math.floor(tile.x/newTilesPerSide);
			tile.y -= newTilesPerSide*Math.floor(tile.y/newTilesPerSide);
			return CustomGetTileUrl(tile,zoom);
        }
		else {
            return "http://maps.google.com/mapfiles/transparent.gif";
        }
    };
	return MultiCustomGetTileUrl;
}

      // ====== Create the Euclidean Projection for the flat map ======
      // == Constructor ==
      function EuclideanProjection(a){
      		this.pixelsPerLonDegree=[];
          	this.pixelsPerLonRadian=[];
        	this.pixelOrigo=[];
        	this.tileBounds=[];
	        var b=256;
	        var c=1;
	        for(var d=0; d<a; d++) {
	          var e=b/2;
    	      this.pixelsPerLonDegree.push(b/360);
        	  this.pixelsPerLonRadian.push(b/(2*Math.PI));
	          this.pixelOrigo.push(new GPoint(e,e));
	          this.tileBounds.push(c);
    	      b*=2;
        	  c*=2
        	}
      }
 
      // == Attach it to the GProjection() class ==
      EuclideanProjection.prototype=new GProjection();
 
 
      // == A method for converting latitudes and longitudes to pixel coordinates == 
      EuclideanProjection.prototype.fromLatLngToPixel=function(a,b){
        var c=Math.round(this.pixelOrigo[b].x+a.lng()*this.pixelsPerLonDegree[b]);
        var d=Math.round(this.pixelOrigo[b].y+(-2*a.lat())*this.pixelsPerLonDegree[b]);
        return new GPoint(c,d);
      };

      // == a method for converting pixel coordinates to latitudes and longitudes ==
      EuclideanProjection.prototype.fromPixelToLatLng=function(a,b,c){
        var d=(a.x-this.pixelOrigo[b].x)/this.pixelsPerLonDegree[b];
        var e=-0.5*(a.y-this.pixelOrigo[b].y)/this.pixelsPerLonDegree[b];
        return new GLatLng(e,d,c);
      };

      // == a method that checks if the y value is in range, and wraps the x value ==
      EuclideanProjection.prototype.tileCheckRange=function(a,b,c){
        var d=this.tileBounds[b];
        if (a.y<0||a.y>=d) {
          return false;
        }
        
        //wraps image horizontally
        if(this.pan && (a.x<0||a.x>=d)){
          a.x=a.x%d;
          if(a.x<0){
            a.x+=d;
          }
        }
        return true
      }

      
      // == a method that returns the width of the tilespace ==
      EuclideanProjection.prototype.getWrapWidth=function(zoom) {
	  	if(this.pan){
        	return this.tileBounds[zoom]*256;
		}
		else{
        	return this.tileBounds[zoom]*2048;
		}
     }

      EuclideanProjection.prototype.setPanoramic=function(pan){
	this.pan = pan;
      }
