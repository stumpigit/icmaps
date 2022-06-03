<script>
    import { backend ,createActor } from "../../store/backend";
    import { AuthClient } from "@dfinity/auth-client";
    import { onMount } from "svelte";
  import { navigate } from "svelte-routing";  

    /** @type {AuthClient} */
  let client;
  let whoami = $backend.actor.whoami();
  onMount(async () => {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      handleAuth();
    }
  });
  function handleAuth() {
    backend.update(() => ({
      loggedIn: true,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));
    whoami = $backend.actor.whoami();
    navigate("/admin/dashboard", { replace: true });
  }
  export function login() {
    console.log("in login");
    client.login({
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:8000/#authorize`,
      onSuccess: handleAuth,
    });
  }
  export async function logout() {
    await client.logout();
    backend.update(() => ({
      loggedIn: false,
      actor: createActor(),
    }));
    whoami = $backend.actor.whoami();
  }
</script>
  


  

  {#if $backend.loggedIn}
  <button
  class="bg-blue-400 text-white active:bg-blue-500 text-xs font-bold uppercase px-4 py-2 rounded shadow hover:shadow-lg outline-none focus:outline-none lg:mr-1 lg:mb-0 ml-3 mb-3 ease-linear transition-all duration-150"
  type="button" on:click={logout}
>
  <i class="fas fa-user"></i>
   Logout
</button>
{:else}
<button
class="bg-blue-400 text-white active:bg-blue-500 text-xs font-bold uppercase px-4 py-2 rounded shadow hover:shadow-lg outline-none focus:outline-none lg:mr-1 lg:mb-0 ml-3 mb-3 ease-linear transition-all duration-150"
type="button" on:click={login}
>
<i class="fas fa-user"></i>
 Login
</button>
{/if}
