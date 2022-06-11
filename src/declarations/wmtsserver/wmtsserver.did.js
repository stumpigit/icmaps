export const idlFactory = ({ IDL }) => {
  const TileMatrixSet = IDL.Record({
    'xml' : IDL.Text,
    'identifier' : IDL.Text,
    'supportedCRS' : IDL.Text,
  });
  const CanisterCycleInfo = IDL.Record({
    'canisterType' : IDL.Variant({
      'container' : IDL.Null,
      'bucket' : IDL.Null,
    }),
    'cycles' : IDL.Nat,
    'canisterId' : IDL.Text,
  });
  const WGS84BoundingBox = IDL.Record({
    'upperCorner' : IDL.Text,
    'lowerCorner' : IDL.Text,
  });
  const TileMatrixSet__1 = IDL.Record({
    'xml' : IDL.Text,
    'identifier' : IDL.Text,
    'supportedCRS' : IDL.Text,
  });
  const LayerInfo = IDL.Record({
    'url' : IDL.Text,
    'wGS84BoundingBox' : WGS84BoundingBox,
    'title' : IDL.Text,
    'tilematrixset' : TileMatrixSet__1,
    'providedTilematrixSets' : IDL.Vec(IDL.Nat),
    'identifier' : IDL.Text,
    'format' : IDL.Text,
  });
  const WMTSTile = IDL.Record({
    'srs' : IDL.Text,
    'tileMatrixSet' : IDL.Text,
    'tileMatrix' : IDL.Nat,
    'tileCol' : IDL.Nat,
    'tileRow' : IDL.Nat,
    'layer' : IDL.Text,
    'version' : IDL.Text,
    'style' : IDL.Text,
    'format' : IDL.Text,
  });
  const Timestamp = IDL.Int;
  const FileId = IDL.Text;
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
    'fileId' : FileId,
    'chunkCount' : IDL.Nat,
    'extension' : FileExtension,
    'uploadedAt' : Timestamp,
  });
  const WMTS__1 = IDL.Record({
    'individualName' : IDL.Text,
    'country' : IDL.Text,
    'city' : IDL.Text,
    'positionName' : IDL.Text,
    'electronicMailAddress' : IDL.Text,
  });
  const HeaderField = IDL.Tuple(IDL.Text, IDL.Text);
  const HttpRequest__1 = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const StreamingCallbackToken = IDL.Record({
    'key' : IDL.Text,
    'sha256' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'index' : IDL.Nat,
    'content_encoding' : IDL.Text,
  });
  const StreamingCallbackHttpResponse = IDL.Record({
    'token' : IDL.Opt(StreamingCallbackToken),
    'body' : IDL.Vec(IDL.Nat8),
  });
  const StreamingStrategy = IDL.Variant({
    'Callback' : IDL.Record({
      'token' : StreamingCallbackToken,
      'callback' : IDL.Func(
          [StreamingCallbackToken],
          [StreamingCallbackHttpResponse],
          ['query'],
        ),
    }),
  });
  const HttpResponse = IDL.Record({
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
    'upgrade' : IDL.Bool,
    'streaming_strategy' : IDL.Opt(StreamingStrategy),
    'status_code' : IDL.Nat16,
  });
  const HttpRequest = IDL.Record({
    'url' : IDL.Text,
    'method' : IDL.Text,
    'body' : IDL.Vec(IDL.Nat8),
    'headers' : IDL.Vec(HeaderField),
  });
  const FileId__1 = IDL.Text;
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
  const WMTS = IDL.Record({
    'individualName' : IDL.Text,
    'country' : IDL.Text,
    'city' : IDL.Text,
    'positionName' : IDL.Text,
    'electronicMailAddress' : IDL.Text,
  });
  const WMTSServer = IDL.Service({
    'addLayer' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text, IDL.Text, IDL.Text, IDL.Text, IDL.Text],
        [],
        ['oneway'],
      ),
    'addTileMatrixSet' : IDL.Func([TileMatrixSet], [], []),
    'authorize' : IDL.Func([IDL.Principal], [IDL.Bool], []),
    'getCanisterCycleInfo' : IDL.Func([], [IDL.Vec(CanisterCycleInfo)], []),
    'getLayerInfos' : IDL.Func([], [IDL.Vec(LayerInfo)], ['query']),
    'getTileMatrixSet' : IDL.Func([IDL.Text], [TileMatrixSet], []),
    'getTileMatrixSetFromCRS' : IDL.Func([IDL.Text], [TileMatrixSet], []),
    'getVersion' : IDL.Func([], [IDL.Text], ['query']),
    'getWMTSFile' : IDL.Func([WMTSTile], [IDL.Opt(FileData)], ['query']),
    'getWMTSParameters' : IDL.Func([], [WMTS__1], ['query']),
    'get_controllers' : IDL.Func([], [IDL.Vec(IDL.Principal)], []),
    'http_request' : IDL.Func([HttpRequest__1], [HttpResponse], ['query']),
    'http_request_update' : IDL.Func([HttpRequest], [HttpResponse], []),
    'idQuick' : IDL.Func([], [IDL.Principal], []),
    'putFileChunks' : IDL.Func(
        [FileId__1, IDL.Nat, IDL.Nat, IDL.Vec(IDL.Nat8)],
        [],
        [],
      ),
    'putFileInfo' : IDL.Func([FileInfo, IDL.Bool], [IDL.Opt(FileId__1)], []),
    'removeLayer' : IDL.Func([IDL.Text], [], ['oneway']),
    'setWMTSParameters' : IDL.Func([WMTS], [], ['oneway']),
    'updateAllFiles' : IDL.Func([], [], []),
    'updateStatus' : IDL.Func([], [], []),
    'updateWMSLayers' : IDL.Func([IDL.Opt(FileData)], [], []),
    'wallet_balance' : IDL.Func([], [IDL.Nat], []),
    'wallet_receive' : IDL.Func([], [], []),
  });
  return WMTSServer;
};
export const init = ({ IDL }) => { return []; };
