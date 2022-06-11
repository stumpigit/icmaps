<script>
  // core components
  import UserDropdown from "components/Dropdowns/UserDropdown.svelte";
  export let location;
</script>

<!-- Navbar -->
<nav
  class="absolute top-0 left-0 w-full z-10 bg-transparent md:flex-row md:flex-nowrap md:justify-start flex items-center p-4"
>
  <div
    class="w-full mx-autp items-center flex justify-between md:flex-nowrap flex-wrap md:px-10 px-4"
  >
    <!-- Brand -->
    <a
      class="text-white text-sm uppercase hidden lg:inline-block font-semibold"
      href="#pablo" on:click={(e) => e.preventDefault()}
    >
      Samples
    </a>
    <!-- Form -->
    <form
      class="md:flex hidden flex-row flex-wrap items-center lg:ml-auto mr-3"
    >
      <div class="relative flex w-full flex-wrap items-stretch">
        
      </div>
    </form>
    <!-- User -->
    <ul class="flex-col md:flex-row list-none items-center hidden md:flex" style="height:30px;">

    </ul>
  </div>
</nav>
<!-- End Navbar -->
