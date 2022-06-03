<script>
  // core components
  import CardStats from "components/Cards/CardStats.svelte";
  import { link } from "svelte-routing";

  export let mycanisters;

  let mycanisterArray = [];
  $: {
    mycanisterArray = Array.from(mycanisters, ([name, canisterInfo]) => ({ name, canisterInfo }));
  }
  
  function onCanisterClick(id) {
    navigate("/admin/canister/"+id, { replace: true });
  }
</script>

<div
  class="relative flex flex-col min-w-0 break-words w-full mb-12 shadow-lg rounded bg-blueGray-700 text-white"
>
  <div class="rounded-t mb-0 px-4 py-3 border-0">
    <div class="flex flex-wrap items-center">
      <div class="relative w-full px-4 max-w-full flex-grow flex-1">
        <h3
          class="font-semibold text-lg text-white"
        >
          Your canister(s)
        </h3>
      </div>
    </div>
  </div>
  <div class="block w-full overflow-x-auto">
    <div class="px-4 md:px-10 mx-auto w-full mb-6">
      <div>
        <!-- Card stats -->
        <div class="flex flex-wrap">
          {#each mycanisterArray as value}
          
          <div class="w-full lg:w-6/12 xl:w-4/12 px-4">
            <a href="/admin/canister/{value.canisterInfo.canisterId}" use:link>
            <CardStats
              statSubtitle="Canister"
              statTitle="{value.canisterInfo.canisterId} (v {value.canisterInfo.version})"
              statArrow=""
              statPercent="{value.canisterInfo.balance}"
              statPercentColor="text-emerald-500"
              statDescripiron="Available cycles"
              statIconName="far fa-chart-bar"
              statIconColor="bg-blue-500"
            />
          </a>
          </div>
          {/each}
          <div class="w-full lg:w-6/12 xl:w-3/12 px-4">
            <a href="/admin/canister/new" use:link>
              <div
              class="relative flex flex-col min-w-0 break-words bg-white rounded mb-6 xl:mb-0 shadow-lg hover:bg-gray-100"
            >
              <div class="flex-auto p-4">
                <div class="flex flex-wrap">
                  <div class="relative w-full pr-4 max-w-full flex-grow flex-1">
                    <h5 class="text-blueGray-400 uppercase font-bold text-xs">
                      Add a new WMTS-Canister
                    </h5>
                    <span class="font-semibold text-xl text-blueGray-700">
                      New
                    </span>
                  </div>
                  <div class="relative w-auto pl-4 flex-initial">
                    <div
                      class="text-white p-3 text-center inline-flex items-center justify-center w-12 h-12 shadow-lg rounded-full bg-blue-500"
                    >
                      <i class="fas fa-plus-circle"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
