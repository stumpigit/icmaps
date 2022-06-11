import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Char "mo:base/Char";
import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Option "mo:base/Option";
import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import TrieMap "mo:base/TrieMap";

import Container "Container";
import Types "Types";
import WMTSGetCapabilitiesResponse "WMTSGetCapabilities";


/////////////////////////////////////////////////////////////////////////////////////////////////////////
// WMTSServer.mo - OGC Compliant WMTS Server implementation for Internet Computer                      //
/////////////////////////////////////////////////////////////////////////////////////////////////////////
// Author: Christoph Suter                                                                             //
// Licence: MIT                                                                                        //
/////////////////////////////////////////////////////////////////////////////////////////////////////////

shared({caller = owner}) actor class WMTSServer() = this {

    let version = "0.1.0";

    type Service = Types.Service;
    type FileId = Types.FileId;
    type FileInfo = Types.FileInfo;
    type FileData = Types.FileData;
    type State = Types.State;
    type StreamingCallbackToken = Types.StreamingCallbackToken;
    type StreamingCallbackHttpResponse = Types.StreamingCallbackHttpResponse;
    type HttpResponse = Types.HttpResponse;
    type StreamingStrategy = Types.StreamingStrategy;
    type WMTSTile = Types.WMTSTile;
    type HttpRequest = Types.HttpRequest;
    type WMTS = Types.WMTS;
    type WGS84BoundingBox = Types.WGS84BoundingBox;
    type Layer = Types.Layer;
    type Map <X, Y> = Types.Map <X, Y> ;
    type LayerInfo = Types.LayerInfo;
    type TileMatrixSet = Types.TileMatrixSet;
    type CanisterCycleInfo = Types.CanisterCycleInfo;

    type Container = Container.Container;

    var myContainer : [var ? Container] = Array.init(1,null);
    //stable var myContainerPrincipal : ? Principal = ? Principal.fromText("vrmsk-7yaaa-aaaak-aaqtq-cai");
    stable var myContainerPrincipal : ? Principal = null;
    var layers: Types.Layers = HashMap.HashMap(5, Text.equal, Text.hash);
    stable var tilematrixsets : [var ? TileMatrixSet] = Array.init(10, null);

    stable var layersInfos : [LayerInfo] = [];

    private let cycleShare = 2_000_000_000_000;
    private stable var wmtsParameters: Types.WMTS = {
        city = "Zimmerwald";
        country = "Switzerland";
        electronicMailAddress = "info@icmaps.org";
        individualName = "Christoph Suter";
        positionName = "Head of Geoinformatics";
    };
    
    let wmtsresponse = WMTSGetCapabilitiesResponse;

    // The Container-Actor is acting as a self running container. We save the reference on myContainer but also as stable var as Principal in myContainerPrincipal
    // After an update we could regenerate the connection to the container thanks to the stable var.
    private func getOrSetContainer() : async (Container) {
        switch (myContainerPrincipal)
        {
            case null { 
                // Not yet an Container created, so let's do it
                Cycles.add(cycleShare);
                let myContainerActor = await Container.Container();
                let _ = await updateCanister(myContainerActor); 
                Debug.print("Created new Container with id " # Principal.toText(Principal.fromActor(myContainerActor)));
                myContainerPrincipal := ? Principal.fromActor(myContainerActor);
                myContainer := Array.init(1,? myContainerActor);
                await updateAllFiles();
                return myContainerActor;
            };
            case (? myContainerPrincipal) {
                let myc = myContainer[0];
                switch (myc) {
                    case null {
                        // not yet in the container-list (after a update of the canister). Lets create the actor from principal
                        let existing = actor(Principal.toText(myContainerPrincipal)): Container;
                        let _ = await updateCanister(existing); 
                        myContainer := Array.init(1,? existing);
                        return existing;
                    };
                    case (? myc) {
                        return myc;
                    };
                };
                
            };
        };       
    }; 

    public shared({caller}) func getCanisterCycleInfo(): async ([CanisterCycleInfo]) {
        //assert (await authorize(caller));
        let buf = Buffer.Buffer<CanisterCycleInfo>(0);
        let c = await getOrSetContainer();
        let a = await c.getCanisterCycleInfo();
        for (i in a.vals()) {
            buf.add(i);
        };
        let available = await c.wallet_balance();
        let cci : CanisterCycleInfo = {
            canisterType = #container;
            canisterId = Principal.toText(Principal.fromActor(c));
            cycles = available;
        };
        buf.add(cci);
        buf.toArray();
    };


    public shared({caller}) func putFileChunks(fileId: FileId, chunkNum: Nat, fileSize: Nat, chunkData: Blob): async () {
        assert (await authorize(caller));
        let c = await getOrSetContainer();
        let fd = await c.putFileChunks(fileId, chunkNum, fileSize, chunkData);
        await updateWMSLayers(fd);
    };

    // save file info 
    public shared({caller}) func putFileInfo(fi: FileInfo, overwrite: Bool): async ?FileId {
        assert (await authorize(caller));
        if (overwrite==false) {
            let wmts_call: WMTSTile = {
                        version = "1.0.0";
                        layer = fi.layer;
                        style = "default";
                        format = "jpeg";
                        tileMatrixSet = fi.tilematrixset;
                        srs = fi.tilematrixset;
                        tileMatrix = fi.z;
                        tileRow = fi.y;
                        tileCol = fi.x;
                    };
            Debug.print("Searching for existing file");
            let existingFD = await getWMTSFile(wmts_call);
            Debug.print("Found: " # debug_show(wmts_call) # " " # debug_show(existingFD));
            switch (existingFD) {
                case null {};
                case (? existingFD) return null;
            };
        };
        let c = await getOrSetContainer();
        await c.putFileInfo(fi);
    };

    public shared({caller}) func updateStatus(): async () {
        assert (await authorize(caller));
        let c = await getOrSetContainer();
        await c.updateStatus();
    };

    public func wallet_receive(): async () {
        ignore Cycles.accept(Cycles.available());
    };
    public func wallet_balance(): async Nat {
        Cycles.balance();
    };

    public func get_controllers() : async [Principal] {
        let principal = Principal.fromActor(this);
        let status = await IC.canister_status({ canister_id = principal });
        return status.settings.controllers;
    };

    public func authorize(caller: Principal) : async(Bool) {
        Debug.print("Caller:");
        Debug.print(debug_show(caller));
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

    // Part for serving the image directly by http_request GET 

    
    public shared({caller}) func updateWMSLayers(fd: ? FileData): async () {
        assert (await authorize(caller));
        Debug.print(debug_show(fd));
        let fdNN: FileData =
            switch (fd) {
                case null
                return;
                case ( ? fd) fd;
            };
        let mylayer = layers.get(fdNN.layer);
        let myLayerNN: Layer =
            switch mylayer {
                case null {
                    let wGS84BoundingBox: WGS84BoundingBox = {
                        lowerCorner = "1";
                        upperCorner = "2";
                    };
                    let tilematrixes: Types.TileMatrixes = HashMap.HashMap(10, Nat.equal, Hash.hash);
                    let newLayerInfo: LayerInfo = {
                        identifier = fdNN.layer;
                        title = fdNN.layer;
                        wGS84BoundingBox = wGS84BoundingBox;
                        tilematrixset = await getTileMatrixSet("3857");
                        format = "png";
                        providedTilematrixSets = [];
                        url = "";
                    };
                    let newLayer: Layer = {
                        tilematrixes = tilematrixes;
                        layerInfo = newLayerInfo;
                    };
                    layers.put(fdNN.layer, newLayer);
                    Debug.print("Neuer Layer "
                        # Nat.toText(layers.size()));
                    newLayer;
                };
                case ( ? mylayer) {
                    mylayer
                }
            };
        let tilerow = myLayerNN.tilematrixes.get(fdNN.z);
        let tilerowNN: Types.TileRows =
            switch tilerow {
                case null {
                    let tilerow: Types.TileRows = HashMap.HashMap(100, Nat.equal, Hash.hash);
                    myLayerNN.tilematrixes.put(fdNN.z, tilerow);
                    tilerow;
                };
                case ( ? tilerow) tilerow;
            };
        let tilecol = tilerowNN.get(fdNN.y);
        let tilecolNN: Types.TileCols =
            switch tilecol {
                case null {
                    let tilecol: Types.TileCols = HashMap.HashMap(100, Nat.equal, Hash.hash);
                    tilerowNN.put(fdNN.y, tilecol);
                    tilecol;
                };
                case ( ? tilecol) tilecol;
            };
        let format = tilecolNN.get(fdNN.x);
        let formatNN: Types.Formats =
            switch format {
                case null {
                    let format: Types.Formats = HashMap.HashMap(1, Text.equal, Text.hash);
                    tilecolNN.put(fdNN.x, format);
                    format;
                };
                case ( ? format) format;
            };
        let myfd = formatNN.get("png");
        switch myfd {
            case null {
                formatNN.put("png", fdNN);
            };
            case _ {
                formatNN.put("png", fdNN);
            }
        };
    };
    
    public shared({caller}) func updateAllFiles(): async () {
        //Debug.print(debug_show(caller));
        //Debug.print(debug_show(owner));
        //assert (await authorize(caller));
        let tm = await getTileMatrixSet("3857");
        Debug.print("TMS: " # tm.identifier);
        if (tm.identifier=="NotFound")
         {
                Debug.print("Generation first Tileset");
                tilematrixsets := Array.init(10, ?wmtsresponse.getStandardTileMatrixSet());
            };
        let container : Container = await getOrSetContainer();
        let allFiles = await container.getAllFiles();
        Debug.print(debug_show(allFiles));
        for (i in allFiles.vals()) {
            await updateWMSLayers( ? i);
        };
    };

    
    
    public query func getWMTSFile(wmts: WMTSTile): async ?FileData {
        let mylayer = layers.get(wmts.layer);
        let myLayerNN: Layer =
            switch mylayer {
                case null {
                    return null;
                };
                case ( ? mylayer) {
                    mylayer
                }
            };
        Debug.print("Found layer: "
            # myLayerNN.layerInfo.identifier);
        let tilerow = myLayerNN.tilematrixes.get(wmts.tileMatrix);
        let tilerowNN: Types.TileRows =
            switch tilerow {
                case null {
                    return null;
                };
                case ( ? tilerow) tilerow;
            };
        Debug.print("Found tileMatrix "
            # Nat.toText(wmts.tileMatrix));
        let hmm: ? Nat = tilerowNN.keys().next();
        let hmmNN: Nat =
            switch hmm {
                case null {
                    0
                };
                case ( ? hmm) hmm
            };
        Debug.print(Nat.toText(hmmNN));
        let tilecol = tilerowNN.get(wmts.tileRow);
        let tilecolNN: Types.TileCols =
            switch tilecol {
                case null {
                    return null;
                };
                case ( ? tilecol) tilecol;
            };
        Debug.print("Found tileRow "
            # Nat.toText(wmts.tileRow));
        let format = tilecolNN.get(wmts.tileCol);
        let formatNN: Types.Formats =
            switch format {
                case null {
                    return null;
                };
                case ( ? format) format;
            };
        Debug.print("Found tileCol "
            # Nat.toText(wmts.tileCol));
        let myfd = formatNN.get("png");
        switch myfd {
            case null {
                return null;
            };
            case _ {
                Debug.print("Found FD ");
                return myfd;
            }
        };
    };

    
    system func preupgrade()  {
        let buff = Buffer.Buffer <LayerInfo> (0);
        for (i in layers.vals()) {
            buff.add(i.layerInfo);
        };
        layersInfos := buff.toArray();
    };

    system func postupgrade() {
        for (i in layersInfos.vals()) {
            let tilematrixes: Types.TileMatrixes = HashMap.HashMap(10, Nat.equal, Hash.hash);
            let newLayer: Layer = {
                tilematrixes = tilematrixes;
                layerInfo = i;
            };
            layers.put(i.identifier, newLayer);
        };
    };
    
    public query func getLayerInfos(): async [LayerInfo] {
        let buff = Buffer.Buffer <LayerInfo> (0);
        for (i in layers.vals()) {
            // recalculate the proved tilematrixsets
            let tilematrixbuff = Buffer.Buffer<Nat>(0);
            for (tms in i.tilematrixes.keys()) {
                tilematrixbuff.add(tms);
            };
            let li : LayerInfo = {
                    identifier = i.layerInfo.identifier;
                    title = i.layerInfo.title;
                    wGS84BoundingBox = i.layerInfo.wGS84BoundingBox;
                    tilematrixset = i.layerInfo.tilematrixset;
                    format = i.layerInfo.format;
                    providedTilematrixSets = tilematrixbuff.toArray();
                    url = i.layerInfo.url;
            };

            buff.add(li);
        };
        buff.toArray();
    };

    public func getTileMatrixSet(identifier : Text): async (TileMatrixSet) {
        for (i in tilematrixsets.vals()) {
            switch (i) {
                case null {};
                case (? i) {
                    if (i.identifier == identifier) return i;
                };
            };
        };
        return let undefinedTMS : TileMatrixSet = {
            identifier = "NotFound";
            supportedCRS = "";
            xml = "";
        };
    };

    public func getTileMatrixSetFromCRS(supportedCRS : Text): async (TileMatrixSet) {
        for (i in tilematrixsets.vals()) {
            switch (i) {
                case null {};
                case (? i) {
                    if (i.supportedCRS == supportedCRS) return i;
                };
            };
        };
        return let undefinedTMS : TileMatrixSet = {
            identifier = "NotFound";
            supportedCRS = "";
            xml = "";
        };
    };

    public shared({caller}) func addTileMatrixSet(tms : TileMatrixSet): async () {
        assert (await authorize(caller));
        let tileMatrixSetsBuffer : Buffer.Buffer<?TileMatrixSet> = Buffer.Buffer<?TileMatrixSet>(tilematrixsets.size());
        for (i in tilematrixsets.vals()) {
            tileMatrixSetsBuffer.add(i);
        };
        tileMatrixSetsBuffer.add(?tms);
        tilematrixsets := tileMatrixSetsBuffer.toVarArray();
    };
    
    public shared({caller}) func removeLayer(layerName: Text): () {
        assert (await authorize(caller));
        let isexistinglayer = layers.get(layerName);
        switch (isexistinglayer)
        {
            case null {
                return;
            };
            case (? isexistinglayer) {
                let container : Container = await getOrSetContainer();
                for (tilematrix in isexistinglayer.tilematrixes.vals()) 
                {
                    for (tilerow in tilematrix.vals())
                    {
                        for (tilecol in tilerow.vals())
                        {
                            for (format in tilecol.vals())
                            {
                                Debug.print(debug_show(format));
                                let ok = await container.removeFileInfo(format.fileId, format.cid);

                            };
                        };
                    };
                };
                layers.delete(layerName);
            };
        };
        return;
    };

    public shared({caller}) func addLayer(layerName: Text, layerTitle: Text, format: Text, tilematrix: Text, upperCorner: Text, lowerCorner: Text, url: Text): () {
        assert (await authorize(caller));
        let tilematrixes: Types.TileMatrixes = HashMap.HashMap(10, Nat.equal, Hash.hash);
        let wGS84BoundingBox: WGS84BoundingBox = {
            lowerCorner = lowerCorner;
            upperCorner = upperCorner;
        };
        let newLayerInfo: LayerInfo = {
            identifier = layerName;
            title = layerTitle;
            wGS84BoundingBox = wGS84BoundingBox;
            format = format;
            tilematrixset = await getTileMatrixSet(tilematrix);
            providedTilematrixSets = [];
            url = url;
        };
        Debug.print("new layerinfo: " # debug_show(newLayerInfo));
        let alreadyexistinglayer = layers.get(layerName);
        switch (alreadyexistinglayer)
        {
            case null {
                let newLayer: Layer = {
                    tilematrixes = tilematrixes;
                    layerInfo = newLayerInfo;
                };
                layers.put(layerName, newLayer);};
            case (? alreadyexistinglayer) {
                let newLayer: Layer = {
                    tilematrixes = alreadyexistinglayer.tilematrixes;
                    layerInfo = newLayerInfo;
                };
                layers.put(layerName, newLayer);
            };
        };
    };
    

    public query func getWMTSParameters(): async Types.WMTS {
        wmtsParameters;
    };
    public shared({caller}) func setWMTSParameters(parameters: WMTS): () {
        assert (await authorize(caller));
        wmtsParameters := parameters;
    };
    public func idQuick(): async Principal {
        return Principal.fromActor(this);
    };
    public query func getVersion(): async Text {
        version;
    };
    




    public query func http_request(req: Types.HttpRequest): async (HttpResponse) {
        //let path = removeQuery(req.url);
        return {
            body = Text.encodeUtf8("Should forward to http_request_update");
            headers = [];
            status_code = 200;
            streaming_strategy = null;
            upgrade = true;
        };
    };

    // The main http request parsing method. Possible calls are
    // http://canisterid.localhost:8000/wmts?request=getcapabilities
    //
    public func http_request_update(req: HttpRequest): async HttpResponse {
        let url: Text = Text.map(req.url, Prim.charToLower);
        if (req.method == "GET") {
            if (Text.startsWith(url, #text "/wmts?") == true) {
                // parse query
                let querys: Text = queryString(url);
                let queryHashMap = queryMap(url);
                let queryHashMapOrig = queryMap(req.url);
                // GetCapabilities
                if (Text.contains(url, #text "request=getcapabilities") == true) {
                    let myId: Principal = await idQuick();
                    return {
                        body = Text.encodeUtf8(wmtsresponse.getCapabilities(myId, wmtsParameters, layers, tilematrixsets));
                        headers = [("Access-Control-Allow-Origin", "*")];
                        status_code = 200;
                        streaming_strategy = null;
                        upgrade = true;
                    };
                };
                // GetTile
                if (Text.contains(url, #text "request=gettile") == true) {
                    var errormsg: Text = "";
                    let tilematrixset = getParameterValue("tilematrixset", queryHashMap);
                    if (tilematrixset == "") errormsg := "No tilematrixset defined";
                    let version = getParameterValue("version", queryHashMap);
                    if (version == "") errormsg := "No version defined";
                    let style = getParameterValue("style", queryHashMap);
                    if (style == "") errormsg := "No style defined";
                    let format = getParameterValue("format", queryHashMap);
                    if (format == "") errormsg := "No format defined";
                    let tilematrix = getParameterValue("tilematrix", queryHashMap);
                    if (tilematrix == "") errormsg := "No tilematrix defined";
                    let tilecol = getParameterValue("tilecol", queryHashMap);
                    if (tilecol == "") errormsg := "No tilecol defined";
                    let tilerow = getParameterValue("tilerow", queryHashMap);
                    if (tilerow == "") errormsg := "No tilerow defined";
                    let layer = getParameterValue("layer", queryHashMapOrig);
                    if (layer == "") errormsg := "No layer defined";
                    let wmts_call: WMTSTile = {
                        version = version;
                        layer = layer;
                        style = style;
                        format = "jpeg";
                        tileMatrixSet = tilematrixset;
                        srs = tilematrixset;
                        tileMatrix = textToNat(tilematrix);
                        tileRow = textToNat(tilerow);
                        tileCol = textToNat(tilecol);
                    };
                    let toServeFile = await getWMTSFile(wmts_call);


                    let toServeFileNN: FileData =
                        switch (toServeFile) {
                            case null
                            return {
                                status_code = 404;
                                headers = [("content-type", "text/plain"),("Access-Control-Allow-Origin", "*")];
                                body = "404 Tile Not found \n/ .. \n";
                                upgrade = false;
                                streaming_strategy = null;
                            };
                            case ( ? FileData) FileData;
                        };
                    let container : Container = await getOrSetContainer();
                    let b = await container.getFileChunk(toServeFileNN.fileId, 1, toServeFileNN.cid);
                    let myBlob: Blob =
                        switch (b) {
                            case null {
                                Blob.fromArray([])
                            };
                            case ( ? Blob) Blob;
                        };
                    return {
                        status_code = 200;
                        headers = [("content-type", "image/jpeg"),("Access-Control-Allow-Origin", "*")];
                        body = myBlob;
                        upgrade = false;
                        streaming_strategy = null;
                    };
                }
            }
        };
        // try to parse the req.url as a GET Tile Request
        let wmts_call = label exit: ? (WMTSTile) {
            let splitted = Text.split(req.url, #char '/');
            let array = Iter.toArray <Text> (splitted);
            if (array.size() != 9) {
                break exit(null)
            };
            // get col and format from last
            let lastSplittet = Text.split(array[8], #char '.');
            let lastSplittetArray = Iter.toArray <Text> (lastSplittet);
            if (lastSplittetArray.size() != 2) {
                break exit(null)
            };
            let WMTSTile = {
                version = array[1];
                layer = array[2];
                style = array[3];
                format = lastSplittetArray[1];
                tileMatrixSet = array[4];
                srs = array[5];
                tileMatrix = textToNat(array[6]);
                tileRow = textToNat(array[7]);
                tileCol = textToNat(lastSplittetArray[0]);
            }; ? (WMTSTile)
        };
        let wmts_callNN: WMTSTile =
            switch (wmts_call) {
                case null
                return {
                    status_code = 404;
                    headers = [("content-type", "text/plain"),("Access-Control-Allow-Origin", "*")];
                    body = "404 Not found.\n Check Tile call again /.\n";
                    upgrade = false;
                    streaming_strategy = null;
                };
                case ( ? WMTSTile) WMTSTile;
            };
        if (wmts_call != null) {
            let toServeFile = await getWMTSFile(wmts_callNN);
            let toServeFileNN: FileData =
                switch (toServeFile) {
                    case null
                    return {
                        status_code = 404;
                        headers = [("content-type", "text/plain"),("Access-Control-Allow-Origin", "*")];
                        body = "404 Tile Not found.\n/.\n";
                        upgrade = false;
                        streaming_strategy = null;
                    };
                    case ( ? FileData) FileData;
                };
                let container : Container = await getOrSetContainer();
            let b = await container.getFileChunk(toServeFileNN.fileId, 1, toServeFileNN.cid);
            let myBlob: Blob =
                switch (b) {
                    case null {
                        Blob.fromArray([])
                    };
                    case ( ? Blob) Blob;
                };
            return {
                status_code = 200;
                
                        headers = [("content-type", "image/jpeg"),("Access-Control-Allow-Origin", "*")];
                body = myBlob;
                upgrade = false;
                streaming_strategy = null;
            };
        };
        // Else return an error code.      
        return {
            status_code = 404;
            headers = [("content-type", "text/plain"),("Access-Control-Allow-Origin", "*")];
            body = "404 Not found.\n This canister only serves /.\n";
            upgrade = false;
            streaming_strategy = null;
        }
    };
 

    // Section Helper Methods

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

    func updateCanister(a: actor {}): async () {
        Debug.print("container balance before: "
            # Nat.toText(Cycles.balance()));
        // Cycles.add(Cycles.balance()/2);
        let cid = {
            canister_id = Principal.fromActor(a)
        };
        Debug.print("IC status..."
            # debug_show(await IC.canister_status(cid)));
        // let cid = await IC.create_canister(  {
        //    settings = ?{controllers = [?(owner)]; compute_allocation = null; memory_allocation = ?(4294967296); freezing_threshold = null; } } );
        await (IC.update_settings({
            canister_id = cid.canister_id;
            settings = {
                controllers = ? [owner, Principal.fromActor(this), Principal.fromActor(a)];
                compute_allocation = null;
                //  memory_allocation = ?4_294_967_296; // 4GB
                memory_allocation = null; // 4GB
                freezing_threshold = ? 31_540_000
            }
        }));
    };

    private func removeQuery(str: Text): Text {
        let urlquery : ?Text = Text.split(str, #char '?').next();
        switch (urlquery) {
            case null {return "";};
            case (?urlquery) {return urlquery };
        };
    };

    func textToNat(txt: Text): Nat {
        assert(txt.size() > 0);
        let chars = txt.chars();
        var num: Nat = 0;
        for (v in chars) {
            let charToNum = Nat32.toNat(Char.toNat32(v) - 48);
            assert(charToNum>= 0 and charToNum <= 9);
            num := num * 10 + charToNum;
        };
        num;
    };

    private func queryString(str: Text): Text {
        let queryPart = Text.split(str, #char '?');
        let textArray = Iter.toArray <Text> (queryPart);
        if (textArray.size() == 2) return textArray[1];
        return "";
    };
    private func queryMap(url: Text): HashMap.HashMap <Text, Text> {
        let queryHashMap = HashMap.HashMap <Text,
            Text> (100, Text.equal, Text.hash);
        let queryText: Text = queryString(url);
        for (parameter in Text.split(queryText, #char '&')) {
            Debug.print("Found parameter: "
                # parameter);
            let paramPart = Text.split(parameter, #char '=');
            let peramPartArray = Iter.toArray <Text> (paramPart);
            queryHashMap.put(peramPartArray[0], peramPartArray[1]);
        };
        return queryHashMap;
    };
    private func getParameterValue(parameter: Text, queryHashMap: HashMap.HashMap <Text, Text> ): Text {
        let param: Text =
            switch (queryHashMap.get(parameter)) {
                case null "";
                case ( ? Text) Text
            };
        return param;
    };



};