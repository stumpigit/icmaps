<script>
  import { link } from "svelte-routing";

  // core components
  import UserDropdown from "components/Dropdowns/UserDropdown.svelte";
  const logosmall = "../../assets/img/logo_small.png";
  let collapseShow = "hidden";

  function toggleCollapseShow(classes) {
    collapseShow = classes;
  }

  export let location;
</script>

<nav
  class="md:left-0 md:block md:fixed md:top-0 md:bottom-0 md:overflow-y-auto md:flex-row md:flex-nowrap md:overflow-hidden shadow-xl bg-white flex flex-wrap items-center justify-between relative md:w-64 z-10 py-4 px-6"
>
  <div
    class="md:flex-col md:items-stretch md:min-h-full md:flex-nowrap px-0 flex flex-wrap items-center justify-between w-full mx-auto"
  >
    <!-- Toggler -->
    <button
      class="cursor-pointer text-black opacity-50 md:hidden px-3 py-1 text-xl leading-none bg-transparent rounded border border-solid border-transparent"
      type="button"
      on:click={() => toggleCollapseShow('bg-white m-2 py-3 px-6')}
    >
      <i class="fas fa-bars"></i>
    </button>
    <!-- Brand -->
    <a
        use:link
        class="text-blueGray-700 text-sm font-bold leading-relaxed inline-block mr-4 py-2 whitespace-nowrap uppercase"
        href="/"
      >
      <img class="object-cover" src="{logosmall}" alt="icmaps logo">
      </a>
    <!-- User -->
    <ul class="md:hidden items-center flex flex-wrap list-none">
      <li class="inline-block relative">
        <UserDropdown />
      </li>
    </ul>
    <!-- Collapse -->
    <div
      class="md:flex md:flex-col md:items-stretch md:opacity-100 md:relative md:mt-4 md:shadow-none shadow absolute top-0 left-0 right-0 z-40 overflow-y-auto overflow-x-hidden h-auto items-center flex-1 rounded {collapseShow}"
    >
      <!-- Collapse header -->
      <div
        class="md:min-w-full md:hidden block pb-4 mb-4 border-b border-solid border-blueGray-200"
      >
        <div class="flex flex-wrap">
          <div class="w-6/12">
            <a
              use:link
              class="md:block text-left md:pb-2 text-blueGray-600 mr-0 inline-block whitespace-nowrap text-sm uppercase font-bold p-4 px-0"
              href="/"
            >
              ICMaps
            </a>
          </div>
          <div class="w-6/12 flex justify-end">
            <button
              type="button"
              class="cursor-pointer text-black opacity-50 md:hidden px-3 py-1 text-xl leading-none bg-transparent rounded border border-solid border-transparent"
              on:click={() => toggleCollapseShow('hidden')}
            >
              <i class="fas fa-times"></i>
            </button>
          </div>
        </div>
      </div>

      <!-- Divider -->
      <hr class="my-4 md:min-w-full" />
      <!-- Heading -->
      <h6
        class="md:min-w-full text-blueGray-500 text-xs uppercase font-bold block pt-1 pb-4 no-underline"
      >
        ICMaps Settings
      </h6>
      <!-- Navigation -->

      <ul class="md:flex-col md:min-w-full flex flex-col list-none">
        <li class="items-center">
          <a
            use:link
            href="/admin/dashboard"
            class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/admin/dashboard') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
          >
            <i
              class="fas fa-tv mr-2 text-sm {location.href.indexOf('/admin/dashboard') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
            ></i>
            Dashboard
          </a>
        </li>
        <li class="items-center">
          <a
            use:link
            href="/admin/canister"
            class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/admin/canister') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
          >
            <i
              class="fas fa-box mr-2 text-sm {location.href.indexOf('/admin/canister') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
            ></i>
            Canisters
          </a>
        </li>
        <li class="items-center">
          <a
            use:link
            href="/admin/layers"
            class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/admin/layers') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
          >
            <i
              class="fas fa-layer-group mr-2 text-sm {location.href.indexOf('/admin/layers') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
            ></i>
            Layers
          </a>
        </li>

        <li class="items-center">
          <a
            use:link
            href="/admin/preview"
            class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/admin/preview') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
          >
            <i
              class="fas fa-map mr-2 text-sm {location.href.indexOf('/admin/preview') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
            ></i>
            Preview
          </a>
        </li>

        <li class="items-center">
          <a
            use:link
            href="/samples/dashboard"
            class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/dashboard') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
          >
            <i
              class="fas fa-map-marked mr-2 text-sm {location.href.indexOf('/samples/dashboard') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
            ></i>
            Maps
          </a>
        </li>
      </ul>

      <!-- Divider -->
      <hr class="my-4 md:min-w-full" />
      <!-- Heading -->
      <h6
        class="md:min-w-full text-blueGray-500 text-xs uppercase font-bold block pt-1 pb-4 no-underline"
      >
        About ICMaps
      </h6>
      <!-- Navigation -->

      <ul class="md:flex-col md:min-w-full flex flex-col list-none md:mb-4">
        <li class="items-center">
          <a
            use:link
            class="text-blueGray-700 hover:text-blueGray-500 text-xs uppercase py-3 font-bold block"
            href="/auth/login"
          >
            <i class="fas fa-fingerprint text-blueGray-300 mr-2 text-sm"></i>
            About IC
          </a>
        </li>

        <li class="items-center">
          <a
            use:link
            class="text-blueGray-700 hover:text-blueGray-500 text-xs uppercase py-3 font-bold block"
            href="/auth/register"
          >
            <i class="fas fa-clipboard-list text-blueGray-300 mr-2 text-sm"></i>
            About ICMaps
          </a>
        </li>
      </ul>

    </div>
  </div>
</nav>
