<script>
  import { Link } from "svelte-routing";

  // core components
  import IndexNavbar from "components/Navbars/IndexNavbar.svelte";
  import Footer from "components/Footers/Footer.svelte";

  const login = "/assets/img/login.jpg";
  const profile = "/assets/img/profile.jpg";
  const landing = "/assets/img/landing.jpg";

</script>

<IndexNavbar />

<section class="mt-48 md:mt-40 pb-40 relative bg-blueGray-100">
  <div
    class="-mt-20 top-0 bottom-auto left-0 right-0 w-full absolute h-20"
    style="transform: translateZ(0);"
  >
    <svg
      class="absolute bottom-0 overflow-hidden"
      xmlns="http://www.w3.org/2000/svg"
      preserveAspectRatio="none"
      version="1.1"
      viewBox="0 0 2560 100"
      x="0"
      y="0"
    >
      <polygon
        class="text-blueGray-100 fill-current"
        points="2560 0 2560 100 0 100"
      ></polygon>
    </svg>
  </div>

  <div class="justify-center text-center flex flex-wrap mt-24">
    <div class="w-full md:w-6/12 px-12 md:px-4">
      <h2 class="font-semibold text-4xl">Beautiful Example Pages</h2>
      <p class="text-lg leading-relaxed mt-4 mb-4 text-blueGray-500">
        Notus Svelte is a completly new product built using our past
        experience in web templates. Take the examples we made for you and start
        playing with them.
      </p>
    </div>
  </div>
</section>

<section class="block relative z-1 bg-blueGray-600">
  <div class="container mx-auto">
    <div class="justify-center flex flex-wrap">
      <div class="w-full lg:w-12/12 px-4 -mt-24">
        <div class="flex flex-wrap">
          <div class="w-full lg:w-4/12 px-4">
            <h5 class="text-xl font-semibold pb-4 text-center">
              Login Page
            </h5>
            <Link to="/auth/login">
              <div
                class="hover:-mt-4 relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded-lg ease-linear transition-all duration-150"
              >
                <img
                  alt="..."
                  class="align-middle border-none max-w-full h-auto rounded-lg"
                  src="{login}"
                />
              </div>
            </Link>
          </div>

          <div class="w-full lg:w-4/12 px-4">
            <h5 class="text-xl font-semibold pb-4 text-center">
              Profile Page
            </h5>
            <Link to="/profile">
              <div
                class="hover:-mt-4 relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded-lg ease-linear transition-all duration-150"
              >
                <img
                  alt="..."
                  class="align-middle border-none max-w-full h-auto rounded-lg"
                  src="{profile}"
                />
              </div>
            </Link>
          </div>

          <div class="w-full lg:w-4/12 px-4">
            <h5 class="text-xl font-semibold pb-4 text-center">
              Landing Page
            </h5>
            <Link to="/landing">
              <div
                class="hover:-mt-4 relative flex flex-col min-w-0 break-words bg-white w-full mb-6 shadow-lg rounded-lg ease-linear transition-all duration-150"
              >
                <img
                  alt="..."
                  class="align-middle border-none max-w-full h-auto rounded-lg"
                  src="{landing}"
                />
              </div>
            </Link>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<Footer />
