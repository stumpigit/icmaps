<script>
  // library for creating dropdown menu appear on click
  import { createPopper } from "@popperjs/core";
  import { backend ,createActor } from "../../store/backend";
    import { AuthClient } from "@dfinity/auth-client";
  import { navigate } from "svelte-routing";  

  // core components

  const image = "../assets/img/team-1-800x800.jpg";

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

  async function logout() {
    
    let client = await AuthClient.create();
    await client.logout();
    backend.update(() => ({
      loggedIn: false,
      actor: createActor(),
    }));
    
    navigate("/", { replace: true });
  }

  async function showMe() {
    whoami = await $backend.actor.whoami(); 
    alert(whoami);
  }

  let whoami = $backend.actor.whoami();

</script>

<div>
  <a
    class="text-blueGray-500 block"
    href="#pablo"
    bind:this="{btnDropdownRef}"
    on:click="{toggleDropdown}"
  >
    <div class="items-center flex">
      <span
        class="w-12 h-12 text-sm text-white bg-blueGray-200 inline-flex items-center justify-center rounded-full"
      >
        <img
          alt="..."
          class="w-full rounded-full align-middle border-none shadow-lg"
          src="{image}"
        />
      </span>
    </div>
  </a>
  <div
    bind:this="{popoverDropdownRef}"
    class="bg-white text-base z-50 float-left py-2 list-none text-left rounded shadow-lg min-w-48 {dropdownPopoverShow ? 'block':'hidden'}"
  >
    <a
      href="#suti" on:click={(e) => {e.preventDefault(); showMe();} }
      class="text-sm py-2 px-4 font-normal block w-full whitespace-nowrap bg-transparent text-blueGray-700"
    >
      Who am I
    </a>
    <div class="h-0 my-2 border border-solid border-blueGray-100" />
    <a
      href="#suti" on:click={(e) => {e.preventDefault(); logout(); }}
      class="text-sm py-2 px-4 font-normal block w-full whitespace-nowrap bg-transparent text-blueGray-700"
    >
      Logout
    </a>
  </div>
</div>
