<script>
  import { link } from "svelte-routing";
</script>

<div>
  <div class="flex flex-wrap">
    <div class="w-full xl:w-4/12 mb-12 xl:mb-12 px-4">
      <div
        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700" style="height: 430px;"
      >
        <a use:link href="/samples/simple">
          <img class="rounded-t-lg" src="/assets/img/simpla_sample.png" alt="" />
        </a>
        <div class="p-5">
          <a use:link href="/samples/simple">
            <h5
              class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
            >
              Topographic map
            </h5>
          </a>
          <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
            A topographic map of Switzerland shows the simple use of maps in Web3 applications.
          </p>
          <a
            use:link
            href="/samples/simple"
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
          >
            View sample
          </a>
        </div>
      </div>
    </div>

    <div class="w-full xl:w-4/12 mb-12 xl:mb-12 px-4">
      <div
        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700" style="height: 430px;"
      >
        <a use:link href="/samples/osm">
          <img class="rounded-t-lg" src="/assets/img/osm_sample.png" alt="" />
        </a>
        <div class="p-5">
          <a use:link href="/samples/osm">
            <h5
              class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
            >
              Map with kml marker
            </h5>
          </a>
          <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
            An example of an Open Street Map with a marker loaded and displayed
            using KML.
          </p>
          <a
            use:link
            href="/samples/osm"
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
          >
            View sample
          </a>
        </div>
      </div>
    </div>
    <div class="w-full xl:w-4/12 mb-12 xl:mb-12 px-4">
      <div
        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700" style="height: 430px;"
      >
        <a use:link href="/samples/earthquake">
          <img
            class="rounded-t-lg"
            src="/assets/img/earthquake_sample.png"
            alt=""
          />
        </a>
        <div class="p-5">
          <a use:link href="/samples/earthquake">
            <h5
              class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
            >
              Earthquakes
            </h5>
          </a>
          <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
            Large-scale map showing recorded earthquakes on the US West Coast.
            The magnitudes are shown in the size of the circles.
          </p>
          <a
            use:link
            href="/samples/earthquake"
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
          >
            View sample
          </a>
        </div>
      </div>
    </div>

    <div class="w-full xl:w-4/12 mb-12 xl:mb-12 px-4">
      <div
        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700" style="height: 430px;"
      >
        <a use:link href="/samples/aletsch">
          <img
            class="rounded-t-lg"
            src="/assets/img/climate_change_sample.png"
            alt=""
          />
        </a>
        <div class="p-5">
          <a use:link href="/samples/aletsch">
            <h5
              class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
            >
              Climate Change
            </h5>
          </a>
          <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
            Due to global warming, the glaciers are melting. An impressive example allows the comparison of the Aletsch glacier between 2016 and 2021.
          </p>
          <a
            use:link
            href="/samples/aletsch"
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
          >
            View sample
          </a>
        </div>
      </div>
    </div>

    <div class="w-full xl:w-4/12 mb-12 xl:mb-12 px-4">
      <div
        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700" style="height: 430px;"
      >
        <a use:link href="/samples/qgis">
          <img
            class="rounded-t-lg"
            src="/assets/img/qgis_sample.png"
            alt=""
          />
        </a>
        <div class="p-5">
          <a use:link href="/samples/qgis">
            <h5
              class="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white"
            >
              QGIS
            </h5>
          </a>
          <p class="mb-3 font-normal text-gray-700 dark:text-gray-400">
            ICMaps maps can also be used in conventional desktop GIS. The application is demonstrated using the open source QGIS.
          </p>
          <a
            use:link
            href="/samples/aletsch"
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
          >
            View sample
          </a>
        </div>
      </div>
    </div>
  </div>
</div>
