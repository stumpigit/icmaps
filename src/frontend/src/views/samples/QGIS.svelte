<script>
</script>

<div class="flex flex-wrap">
  <div class="w-full xl:w-12/12 mb-12 xl:mb-0 px-4">
    <div
      class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
    >
      <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
        <div class="text-center flex justify-between">
          <h6 class="text-white text-xl font-bold">
            Use your map in desktop GIS like QGIS
          </h6>
        </div>
      </div>
      <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
        <div class="flex flex-wrap">
          <div class="w-full pt-3">
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              Because the ICMap Web Server is a fully functional WMTS server,
              the maps can also be integrated into desktop GIS. In this
              tutorial, a layer is integrated into QGIS.
            </p>
            <div class="flex flex-wrap justify-center">
              <div class="w-6/12 sm:w-4/12 px-4">
                <img src="/assets/img/qgis1.png" alt="Add a layer in QGIS" class="shadow rounded max-w-full h-auto align-middle border-none" />
              </div>
            </div>
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              Start QGIS and select Layer -> Add Layer -> Add WMS / WMTS Layer.
              In the Data Source window you can create a new connection with
              New. The server can be named as the name, because the connection
              can easily be used again later. The URL is now the server in the
              form of:
            </p>

            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              https://vk72n-daaaa-aaaak-aapuq-cai.raw.ic0.app/wmts?Service=WMTS&Request=GetCapabilities
            </p>
            <div class="flex flex-wrap justify-center">
              <div class="w-6/12 sm:w-4/12 px-4">
                <img src="/assets/img/qgis2.png" alt="Sample connection details" class="shadow rounded max-w-full h-auto align-middle border-none" />
              </div>
            </div>
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              The connection can then be established using Connect. If everything has been entered correctly, the layer can be selected in the next screen. Several layers can also be clicked at the same time.
            </p>
            <div class="flex flex-wrap justify-center">
              <div class="w-6/12 sm:w-4/12 px-4">
                <img src="/assets/img/qgis3.png" alt="Connect to the layer" class="shadow rounded max-w-full h-auto align-middle border-none" />
              </div>
            </div>
            <p class="text-lg font-light leading-relaxed mt-6 mb-4">
              It will now automatically zoom in on the layer and the map will be displayed. This requires that the corresponding zoom level is also available in ICMaps. Otherwise you have to zoom until the map tiles appear.
            </p>
            <div class="flex flex-wrap justify-center">
              <div class="w-6/12 sm:w-4/12 px-4">
                <img src="/assets/img/qgis4.png" alt="Map inside QGIS" class="shadow rounded max-w-full h-auto align-middle border-none" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
