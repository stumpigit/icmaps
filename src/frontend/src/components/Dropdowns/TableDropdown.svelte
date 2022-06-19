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
  }};
</script>

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
