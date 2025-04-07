import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { NftController } from './nft.controller';
import { NftService } from './nft.service';
import { NftAccessController } from './nft-access.controller';
import { NftAccessService } from './nft-access.service';

@Module({
  imports: [ConfigModule],
  controllers: [NftController, NftAccessController],
  providers: [NftService, NftAccessService],
})
export class NftModule {} 