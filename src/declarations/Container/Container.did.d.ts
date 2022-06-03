import type { Principal } from '@dfinity/principal';
export interface CanisterCycleInfo {
  'canisterType' : { 'container' : null } |
    { 'bucket' : null },
  'cycles' : bigint,
  'canisterId' : string,
}
export interface Container {
  'addCanisterIdToBucketsList' : (arg_0: string) => Promise<undefined>,
  'authorize' : (arg_0: Principal) => Promise<boolean>,
  'getAllFiles' : () => Promise<Array<FileData>>,
  'getCanisterCycleInfo' : () => Promise<Array<CanisterCycleInfo>>,
  'getFileChunk' : (arg_0: FileId, arg_1: bigint, arg_2: Principal) => Promise<
      [] | [Array<number>]
    >,
  'getFileInfo' : (arg_0: FileId, arg_1: Principal) => Promise<[] | [FileData]>,
  'getStatus' : () => Promise<Array<[Principal, bigint]>>,
  'get_controllers' : () => Promise<Array<Principal>>,
  'putFileChunks' : (
      arg_0: FileId,
      arg_1: bigint,
      arg_2: bigint,
      arg_3: Array<number>,
    ) => Promise<[] | [FileData]>,
  'putFileInfo' : (arg_0: FileInfo) => Promise<[] | [FileId]>,
  'updateCycles' : () => Promise<undefined>,
  'updateStatus' : () => Promise<undefined>,
  'wallet_balance' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<undefined>,
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
  'fileId' : FileId__1,
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
export type Timestamp = bigint;
export interface _SERVICE extends Container {}
