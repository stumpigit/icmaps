import { writable } from "svelte/store";
import { idlFactory } from "../../../declarations/wmtsserver/wmtsserver.did.js";
import { Actor, HttpAgent } from "@dfinity/agent";


let canisterid = "";

export function setCanisterId(canister_id) {
  canisterid = canister_id;
}

/**
 * Creates an actor for the WMTSServer canister
 *
 * @param {{agentOptions: import("@dfinity/agent").HttpAgentOptions, actorOptions: import("@dfinity/agent").ActorConfig}} options
 * @returns {import("@dfinity/agent").ActorSubclass<import("../../../declarations/backend/backend.did")._SERVICE>}
 */
export function createWMTSActor(options) {
  if (canisterid=="") return;
  const hostOptions = {
    host:
      process.env.DFX_NETWORK === "ic"
        ? `https://${process.env.WMTSSERVER_CANISTER_ID}.ic0.app`
        : "http://localhost:8000",
  };
  if (!options) {
    options = {
      agentOptions: hostOptions,
    };
  } else if (!options.agentOptions) {
    options.agentOptions = hostOptions;
  } else {
    options.agentOptions.host = hostOptions.host;
  }

  const agent = new HttpAgent({ ...options.agentOptions });
  agent.fetchRootKey();
  // Fetch root key for certificate validation during development
  if (process.env.NODE_ENV !== "production") {
    agent.fetchRootKey().catch((err) => {
      console.warn(
        "Unable to fetch root key. Check to ensure that your local replica is running"
      );
      console.error(err);
    });
  }
  console.log("In Canister-creation with canister " + canisterid);
  // Creates an actor with using the candid interface and the HttpAgent
  return Actor.createActor(idlFactory, {
    agent,
    canisterId: canisterid,
    ...options?.actorOptions,
  });
}

export const wmtsserver = writable({
  loggedIn: false,
  actor: createWMTSActor(),
});