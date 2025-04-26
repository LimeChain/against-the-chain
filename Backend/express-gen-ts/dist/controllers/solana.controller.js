"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SolanaController = void 0;
const web3_js_1 = require("@solana/web3.js");
const jet_logger_1 = __importDefault(require("jet-logger"));
class SolanaController {
    constructor(io) {
        this.RPC_ENDPOINTS = [
            'https://mainnet.helius-rpc.com/?api-key=7148b4c3-6dd9-48fe-bb75-e052f07dce11',
            'https://api.mainnet-beta.solana.com'
        ];
        this.currentEndpointIndex = 0;
        this.updateInterval = null;
        this.lastRequestTime = 0;
        this.MIN_REQUEST_INTERVAL = 666;
        this.requestCount = 0;
        this.REQUEST_WINDOW = 1000;
        this.MAX_REQUESTS_PER_WINDOW = 1;
        this.lastTotalTransactions = 0;
        if (!io)
            throw new Error('Socket.IO server instance is required');
        this.io = io;
        this.startBlockUpdates();
        setInterval(() => {
            this.requestCount = 0;
        }, this.REQUEST_WINDOW);
    }
    getNextEndpoint() {
        this.currentEndpointIndex = (this.currentEndpointIndex + 1) % this.RPC_ENDPOINTS.length;
        return this.RPC_ENDPOINTS[this.currentEndpointIndex];
    }
    async sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    async getCurrentBlockState() {
        const now = Date.now();
        const timeSinceLastRequest = now - this.lastRequestTime;
        if (this.requestCount >= this.MAX_REQUESTS_PER_WINDOW) {
            const waitTime = this.REQUEST_WINDOW - (now % this.REQUEST_WINDOW);
            jet_logger_1.default.info(`Rate limit reached. Waiting ${waitTime}ms before next request`);
            await this.sleep(waitTime);
            this.requestCount = 0;
        }
        if (timeSinceLastRequest < this.MIN_REQUEST_INTERVAL) {
            const delay = this.MIN_REQUEST_INTERVAL - timeSinceLastRequest;
            jet_logger_1.default.info(`Throttling request: waiting ${delay}ms`);
            await this.sleep(delay);
        }
        const endpoint = this.RPC_ENDPOINTS[this.currentEndpointIndex];
        const connection = new web3_js_1.Connection(endpoint, 'confirmed');
        try {
            this.lastRequestTime = Date.now();
            this.requestCount++;
            const slot = await connection.getSlot();
            const block = await connection.getBlock(slot, {
                maxSupportedTransactionVersion: 0,
                rewards: true
            });
            if (!block) {
                jet_logger_1.default.warn(`No block data received for slot ${slot}`);
                return null;
            }
            const totalTransactions = await connection.getTransactionCount();
            const transactionCount = totalTransactions - this.lastTotalTransactions;
            this.lastTotalTransactions = totalTransactions;
            const blockState = {
                slot,
                blockhash: block.blockhash,
                leader: block.rewards?.[0]?.pubkey ?? 'unknown',
                reward: block.rewards?.reduce((sum, reward) => sum + reward.lamports, 0) ?? 0,
                timestamp: Date.now(),
                transactionCount,
                totalTransactions
            };
            return blockState;
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            jet_logger_1.default.warn(`Error fetching block state from ${endpoint}: ${errorMessage}`);
            this.getNextEndpoint();
            return null;
        }
    }
    async updateBlockState() {
        const blockState = await this.getCurrentBlockState();
        if (blockState !== null) {
            jet_logger_1.default.info('Current block state: ' + JSON.stringify(blockState));
            this.io.emit('blockUpdate', blockState);
        }
    }
    startBlockUpdates() {
        this.updateInterval = setInterval(() => {
            this.updateBlockState().catch((error) => {
                const errorMessage = error instanceof Error ? error.message : String(error);
                jet_logger_1.default.err(`Error in block update: ${errorMessage}`, true);
            });
        }, 2000);
        this.updateBlockState().catch((error) => {
            const errorMessage = error instanceof Error ? error.message : String(error);
            jet_logger_1.default.err(`Error in initial block update: ${errorMessage}`, true);
        });
    }
    stopUpdates() {
        if (this.updateInterval) {
            clearInterval(this.updateInterval);
            this.updateInterval = null;
        }
    }
    getBlockHistory() {
        return [];
    }
}
exports.SolanaController = SolanaController;
