import type { Principal } from '@dfinity/principal';
export interface Backend {
  'authorize' : (arg_0: Principal) => Promise<boolean>,
  'generateRandom' : (arg_0: string) => Promise<string>,
  'getChunks' : (arg_0: FileId, arg_1: bigint) => Promise<[] | [Array<number>]>,
  'getFileInfo' : (arg_0: FileId) => Promise<[] | [FileData]>,
  'getInfo' : () => Promise<Array<FileData>>,
  'getMyCanisters' : (arg_0: User) => Promise<Array<Canister>>,
  'getSize' : () => Promise<bigint>,
  'get_controllers' : () => Promise<Array<Principal>>,
  'insert' : (arg_0: User, arg_1: string, arg_2: boolean) => Promise<undefined>,
  'installWMTSServer' : (arg_0: string, arg_1: string) => Promise<undefined>,
  'putChunks' : (arg_0: FileId, arg_1: bigint, arg_2: Array<number>) => Promise<
      [] | [null]
    >,
  'putFile' : (arg_0: string, arg_1: FileInfo) => Promise<[] | [FileId]>,
  'updateFileInfoData' : (arg_0: FileId, arg_1: FileData) => Promise<undefined>,
  'upgradeWMTSServer' : (arg_0: string, arg_1: string) => Promise<undefined>,
  'wallet_balance' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<{ 'accepted' : bigint }>,
  'whoami' : () => Promise<Principal>,
}
export interface Canister { 'managed' : boolean, 'desc' : Principal }
export interface FileData {
  'cid' : Principal,
  'name' : string,
  'createdAt' : Timestamp,
  'size' : bigint,
  'fileId' : FileId__1,
  'chunkCount' : bigint,
  'uploadedAt' : Timestamp,
}
export type FileId = string;
export type FileId__1 = string;
export interface FileInfo {
  'name' : string,
  'createdAt' : Timestamp,
  'size' : bigint,
  'chunkCount' : bigint,
}
export type Timestamp = bigint;
export type User = string;
export interface _SERVICE extends Backend {}
