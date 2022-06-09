<script>
  import Map from "ol/Map";
  import View from "ol/View";
  import TileLayer from "ol/layer/Tile";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import { fromLonLat } from "ol/proj";
  import WebGLPointsLayer from "ol/layer/WebGLPoints";
  import VectorSource from "ol/source/Vector";
  import Point from "ol/geom/Point";
  import Feature from "ol/Feature";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import { onMount } from "svelte";
  import {getRenderPixel} from 'ol/render';

  var view;
  var center;
  var doPopulate = false;
  var code = "";




  export function init() {
    const parser = new WMTSCapabilities();

    fetch(
      "http://geoserver.geobrowser.ch/geoserver/Aletsch/gwc/service/wmts?REQUEST=GetCapabilities",
      { mode: "cors" }
    )
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        
  const swipe = document.getElementById('swipe');
        const result = parser.read(text);
        console.log(result);
        const aletsch21 = optionsFromCapabilities(result, {
          layer: "Aletsch2021",
        });
        
        let aletsch21Layer = new TileLayer({
          opacity: 1,
          source: new WMTS(aletsch21),
        });

        const aletsch16 = optionsFromCapabilities(result, {
          layer: "Aletsch2016",
        });
        
        let aletsch16Layer = new TileLayer({
          opacity: 1,
          source: new WMTS(aletsch16),
        });

        const view = new View({
          center: fromLonLat([8.035040,46.499810]),
          zoom: 14,
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [
            aletsch16Layer, aletsch21Layer
            
          ],
        });

        aletsch21Layer.on('prerender', function (event) {
          const ctx = event.context;
          const mapSize = olMap.getSize();
          const width = mapSize[0] * (swipe.value / 100);
          const tl = getRenderPixel(event, [width, 0]);
          const tr = getRenderPixel(event, [mapSize[0], 0]);
          const bl = getRenderPixel(event, [width, mapSize[1]]);
          const br = getRenderPixel(event, mapSize);

          ctx.save();
          ctx.beginPath();
          ctx.moveTo(tl[0], tl[1]);
          ctx.lineTo(bl[0], bl[1]);
          ctx.lineTo(br[0], br[1]);
          ctx.lineTo(tr[0], tr[1]);
          ctx.closePath();
          ctx.clip();
        });

        aletsch21Layer.on('postrender', function (event) {
          const ctx = event.context;
          ctx.restore();
        });

        const listener = function () {
          olMap.render();
        };

        swipe.addEventListener('input', listener);
        swipe.addEventListener('change', listener);
        
      });
  }
  onMount(async () => {
    init();
  });
</script>

<div>
  <div class="flex flex-wrap">
    <div class="w-full xl:w-12/12 mb-12 xl:mb-0 px-4">
      <div
        class="relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded"
      >
        <div id="map" class="relative w-full rounded h-600-px" />
        <input id="swipe" type="range" style="width: 100%">
      </div>
    </div>
  </div>
</div>
