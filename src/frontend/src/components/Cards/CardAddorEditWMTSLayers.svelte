<script>
  import { Map, View } from "ol";
  import { Tile as TileLayer } from "ol/layer";
  import {
    defaults as defaultControls,
    ScaleLine,
    ZoomToExtent,
  } from "ol/control";
  import MultiSelect from "svelte-multiselect";
  import WMTSCapabilities from "ol/format/WMTSCapabilities";
  import ProgressBar from "@okrad/svelte-progressbar";
  import { AuthClient } from "@dfinity/auth-client";
  import  Error  from "components/Modals/Error.svelte";
  import {
    wmtsserver,
    createWMTSActor,
    setCanisterId,
    getWMTSParameters,
    WMTS,
  } from "../../store/wmtsserver";

  import { fromLonLat } from "ol/proj";
  import { epsg3857tms } from "../../store/epsg3857tms";

  const parser = new WMTSCapabilities();
  let color = "light";
  export let mycanisters;
  export let isEdit = false;
  let value;
  export let newlayerid;
  export let newlayertitle;
  export let newlayercanister;
  let error = "";

  let mycanisterArray = [];
  $: {
    mycanisterArray = Array.from(mycanisters, ([name, canisterInfo]) => ({
      name,
      canisterInfo,
    }));
  }
  let client;
  export let tileURL =
    "https://geoserver.geobrowser.ch/geoserver/Aletsch/gwc/service/wmts?REQUEST=GetCapabilities";
  let parsedGetCapabilities;
  let layer;
  let tms;
  export let bbuppercornery;
  export let bbuppercornerx;
  export let bblowercornery;
  export let bblowercornerx;

  let bbuppercornerx_tms;
  let bbuppercornery_tms;
  let bblowercornerx_tms;
  let bblowercornery_tms;

  export let selectedTMS;
  let selectedTMSMultiSelectArray = [];
  let selectedZoomLevels = [];

  $: {
    if (
      parsedGetCapabilities != null &&
      tms != null && tms != "" &&
      bbuppercornerx != null &&
      bbuppercornery != null &&
      bblowercornerx != null &&
      bblowercornery != null
    )
    {
      tmsSelected();
    }
  }

  function handleGetCapa() {
    fetch(tileURL, {
      mode: "cors",
    })
      .then(function (response) {
        return response.text();
      })
      .then(function (text) {
        parsedGetCapabilities = parser.read(text);
        console.log(parsedGetCapabilities);
      });
  }

  function tmsSelected() {
    selectedTMS = parsedGetCapabilities.Contents.TileMatrixSet.find(
      (e) => e.Identifier == tms
    );
    console.log(selectedTMS);
    selectedTMSMultiSelectArray = [];
    selectedTMS.TileMatrix.forEach((tms) => {
      selectedTMSMultiSelectArray.push(tms.Identifier);
    });

    // calculate boundaries
    let bottomleft = fromLonLat([bbuppercornerx, bbuppercornery]);
    let topright = fromLonLat([bblowercornerx, bblowercornery]);

    bbuppercornerx_tms = bottomleft[0];
    bbuppercornery_tms = bottomleft[1];

    bblowercornerx_tms = topright[0];
    bblowercornery_tms = topright[1];
  }

  let zoomLevel = {
    Identifier: Text,
    tms: Object,
  };

  let selected;
  let myTMSSelected = [];
  let selectedStrings = [];
  export let selectedTMSNumbers = [];
  $: {
    if (selectedStrings.length == 0) {
      selectedStrings = [];
      selectedTMSNumbers.forEach((tmsnumber) => {
        selectedStrings.push(tmsnumber.toString());
      });
      if (selectedTMS) zoomLevelsSelected();
    }
  }

  function zoomLevelsSelected() {
    myTMSSelected = [];
    console.log("Selected change");
    console.log(selectedStrings);

    selectedStrings.forEach((zoomLevel) => {
      let myZoomLevelTMS = selectedTMS.TileMatrix.find(
        (e) => e.Identifier == zoomLevel
      );

      let tilematrixtopleftx = myZoomLevelTMS.TopLeftCorner[0];
      let tilematrixtoplefty = myZoomLevelTMS.TopLeftCorner[1];

      let tilewidth = myZoomLevelTMS.TileWidth;
      let div = tilewidth * 0.00028 * myZoomLevelTMS.ScaleDenominator;

      let myZoomLevel = {
        Identifier: myZoomLevelTMS.Identifier,
        tms: myZoomLevelTMS,
        topleftTileCol: Math.round(
          (bbuppercornerx_tms - tilematrixtopleftx) / div
        ),
        bottomrightTileCol: Math.round(
          (bblowercornerx_tms - tilematrixtopleftx) / div
        ),
        topleftTileRow: Math.round(
          (tilematrixtoplefty - bbuppercornery_tms) / div
        ),
        bottomrightTileRow: Math.round(
          (tilematrixtoplefty - bblowercornery_tms) / div
        ),
        totalTiles: 0,
      };
      myZoomLevel.totalTiles =
        (myZoomLevel.topleftTileRow - myZoomLevel.bottomrightTileRow + 1) *
        (myZoomLevel.bottomrightTileCol - myZoomLevel.topleftTileCol + 1);
      myTMSSelected.push(myZoomLevel);
    });
  }

  let myLayer;
  function layerSelected() {
    console.log(layer);
    myLayer = parsedGetCapabilities.Contents.Layer.find(
      (e) => e.Identifier == layer
    );
    console.log("da noch");
    try {
      
      bbuppercornerx = myLayer.WGS84BoundingBox[0];
      bbuppercornery = myLayer.WGS84BoundingBox[1];
      bblowercornerx = myLayer.WGS84BoundingBox[2];
      bblowercornery = myLayer.WGS84BoundingBox[3];
    } catch (e) {
      
    }
  }

  // upload

  export async function save() {
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

      let tilematrixsetcrs = "urn:ogc:def:crs:EPSG:3857";
      let tilematrixset = await $wmtsserver.actor.getTileMatrixSetFromCRS(
        tilematrixsetcrs
      );
      if (tilematrixset.Identifier == "NotFound") {
        // error handling
        console.log("TMS not found");
      }
      let saving = await $wmtsserver.actor.addLayer(
        newlayerid,
        newlayertitle,
        "png",
        tilematrixset.identifier,
        bbuppercornerx + " " + bbuppercornery,
        bblowercornerx + " " + bblowercornery,
        tileURL
      );
    }
  }

  export let progress = 0;
  let progressText = "Start seeding";
  const MAX_CHUNK_SIZE = 1024 * 500; // 500kb
  const encodeArrayBuffer = (file) => Array.from(new Uint8Array(file));

  let isCancel = false;
  let isError = false;

  const processAndUploadChunk = async (
    blob,
    byteStart,
    fileId,
    chunk,
    fileSize
  ) => {
    const blobSlice = blob.slice(
      byteStart,
      Math.min(Number(fileSize), byteStart + MAX_CHUNK_SIZE),
      blob.type
    );

    const bsf = await blobSlice.arrayBuffer();

    return $wmtsserver.actor.putFileChunks(
      fileId,
      BigInt(chunk),
      BigInt(fileSize),
      encodeArrayBuffer(bsf)
    );
  };
  const getFileExtension = (type) => {
    switch (type) {
      case "image/jpeg":
        return { jpeg: null };
      case "image/gif":
        return { gif: null };
      case "image/jpg":
        return { jpg: null };
      case "image/png":
        return { png: null };
      default:
        return null;
    }
  };

  async function fetchImage(
    selectedZoom,
    tilematrixsetidentifier,
    tilematrix,
    tilecol,
    tilerow,
    totalTiles, overwrite=false
  ) {
    let isRunning = true;
    //

    let capaResource = myLayer.ResourceURL.find(
      (x) => x.format === "image/png"
    );
    console.log(capaResource);
    tilematrix;
    let fetchUrl = capaResource.template
      .replace(/http:/i, "https:")
      .replace(/\{tilematrixset\}/i, selectedTMS.Identifier)
      .replace(/\{tilematrix\}/i, tilematrix)
      .replace(/\{tilecol\}/i, tilecol)
      .replace(/\{tilerow\}/i, tilerow)
      .replace(/\{style\}/i, "raster");
    console.log(fetchUrl);
    let file = await fetch(fetchUrl)
      .then(function (response) {
        if (!response.ok) {
          console.log("Error while fetching: ");
          console.log(response);
          isRunning = false;
          return false;
        }
        return response.blob();
      })
      .then(async function (file) {
        const fileInfo = {
          name: Math.random().toString(36).substring(2),
          createdAt: BigInt(Number(Date.now() * 1000)),
          size: BigInt(file.size),
          chunkCount: BigInt(1),
          // @ts-ignore
          extension: getFileExtension("image/png"),
          x: BigInt(tilecol),
          y: BigInt(tilerow),
          z: BigInt(tilematrix),
          layer: newlayerid,
          tilematrixset: tilematrixsetidentifier,
        };
        console.log(fileInfo);
        const fileId = (
          await $wmtsserver.actor.putFileInfo(fileInfo, overwrite)
        )[0];
        current++;

        if (fileId) {
          console.log("Got fileId: " + fileId);
          progress = Math.round(((current / 2) * 100) / totalTiles);
          progressText =
            "Got id for " + tilematrix + "/" + tilecol + "/" + tilerow;
          const blob = file;
          let chunk = 1;
          let x = await processAndUploadChunk(
            blob,
            0,
            fileId,
            chunk,
            file.size
          );
          current++;
          progress = Math.round(((current / 2) * 100) / totalTiles);
          progressText =
            "Saved tile " + tilematrix + "/" + tilecol + "/" + tilerow;
          console.log(
            "Successfully saved tile " +
              tilematrix +
              "/" +
              tilecol +
              "/" +
              tilerow
          );
        } else {
          // File already uploaded, skip
          current++;
          console.log("File already uploaded");
          progress = Math.round(((current / 2) * 100) / totalTiles);
          progressText =
            "File already uploaded: " +
            tilematrix +
            "/" +
            tilecol +
            "/" +
            tilerow;
        }

        isRunning = false;
      })
      .catch(function (error) {
        console.log("Error in processing File: " + error);
        return false;
      });
    while (isRunning) {}
    return true;
  }

  let showModal = false;

  function toggleModal(cancelclicked = false) {
    if (cancelclicked) isCancel = true;
    showModal = !showModal;
  }

  let current = 0;

  async function handleSeed(selectedZoom, overwrite = false) {
    progress = 0;
    progressText = "Starting";
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

      let tilematrixsetcrs = "urn:ogc:def:crs:EPSG:3857";
      let tilematrixset = await $wmtsserver.actor.getTileMatrixSetFromCRS(
        tilematrixsetcrs
      );
      if (tilematrixset.Identifier == "NotFound") {
        // error handling
        console.log("TMS not found");
      }
      console.log(tileURL);

      let saving = await $wmtsserver.actor.addLayer(
        newlayerid,
        newlayertitle,
        "png",
        tilematrixset.identifier,
        bbuppercornerx + " " + bbuppercornery,
        bblowercornerx + " " + bblowercornery,
        tileURL
      );
      let tilerow;
      let tilecol;
      let todos = [];
      current = 0;

      for (
        tilecol = selectedZoom.topleftTileCol;
        tilecol <= selectedZoom.bottomrightTileCol;
        tilecol++
      ) {
        for (
          tilerow = selectedZoom.bottomrightTileRow;
          tilerow <= selectedZoom.topleftTileRow;
          tilerow++
        ) {
          if (!isCancel && !isError)
            todos.push(
              fetchImage(
                selectedZoom,
                tilematrixset.identifier,
                selectedZoom.Identifier,
                tilecol,
                tilerow,
                selectedZoom.totalTiles, overwrite
              )
            );
          //await fetchImage(selectedZoom, tilematrixset.identifier, selectedZoom.Identifier, tilecol, tilerow);
        }
        if (!isCancel && !isError) await Promise.allSettled(todos);
        todos = [];
      }

      if (!isCancel && !isError) await $wmtsserver.actor.updateStatus();
      showModal = false;
      window.location.reload();
    }
    } catch (e) {
      console.log("Error in Fetching: " + e);
      error = e.toString();
      showModal = false;
    }
  }

  async function handleAllSeed(overwrite) {
    progress = 0;
    progressText = "Starting";
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

        let tilematrixsetcrs = "urn:ogc:def:crs:EPSG:3857";
        let tilematrixset = await $wmtsserver.actor.getTileMatrixSetFromCRS(
          tilematrixsetcrs
        );
        if (tilematrixset.Identifier == "NotFound") {
          // error handling
          console.log("TMS not found");
        }

        let saving = await $wmtsserver.actor.addLayer(
          newlayerid,
          newlayertitle,
          "png",
          tilematrixset.identifier,
        bbuppercornerx + " " + bbuppercornery,
        bblowercornerx + " " + bblowercornery,
          tileURL
        );
        let tilerow;
        let tilecol;
        let todos = [];
        current = 0;

        // calculating total tiles
        let totaltiles = 0;
        for (var sz of myTMSSelected) {
          totaltiles += sz.totalTiles;
        }

        for (var selectedZoom of myTMSSelected) {
          for (
            tilecol = selectedZoom.topleftTileCol;
            tilecol <= selectedZoom.bottomrightTileCol;
            tilecol++
          ) {
            for (
              tilerow = selectedZoom.bottomrightTileRow;
              tilerow <= selectedZoom.topleftTileRow;
              tilerow++
            ) {
              if (!isCancel && !isError)
                todos.push(
                  fetchImage(
                    selectedZoom,
                    tilematrixset.identifier,
                    selectedZoom.Identifier,
                    tilecol,
                    tilerow,
                    totaltiles, overwrite
                  )
                );
              //await fetchImage(selectedZoom, tilematrixset.identifier, selectedZoom.Identifier, tilecol, tilerow);
            }
            if (!isCancel && !isError) await Promise.allSettled(todos);
            todos = [];
          }
        }
        if (!isCancel && !isError) {
          await $wmtsserver.actor.updateStatus();
        }
        showModal = false;
        window.location.reload();
      }
    } catch (e) {
      console.log("Error in Fetching: " + e);
      error = e.toString();
      showModal = false;
    }
  }

  function handleAllReseed() {
    handleAllSeed(true);
  }
</script>

{#if showModal}
  <div
    class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex "
  >
    <div class="relative w-auto my-6 mx-auto max-w-sm">
      <!--content-->
      <div
        class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none"
      >
        <!--header-->
        <div
          class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t"
        >
          <h3 class="text-3xl font-semibold">Seeding tiles</h3>
          <button
            class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none"
            on:click={toggleModal}
          >
            <span
              class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none"
            >
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
        <div
          class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b"
        >
          <button
            class="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150"
            type="button"
            on:click={toggleModal}
          >
            Cancel
          </button>
        </div>
      </div>
    </div>
  </div>
  <div class="opacity-25 fixed inset-0 z-40 bg-black" />
{/if}

<form>
  <h6 class="text-blueGray-400 text-sm mt-3 mb-6 font-bold uppercase">
    FROM AN EXISTING WMTS GETCAPABILITIES
  </h6>
  <div class="flex flex-wrap">
    <div class="w-full lg:w-4/12 px-4">
      <div class="relative w-full mb-3">
        <label
          class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
          for="grid-username"
        >
          {isEdit === true ? "Layer identifier" : "New layer identifier"}
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
          {isEdit === true ? "Layer title" : "New layer title"}
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
        <select
          bind:value={newlayercanister}
          class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
        >
          <option value="none"> Please select layer </option>
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
            bind:value={tileURL}
          />
        </div>
      </div>
      <div class="w-full lg:w-3/12 px-4">
        <div class="relative w-full mt-8">
          <button
            class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
            type="button"
            on:click={handleGetCapa}
          >
            Get capabilities
          </button>
        </div>
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
            <option value="none"> Please select layer </option>
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
    <!-- Zoom levels -->
    {#if selectedTMS != null && selectedTMS.TileMatrix != null}
      <div class="flex flex-wrap">
        <div class="w-full lg:w-3/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
              Bounding Box WGS 86 Min Lon
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
              >Min Lat
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
              >Max Lon
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={bblowercornery}
            />
          </div>
        </div>
        <div class="w-full lg:w-3/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
              >Max Lat
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={bblowercornerx}
            />
          </div>
        </div>
      </div>

      <div class="flex flex-wrap">
        <div class="w-full lg:w-3/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
              Bounding Box in EPSG:3857. Min Lon
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
              >Min Lat
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
              >Max Lon
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={bblowercornery_tms}
            />
          </div>
        </div>
        <div class="w-full lg:w-3/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
              >Max Lat
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={bblowercornerx_tms}
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

              <MultiSelect
                bind:selected={selectedStrings}
                options={selectedTMSMultiSelectArray}
                on:change={zoomLevelsSelected}
              />
            </label>
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
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color ===
                  'light'
                    ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100'
                    : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Zoom level
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color ===
                  'light'
                    ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100'
                    : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Top left tile
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color ===
                  'light'
                    ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100'
                    : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Bottom right tile
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color ===
                  'light'
                    ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100'
                    : 'bg-blue-700 text-blue-200 border-blue-600'}"
                >
                  Total tiles
                </th>
                <th
                  class="px-6 align-middle border border-solid py-3 text-xs uppercase border-l-0 border-r-0 whitespace-nowrap font-semibold text-left {color ===
                  'light'
                    ? 'bg-blueGray-50 text-blueGray-500 border-blueGray-100'
                    : 'bg-blue-700 text-blue-200 border-blue-600'}"
                />
              </tr>
            </thead>
            <tbody>
              {#each myTMSSelected as myTMSSelectedZoom}
                <tr>
                  <th
                    class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-left flex items-center"
                  >
                    <span class="ml-3 font-bold btext-blueGray-600'">
                      {myTMSSelectedZoom.Identifier}
                    </span>
                  </th>
                  <td
                    class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                  >
                    {myTMSSelectedZoom.topleftTileCol} / {myTMSSelectedZoom.topleftTileRow}
                  </td>
                  <td
                    class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                  >
                    {myTMSSelectedZoom.bottomrightTileCol} / {myTMSSelectedZoom.bottomrightTileRow}
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
                    <button
                      class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
                      type="button"
                      on:click={handleSeed(myTMSSelectedZoom, true)}
                    >
                      Reseed (Overwrite)
                    </button>
                  </td>
                </tr>
              {/each}
              <tr>
                <th
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-left flex items-center"
                >
                  <span class="ml-3 font-bold btext-blueGray-600'" />
                </th>
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                />
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                />
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4"
                />
                <td
                  class="border-t-0 px-6 align-middle border-l-0 border-r-0 text-xs whitespace-nowrap p-4 text-right"
                >
                  <button
                    class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
                    type="button"
                    on:click={handleAllSeed("Hallo", false)}
                  >
                    Seed All
                  </button>
                  <button
                    class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
                    type="button"
                    on:click={handleAllReseed}
                  >
                    Reseed All
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      {/if}
    {/if}
  {/if}
</form>
