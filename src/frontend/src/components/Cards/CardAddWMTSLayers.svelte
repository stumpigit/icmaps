<script>
  import { Map, View } from "ol";
  import { Tile as TileLayer } from "ol/layer";
  import { defaults as defaultControls, ScaleLine } from "ol/control";
  import MultiSelect from 'svelte-multiselect'
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import ProgressBar from "@okrad/svelte-progressbar";
  import { AuthClient } from "@dfinity/auth-client";
  import { wmtsserver,createWMTSActor, setCanisterId, getWMTSParameters, WMTS } from "../../store/wmtsserver";

  import {fromLonLat} from 'ol/proj';

  const parser = new WMTSCapabilities();
  let color ='light';
  export let mycanisters;
  let value;

  let newlayerid;
  let newlayertitle;
  let newlayercanister;

  let mycanisterArray = [];
  $: {
    mycanisterArray = Array.from(mycanisters, ([name, canisterInfo]) => ({
      name,
      canisterInfo,
    }));
    console.log("im artra");
    console.log(mycanisterArray);
  }
  let client;
  let getCapabilities =
    "https://geogeoserver.azurewebsites.net/geoserver/gwc/service/wmts?REQUEST=GetCapabilities";
  let parsedGetCapabilities;
  let layer;
  let tms;
  let bbuppercornerx;
  let bbuppercornery;
  let bblowercornerx;
  let bblowercornery;

  let bbuppercornerx_tms;
  let bbuppercornery_tms;
  let bblowercornerx_tms;
  let bblowercornery_tms;

  function handleGetCapa() {
    console.log(getCapabilities);
    fetch(getCapabilities, {
      mode: "cors",
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
    })
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        parsedGetCapabilities = parser.read(text);
        console.log(parsedGetCapabilities);
      });
  }
  let selectedTMS;
  let selectedTMSMultiSelectArray = [];
  let selectedZoomLevels = [];
  function tmsSelected() {
    selectedTMS = parsedGetCapabilities.Contents.TileMatrixSet.find(e => e.Identifier == tms);
    selectedTMSMultiSelectArray = [];
    selectedTMS.TileMatrix.forEach(tms => {selectedTMSMultiSelectArray.push(tms.Identifier);});
    
    // calculate boundaries
    
    let bottomleft = fromLonLat([bbuppercornerx, bbuppercornery]);
    let topright = fromLonLat([bblowercornerx, bblowercornery]);

    bbuppercornerx_tms = bottomleft[0];
    bbuppercornery_tms = topright[1];

    bblowercornerx_tms = topright[0];
    bblowercornery_tms = bottomleft[1];
  }

  let zoomLevel = {
    Identifier : Text,
    tms : Object,

  }

  let selected;
  let myTMSSelected = [];
  function zoomLevelsSelected() {
    myTMSSelected = [];
    selected.forEach(zoomLevel => {
      let myZoomLevelTMS = selectedTMS.TileMatrix.find(e => e.Identifier == zoomLevel);
      
      let tilematrixtopleftx = myZoomLevelTMS.TopLeftCorner[0];
      let tilematrixtoplefty = myZoomLevelTMS.TopLeftCorner[1];


      let tilewidth = myZoomLevelTMS.TileWidth;
      let div = tilewidth * 0.00028 * myZoomLevelTMS.ScaleDenominator;
      
      let myZoomLevel = {
        Identifier : myZoomLevelTMS.Identifier,
        tms : myZoomLevelTMS,
        topleftTileRow : Math.round((bbuppercornerx_tms - tilematrixtopleftx) / div),
        bottomrightTileRow : Math.round((bblowercornerx_tms - tilematrixtopleftx) / div),
        topleftTileCol : Math.round((tilematrixtoplefty-bbuppercornery_tms) / div),
        bottomrightTileCol : Math.round((tilematrixtoplefty-bblowercornery_tms) / div),
        totalTiles : 0
      }
      console.log(myZoomLevel.bottomrightTileCol - myZoomLevel.topleftTileCol);
      console.log(myZoomLevel.topleftTileRow  - myZoomLevel.bottomrightTileRow);
      myZoomLevel.totalTiles = (myZoomLevel.bottomrightTileCol - myZoomLevel.topleftTileCol + 1) * (myZoomLevel.bottomrightTileRow  - myZoomLevel.topleftTileRow + 1);
      myTMSSelected.push(myZoomLevel);
      
    });
  }


  let myLayer;
  function layerSelected() {
    console.log(layer);
    myLayer = parsedGetCapabilities.Contents.Layer.find(e => e.Identifier == layer);
    bbuppercornerx = myLayer.WGS84BoundingBox[0];
    bbuppercornery = myLayer.WGS84BoundingBox[1];
    bblowercornerx = myLayer.WGS84BoundingBox[2];
    bblowercornery = myLayer.WGS84BoundingBox[3];
  }

  // upload

  export let progress = 0;
  let progressText = "Starting seeding";
  const MAX_CHUNK_SIZE = 1024 * 500; // 500kb
const encodeArrayBuffer = (file) =>
      Array.from(new Uint8Array(file));

const processAndUploadChunk = async (
  blob,
  byteStart,
  fileId,
  chunk,
  fileSize,
)  => {
  const blobSlice = blob.slice(
    byteStart,
    Math.min(Number(fileSize), byteStart + MAX_CHUNK_SIZE),
    blob.type
  );
 
  const bsf = await blobSlice.arrayBuffer();
  // console.log(fileId);
  // console.log(chunk);
  // console.log(fileSize);
  // console.log(encodeArrayBuffer(bsf));
  return $wmtsserver.actor.putFileChunks(fileId, BigInt(chunk), BigInt(fileSize), encodeArrayBuffer(bsf));
}
const getFileExtension = (type) => {
  switch(type) {
    case 'image/jpeg':
      return { 'jpeg' : null };
    case 'image/gif':
      return { 'gif' : null };
    case 'image/jpg':
      return { 'jpg' : null };
    case 'image/png':
      return { 'png' : null };          
    default :
    return null;
  }
};

  async function fetchImage(selectedZoom, tilematrix, tilecol, tilerow)
  {

  let wmts_call = {
    version : "1.0.0",
    layer : newlayerid,
    style : "",
    format : "jpeg",
    tileMatrixSet : "3857",
    srs : "3857",
    tileMatrix : tilematrix.toString(),
    tileRow : tilecol.toString(),
    tileCol : tilerow.toString()
  };
  // 
let fetchUrl = "http://geogeoserver.azurewebsites.net/geoserver/gwc/service/wmts/rest/cite:Aletsch2021/raster/"+ tms +"/"+ tilematrix +"/"+ tilerow+"/"+ tilecol+"?format=image/png";
console.log(fetchUrl)
let file = await fetch(fetchUrl).then(response => response.blob())
.then(async function(file) {
  const fileInfo  = {
    name: Math.random().toString(36).substring(2),
    createdAt: BigInt(Number(Date.now() * 1000)),
    size: BigInt(file.size),
    chunkCount: BigInt(1),
    // @ts-ignore
    extension: getFileExtension("image/jpeg"),
    x: BigInt(tilecol),
    y: BigInt(tilerow),
    z: BigInt(tilematrix),
    layer: newlayerid,
    tilematrixset: "3857"
  };


  // const authenticated = await authClient.isAuthenticated();
  // console.log(authenticated);
  const fileId = (await $wmtsserver.actor.putFileInfo(fileInfo))[0];
  const blob = file;
  /*const putChunkPromises: Promise<undefined>[] = [];
  let chunk = 1;
    putChunkPromises.push(
      processAndUploadChunk(blob, 0, fileId, chunk, file.size)
    );
  
  await Promise.all(putChunkPromises);*/
    let chunk = 1;
  await processAndUploadChunk(blob, 0, fileId, chunk, file.size);
  });
}

let showModal = false;

function toggleModal(){
  showModal = !showModal;
}

 async function handleSeed(selectedZoom)
  {
    
    showModal = true;

  try {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      setCanisterId(newlayercanister);
    wmtsserver.update(() => ({
      loggedIn: true,
      actor: createWMTSActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));

    let saving = await $wmtsserver.actor.addLayer(newlayerid, newlayertitle, "png", "3857");
    let tilerow;
    let tilecol;
    let current=0;
    for (tilerow = selectedZoom.topleftTileRow; tilerow<=selectedZoom.bottomrightTileRow; tilerow++) {
    for (tilecol =selectedZoom.topleftTileCol; tilecol <=selectedZoom.bottomrightTileCol; tilecol++) {
      progress = Math.round((current * 100) / selectedZoom.totalTiles);
      progressText = "Getting tile " + selectedZoom.Identifier + "/"+ tilecol + "/" + tilerow;
      console.log(selectedZoom.Identifier + "/"+ tilecol + "/" + tilerow);
      await fetchImage(selectedZoom, selectedZoom.Identifier, tilerow, tilecol);
      current++;
    }

  }

    await $wmtsserver.actor.updateStatus();
    showModal = false;
};
    }
    catch (e)
    {
      console.log("Error in Fetching: " + e);
      
    showModal = false;
    }


//}
//else {
//  console.log("File already in store");
//}

  }

</script>
{#if showModal}
<div class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex">
  <div class="relative w-auto my-6 mx-auto max-w-sm">
    <!--content-->
    <div class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none">
      <!--header-->
      <div class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t">
        <h3 class="text-3xl font-semibold">
          Seeding tiles
        </h3>
        <button class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none" on:click={toggleModal}>
          <span class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none">
            ×
          </span>
        </button>
      </div>
      <!--body-->
      <div class="relative p-6 flex-auto">
        <ProgressBar series={progress} />
        <p class="my-4 text-blueGray-500 leading-relaxed">
          {progressText}
        </p>
      </div>
      <!--footer-->
      <div class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b">
        <button class="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150" type="button" on:click={toggleModal}>
          Cancel
        </button>
      </div>
    </div>
  </div>
</div>
<div class="opacity-25 fixed inset-0 z-40 bg-black"></div>
{/if}

    <form>
      <h6 class="text-blueGray-400 text-sm mt-3 mb-6 font-bold uppercase">
        From an existing WMTS GetCapabilities
      </h6>
      <div class="flex flex-wrap">
        <div class="w-full lg:w-4/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
              New layer identifier
            </label>
            <input
              id="layerid"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={newlayerid}
            />
          </div>
          
        </div>
        <div class="w-full lg:w-4/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
              New layer title
            </label>
            <input
              id="layerid"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={newlayertitle}
            />
          </div>
          
        </div>
        <div class="w-full lg:w-4/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
              Canister
            </label>
            <select bind:value={newlayercanister}>
              <option value="none">
                Please select layer
              </option>
              {#each mycanisterArray as canister}
                <option value={canister.name}>
                  {canister.name}
                </option>
              {/each}
            </select>
          </div>
          
        </div>
        {#if newlayerid && newlayercanister}
        <div class="w-full lg:w-9/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
              GetCapabilities-Url
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={getCapabilities}
            />
          </div>
        </div>
        <div class="w-full lg:w-3/12 px-4">
          <div class="relative w-full mt-8"><button
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
            type="button"
            on:click={handleGetCapa}
          >
            Get capabilities
          </button></div>
        </div>
        {/if}
      </div>
      {#if parsedGetCapabilities != null}
        <div class="flex flex-wrap">
          <div class="w-full lg:w-6/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >
                Layer
              </label>
              <select bind:value={layer} on:change={layerSelected}>
                <option value="none">
                  Please select layer
                </option>
                {#each parsedGetCapabilities.Contents.Layer as layer}
                  <option value={layer.Identifier}>
                    {layer.Title}
                  </option>
                {/each}
              </select>
            </div>
          </div>
          {#if myLayer != null && myLayer.TileMatrixSetLink != null && myLayer.TileMatrixSetLink.length > 0}
          <div class="w-full lg:w-6/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >
                TileMatrixSet
              </label>
              <select bind:value={tms} on:change={tmsSelected}>
                <option value="">Select TileMatrixSet</option>
                {#each myLayer.TileMatrixSetLink as tilematrixset}
                  <option value={tilematrixset.TileMatrixSet}>
                    {tilematrixset.TileMatrixSet}
                  </option>
                {/each}
              </select>
            </div>
          </div>
          {/if}
        </div>
      {/if}
      {#if myLayer != null}
        <div class="flex flex-wrap">
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >
              Bounding Box WGS 86
              </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bbuppercornerx}
              />
            </div>
          </div>
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >x
              </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bbuppercornery}
              />
            </div>
          </div>
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >x
              </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bblowercornerx}
              />
            </div>
          </div>
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3"><label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >x
            </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bblowercornery}
              />
            </div>
          </div>
        </div>
        <!-- Zoom levels -->
        {#if selectedTMS!= null && selectedTMS.TileMatrix != null}

        <div class="flex flex-wrap">
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >
              Bounding Box in EPSG:3857
              </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bbuppercornerx_tms}
              />
            </div>
          </div>
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >x
              </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bbuppercornery_tms}
              />
            </div>
          </div>
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >x
              </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bblowercornerx_tms}
              />
            </div>
          </div>
          <div class="w-full lg:w-3/12 px-4">
            <div class="relative w-full mb-3"><label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >x
            </label>
              <input
                id="grid-username"
                type="text"
                class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
                bind:value={bblowercornery_tms}
              />
            </div>
          </div>
        </div>

        <div class="flex flex-wrap">
          <div class="w-full lg:w-12/12 px-4">
            <div class="relative w-full mb-3">
              <label
                class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
                for="grid-username"
              >
              Select Zoom levels
 
              <MultiSelect bind:selected options={selectedTMSMultiSelectArray} on:change={zoomLevelsSelected} />
            </div>
          </div>
        </div>

        {#if myTMSSelected}
        <div class="block w-full overflow-x-auto">
          <!-- Projects table -->
          <table class="items-center w-full bg-transparent border-collapse">
            <thead>
              <tr>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Zoom level
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Top left tile
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Bottom right tile
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Total tiles
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color === 'light' ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100' : 'bg-blue-700 text-blue-200 border-blue-600'}"
                ></th>
              </tr>
            </thead>
            <tbody>
              {#each myTMSSelected as myTMSSelectedZoom}
              <tr>
                <th
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-left flex items-center"
                >
                  <span
                    class="ml-3 font-bold btext-blueGray-600'"
                  >
                    {myTMSSelectedZoom.Identifier}
                  </span>
                </th>
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                >
                  {myTMSSelectedZoom.topleftTileRow} / {myTMSSelectedZoom.topleftTileCol}
                </td>
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                >
                  {myTMSSelectedZoom.bottomrightTileRow} / {myTMSSelectedZoom.bottomrightTileCol}
                </td>  
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                >
                  {myTMSSelectedZoom.totalTiles}
                </td>              
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-right"
                >
                <button
                class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
                type="button"
                on:click={handleSeed(myTMSSelectedZoom)}
              >
                Seed
              </button>


                </td>
              </tr>
              {/each}
            </tbody>
          </table>
        </div>
        {/if}

        {/if}
      {/if}
    </form>
