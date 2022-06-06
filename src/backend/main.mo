import Types "./Types";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Map "mo:base/HashMap";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";
import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";
import Iter "mo:base/Iter";

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// main.mo - Backend for ICMaps - WMTS Canister configuration tool                                     //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Christoph Suter                                                                             //
// Licence: MIT                                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

shared({caller = owner}) actor class Backend() = this {
    // Storage for user-canisters
    public type Canister = {
        desc: Principal;
        managed: Bool;
    };

    public type User = Text;

    // Save a Map Users - Canisters. Every user can have one or more canisters with the wmts software on it
    type MyCanistersArray = [Canister];
    stable var canistersArray : [(User, MyCanistersArray)] = [];
    let canisters = Map.HashMap<User, Buffer.Buffer<Canister>>(100, Text.equal, Text.hash);

    // Get the controllers of the current canister. Used from authorize
    public func get_controllers() : async [Principal] {
        let principal = Principal.fromActor(this);
        let status = await IC.canister_status({ canister_id = principal });
        return status.settings.controllers;
    };

    // Is the caller authorized to call the functions? First check owner, than myself and finaly check the controllers
    public func authorize(caller: Principal) : async(Bool) {
        var isAuthorized : Bool = false;
        if (owner == caller) return true;
        if (Principal.fromActor(this) == caller) return true;
        let x = await get_controllers();
        for (i in x.vals()) {
            Debug.print(debug_show(i));
            if (i == caller) return true;
        };
        return isAuthorized;
    };

    // Insert a canister for a specific user
    public shared({caller}) func insert(user : User, canister : Text, isManaged: Bool): async () {
        assert (Principal.toText(caller) == user);
        let newCanister : Canister = { desc = Principal.fromText(canister); managed = isManaged;};
        let mycanisters : ?Buffer.Buffer<Canister> = canisters.get(user);
        let c: Buffer.Buffer<Canister> = switch (mycanisters) {
            case null { Buffer.Buffer<Canister>(10); };
            case (?mycanisters) { mycanisters; };
        };
        // update controller to canister
        await updateCanister(newCanister.desc, Principal.fromText(user));
        
        c.add(newCanister);
        canisters.put(user, c);
    };

    // Get the canisters for a user
    public shared({caller}) func getMyCanisters(id : User) :async [Canister] {
        assert (Principal.toText(caller) == id);
        let mycanisters : ?Buffer.Buffer<Canister> = canisters.get(id);
        let c: Buffer.Buffer<Canister> = switch (mycanisters) {
            case null { Buffer.Buffer<Canister>(10); };
            case (?mycanisters) { mycanisters; };
        };
        c.toArray();
    };

    // Just for some tests
    public shared query (msg) func whoami() : async Principal {
        return msg.caller;
    };

    // Save the HashMap to the stable array
    system func preupgrade()  {
        let buff = Map.HashMap<User, MyCanistersArray>(100, Text.equal, Text.hash);
        for ((user, buffer) in canisters.entries()) {
            let canisterBuff = Buffer.Buffer<Canister>(0);
            for (j : Canister in buffer.vals())
            {
              canisterBuff.add(j);
            };
            let myCans : (User, MyCanistersArray) = (user, canisterBuff.toArray());

            buff.put(myCans);
        };
        canistersArray := Iter.toArray<(User, MyCanistersArray)>(buff.entries());
    };

    // Populate the HashMap from the stable array
    system func postupgrade() {
        for ((user, myCanistersArray) in canistersArray.vals()) {
          let mycans = Buffer.Buffer<Canister>(10);
          for (j in myCanistersArray.vals()) {
            mycans.add(j);
          };
          let myCans = (user, mycans);
          canisters.put(myCans);
        };
    };

    // WASM Installer functions
    // It is possible to uplaod a WASM file to the canister and deploy the binary to the canisters

    type FileId = Types.FileId;
  type FileInfo = Types.FileInfo;
  type FileData = Types.FileData;
  type ChunkId = Types.ChunkId;
  type State = Types.State;

  var state = Types.empty();
  let limit = 20_000_000_000_000;

  public  shared({caller}) func getSize(): async Nat {
        assert (await authorize(caller));
    Debug.print("canister balance: " # Nat.toText(Cycles.balance()));
    Prim.rts_memory_size();
  };
  // consume 1 byte of entrypy
  func getrByte(f : Random.Finite) : ? Nat8 {
    do ? {
      f.byte()!
    };
  };
  // append 2 bytes of entropy to the name
  // https://sdk.dfinity.org/docs/base-libraries/random
  public  shared({caller}) func generateRandom(name: Text): async Text {
        assert (await authorize(caller));
    var n : Text = name;
    let entropy = await Random.blob(); // get initial entropy
    var f = Random.Finite(entropy);
    let count : Nat = 2;
    var i = 1;
    label l loop {
      if (i >= count) break l;
      let b = getrByte(f);
      switch (b) {
        case (?b) { n := n # Nat8.toText(b); i += 1 };
        case null { // not enough entropy
          Debug.print("need more entropy...");
          let entropy = await Random.blob(); // get more entropy
          f := Random.Finite(entropy);
        };
      };
      
    };
    
    n
  };

  func createFileInfo(fileId: Text, fi: FileInfo) : ?FileId {
         state.files.put(fileId,
                                      {
                                          fileId = fileId;
                                          cid = Principal.fromActor(this);
                                          name = fi.name;
                                          createdAt = fi.createdAt;
                                          uploadedAt = Time.now();
                                          chunkCount = fi.chunkCount;
                                          size = fi.size ;
                                      }
                  );
                  ?fileId;
  };

  public  shared({caller}) func putFile(fileId: Text, fi: FileInfo) : async ?FileId {
        assert (await authorize(caller));
    do ? {
      // append 2 bytes of entropy to the name
      createFileInfo(fileId, fi)!;
    }
  };

  func chunkId(fileId : FileId, chunkNum : Nat) : ChunkId {
      fileId # (Nat.toText(chunkNum))
  };
  // add chunks 
  // the structure for storing blob chunks is to unse name + chunk num eg: 123a1, 123a2 etc
  public  shared({caller}) func putChunks(fileId : FileId, chunkNum : Nat, chunkData : Blob) : async ?() {
        assert (await authorize(caller));
    do ? {
      Debug.print("generated chunk id is " # debug_show(chunkId(fileId, chunkNum)) # "from"  #   debug_show(fileId) # "and " # debug_show(chunkNum)  #"  and chunk size..." # debug_show(Blob.toArray(chunkData).size()) );
      state.chunks.put(chunkId(fileId, chunkNum), chunkData);
    }
  };

  func getFileInfoData(fileId : FileId) : ?FileData {
      do ? {
          let v = state.files.get(fileId)!; 
            {
            fileId = v.fileId;
            cid = v.cid;
            name = v.name;
            size = v.size;
            chunkCount = v.chunkCount;
            createdAt = v.createdAt;
            uploadedAt = v.uploadedAt;
          }
      }
  };

  public  shared({caller}) func updateFileInfoData(fileId : FileId, newFileData : FileData) {
        assert (await authorize(caller));
      state.files.put(fileId, newFileData);    
  };

  public query func getFileInfo(fileId : FileId) : async ?FileData {
    do ? {
      getFileInfoData(fileId)!
    }
  };

  public query func getChunks(fileId : FileId, chunkNum: Nat) : async ?Blob {
      state.chunks.get(chunkId(fileId, chunkNum))
  };

  public query func getInfo() : async [FileData] {
    let b = Buffer.Buffer<FileData>(0);
    let _ = do ? {
      for ((f, _) in state.files.entries()) {
        b.add(getFileInfoData(f)!)
      };
    };
    b.toArray()
  };

  public func wallet_receive() : async { accepted: Nat64 } {
    let available = Cycles.available();
    let accepted = Cycles.accept(Nat.min(available, limit));
    { accepted = Nat64.fromNat(accepted) };
  };

  public func wallet_balance() : async Nat {
    return Cycles.balance();
  };


  // IC Functions
  public type canister_id = Principal;
    public type canister_settings = {
        freezing_threshold: ? Nat;
        controllers: ? [Principal];
        memory_allocation: ? Nat;
        compute_allocation: ? Nat;
    };
    public type definite_canister_settings = {
        freezing_threshold: Nat;
        controllers: [Principal];
        memory_allocation: Nat;
        compute_allocation: Nat;
    };
    public type user_id = Principal;
    public type wasm_module = [Nat8];
    public type mode = {#reinstall;#upgrade;#install};
    let IC = actor "aaaaa-aa": actor {
        canister_status: shared {
            canister_id: canister_id
        } -> async {
            status: {
                #stopped;#stopping;#running
            };
            memory_size: Nat;
            cycles: Nat;
            settings: definite_canister_settings;
            module_hash: ? [Nat8];
        };
        create_canister: shared {
            settings: ? canister_settings
        } -> async {
            canister_id: canister_id;
        };
        delete_canister: shared {
            canister_id: canister_id
        } -> async ();
        deposit_cycles: shared {
            canister_id: canister_id
        } -> async ();
        install_code: shared {
            arg: [Nat8];
            wasm_module: wasm_module;
            mode: {
                #reinstall;#upgrade;#install
            };
            canister_id: canister_id;
        } -> async ();
        provisional_create_canister_with_cycles: shared {
            settings: ? canister_settings;
            amount: ? Nat;
        } -> async {
            canister_id: canister_id
        };
        provisional_top_up_canister: shared {
            canister_id: canister_id;
            amount: Nat;
        } -> async ();
        raw_rand: shared() -> async [Nat8];
        start_canister: shared {
            canister_id: canister_id
        } -> async ();
        stop_canister: shared {
            canister_id: canister_id
        } -> async ();
        uninstall_code: shared {
            canister_id: canister_id
        } -> async ();
        update_settings: shared {
            canister_id: Principal;
            settings: canister_settings;
        } -> async ();
    };
    


    public shared({caller}) func installWMTSServer(fileID : Text, canisterId: Text) : async () {
        assert (await authorize(caller));
        let wasmblob : ?Blob = await getChunks(fileID, 1);
        switch (wasmblob) {
                    case null {
                        return;
                    };
                    case ( ? wasmblob) {
                        await (IC.install_code({
                            canister_id = Principal.fromText(canisterId);
                            mode = #install;
                            wasm_module =  Blob.toArray(wasmblob);
                            arg = [];
                        }));
                    };
                };        
    };

    public  shared({caller}) func upgradeWMTSServer(fileID : Text, canisterId: Text) : async () {
        assert (await authorize(caller));
        let wasmblob : ?Blob = await getChunks(fileID, 1);
        switch (wasmblob) {
                    case null {
                        return;
                    };
                    case ( ? wasmblob) {
                        await (IC.install_code({
                            canister_id = Principal.fromText(canisterId);
                            mode = #upgrade;
                            wasm_module =  Blob.toArray(wasmblob);
                            arg = [];
                        }));
                    };
                };        
    };

    func updateCanister(a : Principal, u : Principal): async () {
        Debug.print("container balance before: "
            # Nat.toText(Cycles.balance()));
        // Cycles.add(Cycles.balance()/2);
        let cid = {
            canister_id = a
        };
        Debug.print("IC status..."
            # debug_show(await IC.canister_status(cid)));
        // let cid = await IC.create_canister(  {
        //    settings = ?{controllers = [?(owner)]; compute_allocation = null; memory_allocation = ?(4294967296); freezing_threshold = null; } } );
        await (IC.update_settings({
            canister_id = cid.canister_id;
            settings = {
                controllers = ? [owner, Principal.fromActor(this), a, u];
                compute_allocation = null;
                //  memory_allocation = ?4_294_967_296; // 4GB
                memory_allocation = null; // 4GB
                freezing_threshold = ? 31_540_000
            }
        }));
    };
};