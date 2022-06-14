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
  import { getRenderPixel } from "ol/render";

  var view;
  var center;
  var doPopulate = false;
  var code = "";

  export function init() {
    const parser = new WMTSCapabilities();
    const view = new View({
      center: fromLonLat([8.03504, 46.49981]),
      zoom: 14,
    });
    const olMap = new Map({
      view,
      target: "map",
    });

    const swipe = document.getElementById("swipe");

    fetch(
      "https://vk72n-daaaa-aaaak-aapuq-cai.raw.ic0.app/wmts?request=getcapabilities",
      { mode: "cors" }
    )
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        const result = parser.read(text);
        console.log(result);

        const aletsch16 = optionsFromCapabilities(result, {
          layer: "aletsch2016",
        });

        let aletsch16Layer = new TileLayer({
          opacity: 1,
          source: new WMTS(aletsch16),
        });

        olMap.addLayer(aletsch16Layer);
        fetch(
          "https://oupjj-iiaaa-aaaal-aap5a-cai.raw.ic0.app/wmts?request=getcapabilities",
          { mode: "cors" }
        )
          .then(function (response) {
            return response.text();
          })
          .then(function (text) {
            const result = parser.read(text);
            console.log(result);
            const aletsch21 = optionsFromCapabilities(result, {
              layer: "Aletsch2021",
            });

            let aletsch21Layer = new TileLayer({
              opacity: 1,
              source: new WMTS(aletsch21),
            });

            olMap.addLayer(aletsch21Layer);

            aletsch21Layer.on("prerender", function (event) {
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

            aletsch21Layer.on("postrender", function (event) {
              const ctx = event.context;
              ctx.restore();
            });

            const listener = function () {
              olMap.render();
            };

            swipe.addEventListener("input", listener);
            swipe.addEventListener("change", listener);
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
        class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
      >
        <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
          <div class="text-center flex justify-between">
            <h6 class="text-white text-xl font-bold">
              Make the climate change visible
            </h6>
          </div>
        </div>
        <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
          <div class="flex flex-wrap">
            <div class="w-full pt-3">
              <p class="text-lg font-light leading-relaxed mt-6 mb-4">
                In the Alps, temperatures are rising almost twice as fast as in
                the rest of the Northern Hemisphere. The temperature increase of
                almost 2°C since the late 19th century is already having a
                significant impact on the alpine environment: Decline in
                habitats of native animal and plant species, changes in water
                availability (including snow), stress on forests, increased risk
                and unpredictability of natural hazards - affecting almost all
                human activities. Transport and buildings are among the largest
                greenhouse gas emitters, as they are everywhere in Europe. The
                Alpine Convention treats climate change mitigation and
                adaptation as an integrative cross-cutting issue. There are
                solutions that can contribute to a sustainable future and high
                quality of life in the Alps.
              </p>

              <p class="mt-6">
                <b>ICMaps</b> helps make climate change visible. The two sentinel
                images show the longest glacier in the Alps (Aletsch glacier) at
                the two times October 2016 and October 2021. The different glacier
                extents can be recognized with the slider.
              </p>
            </div>
          </div>
        </div>
      </div>

      <div
        class="flex break-words bg-white shadow-lg rounded mb-6 mx-4"
      >
        <div id="map" class="relative w-full rounded h-600-px" />
        <input id="swipe" type="range" style="width: 100%" />
      </div>
    </div>
  </div>
</div>
