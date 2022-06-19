<script>
  import { Map, View } from "ol";
  import { Tile as TileLayer } from "ol/layer";
  import { defaults as defaultControls, ScaleLine } from "ol/control";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import { fromLonLat } from "ol/proj";
  
  import Prism from 'prismjs';

  export let mycanister;
  export let layeridentifier;

  const parser = new WMTSCapabilities();
  var view;
  var center;
  var doPopulate = false;
  var code ="";
  $: {
    if (!doPopulate) {
      if ((mycanister) && (mycanister.layerInfo.length > 0)) {
        const layerInfo = mycanister.layerInfo.find(li => li.identifier == layeridentifier);
        doPopulate = true;

      const upperCorner =
      layerInfo.wGS84BoundingBox.upperCorner.split(" ");
      const lowerCorner =
      layerInfo.wGS84BoundingBox.lowerCorner.split(" ");

      const centerLon =
        parseFloat(upperCorner[0]) +
        (parseFloat(lowerCorner[0]) - parseFloat(upperCorner[0])) / 2;
      const centerLat =
        parseFloat(upperCorner[1]) +
        (parseFloat(lowerCorner[1]) - parseFloat(upperCorner[1])) / 2;

      center = fromLonLat([centerLon, centerLat]);
      
      view = new View({
        projection:layerInfo.tilematrixset.supportedCRS,
        center: center,
        zoom: 15,
      });

    
      const myHost =
        process.env.DFX_NETWORK === "ic" ? `.raw.ic0.app` : ".localhost:8000";
      const myProtocol = 
        process.env.DFX_NETWORK === "ic" ? `https` : "http";
      fetch(
        myProtocol + "://" +
          mycanister.canisterId.toText() +
          myHost +
          "/wmts?request=getcapabilities",
        { mode: "cors" }
      )
        .then(function (response) {
          return response.text();
        })
        .then(function (text) {
          const result = parser.read(text);
          console.log(result);
          const options = optionsFromCapabilities(result, {
            layer: layeridentifier,
          });

          let icsource = new WMTS(options);

          let iclayer = new TileLayer({
            opacity: 1,
            source: icsource,
          });
          const map = new Map({
            target: "map",
            controls: defaultControls().extend([
              new ScaleLine({
                units: "metric",
              }),
            ]),
            layers: [iclayer],
            view: view,
          });
        });



        // code
       code = `
<script>
  import { onMount } from "svelte";
  import Map from "ol/Map";
  import View from "ol/View";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import { fromLonLat } from "ol/proj";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import TileLayer from "ol/layer/Tile";
  import {Attribution, defaults as defaultControls} from 'ol/control';

  var view;
  var center;
  var markerLayer;

  export function init() {
    const parser = new WMTSCapabilities();

    fetch(
      "`+
        myProtocol + `://` +
          mycanister.canisterId.toText() +
          myHost +
          `/wmts?request=getcapabilities",
      { mode: "cors" }
    )
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        const result = parser.read(text);
        const options = optionsFromCapabilities(result, {
          layer: "` + layeridentifier + `",
        });

        const source = new WMTS(options);
        source.setAttributions(['Maps provided by ICMaps']);

        let iclayer = new TileLayer({
          opacity: 1,
          source: source,
        });
        const attribution = new Attribution({
          collapsible: false,
        });
        const view = new View({
          maxZoom: 16,
          minZoom: 10,
          zoom: 16,
          center: [` + center + `],
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [iclayer],
          controls: defaultControls({attribution: false}).extend([attribution])
        });
      });
  }
  onMount(async () => {
    init();
  });
<\/script>

<div id="map" />
`;
      }
    }
  }

  let language = 'javascript';
 
</script>

<svelte:head>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.22.0/themes/prism.min.css" rel="stylesheet" />
</svelte:head>
<div
class="relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded"
>
<div id="map" class="relative w-full rounded h-600-px" />
</div>
<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
    <div class="text-center flex justify-between">
      <h6 class="text-white text-xl font-bold">Code</h6>
    </div>
  </div>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
    <div class="flex flex-wrap">
      <div class="w-full pt-3">

        <div id="code" class="code relative w-full rounded">
          {@html Prism.highlight(code, Prism.languages[language])}
        
        </div>   
        
      </div>
    </div>
  </div>
</div>

<style>
  .code {
    white-space: pre-wrap;
  }
</style>