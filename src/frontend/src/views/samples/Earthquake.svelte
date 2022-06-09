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

  var view;
  var center;
  var doPopulate = false;
  var code = "";

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
          layer: "sample_earthquake",
        });
        
        let iclayer = new TileLayer({
          opacity: 1,
          source: new WMTS(options),
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
            attributions: "USGS",
          }),
          style: layerStyle,
        });

        const view = new View({
          center: fromLonLat([-119.796982,36.752089]),
          zoom: 8,
        });
        const olMap = new Map({
          view,
          target: "map",
          layers: [
            iclayer,
            vectorLayer,
          ],
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
