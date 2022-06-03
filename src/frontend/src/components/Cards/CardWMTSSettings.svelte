<script>
  import { AuthClient } from "@dfinity/auth-client";
  import { wmtsserver,createWMTSActor, setCanisterId, getWMTSParameters, WMTS } from "../../store/wmtsserver";


  export let mycanister;

  let showModal = false;

  function toggleModal(){
    showModal = !showModal;
  }

  let showModalUpdate = false;

  function toggleModalUpdate(){
    showModalUpdate = !showModalUpdate;
  }

  let client;

  async function handleSave() {
    toggleModal();
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      setCanisterId(mycanister.canisterId);
    wmtsserver.update(() => ({
      loggedIn: true,
      actor: createWMTSActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));

    let saving = await $wmtsserver.actor.setWMTSParameters(mycanister.wmtsInfos);
    toggleModal();
      
    }

    
  }

  async function handleUpdateAllFiles() {
    toggleModalUpdate();
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      setCanisterId(mycanister.canisterId);
    wmtsserver.update(() => ({
      loggedIn: true,
      actor: createWMTSActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));

    await $wmtsserver.actor.updateAllFiles();
    toggleModalUpdate();
      
    }
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
          WMTS Settings saved
        </h3>
        <button class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none" on:click={toggleModal}>
          <span class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none">
            ×
          </span>
        </button>
      </div>
      <!--body-->
      <div class="relative p-6 flex-auto">
        <p class="my-4 text-blueGray-500 text-lg leading-relaxed">
          The settings are saved to the WMTS Canister
        </p>
      </div>
      <!--footer-->
      <div class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b">
        <button class="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150" type="button" on:click={toggleModal}>
          Close
        </button>
      </div>
    </div>
  </div>
</div>
<div class="opacity-25 fixed inset-0 z-40 bg-black"></div>
{/if}


{#if showModalUpdate}
<div class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex">
  <div class="relative w-auto my-6 mx-auto max-w-sm">
    <!--content-->
    <div class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none">
      <!--header-->
      <div class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t">
        <h3 class="text-3xl font-semibold">
          Updating all files
        </h3>
        <button class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none" on:click={toggleModalUpdate}>
          <span class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none">
            ×
          </span>
        </button>
      </div>
      <!--body-->
      <div class="relative p-6 flex-auto">
        <p class="my-4 text-blueGray-500 text-lg leading-relaxed">
          The system is regenerating the layer tree. This may take some minutes (depends on the count of tiles)
        </p>
      </div>
      <!--footer-->
      <div class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b">
        <button class="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150" type="button" on:click={toggleModalUpdate}>
          Close
        </button>
      </div>
    </div>
  </div>
</div>
<div class="opacity-25 fixed inset-0 z-40 bg-black"></div>
{/if}

<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg bg-blueGray-100 border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6">
    <div class="text-center flex justify-between">
      <h6 class="text-blueGray-700 text-xl font-bold">WMTS-Settings for canister {mycanister.canisterId}</h6>
      <button
        class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
        type="button" on:click={handleSave}
      >
        Save
      </button>
    </div>
  </div>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
   {#if mycanister.wmtsInfos!=null}    
    <form>
      <h6 class="text-blueGray-400 text-sm mt-3 mb-6 font-bold uppercase">
        WMTS User Information
      </h6>
      <div class="flex flex-wrap">
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
             Individual Name
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={mycanister.wmtsInfos.individualName}            />
          </div>
        </div>
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-email"
            >
              Email address
            </label>
            <input
              id="grid-email"
              type="email"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={mycanister.wmtsInfos.electronicMailAddress}
            />
          </div>
        </div>
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-first-name"
            >
              Position
            </label>
            <input
              id="grid-first-name"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={mycanister.wmtsInfos.positionName}
            />
          </div>
        </div>
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-last-name"
            >
              City
            </label>
            <input
              id="grid-last-name"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={mycanister.wmtsInfos.city}
            />
          </div>
        </div>
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-last-name"
            >
              Country
            </label>
            <input
              id="grid-last-name"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={mycanister.wmtsInfos.country}
            />
          </div>
        </div>
      </div>
    </form>

    <button
        class="bg-blue-400 text-white active:bg-blue-500 font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
        type="button" on:click={handleUpdateAllFiles}
      >
        Refresh intern Layer-tree
      </button>

  {:else}
  <h6 class="text-blueGray-400 text-sm mt-3 mb-6 font-bold uppercase">
    Please wait, getting WMTS settings from Internet Computer
  </h6>
  {/if}

  </div>
</div>


