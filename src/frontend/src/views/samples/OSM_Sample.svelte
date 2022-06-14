<script>
  import Map from "ol/Map";
  import View from "ol/View";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import { fromLonLat } from "ol/proj";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import { onMount } from "svelte";
  import VectorSource from "ol/source/Vector";
  import { Vector as VectorLayer } from "ol/layer";
  import TileLayer from "ol/layer/Tile";
  import KML from "ol/format/KML";
  import Style from "ol/style/Style";
  import Icon from "ol/style/Icon";

  var view;
  var center;
  var markerLayer;

  export function init() {
    const parser = new WMTSCapabilities();

    // KML with the position of the dfinity foundation
    var markerLayer = new VectorLayer({
      source: new VectorSource({
        url: "/assets/samples/dfinity_foundation.kml",
        format: new KML(),
      }),
    });

    // Style for the big dfinity marker
    const iconStyle = new Style({
      image: new Icon({
        anchorOrigin: "bottom-left",
        anchor: [0.5, -5],
        anchorXUnits: "fraction",
        anchorYUnits: "pixels",
        src: "https://5yimg-viaaa-aaaak-aareq-cai.raw.ic0.app/assets/samples/dfinity_marker_small.png",
      }),
    });

    markerLayer.getSource().on("addfeature", function (evt) {
      var feature = evt.feature;
      feature.setStyle(iconStyle);
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
          center: fromLonLat([8.534145,47.368286]),
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [iclayer, markerLayer],
        });
      });
  }
  onMount(async () => {
    init();
  });
</script>

<div class="flex flex-wrap">
  <div class="w-full xl:w-12/12 mb-12 xl:mb-0 px-4">
    <div
      class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
    >
      <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
        <div class="text-center flex justify-between">
          <h6 class="text-white text-xl font-bold">Show your location</h6>
        </div>
      </div>
      <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
        <div class="flex flex-wrap">
          <div class="w-full pt-3">
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              KML files can be loaded directly using OpenLayers and displayed on
              ICMaps maps. The example shows the location of the DFINITY
              Foundation. The KML is offered as an asset in the frontend.
            </p>
          </div>
        </div>
      </div>

      <div
        class="flex break-words bg-white shadow-lg rounded mb-6 mx-4"
      >
        <div id="map" class="relative w-full rounded h-600-px" />
      </div>
    </div>
  </div>
</div>
