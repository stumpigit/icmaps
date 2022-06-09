<script>
  import Map from "ol/Map";
  import View from "ol/View";
  import TileLayer from "ol/layer/Tile";
  import XYZ from "ol/source/XYZ";
  import { fromLonLat } from "ol/proj";
  import WebGLPointsLayer from "ol/layer/WebGLPoints";
  import VectorSource from "ol/source/Vector";
  import Point from "ol/geom/Point";
  import Feature from "ol/Feature";
  import { onMount } from "svelte";

  var view;
  var center;
  var doPopulate = false;
  var code = "";

  export function init() {
    const layerStyle = {
      variables: {
        min: -Infinity,
        max: Infinity,
      },
      filter: ["between", ["get", "date"], ["var", "min"], ["var", "max"]],
      symbol: {
        symbolType: "circle",
        size: ["interpolate", ["linear"], ["get", "magnitude"], 2.5, 4, 5, 20],
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
      center: fromLonLat([-122.297374, 37.355579]),
      zoom: 5.55,
    });
    const olMap = new Map({
      view,
      target: "map",
      layers: [
        new TileLayer({
          source: new XYZ({
            urls: [
              "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
              "https://b.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
              "https://c.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png",
            ],
            crossOrigin: "anonymous",
          }),
        }),
        vectorLayer,
      ],
    });
    // load map data
    fetch(
      "https://raw.githubusercontent.com/uber-web/kepler.gl-data/master/earthquakes/data.csv"
    )
      .then((response) => response.text())
      .then((csv) => {
        var features = [];
        var prevIndex = csv.indexOf("\n") + 1; // scan past the header line
        var curIndex;

        while ((curIndex = csv.indexOf("\n", prevIndex)) !== -1) {
          var line = csv.substr(prevIndex, curIndex - prevIndex).split(",");
          prevIndex = curIndex + 1;

          var coords = fromLonLat([parseFloat(line[2]), parseFloat(line[1])]);
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
