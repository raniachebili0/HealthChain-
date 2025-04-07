import { Controller, Post, Body, Get, Query, Delete, HttpException, HttpStatus } from '@nestjs/common';
import { NftAccessService } from './nft-access.service';

@Controller('nft-access')
export class NftAccessController {
  constructor(private readonly nftAccessService: NftAccessService) {}

  @Post('grant')
  async grantAccess(
    @Body() body: {
      nftContract: string;
      tokenId: number;
      userAddress: string;
      durationInHours: number;
    }
  ) {
    try {
      if (!body.nftContract || !body.tokenId || !body.userAddress || body.durationInHours === undefined) {
        throw new HttpException('Missing required fields', HttpStatus.BAD_REQUEST);
      }

      if (body.durationInHours <= 0) {
        throw new HttpException('Duration must be positive', HttpStatus.BAD_REQUEST);
      }
      
      if (body.durationInHours < 0.0167) { // Less than 1 minute
        console.warn('Duration is very small, will be rounded up to minimum 1 minute');
      }

      return await this.nftAccessService.grantAccess(
        body.nftContract,
        body.tokenId,
        body.userAddress,
        body.durationInHours
      );
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to grant access',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }

  @Delete('revoke')
  async revokeAccess(
    @Body() body: {
      nftContract: string;
      tokenId: number;
      userAddress: string;
    }
  ) {
    try {
      if (!body.nftContract || !body.tokenId || !body.userAddress) {
        throw new HttpException('Missing required fields', HttpStatus.BAD_REQUEST);
      }

      return await this.nftAccessService.revokeAccess(
        body.nftContract,
        body.tokenId,
        body.userAddress
      );
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to revoke access',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }

  @Get('check')
  async checkAccess(
    @Query('nftContract') nftContract: string,
    @Query('tokenId') tokenId: number,
    @Query('userAddress') userAddress: string
  ) {
    try {
      if (!nftContract || !tokenId || !userAddress) {
        throw new HttpException('Missing required query parameters', HttpStatus.BAD_REQUEST);
      }

      return await this.nftAccessService.checkAccess(
        nftContract,
        tokenId,
        userAddress
      );
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to check access',
        error.status || HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
} 