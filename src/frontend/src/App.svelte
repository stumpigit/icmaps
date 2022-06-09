<!-- App.svelte -->
<script>
  import { Router, Route } from "svelte-routing";

  // Admin Layout
  import Admin from "./layouts/Admin.svelte";

  // No Layout Pages
  import Index from "./views/Index.svelte";
  import Samples from "./layouts/Samples.svelte";
  import WASMUploader from "views/admin/WASMUploader.svelte";

  export let url = "";
</script>

<Router url="{url}">
  <!-- admin layout -->
  <Route path="admin/*admin" component="{Admin}" />
  <!-- admin layout -->
  <Route path="samples/*samples" component="{Samples}" />
  <!-- no layout pages -->
  <Route path="/" component="{Index}" />
  <Route path="/WASMUploader" component="{WASMUploader}" />
</Router>
