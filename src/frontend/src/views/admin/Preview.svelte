<script>
  // core components
  import MapPreview from "components/Maps/MapPreview.svelte";
  import CardLayers from "components/Cards/CardLayers.svelte";
  export let location;

  export let mycanisters = new Map();
  export let canisterid;
  export let layeridentifier;

  let mycanister;

  $: {
    mycanister = mycanisters.get(canisterid);
  }
</script>

<div class="flex flex-wrap">
  {#if canisterid == null}
    <div class="w-full lg:w-12/12 px-4">
      <CardLayers {mycanisters} isPreview=true />
    </div>
  {/if}

  {#if mycanisters != null}
    <div class="w-full px-4">
      <div
        class="relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded"
      >
        <MapPreview {mycanister} {layeridentifier} />
      </div>
    </div>
  {/if}
</div>
