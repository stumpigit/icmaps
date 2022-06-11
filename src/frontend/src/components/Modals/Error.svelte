<script>
    export let error="";

    let showModal = false;

    $: {
        if (error!="") showModal=true;
    }

    function toggleModal() {
        showModal = !showModal;
        if (!showModal) error="";
    }
</script>

{#if showModal}
  <div
    class="overflow-x-hidden overflow-y-auto fixed inset-0 z-50 outline-none focus:outline-none justify-center items-center flex "
  >
    <div class="relative w-auto my-6 mx-auto max-w-sm">
      <!--content-->
      <div
        class="border-0 rounded-lg shadow-lg relative flex flex-col w-full bg-white outline-none focus:outline-none"
      >
        <!--header-->
        <div
          class="flex items-start justify-between p-5 border-b border-solid border-blueGray-200 rounded-t"
        >
          <h3 class="text-3xl font-semibold">Error has occurred</h3>
          <button
            class="p-1 ml-auto bg-transparent border-0 text-black opacity-5 float-right text-3xl leading-none font-semibold outline-none focus:outline-none"
            on:click={toggleModal}
          >
            <span
              class="bg-transparent text-black opacity-5 h-6 w-6 text-2xl block outline-none focus:outline-none"
            >
              ×
            </span>
          </button>
        </div>
        <!--body-->
        <div class="relative p-6 flex-auto">
          <p class="my-4 text-blueGray-500 leading-relaxed">
            {error}
          </p>
        </div>
        <!--footer-->
        <div
          class="flex items-center justify-end p-6 border-t border-solid border-blueGray-200 rounded-b"
        >
          <button
            class="text-red-500 background-transparent font-bold uppercase px-6 py-2 text-sm outline-none focus:outline-none mr-1 mb-1 ease-linear transition-all duration-150"
            type="button"
            on:click={toggleModal}
          >
            OK
          </button>
        </div>
      </div>
    </div>
  </div>
  <div class="opacity-25 fixed inset-0 z-40 bg-black" />
{/if}