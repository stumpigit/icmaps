export const idlFactory = ({ IDL }) => {
  const FileId = IDL.Text;
  const Timestamp = IDL.Int;
  const FileId__1 = IDL.Text;
  const FileExtension = IDL.Variant({
    'gif' : IDL.Null,
    'jpg' : IDL.Null,
    'png' : IDL.Null,
    'jpeg' : IDL.Null,
  });
  const FileData = IDL.Record({
    'x' : IDL.Nat,
    'y' : IDL.Nat,
    'z' : IDL.Nat,
    'cid' : IDL.Principal,
    'name' : IDL.Text,
    'createdAt' : Timestamp,
    'size' : IDL.Nat,
    'layer' : IDL.Text,
    'tilematrixset' : IDL.Text,
    'fileId' : FileId__1,
    'chunkCount' : IDL.Nat,
    'extension' : FileExtension,
    'uploadedAt' : Timestamp,
  });
  const FileInfo = IDL.Record({
    'x' : IDL.Nat,
    'y' : IDL.Nat,
    'z' : IDL.Nat,
    'name' : IDL.Text,
    'createdAt' : Timestamp,
    'size' : IDL.Nat,
    'layer' : IDL.Text,
    'tilematrixset' : IDL.Text,
    'chunkCount' : IDL.Nat,
    'extension' : FileExtension,
  });
  const Bucket = IDL.Service({
    'authorize' : IDL.Func([IDL.Principal], [IDL.Bool], ['query']),
    'generateRandom' : IDL.Func([IDL.Text], [IDL.Text], []),
    'getChunks' : IDL.Func(
        [FileId, IDL.Nat],
        [IDL.Opt(IDL.Vec(IDL.Nat8))],
        ['query'],
      ),
    'getFileInfo' : IDL.Func([FileId], [IDL.Opt(FileData)], ['query']),
    'getInfo' : IDL.Func([], [IDL.Vec(FileData)], ['query']),
    'getSize' : IDL.Func([], [IDL.Nat], []),
    'putChunks' : IDL.Func(
        [FileId, IDL.Nat, IDL.Vec(IDL.Nat8)],
        [IDL.Opt(IDL.Null)],
        [],
      ),
    'putFile' : IDL.Func([FileInfo], [IDL.Opt(FileId)], []),
    'updateFileInfoData' : IDL.Func([FileId, FileData], [], ['oneway']),
    'wallet_balance' : IDL.Func([], [IDL.Nat], []),
    'wallet_receive' : IDL.Func(
        [],
        [IDL.Record({ 'accepted' : IDL.Nat64 })],
        [],
      ),
  });
  return Bucket;
};
export const init = ({ IDL }) => { return []; };
