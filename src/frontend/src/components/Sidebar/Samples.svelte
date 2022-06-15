<script>
    import { link } from "svelte-routing";

  </script> 
 
 <!-- Divider -->
 <hr class="my-4 md:min-w-full" />
 <!-- Heading -->
 <h6
   class="md:min-w-full text-blueGray-500 text-xs uppercase font-bold block pt-1 pb-4 no-underline"
 >
   ICMaps Samples
 </h6>
 <!-- Navigation -->

 <ul class="md:flex-col md:min-w-full flex flex-col list-none">
  <li class="items-center">
    <a
      use:link
      href="/samples/dashboard"
      class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/dashboard') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
    >
      <i
        class="fas fa-tv mr-2 text-sm {location.href.indexOf('/samples/dashboard') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
      ></i>
      Overview
    </a>
  </li>
   <li class="items-center">
     <a
       use:link
       href="/samples/simple"
       class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/simple') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
     >
       <i
         class="fas fa-map mr-2 text-sm {location.href.indexOf('/samples/simple') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
       ></i>
       Simple Map
     </a>
   </li>
   <li class="items-center">
     <a
       use:link
       href="/samples/osm"
       class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/osm') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
     >
       <i
         class="fas fa-map-marked mr-2 text-sm {location.href.indexOf('/samples/osm') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
       ></i>
       Open Street Map
     </a>
   </li>
   <li class="items-center">
     <a
       use:link
       href="/samples/earthquake"
       class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/earthquake') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
     >
       <i
         class="fas fa-house-damage mr-2 text-sm {location.href.indexOf('/samples/earthquake') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
       ></i>
       Earthquakes
     </a>
   </li>

   <li class="items-center">
     <a
       use:link
       href="/samples/aletsch"
       class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/aletsch') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
     >
       <i
         class="fas fa-mountain mr-2 text-sm {location.href.indexOf('/samples/aletsch') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
       ></i>
       Climate change
     </a>
   </li>

   <li class="items-center">
     <a
       use:link
       href="/samples/qgis"
       class="text-xs uppercase py-3 font-bold block {location.href.indexOf('/samples/qgis') !== -1 ? 'text-blue-500 hover:text-blue-600':'text-blueGray-700 hover:text-blueGray-500'}"
     >
       <i
         class="fas fa-toolbox mr-2 text-sm {location.href.indexOf('/samples/qgis') !== -1 ? 'opacity-75' : 'text-blueGray-300'}"
       ></i>
       QGIS
     </a>
   </li>
 </ul>
