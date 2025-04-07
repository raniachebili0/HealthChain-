import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { NftModule } from './nft/nft.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    NftModule,
  ],
})
export class AppModule {} 