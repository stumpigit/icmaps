<script>
  import Map from "ol/Map";
  import View from "ol/View";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import { fromLonLat } from "ol/proj";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import { onMount } from "svelte";
  import VectorSource from "ol/source/Vector";
  import {Vector as VectorLayer} from 'ol/layer';
  import TileLayer from "ol/layer/Tile";
  import KML from 'ol/format/KML';

  var view;
  var center;
  var markerLayer;

  export function init() {
    const parser = new WMTSCapabilities();

    const markerLayer = new VectorLayer({
      source: new VectorSource({
        url: '/assets/samples/dfinity_foundation.kml',
        format: new KML(),
      }),
    });

    fetch(
      "https://vk72n-daaaa-aaaak-aapuq-cai.raw.ic0.app/wmts?request=getcapabilitiess",
      { mode: "cors" }
    )
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        const result = parser.read(text);
        console.log(result);
        const options = optionsFromCapabilities(result, {
          layer: "osm_dfinity",
        });
        
        let iclayer = new TileLayer({
          opacity: 1,
          source: new WMTS(options),
        });

        const view = new View({
          maxZoom: 18,
          minZoom: 15,
          zoom: 17,
          center: fromLonLat([8.535776,47.367423])
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [
            iclayer, markerLayer
          ],
        });
        
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
      </div>
    </div>
  </div>
</div>
