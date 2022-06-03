import { AuthClient } from "@dfinity/auth-client";
import { backend, createActor } from "./backend"

export const auth = {
 whoami : async function () { return "HallO";},
 loggedIn: function() {return $backend.logedIn; },
 handleAuth: function() {
    backend.update(() => ({
      loggedIn: true,
      actor: createActor({
        agentOptions: {
          identity: client.getIdentity(),
        },
      }),
    }));
    whoami = $backend.actor.whoami();
  },
  login: function() {
    client.login({
        identityProvider:
          "https://identity.ic0.app/#authorize",
        onSuccess: handleAuth,
      });
  },
  logout: async function() {
    await client.logout();
    backend.update(() => ({
      loggedIn: false,
      actor: createActor(),
    }));
    whoami = $backend.actor.whoami();
  },
  onMount: async function() {
    console.log("4");
    client = await AuthClient.create();
    if (await client.isAuthenticated()) {
      handleAuth();
    }
  }
    
}