import type { Principal } from '@dfinity/principal';
export interface Bucket {
  'authorize' : (arg_0: Principal) => Promise<boolean>,
  'generateRandom' : (arg_0: string) => Promise<string>,
  'getChunks' : (arg_0: FileId, arg_1: bigint) => Promise<[] | [Array<number>]>,
  'getFileInfo' : (arg_0: FileId) => Promise<[] | [FileData]>,
  'getInfo' : () => Promise<Array<FileData>>,
  'getSize' : () => Promise<bigint>,
  'putChunks' : (arg_0: FileId, arg_1: bigint, arg_2: Array<number>) => Promise<
      [] | [null]
    >,
  'putFile' : (arg_0: FileInfo) => Promise<[] | [FileId]>,
  'removeFile' : (arg_0: FileId) => Promise<[] | [bigint]>,
  'updateFileInfoData' : (arg_0: FileId, arg_1: FileData) => Promise<undefined>,
  'wallet_balance' : () => Promise<bigint>,
  'wallet_receive' : () => Promise<{ 'accepted' : bigint }>,
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
export interface _SERVICE extends Bucket {}
