<script>
  import { Router, Route } from "svelte-routing";
  import { navigate } from "svelte-routing";  
  import { AuthClient } from "@dfinity/auth-client";
  import { onMount } from "svelte";
  
  // components for this layout
  import SamplesNavbar from "components/Navbars/SamplesNavbar.svelte";
  import Sidebar from "components/Sidebar/Sidebar.svelte";
  import HeaderStats from "components/Headers/HeaderStats.svelte";
  import SamplesSidebar from "components/Sidebar/SamplesSidebar.svelte";
  import FooterAdmin from "components/Footers/FooterAdmin.svelte";
  // pages for this layout
  import Dashboard from "views/samples/Dashboard.svelte";
  import Earthquake from "views/samples/Earthquake.svelte";
  import Aletsch from "views/samples/Aletsch.svelte";
  import OSM_Sample from "views/samples/OSM_Sample.svelte";
  import Simple from "views/samples/Simple.svelte";
  import QGIS from "views/samples/QGIS.svelte";

  export let location;
  
  let isLoggedIn = false;
  let client;
  onMount(async () => {
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      isLoggedIn = true;
    }
    else {
      isLoggedIn = false;
    }
  });

</script>


<div>
  {#if (isLoggedIn)}
  <Sidebar location={location}/>
  {:else}
  <SamplesSidebar location={location}/>
  {/if}
  <div class="relative md:ml-64 bg-blueGray-100">

    <SamplesNavbar location="Samples"/>

    <HeaderStats />

    <div class="px-4 md:px-10 mx-auto w-full mt-6 pt-6">
      <Router url="admin">
        <Route path="dashboard" component="{Dashboard}" />
        <Route path="earthquake" component="{Earthquake}" />
        <Route path="aletsch" component="{Aletsch}" />
        <Route path="osm" component="{OSM_Sample}" />
        <Route path="simple" component="{Simple}" />
        <Route path="qgis" component="{QGIS}" />
      </Router>
      <FooterAdmin />
    </div>
  </div>
</div>
