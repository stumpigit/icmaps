<script>
  
  import CardAddorEditWMTSLayers from "components/Cards/CardAddorEditWMTSLayers.svelte";
  import CardAddorEditOSMLayers from "components/Cards/CardAddorEditOSMLayers.svelte";

  export let mycanisters;
  let openTab = 1;

  function toggleTabs(tabNumber){
    openTab = tabNumber
  }

</script>
<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
    <div class="text-center flex justify-between">
      <h6 class="text-white text-xl font-bold">Add a new layer</h6>
    </div>
  </div>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
<div class="flex flex-wrap">
  <div class="w-full pt-3">
    <ul class="flex mb-0 list-none flex-wrap pt-3 pb-4 flex-row">
      <li class="-mb-px mr-2 last:mr-0 flex-auto text-center">
        <a class="text-xs font-bold uppercase px-5 py-3 shadow-lg rounded block leading-normal {openTab === 1 ? 'text-white bg-blue-600':'text-blue-600 bg-white'}" on:click={() => toggleTabs(1)}>
          From XYZ-Tileserver
        </a>
      </li>
      <li class="-mb-px mr-2 last:mr-0 flex-auto text-center">
        <a class="text-xs font-bold uppercase px-5 py-3 shadow-lg rounded block leading-normal {openTab === 2 ? 'text-white bg-blue-600':'text-blue-600 bg-white'}" on:click={() => toggleTabs(2)}>
          From WMTS Server
        </a>
      </li>
    </ul>
    <div class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded  bg-blueGray-100">
      <div class="px-4 py-5 flex-auto">
        <div class="tab-content tab-space">
          <div class="{openTab === 1 ? 'block':'hidden'}">
            <CardAddorEditOSMLayers mycanisters={mycanisters} />
          </div>
          <div class="{openTab === 2 ? 'block':'hidden'}">
            <CardAddorEditWMTSLayers mycanisters={mycanisters} />
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
</div></div>