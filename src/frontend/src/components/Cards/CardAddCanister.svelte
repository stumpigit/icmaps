<script>
  import { AuthClient } from "@dfinity/auth-client";
  import { navigate } from "svelte-routing";  
  import { backend,createActor } from "../../store/backend";
  import { wmtsserver,createWMTSActor, setCanisterId, getWMTSParameters, WMTS } from "../../store/wmtsserver";
  import  Error  from "components/Modals/Error.svelte";
  
  let canisterId="";
  let isManaged;

  let showModal = false;

  function toggleModal(){
    showModal = !showModal;
  }

  let client;

  let error="";

  async function handleSave() {

    toggleModal();
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      backend.update(() => ({
        loggedIn: true,
        actor: createActor({
          agentOptions: {
            identity: client.getIdentity(),
          },
        }),
      }));
      let whoamivar = await $backend.actor.whoami();

      try {
      await $backend.actor.installWMTSServer("v1", canisterId);
      if (!isManaged) isManaged = false;
      await $backend.actor.insert(whoamivar.toText(), canisterId, isManaged);

      window.location.reload();
      }
      catch (e)
      {
        showModal = false;
        error = e.toString();
        console.log(e);
      }

      
    }

    
  }

</script>

<Error error={error} />
{#if showModal}
<div class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex">
  <div class="relative w-auto my-6 mx-auto max-w-sm">
    <!--content-->
    <div class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none">
      <!--header-->
      <div class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t">
        <h3 class="text-3xl font-semibold">
          Adding new canister
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
          We are uploading the WMTS software to the canister and add it to your canisters
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

<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg bg-blueGray-100 border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6">
    <div class="text-center flex justify-between">
      <h6 class="text-blueGray-700 text-xl font-bold">Add a new canister</h6>
      <button
        class="{canisterId=="" ? 'bg-grey-400 text-black active:bg-grey-400' : 'bg-blue-400 text-white active:bg-blue-500'}  font-bold uppercase text-xs px-4 py-2 rounded shadow hover:shadow-md outline-none focus:outline-none mr-1 ease-linear transition-all duration-150"
        type="button" on:click={handleSave}
      >
        Save
      </button>
    </div>
  </div>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">

    <form>
      <h6 class="text-blueGray-400 text-sm mt-3 mb-6 font-bold uppercase">
        The canister have to exist already and have the backend ({process.env.BACKEND_CANISTER_ID}) as controller. For infos see below. All datas on the canister will be deleted.
      </h6>
      <div class="flex flex-wrap">
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3">
            <label
              class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
              for="grid-username"
            >
             Canister Id:
            </label>
            <input
              id="grid-username"
              type="text"
              class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
              bind:value={canisterId}            />
          </div>
        </div>
        <div class="w-full lg:w-6/12 px-4">
          <div class="relative w-full mb-3 mt-7">
            <label class="inline-flex items-center">
              <input type="checkbox" bind:checked={isManaged} class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring ease-linear transition-all duration-150">
              <span class="block uppercase text-blueGray-600 text-xs font-bold mb-1 ml-3">Managed Canister</span>
            </label>
          </div>
        </div>

        

      </div>
    </form>

  </div>
</div>



