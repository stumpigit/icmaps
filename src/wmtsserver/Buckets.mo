import Types "./Types";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Debug "mo:base/Debug";
import Prim "mo:prim";
import Buffer "mo:base/Buffer";
import Cycles "mo:base/ExperimentalCycles";

shared({caller = owner}) actor class Bucket () = this {

  type FileId = Types.FileId;
  type FileInfo = Types.FileInfo;
  type FileData = Types.FileData;
  type ChunkId = Types.ChunkId;
  type State = Types.State;

  var state = Types.empty();
  let limit = 20_000_000_000_000;
    
  public query func authorize(caller: Principal) : async(Bool) {
      return true;
      /*var isAuthorized : Bool = false;
      if (owner == caller) isAuthorized := true;
      if (Principal.fromActor(this) == caller) isAuthorized := true;
      return isAuthorized;*/
  };

  public shared({caller}) func getSize(): async Nat {
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
  public shared({caller}) func generateRandom(name: Text): async Text {
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
          switch (state.files.get(fileId)) {
              case (?_) { /* error -- ID already taken. */ null }; 
              case null { /* ok, not taken yet. */
                  state.files.put(fileId,
                                      {
                                          fileId = fileId;
                                          cid = Principal.fromActor(this);
                                          name = fi.name;
                                          createdAt = fi.createdAt;
                                          uploadedAt = Time.now();
                                          chunkCount = fi.chunkCount;
                                          size = fi.size ;
                                          extension = fi.extension;
                                          x = fi.x;
                                          y = fi.y;
                                          z = fi.z;
                                          layer = fi.layer;
                                          tilematrixset = fi.tilematrixset;
                                      }
                  );
                  ?fileId
              };
          }
  };

  public shared({caller}) func putFile(fi: FileInfo) : async ?FileId {
    assert (await authorize(caller));
    do ? {
      // append 2 bytes of entropy to the name
      let fileId = await generateRandom(fi.name);
      createFileInfo(fileId, fi)!;
    }
  };

  func chunkId(fileId : FileId, chunkNum : Nat) : ChunkId {
      fileId # (Nat.toText(chunkNum))
  };
  // add chunks 
  // the structure for storing blob chunks is to unse name + chunk num eg: 123a1, 123a2 etc
  public shared({caller}) func putChunks(fileId : FileId, chunkNum : Nat, chunkData : Blob) : async ?() {
    assert (await authorize(caller));
    do ? {
      Debug.print("generated chunk id is " # debug_show(chunkId(fileId, chunkNum)) # "from"  #   debug_show(fileId) # "and " # debug_show(chunkNum)  #"  and chunk size..." # debug_show(Blob.toArray(chunkData).size()) );
      state.chunks.put(chunkId(fileId, chunkNum), chunkData);
    }
  };

  func getFileInfoData(fileId : FileId) : ?FileData {
      do ? {
          let v = state.files.get(fileId)!;
          Debug.print("x is ..." # debug_show(v.x));
 
            {
            fileId = v.fileId;
            cid = v.cid;
            name = v.name;
            size = v.size;
            chunkCount = v.chunkCount;
            extension = v.extension;
            createdAt = v.createdAt;
            uploadedAt = v.uploadedAt;
            x = v.x;
            y = v.y;
            z = v.z;
            layer = v.layer;
            tilematrixset = v.tilematrixset;
          }
      }
  };

  public shared({caller}) func updateFileInfoData(fileId : FileId, newFileData : FileData) {
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

};