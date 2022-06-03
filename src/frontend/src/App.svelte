<!-- App.svelte -->
<script>
  import { Router, Route } from "svelte-routing";

  // Admin Layout
  import Admin from "./layouts/Admin.svelte";
  // Auth Layout
  import Auth from "./layouts/Auth.svelte";

  // No Layout Pages
  import Index from "./views/Index.svelte";
  import Samples from "./views/Samples.svelte";
  import WASMUploader from "views/admin/WASMUploader.svelte";

  export let url = "";
</script>

<Router url="{url}">
  <!-- admin layout -->
  <Route path="admin/*admin" component="{Admin}" />
  <!-- auth layout -->
  <Route path="auth/*auth" component="{Auth}" />
  <!-- no layout pages -->
  <Route path="/" component="{Index}" />
  <Route path="/samples" component="{Samples}" />
  <Route path="/WASMUploader" component="{WASMUploader}" />
</Router>
