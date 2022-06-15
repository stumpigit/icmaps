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
  import {ATTRIBUTION as osmAttribution} from 'ol/source/OSM';
  import {Attribution, defaults as defaultControls} from 'ol/control';

  var view;
  var center;
  var doPopulate = false;
  var code = "";

  export function init() {
    const parser = new WMTSCapabilities();

    fetch(
      "https://oupjj-iiaaa-aaaal-aap5a-cai.raw.ic0.app/wmts?request=getcapabilitiess",
      { mode: "cors" }
    )
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        const result = parser.read(text);
        console.log(result);
        const options = optionsFromCapabilities(result, {
          layer: "earthquake",
        });
        const osm_source = new WMTS(options);
        osm_source.setAttributions([osmAttribution]);
        let iclayer = new TileLayer({
          opacity: 1,
          source: osm_source,
        });

        const layerStyle = {
          variables: {
            min: -Infinity,
            max: Infinity,
          },
          filter: ["between", ["get", "date"], ["var", "min"], ["var", "max"]],
          symbol: {
            symbolType: "circle",
            size: [
              "interpolate",
              ["linear"],
              ["get", "magnitude"],
              2.5,
              4,
              5,
              20,
            ],
            color: [
              "case",
              ["<", ["get", "depth"], 0],
              "rgb(223,22,172)",
              "rgb(223,113,7)",
            ],
            opacity: 0.5,
          },
        };
        const vectorLayer = new WebGLPointsLayer({
          source: new VectorSource({
            attributions: "Earthquakes: USGS",
          }),
          style: layerStyle,
        });

        const view = new View({
          center: fromLonLat([-119.796982,36.752089]),
          zoom: 8,
        });
        const attribution = new Attribution({
          collapsible: false,
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [
            iclayer,
            vectorLayer,
          ],
          controls: defaultControls({attribution: false}).extend([attribution])
        });
        // load map data
        fetch("/assets/samples/earthquake.csv")
          .then((response) => response.text())
          .then((csv) => {
            var features = [];
            var prevIndex = csv.indexOf("\n") + 1; // scan past the header line
            var curIndex;

            while ((curIndex = csv.indexOf("\n", prevIndex)) !== -1) {
              var line = csv.substr(prevIndex, curIndex - prevIndex).split(",");
              prevIndex = curIndex + 1;

              var coords = fromLonLat([
                parseFloat(line[2]),
                parseFloat(line[1]),
              ]);
              if (isNaN(coords[0]) || isNaN(coords[1])) {
                // guard against bad data
                continue;
              }

              features.push(
                new Feature({
                  date: new Date(line[0].replace(/\..+$/, "")), // remove trailing fraction in date
                  depth: parseInt(line[3]),
                  magnitude: parseInt(line[4]),
                  geometry: new Point(coords),
                  eventId: parseInt(line[11]),
                })
              );
            }

            vectorLayer.getSource().addFeatures(features);
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
          <h6 class="text-white text-xl font-bold">Earthquakes</h6>
        </div>
      </div>
      <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
        <div class="flex flex-wrap">
          <div class="w-full pt-3">
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              The dataset contains a list of 2.5+ magnitude earthquakes in california. Information was generated using USGS website and contains multiple properties (location, magnitude, magtype) for each single entry. Data source: <a class="text-sky-900 hover:text-gray-400 underline decoration-sky-500/30" href="https://earthquake.usgs.gov/data/data.php">USGS</a> and <a class="text-sky-900 hover:text-gray-400 underline decoration-sky-500/30" href="https://github.com/uber-web/kepler.gl-data">kepler.gl-data</a>. In this example the data is laoded as CSV from asset canister.
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
