<script>
  // library for creating dropdown menu appear on click
  import { createPopper } from "@popperjs/core";
  import { link } from "svelte-routing";
  import { AuthClient } from "@dfinity/auth-client";
  import { wmtsserver, createWMTSActor, setCanisterId } from "../../store/wmtsserver";

  // core components

  export let canisterid;
  export let layeridentifier;

  let dropdownPopoverShow = false;

  let btnDropdownRef;
  let popoverDropdownRef;

  const toggleDropdown = (event) => {
    event.preventDefault();
    if (dropdownPopoverShow) {
      dropdownPopoverShow = false;
    } else {
      dropdownPopoverShow = true;
      createPopper(btnDropdownRef, popoverDropdownRef, {
        placement: "bottom-start",
      });
    }
  };

  let client;
  
  async function deleteLayer(canisterid, layeridentifier) {
    toggleDeleteModal();
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      setCanisterId(canisterid);
    wmtsserver.update(() => ({
      loggedIn: true,
      actor: createWMTSActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));
    let deleting = await $wmtsserver.actor.removeLayer(layeridentifier);
    toggleDeleteModal();
    
    window.location.reload();
  }};


  let showDeleteModal = false;

function toggleDeleteModal(){
  showDeleteModal = !showDeleteModal;
}

</script>

{#if showDeleteModal}
<div class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex">
  <div class="relative w-auto my-6 mx-auto max-w-sm">
    <!--content-->
    <div class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none">
      <!--header-->
      <div class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t">
        <h3 class="text-3xl font-semibold">
          Deleting layer
        </h3>
        <button class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none" on:click={toggleDeleteModal}>
          <span class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none">
            ×
          </span>
        </button>
      </div>
      <!--body-->
      <div class="relative p-6 flex-auto">
        <p class="my-4 text-blueGray-500 text-lg leading-relaxed">
          Please wait, we are deleting the layer
        </p>
        <div wire:loading class="flex mr-2 mt-2 justify-center">
          <svg class="animate-spin rounded-full bg-transparent border-2 border-transparent border-opacity-50 w-9 h-9" style="border-right-color: white; border-top-color: white;" viewBox="0 0 48 48"></svg>
        </div>
      </div>
      <!--footer-->
      <div class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b">
        
      </div>
    </div>
  </div>
</div>
<div class="opacity-25 fixed inset-0 z-40 bg-black"></div>
{/if}
<div>
  <a
    class="text-blueGray-500 py-1 px-3"
    href="#pablo"
    bind:this="{btnDropdownRef}"
    on:click="{toggleDropdown}"
  >
    <i class="fas fa-ellipsis-v"></i>
  </a>
  <div
    bind:this="{popoverDropdownRef}"
    class="bg-white text-base z-50 float-left py-2 list-none text-left rounded shadow-lg min-w-48 {dropdownPopoverShow ? 'block':'hidden'}"
  >
    <a
      href="/admin/layers/edit/{canisterid}/{layeridentifier}" use:link
      class="text-sm py-2 px-4 font-normal block w-full whitespace-nowrap bg-transparent text-blueGray-700"
    >
      Edit
    </a>
    <a
    href="/admin/preview/{canisterid}/{layeridentifier}" use:link
      class="text-sm py-2 px-4 font-normal block w-full whitespace-nowrap bg-transparent text-blueGray-700"
    >
      Preview
    </a>
    <a
      href="#" on:click={(e) => deleteLayer(canisterid, layeridentifier)}
      class="text-sm py-2 px-4 font-normal block w-full whitespace-nowrap bg-transparent text-blueGray-700"
    >
      Delete
    </a>
  </div>
</div>
