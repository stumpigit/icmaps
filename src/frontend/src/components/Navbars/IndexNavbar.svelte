<script>
  import { link } from "svelte-routing";

  // core components
  import Auth from "components/Auth/Auth.svelte";

  const logosmall = "../../assets/img/logo_small.png";

  let navbarOpen = false;

  function setNavbarOpen() {
    navbarOpen = !navbarOpen;
  }
</script>

<nav
  class="top-0 fixed z-50 w-full flex flex-wrap items-center justify-between px-2 py-3 navbar-expand-lg bg-white shadow"
>
  <div
    class="container px-4 mx-auto flex flex-wrap items-center justify-between"
  >
    <div
      class="w-full relative flex justify-between lg:w-auto lg:static lg:block lg:justify-start"
    >
      <a
        use:link
        class="text-blueGray-700 text-sm font-bold leading-relaxed inline-block mr-4 py-2 whitespace-nowrap uppercase"
        href="/"
      >
      <img class="object-cover" src="{logosmall}" alt="icmaps logo">
      </a>
      <button
        class="cursor-pointer text-xl leading-none px-3 py-1 border border-solid border-transparent rounded bg-transparent block lg:hidden outline-none focus:outline-none"
        type="button"
        on:click="{setNavbarOpen}"
      >
        <i class="fas fa-bars"></i>
      </button>
    </div>
    <div
      class="lg:flex flex-grow items-center {navbarOpen ? 'block':'hidden'}"
      id="example-navbar-warning"
    >
      <ul class="flex flex-col lg:flex-row list-none mr-auto">
        
      </ul>
      <ul class="flex flex-col lg:flex-row list-none lg:ml-auto">

        <li class="flex items-center">
          <a
            class="hover:text-blueGray-500 text-blueGray-700 px-3 py-2 flex items-center text-xs uppercase font-bold"
            href="https://discord.gg/PruV4RxD9S"
            target="_blank"
          >
            <i class="text-blueGray-400 fab fa-discord text-lg leading-lg" />
            <span class="lg:hidden inline-block ml-2">Discord</span>
          </a>
        </li>

        <li class="flex items-center">
          <a
            class=""
            href="https://github.com/stumpigit/icmaps"
            target="_blank"
          >
          <button
            class="bg-blue-400 text-white active:bg-blue-500 text-xs font-bold uppercase px-4 py-2 rounded shadow hover:shadow-lg outline-none focus:outline-none lg:mr-1 lg:mb-0 ml-3 mb-3 ease-linear transition-all duration-150"
            type="button"
          >
          
            <i class="fas fa-arrow-alt-circle-down"></i> Github
          </button>
          </a>
        </li>

        <li class="flex items-center">
          <Auth />
        </li>
      </ul>
    </div>
  </div>
</nav>
