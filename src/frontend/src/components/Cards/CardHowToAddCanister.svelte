<script>
  let openTab = 1;

  function toggleTabs(tabNumber) {
    openTab = tabNumber;
  }
</script>

<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg  bg-white border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6 bg-blueGray-400">
    <div class="text-center flex justify-between">
      <h6 class="text-white text-xl font-bold">Canisters</h6>
    </div>
  </div>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
    <div class="flex flex-wrap">
      <div class="w-full pt-3">
        <p
          class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
        >
          With ICMaps, all data remains in your ownership. This means that you
          are the controller of the canister that provides the WMTS server and
          the storage canister that are automatically created. All you have to
          do is provide a canister for ICMaps. By adding ICMaps as a controller
          to the canister and including the canister here, the latest ICMaps
          software is automatically installed on the canister.
        </p>
        <p
          class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
        >
          There are several ways to provide a canister. The simplest option is
          to use the Network Nervous System (NNS). You do not need to install
          any software there. You can also use the SDK and create a canister
          using DFX.
        </p>

        <div class="w-full pt-3">
          <ul class="flex mb-0 list-none flex-wrap pt-3 pb-4 flex-row">
            <li class="-mb-px mr-2 last:mr-0 flex-auto text-center">
              <a
                class="text-xs font-bold uppercase px-5 py-3 shadow-lg rounded block leading-normal {openTab ===
                1
                  ? 'text-white bg-blue-600'
                  : 'text-blue-600 bg-white'}"
                on:click={() => toggleTabs(1)}
              >
                Create canister with NNS
              </a>
            </li>
            <li class="-mb-px mr-2 last:mr-0 flex-auto text-center">
              <a
                class="text-xs font-bold uppercase px-5 py-3 shadow-lg rounded block leading-normal {openTab ===
                2
                  ? 'text-white bg-blue-600'
                  : 'text-blue-600 bg-white'}"
                on:click={() => toggleTabs(2)}
              >
                Create canister with SDK
              </a>
            </li>
          </ul>
          <div
            class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded  bg-white"
          >
            <div class="px-4 py-5 flex-auto">
              <div class="tab-content tab-space">
                <div class={openTab === 1 ? "block" : "hidden"}>
                  <p
                    class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
                  >
                    To create a canister using the Network Nervous System (NNS),
                    you first need some ICP (about 2 ICP are enough to start
                    with). This currency can be purchased on various crypto
                    exchanges (for example Coinbase). Then log in to the NNS at <a
                      class="text-sky-900 hover:text-gray-400 underline decoration-sky-500/30"
                      href="https://nns.ic0.app/v2/">https://nns.ic0.app/v2/</a
                    > using your Internet identity.
                  </p>
                  <p
                    class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
                  >
                    You will see your address in the ICP tab of the NNS. Now
                    transfer the acquired ICP to this address. As soon as they
                    have arrived in NNS, you can create a new canister under
                    Canister. To do this, select "Create or Link Canister" and
                    then "Create new Canister". Select your account and specify
                    how many Terra Cycles should be allocated to the canister
                    (we recommend approx. 4 T Cycles for the start).
                  </p>
                  <div class="flex flex-wrap justify-center">
                    <div class="w-4/12 sm:w-4/12 px-4">
                      <div
                        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700"
                      >
                        <img
                          src="/assets/img/nns1.png"
                          alt="Create new canister in NNS"
                          class="shadow rounded max-w-full h-auto align-middle border-none"
                        />
                      </div>
                    </div>
                    <div class="w-4/12 sm:w-4/12 px-4">
                      <div
                        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700"
                      >
                      <img
                        src="/assets/img/nns2.png"
                        alt="Add new canister"
                        class="shadow rounded max-w-full h-auto align-middle border-none"
                      />
                      </div>
                    </div>
                    <div class="w-4/12 sm:w-4/12 px-4">
                      <div
                        class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700"
                      >
                      <img
                      src="/assets/img/nns4.png"
                      alt="Add cycles"
                      class="shadow rounded max-w-full h-auto align-middle border-none"
                    />
                      </div>
                    </div>
                    
                    <!--<div class="w-4/12 sm:w-4/12 px-4">
                      <img
                        src="/assets/img/nns2.png"
                        alt="Add new canister"
                        class="shadow rounded max-w-full h-auto align-middle border-none"
                      />
                    </div>-->
                    <div class="w-4/12 sm:w-4/12 px-4">
                      
                    </div>
                  </div>
                  <p
                    class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
                  >
                    Once the canister is created, the backend can be added as a
                    controller. This is important so that the backend can write
                    the latest software to the canister and also upload the maps
                    to the canister.
                  </p>
                  <p
                    class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
                  >
                    To do this, select the new canister under Canisters and
                    select "Change Controller". The backend must be entered
                    there with the following entry 57jks-yqaaa-aaaak-aarea-cai.
                    In addition, your own canister must also have access to
                    itself. Therefore, also enter the ID of the canister as
                    controller. Now you are ready to insert your canister ID to
                    ICMaps.
                  </p>
                </div>
                <div class="flex flex-wrap justify-center">
                  <div class="w-4/12 sm:w-4/12 px-4">
                    <div
                      class="max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700"
                    >
                      <img
                        src="/assets/img/nns6.png"
                        alt="Add controller to the canister"
                        class="shadow rounded max-w-full h-auto align-middle border-none"
                      />
                    </div>
                  </div>
                </div>

                <div class={openTab === 2 ? "block" : "hidden"}>
                  <p
                    class="text-lg font-light leading-relaxed mt-6 mb-4 text-lightBlue-800"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
