<script>
  import { onMount } from "svelte";
  import Map from "ol/Map";
  import View from "ol/View";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import { fromLonLat } from "ol/proj";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import TileLayer from "ol/layer/Tile";


  var view;
  var center;
  var markerLayer;

  export function init() {
    const parser = new WMTSCapabilities();

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
          layer: "swisstopo_pk",
        });

        let iclayer = new TileLayer({
          opacity: 1,
          source: new WMTS(options),
        });

        const view = new View({
          maxZoom: 16,
          minZoom: 10,
          zoom: 16,
          center: fromLonLat([7.696738,46.025843]),
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [iclayer],
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
          <h6 class="text-white text-xl font-bold">Simple map</h6>
        </div>
      </div>
      <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
        <div class="flex flex-wrap">
          <div class="w-full pt-3">
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              As a simple example, a map of the Swiss Alps is loaded here. The maps are from <a href="swisstopo.ch" target="_blank">swisstopo</a>, the Federal Office of Topography swisstopo. These wonderful maps are available as Opendata.
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
