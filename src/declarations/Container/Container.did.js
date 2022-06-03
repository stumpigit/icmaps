export const idlFactory = ({ IDL }) => {
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
  const CanisterCycleInfo = IDL.Record({
    'canisterType' : IDL.Variant({
      'container' : IDL.Null,
      'bucket' : IDL.Null,
    }),
    'cycles' : IDL.Nat,
    'canisterId' : IDL.Text,
  });
  const FileId = IDL.Text;
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
  const Container = IDL.Service({
    'addCanisterIdToBucketsList' : IDL.Func([IDL.Text], [], []),
    'authorize' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'getAllFiles' : IDL.Func([], [IDL.Vec(FileData)], []),
    'getCanisterCycleInfo' : IDL.Func([], [IDL.Vec(CanisterCycleInfo)], []),
    'getFileChunk' : IDL.Func(
        [FileId, IDL.Nat, IDL.Principal],
        [IDL.Opt(IDL.Vec(IDL.Nat8))],
        [],
      ),
    'getFileInfo' : IDL.Func([FileId, IDL.Principal], [IDL.Opt(FileData)], []),
    'getStatus' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Nat))],
        ['query'],
      ),
    'get_controllers' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'putFileChunks' : IDL.Func(
        [FileId, IDL.Nat, IDL.Nat, IDL.Vec(IDL.Nat8)],
        [IDL.Opt(FileData)],
        [],
      ),
    'putFileInfo' : IDL.Func([FileInfo], [IDL.Opt(FileId)], []),
    'updateCycles' : IDL.Func([], [], []),
    'updateStatus' : IDL.Func([], [], []),
    'wallet_balance' : IDL.Func([], [IDL.Nat], []),
    'wallet_receive' : IDL.Func([], [], []),
  });
  return Container;
};
export const init = ({ IDL }) => { return []; };
