<script>
  
import { Map, View } from "ol";
import { Tile as TileLayer } from "ol/layer";
import { defaults as defaultControls, ScaleLine } from "ol/control";
import WMTS, {optionsFromCapabilities} from 'ol/source/WMTS';
import WMTSCapabilities from 'ol/format/WMTSCapabilities';




const parser = new WMTSCapabilities();

const view = new View({
  projection: "EPSG:3857",
  center: [832341.40, 5922948.70], //Zimmerwald
  //center: [897528.98, 5857444.40], // Aletschgletscher
  zoom: 15
});



fetch('http://rkp4c-7iaaa-aaaaa-aaaca-cai.localhost:8000/wmts?request=getcapabilities',{mode: 'cors'})
  .then(function (response) {
    return response.text();
  })
  .then(function (text) {
    const result = parser.read(text);
	console.log(result);
    const options = optionsFromCapabilities(result, {
      layer: 'osm',
      matrixSet: '3857_21',
    });

    let icsource = new WMTS(options);
    
    let iclayer = new TileLayer({
            opacity: 1,
            source: icsource
          });
    const map = new Map({
      target: "map",
      controls: defaultControls().extend([
        new ScaleLine({
          units: "metric"
        })
      ]),
      layers: [iclayer],
      view: view
    });
  });



</script>

<div id="map" class="relative w-full rounded h-600-px"></div>