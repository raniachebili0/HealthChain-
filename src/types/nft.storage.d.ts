declare module 'nft.storage' {
  export class NFTStorage {
    constructor(config: { token: string });
    storeBlob(blob: Blob): Promise<string>;
  }
} 