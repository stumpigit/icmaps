<script>
  // core components
  import TableDropdown from "components/Dropdowns/TableDropdown.svelte";
  import { link } from "svelte-routing";

  export let color = 'light';

  export let mycanisters;
  export let isPreview = false;
  export let isOverview = false;
  export let canister;
  

  let mycanisterArray = [];
  $: {
    if (canister) {
      mycanisterArray = [({name: canister.canisterId.toText(), canisterInfo: canister})];
    }
    else mycanisterArray = Array.from(mycanisters, ([name, canisterInfo]) => ({ name, canisterInfo }));
    console.log(mycanisterArray);
  }
  let client;

</script>

<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded {color === 'light' ? 'bg-white' : 'bg-blue-800 text-white'}"
>
    <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
      <div class="text-center flex justify-between">
        <h6 class="text-white text-xl font-bold">Your layers</h6>
      </div>
    </div>
  <div class="block w-full overflow-x-auto">
    <!-- Projects table -->
    <table class="items-center w-full bg-transparent border-collapse">
      <thead>
        <tr>
          {#if !isOverview}
          {#if isPreview}
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          >
            Preview
          </th>
          {/if}
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          >
            Layername
          </th>
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          >
            Title
          </th>
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          >
            Canister
          </th>
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          >
            Bounding Box
          </th>
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          >
            Tilematrixset
          </th>
          <th
            class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
          ></th>
          {:else}
          <th
          class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
        ></th>
          <th
          class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
        >
          Title
        </th>
          {/if}
        </tr>
      </thead>
      <tbody>
        {#each mycanisterArray as mycanister}
        {#if mycanister.canisterInfo.layerInfo}
        {#each mycanister.canisterInfo.layerInfo as value}
        <tr>
          {#if !isOverview}
          {#if isPreview}
          <td
          class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
        >
        <a class="text-color-blue font-semibold" href="/admin/preview/{mycanister.name}/{value.identifier}" use:link>Preview Layer</a>
        </td>
        {/if}


          <td
            class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-left flex items-center"
          >
            <span
              class="ml-3 font-bold {color === 'light' ? 'btext-blueGray-600' : 'text-whit'}"
            >
              {value.identifier}
            </span>
          </td>
          <td
            class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
          >
            {value.title}
          </td>
          
          <td
            class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
          >
            {mycanister.name}
          </td>
          <td
            class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
          >
          {value.wGS84BoundingBox.upperCorner} {value.wGS84BoundingBox.lowerCorner}
          </td>
          <td
            class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
          >
            {value.tilematrixset.identifier}
          </td>
          <td
            class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-right"
          >
            <TableDropdown canisterid={mycanister.name} layeridentifier={value.identifier} />
          </td>
          {:else}
          <td
        class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-right"
      >
        <TableDropdown canisterid={mycanister.name} layeridentifier={value.identifier} />
      </td>
          <td
          class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 font-bold "
        >
          {value.title}
        </td>
        
          {/if}
        </tr>
        {/each}
        {/if}
        {/each}
      </tbody>
    </table>
  </div>
</div>
