import type { Principal } from '@dfinity/principal';
export interface CanisterCycleInfo {
  'canisterType' : { 'container' : null } |
    { 'bucket' : null },
  'cycles' : bigint,
  'canisterId' : string,
}
export interface FileData {
  'x' : bigint,
  'y' : bigint,
  'z' : bigint,
  'cid' : Principal,
  'name' : string,
  'createdAt' : Timestamp,
  'size' : bigint,
  'layer' : string,
  'tilematrixset' : string,
  'fileId' : FileId,
  'chunkCount' : bigint,
  'extension' : FileExtension,
  'uploadedAt' : Timestamp,
}
export type FileExtension = { 'gif' : null } |
  { 'jpg' : null } |
  { 'png' : null } |
  { 'jpeg' : null };
export type FileId = string;
export type FileId__1 = string;
export interface FileInfo {
  'x' : bigint,
  'y' : bigint,
  'z' : bigint,
  'name' : string,
  'createdAt' : Timestamp,
  'size' : bigint,
  'layer' : string,
  'tilematrixset' : string,
  'chunkCount' : bigint,
  'extension' : FileExtension,
}
export type HeaderField = [string, string];
export interface HttpRequest {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpRequest__1 {
  'url' : string,
  'method' : string,
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
}
export interface HttpResponse {
  'body' : Array<number>,
  'headers' : Array<HeaderField>,
  'upgrade' : boolean,
  'streaming_strategy' : [] | [StreamingStrategy],
  'status_code' : number,
}
export interface LayerInfo {
  'url' : string,
  'wGS84BoundingBox' : WGS84BoundingBox,
  'title' : string,
  'tilematrixset' : TileMatrixSet__1,
  'providedTilematrixSets' : Array<bigint>,
  'identifier' : string,
  'format' : string,
}
export interface StreamingCallbackHttpResponse {
  'token' : [] | [StreamingCallbackToken],
  'body' : Array<number>,
}
export interface StreamingCallbackToken {
  'key' : string,
  'sha256' : [] | [Array<number>],
  'index' : bigint,
  'content_encoding' : string,
}
export type StreamingStrategy = {
    'Callback' : {
      'token' : StreamingCallbackToken,
      'callback' : [Principal, string],
    }
  };
export interface TileMatrixSet {
  'xml' : string,
  'identifier' : string,
  'supportedCRS' : string,
}
export interface TileMatrixSet__1 {
  'xml' : string,
  'identifier' : string,
  'supportedCRS' : string,
}
export type Timestamp = bigint;
export interface WGS84BoundingBox {
  'upperCorner' : string,
  'lowerCorner' : string,
}
export interface WMTS {
  'individualName' : string,
  'country' : string,
  'city' : string,
  'positionName' : string,
  'electronicMailAddress' : string,
}
export interface WMTSServer {
  'addLayer' : (
      arg_0: string,
      arg_1: string,
      arg_2: string,
      arg_3: string,
      arg_4: string,
      arg_5: string,
      arg_6: string,
    ) => Promise<undefined>,
  'addTileMatrixSet' : (arg_0: TileMatrixSet) => Promise<undefined>,
  'authorize' : (arg_0: Principal) => Promise<boolean>,
  'getCanisterCycleInfo' : () => Promise<Array<CanisterCycleInfo>>,
  'getLayerInfos' : () => Promise<Array<LayerInfo>>,
  'getTileMatrixSet' : (arg_0: string) => Promise<TileMatrixSet>,
  'getTileMatrixSetFromCRS' : (arg_0: string) => Promise<TileMatrixSet>,
  'getVersion' : () => Promise<string>,
  'getWMTSFile' : (arg_0: WMTSTile) => Promise<[] | [FileData]>,
  'getWMTSParameters' : () => Promise<WMTS__1>,
  'get_controllers' : () => Promise<Array<Principal>>,
  'http_request' : (arg_0: HttpRequest__1) => Promise<HttpResponse>,
  'http_request_update' : (arg_0: HttpRequest) => Promise<HttpResponse>,
  'idQuick' : () => Promise<Principal>,
  'putFileChunks' : (
      arg_0: FileId__1,
      arg_1: bigint,
      arg_2: bigint,
      arg_3: Array<number>,
    ) => Promise<undefined>,
  'putFileInfo' : (arg_0: FileInfo, arg_1: boolean) => Promise<
      [] | [FileId__1]
    >,
  'setWMTSParameters' : (arg_0: WMTS) => Promise<undefined>,
  'updateAllFiles' : () => Promise<undefined>,
  'updateStatus' : () => Promise<undefined>,
  'updateWMSLayers' : (arg_0: [] | [FileData]) => Promise<undefined>,
  'wallet_balance' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
}
export interface WMTSTile {
  'srs' : string,
  'tileMatrixSet' : string,
  'tileMatrix' : bigint,
  'tileCol' : bigint,
  'tileRow' : bigint,
  'layer' : string,
  'version' : string,
  'style' : string,
  'format' : string,
}
export interface WMTS__1 {
  'individualName' : string,
  'country' : string,
  'city' : string,
  'positionName' : string,
  'electronicMailAddress' : string,
}
export interface _SERVICE extends WMTSServer {}
