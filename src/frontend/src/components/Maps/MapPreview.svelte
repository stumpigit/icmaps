<script>
  import { Map, View } from "ol";
  import { Tile as TileLayer } from "ol/layer";
  import { defaults as defaultControls, ScaleLine } from "ol/control";
  import WMTS, { optionsFromCapabilities } from "ol/source/WMTS";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import { fromLonLat } from "ol/proj";

  export let mycanister;
  export let layeridentifier;

  const parser = new WMTSCapabilities();
  var view;
  var center;
  var doPopulate = false;
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
      }
    }
  }

 
</script>

<div id="map" class="relative w-full rounded h-600-px" />
