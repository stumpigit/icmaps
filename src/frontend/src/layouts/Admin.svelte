<script>
  import { Router, Route } from "svelte-routing";
  import { navigate } from "svelte-routing";  
  
  // components for this layout
  import AdminNavbar from "components/Navbars/AdminNavbar.svelte";
  import Sidebar from "components/Sidebar/Sidebar.svelte";
  import HeaderStats from "components/Headers/HeaderStats.svelte";
  import FooterAdmin from "components/Footers/FooterAdmin.svelte";

  // pages for this layout
  import Dashboard from "views/admin/Dashboard.svelte";
  import Canister from "views/admin/Canister.svelte";
  import WASMUploader from "views/admin/WASMUploader.svelte";
  import AddCanister from "views/admin/AddCanister.svelte";
  import Layers from "views/admin/Layers.svelte";
  import Preview from "views/admin/Preview.svelte";
  import Maps from "views/admin/Maps.svelte";

  import { AuthClient } from "@dfinity/auth-client";
  import { onMount } from "svelte";
  import { backend,createActor } from "../store/backend";

  import { wmtsserver,createWMTSActor, setCanisterId, getWMTSParameters, WMTS } from "../store/wmtsserver";

  let showLoadingModal = true;

function toggleModal(){
  showLoadingModal = !showLoadingModal;
}


  let whoami = $backend.actor.whoami();
  let mycanistersarray = [];
  let client;

  let mycanisters = new Map();
  let canisterInfo = {
    canisterId: String,
    balance: BigInt,
    wmtsInfos: Object,
    layerInfo: Object
  }

  onMount(async () => {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      await handleAuth();
    }
    else {
      navigate("/", { replace: true });
    }
  });
  async function handleAuth() {
    console.log("HandleAuth");
    backend.update(() => ({
      loggedIn: true,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));
    let whoamivar = await $backend.actor.whoami();
    console.log(whoamivar.toText());
    if (mycanisters.size==0)
    {
      mycanistersarray = await $backend.actor.getMyCanisters(whoamivar.toText());
      mycanistersarray.forEach(canister => {
        canisterInfo = {
          canisterId: canister.desc,
          balance: 0,
          layerInfo: []
        };
        mycanisters.set(canister.desc.toText(), canisterInfo);      
      });
      mycanisters = mycanisters;
      await calcCanisterInfos();
    }
  }


  async function calcCanisterInfos() {
    console.log("CalcCanisterInfo");
    console.log(mycanisters);
    for (const canister of mycanisters)
    {
      console.log(canister[1]);
      let mycanisterInfo = canister[1];
      setCanisterId(mycanisterInfo.canisterId);
      wmtsserver.update(() => ({
        loggedIn: true,
        actor: createWMTSActor({
          agentOptions: {
            identity: client.getIdentity(),
          },
        }),
      }));
      let balance =await $wmtsserver.actor.wallet_balance();
      let WMTSInfos = await $wmtsserver.actor.getWMTSParameters(); 
      
      let version = await $wmtsserver.actor.getVersion(); 
      
      mycanisterInfo.balance = BigInt(balance);
      mycanisterInfo.wmtsInfos = WMTSInfos;
      mycanisterInfo.version = version;
      let layerInfo = await $wmtsserver.actor.getLayerInfos();
      mycanisterInfo.layerInfo = layerInfo;
      mycanisters.set(mycanisterInfo.canisterId.toText(), mycanisterInfo);

      console.log("Durch ein canister durch;");
      console.log(canister);
    };
    Dashboard.mycanisters = mycanisters;
    mycanisters = mycanisters;
    Dashboard.mycanisters = mycanisters;
    
    showLoadingModal = false;
  }

  export let location;
  export let admin = "";

</script>
{#if showLoadingModal}
<div class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex">
  <div class="relative w-auto my-6 mx-auto max-w-sm">
    <!--content-->
    <div class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none">
      <!--header-->
      <div class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t">
        <h3 class="text-3xl font-semibold">
          Collecting data...
        </h3>
        <button class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none" on:click={toggleModal}>
          <span class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none">
            ×
          </span>
        </button>
      </div>
      <!--body-->
      <div class="relative p-6 flex-wrap content-center">
        <p class="flex my-4 text-blueGray-500 text-lg leading-relaxed">
          Please wait, we get the data from the Internet Computer...
        </p>
        <div wire:loading class="flex mr-2 mt-2 justify-center">
          <svg class="animate-spin rounded-full bg-transparent border-2 border-transparent border-opacity-50 w-9 h-9" style="border-right-color: white; border-top-color: white;" viewBox="0 0 48 48"></svg>
        </div>
      </div>
      <!--footer-->
      <div class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b">
        <button class="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150" type="button" on:click={toggleModal}>
          OK
        </button>
      </div>
    </div>
  </div>
</div>
<div class="opacity-25 fixed inset-0 z-40 bg-black"></div>
{/if}


<div>
  <Sidebar location={location}/>
  <div class="relative md:ml-64 bg-blueGray-100">
    <AdminNavbar location="Admin interface"/>
    <HeaderStats />
    <div class="px-4 md:px-10 mx-auto w-full mt-6 pt-6">
      <Router url="admin">
        <Route path="dashboard" component="{Dashboard}" mycanisters={mycanisters} />
        <Route path="canister" component="{Canister}" mycanisters={mycanisters} />
        <Route path="canister/:id" component="{Canister}" mycanisters={mycanisters} />
        <Route path="canister/new" component="{AddCanister}" mycanisters={mycanisters} />
        <Route path="layers" component="{Layers}" mycanisters={mycanisters} />
        <Route path="layers/edit/:canisterid/:layeridentifier" component="{Layers}" mycanisters={mycanisters} />
        <Route path="preview/:canisterid/:layeridentifier" component="{Preview}" mycanisters={mycanisters} />
        <Route path="preview" component="{Preview}" mycanisters={mycanisters} />
        <Route path="maps" component="{Maps}" />
        <Route path="WASMUploader" component="{WASMUploader}" />
      </Router>
      <FooterAdmin />
    </div>
  </div>
</div>
