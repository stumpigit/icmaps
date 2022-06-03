<script>
  	import { onMount } from 'svelte';
  // core components
  import CardLayers from "components/Cards/CardLayers.svelte";
  import CardAddLayers from "components/Cards/CardAddLayers.svelte";
  import CardEditLayers from "components/Cards/CardEditLayers.svelte";
  import CardOSMInfo from "components/Cards/CardOSMInfo.svelte";
  import CardWMTSInfo from "components/Cards/CardWMTSInfo.svelte";
  
  export let mycanisters = new Map();
  export let canisterid;
  export let layeridentifier;

  let mycanister;
  let layerInfo;
  let bbuppercornery;
  let bbuppercornerx;
  let bblowercornery;
  let bblowercornerx;

  $: {
    mycanister = mycanisters.get(canisterid);
    if (mycanister) {
      layerInfo = mycanister.layerInfo.find(li => li.identifier == layeridentifier);
      if (layerInfo) {
        bbuppercornerx = layerInfo.wGS84BoundingBox.upperCorner.split(' ')[0];
        bbuppercornery = layerInfo.wGS84BoundingBox.upperCorner.split(' ')[1];
        bblowercornerx = layerInfo.wGS84BoundingBox.lowerCorner.split(' ')[0];
        bblowercornery = layerInfo.wGS84BoundingBox.lowerCorner.split(' ')[1];
      }
    }
    
  }
</script>

<div class="flex flex-wrap">
  {#if canisterid == null}
    <div class="w-full lg:w-12/12 px-4">
      <CardLayers mycanisters={mycanisters} />
    </div>
    
    <div class="w-full xl:w-8/12 mb-12 xl:mb-0 px-4">
      <CardAddLayers mycanisters={mycanisters} />
    </div>
    <div class="w-full xl:w-4/12 mb-12 xl:mb-0 px-4">
      <CardOSMInfo />
      <CardWMTSInfo />
    </div>
  {:else}
  {#if layerInfo != null}
    <div class="w-full xl:w-8/12 mb-12 xl:mb-0 px-4">
      <CardEditLayers newlayerid="{layerInfo.identifier}" newlayertitle={layerInfo.title} newlayercanister={canisterid} bbuppercornerx={bbuppercornerx} bbuppercornery={bbuppercornery} bblowercornerx={bblowercornerx} bblowercornery={bblowercornery} selectedTMSNumbers={layerInfo.providedTilematrixSets} url={layerInfo.url} mycanisters={mycanisters} />
    </div>
    <div class="w-full xl:w-4/12 mb-12 xl:mb-0 px-4">
      <CardOSMInfo />
      <CardWMTSInfo />
    </div>
    {/if}
  {/if}

</div>
