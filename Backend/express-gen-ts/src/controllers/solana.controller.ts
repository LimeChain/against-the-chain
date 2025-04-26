import { Connection } from '@solana/web3.js';
import { Server as SocketServer } from 'socket.io';
import logger from 'jet-logger';

interface BlockState {
  slot: number;
  blockhash: string;
  leader: string;
  reward: number;
  timestamp: number;
  transactionCount: number;
  totalTransactions: number;
}

export class SolanaController {
  private readonly RPC_ENDPOINTS = [
    'https://mainnet.helius-rpc.com/?api-key=7148b4c3-6dd9-48fe-bb75-e052f07dce11',
    'https://api.mainnet-beta.solana.com'
  ];
  private currentEndpointIndex = 0;
  private io: SocketServer;
  private updateInterval: NodeJS.Timeout | null = null;
  private lastRequestTime = 0;
  private readonly MIN_REQUEST_INTERVAL = 666; // 1.5 requests per second (1000ms / 1.5 = 666ms)
  private requestCount = 0;
  private readonly REQUEST_WINDOW = 1000; // 1 second window
  private readonly MAX_REQUESTS_PER_WINDOW = 1; // Conservative limit of 1 request per window
  private lastTotalTransactions = 0;

  constructor(io: SocketServer) {
    if (!io) throw new Error('Socket.IO server instance is required');
    this.io = io;
    this.startBlockUpdates();
    // Reset request count every second
    setInterval(() => {
      this.requestCount = 0;
    }, this.REQUEST_WINDOW);
  }

  private getNextEndpoint(): string {
    this.currentEndpointIndex = (this.currentEndpointIndex + 1) % this.RPC_ENDPOINTS.length;
    return this.RPC_ENDPOINTS[this.currentEndpointIndex];
  }

  private async sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private async getCurrentBlockState(): Promise<BlockState | null> {
    const now = Date.now();
    const timeSinceLastRequest = now - this.lastRequestTime;
    
    // Check if we've exceeded our rate limit
    if (this.requestCount >= this.MAX_REQUESTS_PER_WINDOW) {
      const waitTime = this.REQUEST_WINDOW - (now % this.REQUEST_WINDOW);
      logger.info(`Rate limit reached. Waiting ${waitTime}ms before next request`);
      await this.sleep(waitTime);
      this.requestCount = 0;
    }
    
    // Ensure minimum delay between requests
    if (timeSinceLastRequest < this.MIN_REQUEST_INTERVAL) {
      const delay = this.MIN_REQUEST_INTERVAL - timeSinceLastRequest;
      logger.info(`Throttling request: waiting ${delay}ms`);
      await this.sleep(delay);
    }

    const endpoint = this.RPC_ENDPOINTS[this.currentEndpointIndex];
    const connection = new Connection(endpoint, 'confirmed');

    try {
      this.lastRequestTime = Date.now();
      this.requestCount++;
      
      // Get current slot
      const slot = await connection.getSlot();
      
      // Get block info
      const block = await connection.getBlock(slot, {
        maxSupportedTransactionVersion: 0,
        rewards: true
      });

      if (!block) {
        logger.warn(`No block data received for slot ${slot}`);
        return null;
      }

      // Get total transaction count
      const totalTransactions = await connection.getTransactionCount();
      const transactionCount = totalTransactions - this.lastTotalTransactions;
      this.lastTotalTransactions = totalTransactions;

      const blockState: BlockState = {
        slot,
        blockhash: block.blockhash,
        leader: block.rewards?.[0]?.pubkey ?? 'unknown',
        reward: block.rewards?.reduce((sum, reward) => sum + reward.lamports, 0) ?? 0,
        timestamp: Date.now(),
        transactionCount,
        totalTransactions
      };

      return blockState;
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.warn(`Error fetching block state from ${endpoint}: ${errorMessage}`);
      // Switch to next endpoint on error
      this.getNextEndpoint();
      return null;
    }
  }

  private async updateBlockState() {
    const blockState = await this.getCurrentBlockState();
    if (blockState !== null) {
      logger.info('Current block state: ' + JSON.stringify(blockState));
      this.io.emit('blockUpdate', blockState);
    }
  }

  private startBlockUpdates() {
    // Update every 2 seconds to stay well within rate limits
    this.updateInterval = setInterval(() => {
      this.updateBlockState().catch((error: unknown) => {
        const errorMessage = error instanceof Error ? error.message : String(error);
        logger.err(`Error in block update: ${errorMessage}`, true);
      });
    }, 2000);

    // Initial update
    this.updateBlockState().catch((error: unknown) => {
      const errorMessage = error instanceof Error ? error.message : String(error);
      logger.err(`Error in initial block update: ${errorMessage}`, true);
    });
  }

  public stopUpdates() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }

  public getBlockHistory(): BlockState[] {
    // TODO: Implement actual block history storage and retrieval
    return [];
  }
} 