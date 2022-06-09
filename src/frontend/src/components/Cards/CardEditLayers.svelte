<script>
  
  import CardAddorEditWMTSLayers from "components/Cards/CardAddorEditWMTSLayers.svelte";
  import CardAddorEditOSMLayers from "components/Cards/CardAddorEditOSMLayers.svelte";
import { includes } from "ol/array";

  export let mycanisters;
  export let newlayerid;
  export let newlayertitle;
  export let newlayercanister;
  export let bbuppercornery = 46.8591;
  export let bbuppercornerx = 7.457;
  export let bblowercornery = 46.8941;
  export let bblowercornerx = 7.4923;
  export let selectedTMSNumbers;
  export let url;
  let openTab = 1;

  function toggleTabs(tabNumber){
    openTab = tabNumber
  }

  async function handleSave() {
    if (isosmedit) await osmEditor.save();
    if (iswmtsedit) await wmtsEditor.save();
  }

  let isosmedit = false;
  let iswmtsedit = false;
  $: {
    if (!url.toLowerCase().includes('getcapabilities')) isosmedit = true;
    else iswmtsedit = true;
  }
  
  let osmEditor;
  let wmtsEditor;
</script>
<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
    <div class="text-center flex justify-between">
      <h6 class="text-white text-xl font-bold">Edit layer</h6>
      <button
        class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
        type="button" on:click={handleSave}
      >
        Save
      </button>
    </div>
  </div>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
<div class="flex flex-wrap">
  <div class="w-full pt-3">
    <div class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded  bg-blueGray-100">
      <div class="px-4 py-5 flex-auto">
        {#if isosmedit}
        <CardAddorEditOSMLayers isEdit=isosmedit bind:this={osmEditor} mycanisters={mycanisters} newlayerid={newlayerid} newlayertitle={newlayertitle} bbuppercornerx={bbuppercornerx} bbuppercornery={bbuppercornery} bblowercornerx={bblowercornerx} bblowercornery={bblowercornery} selectedTMSNumbers={selectedTMSNumbers} tileURL={url} newlayercanister={newlayercanister}/>
        {:else}
        <CardAddorEditWMTSLayers bind:this={wmtsEditor} isEdit=iswmtsedit mycanisters={mycanisters} newlayerid={newlayerid} newlayertitle={newlayertitle} bbuppercornerx={bbuppercornerx} bbuppercornery={bbuppercornery} bblowercornerx={bblowercornerx} bblowercornery={bblowercornery} selectedTMSNumbers={selectedTMSNumbers} tileURL={url} newlayercanister={newlayercanister}/>
        {/if}
        </div>
      </div>
  </div>
</div>
</div></div>