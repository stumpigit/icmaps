<script>
  import { Link } from "svelte-routing";
  import { navigate } from "svelte-routing";  

  // core components
  import IndexNavbar from "components/Navbars/IndexNavbar.svelte";
  import Footer from "components/Footers/Footer.svelte";
  import { AuthClient } from "@dfinity/auth-client";
  import { onMount } from "svelte";
  import { backend,createActor } from "../store/backend";
  import Auth from "components/Auth/Auth.svelte";

  let whoami = $backend.actor.whoami();

  const patternVue = "/assets/img/pattern_svelte.png";
  const componentBtn = "/assets/img/component-btn.png";
  const componentProfileCard = "/assets/img/component-profile-card.png";
  const componentInfoCard = "/assets/img/component-info-card.png";
  const componentInfo2 = "/assets/img/component-info-2.png";
  const componentMenu = "/assets/img/component-menu.png";
  const componentBtnPink = "/assets/img/component-btn-pink.png";
  const documentation = "/assets/img/documentation.png";
  const loginimage = "/assets/img/login.jpg";
  const profile = "/assets/img/profile.jpg";
  const landing = "/assets/img/landing.jpg";
  const background = "/assets/img/icwebmap.png";
  const logo = "../assets/img/logo_icmaps.png";
  let client;

  onMount(async () => {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      handleAuth();
      
      navigate("/admin/dashboard", { replace: true });
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
  function login() {
    console.log("in login");
    client.login({
      identityProvider:
        process.env.DFX_NETWORK === "ic"
          ? "https://identity.ic0.app/#authorize"
          : `http://${process.env.INTERNET_IDENTITY_CANISTER_ID}.localhost:8000/#authorize`,
      onSuccess: handleAuth,
    });
  }


</script>



<IndexNavbar />
<section class="header relative pt-16 items-center flex h-screen max-h-860-px">
  <div class="container mx-auto items-center flex flex-wrap z-10">
    <div class="flex w-full px-4 pl-4">
      <div class="pt-2 sm:pt-0">
        <img class="object-cover pb-4" src="{logo}" alt="icmaps logo">
        <h2 class="font-semibold text-4xl text-blueGray-600 pl-4">
          ICMaps - Decentralized and scalable open source web map server
        </h2>
        <p class="mt-4 text-lg leading-relaxed text-blueGray-500 pl-4">
          ICMaps is a OGC WMTS server running on Internet Computer. You can publish your own maps as a decentralized wmts service and navigate on the map on your own Web3 page, Web2 page oder GIS tools like QGIS.
        </p>
        <div class="flex flex-wrap mt-12 pl-4">
          {#if $backend.loggedIn}
          <a
          href="/admin/dashboard"
          class="get-started text-white font-bold px-6 py-4 rounded outline-none focus:outline-none mr-1 mb-1 bg-blue-400 active:bg-blue-500 uppercase text-sm shadow hover:shadow-lg ease-linear transition-all duration-150"
        >Dashboard</a>
          {:else}
          <a
          href="/dashboard" on:click|preventDefault="{login}" 
          class="get-started text-white font-bold px-6 py-4 rounded outline-none focus:outline-none mr-1 mb-1 bg-blue-400 active:bg-blue-500 uppercase text-sm shadow hover:shadow-lg ease-linear transition-all duration-150"
        >Login</a>
          {/if}
          <a
            href="/samples"
            class="github-star ml-1 text-white font-bold px-6 py-4 rounded outline-none focus:outline-none mr-1 mb-1 bg-blueGray-700 active:bg-blueGray-600 uppercase text-sm shadow hover:shadow-lg ease-linear transition-all duration-150"
          >
            View map examples
          </a>
          
        </div>
      </div>
    </div>
    
  </div>
  <div class="flex w-0 sm:w-4/5 invisible sm:visible" style="
  height: 100%;background-image: url('{background}');
  background-position: center; 
  background-repeat: no-repeat; 
  background-size: contain;">
    
    </div>
  <!--<div class="b-auto right-0 pt-16 sm:w-6/12 -mt-48 sm:mt-0 w-10/12 md:shrink-0 bg-color:black"></div>-->
  <!--<img
    class="absolute top-0 b-auto right-0 pt-16 sm:w-6/12 -mt-48 sm:mt-0 w-10/12 md:shrink-0"
    src="{background}"
    alt="IC Web Map"
  />-->
</section>
<Footer />
