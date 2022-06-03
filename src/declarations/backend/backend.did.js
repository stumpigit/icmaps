export const idlFactory = ({ IDL }) => {
  const FileId = IDL.Text;
  const Timestamp = IDL.Int;
  const FileId__1 = IDL.Text;
  const FileData = IDL.Record({
    'cid' : IDL.Principal,
    'name' : IDL.Text,
    'createdAt' : Timestamp,
    'size' : IDL.Nat,
    'fileId' : FileId__1,
    'chunkCount' : IDL.Nat,
    'uploadedAt' : Timestamp,
  });
  const User = IDL.Text;
  const Canister = IDL.Record({ 'managed' : IDL.Bool, 'desc' : IDL.Principal });
  const FileInfo = IDL.Record({
    'name' : IDL.Text,
    'createdAt' : Timestamp,
    'size' : IDL.Nat,
    'chunkCount' : IDL.Nat,
  });
  const Backend = IDL.Service({
    'authorize' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'generateRandom' : IDL.Func([IDL.Text], [IDL.Text], []),
    'getChunks' : IDL.Func(
        [FileId, IDL.Nat],
        [IDL.Opt(IDL.Vec(IDL.Nat8))],
        ['query'],
      ),
    'getFileInfo' : IDL.Func([FileId], [IDL.Opt(FileData)], ['query']),
    'getInfo' : IDL.Func([], [IDL.Vec(FileData)], ['query']),
    'getMyCanisters' : IDL.Func([User], [IDL.Vec(Canister)], []),
    'getSize' : IDL.Func([], [IDL.Nat], []),
    'get_controllers' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'insert' : IDL.Func([User, IDL.Text, IDL.Bool], [], []),
    'installWMTSServer' : IDL.Func([IDL.Text, IDL.Text], [], []),
    'putChunks' : IDL.Func(
        [FileId, IDL.Nat, IDL.Vec(IDL.Nat8)],
        [IDL.Opt(IDL.Null)],
        [],
      ),
    'putFile' : IDL.Func([IDL.Text, FileInfo], [IDL.Opt(FileId)], []),
    'updateFileInfoData' : IDL.Func([FileId, FileData], [], ['oneway']),
    'upgradeWMTSServer' : IDL.Func([IDL.Text, IDL.Text], [], []),
    'wallet_balance' : IDL.Func([], [IDL.Nat], []),
    'wallet_receive' : IDL.Func(
        [],
        [IDL.Record({ 'accepted' : IDL.Nat64 })],
        [],
      ),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
  return Backend;
};
export const init = ({ IDL }) => { return []; };
