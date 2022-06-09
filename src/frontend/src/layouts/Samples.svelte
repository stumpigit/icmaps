<script>
  import { Router, Route } from "svelte-routing";
  import { navigate } from "svelte-routing";  
  
  // components for this layout
  import SamplesNavbar from "components/Navbars/SamplesNavbar.svelte";
  import HeaderStats from "components/Headers/HeaderStats.svelte";
  import SamplesSidebar from "components/Sidebar/SamplesSidebar.svelte";
  import FooterAdmin from "components/Footers/FooterAdmin.svelte";
  // pages for this layout
  import Dashboard from "views/samples/Dashboard.svelte";
  import Earthquake from "views/samples/Earthquake.svelte";
  import Aletsch from "views/samples/Aletsch.svelte";

  export let location;

</script>


<div>
  <SamplesSidebar location={location}/>
  <div class="relative md:ml-64 bg-blueGray-100">
    <SamplesNavbar location="Samples"/>
    <HeaderStats />

    <div class="px-4 md:px-10 mx-auto w-full mt-6 pt-6">
      <Router url="admin">
        <Route path="dashboard" component="{Dashboard}" />
        <Route path="earthquake" component="{Earthquake}" />
        <Route path="aletsch" component="{Aletsch}" />
      </Router>
      <FooterAdmin />
    </div>
  </div>
</div>
