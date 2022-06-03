<script>
  // core components
  import CardCanisters from "components/Cards/CardCanisters.svelte";
  import CardAddCanister from "components/Cards/CardAddCanister.svelte";

  import { Principal } from "@dfinity/principal";
  
  export let mycanisters = new Map();


</script>

<div class="flex flex-wrap">
  <div class="w-full xl:w-12/12 mb-12 xl:mb-0 px-4">
    <CardCanisters mycanisters={mycanisters}/>
  </div>
  <div class="w-full lg:w-6/12 px-4">
    <CardAddCanister mycanisters={mycanisters} />
  </div>
</div>
