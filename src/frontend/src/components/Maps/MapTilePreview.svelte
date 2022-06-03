<script>
import 'ol/ol.css';
import MVT from 'ol/format/MVT';
import Map from 'ol/Map';
import TileGrid from 'ol/tilegrid/TileGrid';
import VectorTileLayer from 'ol/layer/VectorTile';
import VectorTileSource from 'ol/source/VectorTile';
import View from 'ol/View';
import {Fill, Icon, Stroke, Style, Text} from 'ol/style';
import {get as getProjection} from 'ol/proj';
import stylefunction from 'ol-mapbox-style';

import { onMount } from "svelte";

  export let mycanister;
  export let layeridentifier;
// Calculation of resolutions that match zoom levels 1, 3, 5, 7, 9, 11, 13, 15.
const resolutions = [];
for (let i = 0; i <= 8; ++i) {
  resolutions.push(156543.03392804097 / Math.pow(2, i * 2));
}
// Calculation of tile urls for zoom levels 1, 3, 5, 7, 9, 11, 13, 15.
function tileUrlFunction(tileCoord) {
  console.log("tileUrlFUnction");
  return (
    'http://rrkah-fqaaa-aaaaa-aaaaq-cai.localhost:8000/1.0.0/tile_zh/default/3857/default/{z}/{y}/{x}.pbf'
  )
    .replace('{z}', String(tileCoord[0] * 2 - 1))
    .replace('{x}', String(tileCoord[1]))
    .replace('{y}', String(tileCoord[2]));
}
const tileLayer = new VectorTileLayer({
      source: new VectorTileSource({
        attributions:
          '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> ' +
          '© <a href="https://www.openstreetmap.org/copyright">' +
          'OpenStreetMap contributors</a>',
        format: new MVT(),
        tileGrid: new TileGrid({
          extent: getProjection('EPSG:3857').getExtent(),
          resolutions: resolutions,
          tileSize: 512,
        }),
        tileUrlFunction: tileUrlFunction,
      }),
    });

let map;
onMount(async () => {
  

  map = new Map({
  layers: [
    tileLayer
  ],
  target: 'map',
  view: new View({
    center: [939305.9596297961, 5997860.749436945],
    minZoom: 1,
    zoom: 15,
  }),
});



});
function styleme() {
  
  fetch('https://raw.githubusercontent.com/openmaptiles/maptiler-basic-gl-style/master/style.json').then(function(response) {
  response.json().then(function(glStyle) {
    stylefunction(tileLayer, glStyle);
  });
});
  }

</script>
<button on:click={styleme}>Hallo</button>
<div id="map" class="relative w-full rounded h-600-px" />
