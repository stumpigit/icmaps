<script>
  // core components
  import MapPreview from "components/Maps/MapPreview.svelte";
  export let location;

  export let mycanisters = new Map();

</script>

<div class="flex flex-wrap">
  <div class="w-full px-4">
    <div
      class="relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded"
    >
      <MapPreview mycanister={mycanisters[0]} layeridentifier="osm" />
    </div>
  </div>
</div>
