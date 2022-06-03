<script>
  // core components
  import CardWMTSSettings from "components/Cards/CardWMTSSettings.svelte";
  import CardCanisters from "components/Cards/CardCanisters.svelte";
  import CardLayers from "components/Cards/CardLayers.svelte";
  import CardHowToAddCanister from "components/Cards/CardHowToAddCanister.svelte";

  import { Principal } from "@dfinity/principal";
  
  export let mycanisters = new Map();
  export let id;

  let currentCanister = {
    canisterId : "",
    balance : 0
  };
  $: {
    if (mycanisters.size > 0) 
    {
      currentCanister = mycanisters.get(id);
      currentCanister = currentCanister;
    }
  }

</script>

<div class="flex flex-wrap">
  <div class="w-full xl:w-12/12 mb-12 xl:mb-0 px-4">
    <CardCanisters mycanisters={mycanisters}/>
  </div>
  {#if currentCanister}
  <div class="w-full md:w-8/12 px-4">
    <CardWMTSSettings mycanister={currentCanister} />
  </div>
  <div class="w-full md:w-4/12 px-4">
    <CardLayers canister={currentCanister} isOverview=true/>
  </div>
  {:else}
  <div class="w-full md:w-12/12 px-4">
    <CardHowToAddCanister />
  </div>
  {/if}
</div>
