import { Controller, Post, UploadedFile, Body, UseInterceptors, Logger, HttpException, HttpStatus } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { NftService } from './nft.service';

interface MulterFile {
  buffer: Buffer;
  originalname: string;
  mimetype: string;
  size: number;
}

@Controller('nft')
export class NftController {
  private readonly logger = new Logger(NftController.name);

  constructor(private readonly nftService: NftService) {}

  @Post('create')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
      },
    })
  )
  async createNFT(
    @UploadedFile() file: any,
    @Body() body: { recipientAddress: string },
  ) {
    try {
      this.logger.debug(`Received request with body:`, body);
      this.logger.debug(`File received:`, file?.originalname);

      if (!file) {
        throw new HttpException('File is required', HttpStatus.BAD_REQUEST);
      }

      if (!body?.recipientAddress) {
        throw new HttpException('Recipient address is required', HttpStatus.BAD_REQUEST);
      }

      const multerFile: MulterFile = {
        buffer: file.buffer,
        originalname: file.originalname,
        mimetype: file.mimetype,
        size: file.size
      };

      const result = await this.nftService.createNFT(multerFile, body.recipientAddress);
      this.logger.debug(`NFT created successfully:`, result);
      return result;
    } catch (error) {
      this.logger.error(`Error in createNFT:`, error);
      if (error instanceof HttpException) {
        throw error;
      }
      throw new HttpException(
        error.message || 'Internal server error',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
} 