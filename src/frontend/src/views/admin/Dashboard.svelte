<script>
  // core components

  import CardCanisters from "../../components/Cards/CardCanisters.svelte";
  import CardWelcome from "../../components/Cards/CardWelcome.svelte";
  import CardLayers from "../../components/Cards/CardLayers.svelte";

  export let mycanisters = new Map();
</script>

<div>
  <div class="flex flex-wrap">
    <div class="w-full xl:w-12/12 mb-12 xl:mb-0 px-4">
      <CardCanisters mycanisters={mycanisters}/>
    </div>
    <div class="w-full xl:w-8/12 mb-12 xl:mb-0 px-4">
      <CardWelcome />
    </div>
    <div class="w-full xl:w-4/12 mb-12 xl:mb-0 px-4">
      <CardLayers mycanisters={mycanisters} isOverview=true/>
    </div>
  </div>
</div>
