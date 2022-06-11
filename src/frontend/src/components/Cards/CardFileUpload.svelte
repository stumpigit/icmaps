<script>
  
  import { AuthClient } from "@dfinity/auth-client";
  import { backend , createActor } from "../../store/backend";

  let avatar, fileinput;
  
  let client;
  let fileid;


    const b64toBlob = (b64Data, contentType='', sliceSize=512) => {
      
      const byteCharacters = atob(b64Data);
      const byteArrays = [];
    
      for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
        const slice = byteCharacters.slice(offset, offset + sliceSize);
    
        const byteNumbers = new Array(slice.length);
        for (let i = 0; i < slice.length; i++) {
          byteNumbers[i] = slice.charCodeAt(i);
        }
    
        const byteArray = new Uint8Array(byteNumbers);
        byteArrays.push(byteArray);
      }
      const blob = new Blob(byteArrays, { type: contentType } );
      return blob;
  }

  const MAX_CHUNK_SIZE = 1024 * 2000; // 800kb

  const encodeArrayBuffer = (file) =>
      Array.from(new Uint8Array(file));

  const processAndUploadChunk = async (
    blob,
    byteStart,
    fileId,
    chunk,
    fileSize,
  )  => {
    const blobSlice = blob.slice(
      byteStart,
      Math.min(Number(fileSize), byteStart + MAX_CHUNK_SIZE),
      blob.type
    );
  
    const bsf = await blobSlice.arrayBuffer();
    //const ba = await $wmtsserver.actor.getBackendActor();
    return $backend.actor.putChunks(fileId, BigInt(chunk), encodeArrayBuffer(bsf));
  }
	
	const onFileSelected =(e)=>{
    let file = e.target.files[0];
    let reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = async e => {
      console.log("ONload");
          avatar = e.target.result

          let encoded = reader.result.toString().replace(/^data:(.*,)?/, '');
          if ((encoded.length % 4) > 0) {
            encoded += '='.repeat(4 - (encoded.length % 4));
          }
          const blob = b64toBlob(encoded, file.type);

          console.log("1");
          // handle Upload
          const fileInfo = {
            name: Math.random().toString(36).substring(2),
            createdAt: BigInt(Number(Date.now() * 1000)),
            size: BigInt(file.size),
            chunkCount: BigInt(1),
          };

          console.log("2");
          client = await AuthClient.create();
          if (await client.isAuthenticated()) {
            backend.update(() => ({
              loggedIn: true,
              actor: createActor({
                agentOptions: {
                  identity: client.getIdentity(),
                },
              }),
            }));
          }

          console.log("3");
          const fileId = (await $backend.actor.putFile(fileid, fileInfo))[0];
          console.log("New fileId:");
          console.log(fileId);

          console.log("4");
          const blobImage = file;
          const putChunkPromises = [];
          let chunk = 1;
          putChunkPromises.push(
            processAndUploadChunk(blobImage, 0, fileId, chunk, file.size)
          );
  
          await Promise.all(putChunkPromises);
          console.log("File uploaded successfully");
    }
}
</script>
<div
  class="relative flex flex-col min-w-0 break-words w-full mb-6 shadow-lg rounded-lg bg-blueGray-100 border-0"
>
  <div class="rounded-t bg-white mb-0 px-6 py-6">
    <div class="text-center flex justify-between">
      <h6 class="text-blueGray-700 text-xl font-bold">FileUpload</h6>
    </div>
  </div>
  <label
  class="block uppercase text-blueGray-600 text-xs font-bold mb-2"
  for="grid-username"
>
  FileId
</label>
<input
  id="layerid"
  type="text"
  class="border-0 px-3 py-3 placeholder-blueGray-300 text-blueGray-600 bg-white rounded text-sm shadow focus:outline-none focus:ring w-full ease-linear transition-all duration-150"
  bind:value={fileid}
/>
  <div class="flex-auto px-4 lg:px-10 py-10 pt-0">
    <div class="chan" on:click={()=>{fileinput.click();}}>Choose Container WASM-File</div>
    <input style="display:none" type="file" accept=".wasm" on:change={(e)=>onFileSelected(e)} bind:this={fileinput} >
   </div>


</div>
