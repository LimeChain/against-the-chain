import { Router } from 'express';
import { Server as SocketServer } from 'socket.io';
import { SolanaController } from '../controllers/solana.controller';
import path from 'path';

export function initializeSolanaRoutes(io: SocketServer) {
  const router = Router();
  const solanaController = new SolanaController(io);

  // Serve the HTML client
  router.get('/', (_, res) => {
    res.sendFile(path.join(__dirname, '../views/solana.html'));
  });

  // HTTP endpoint to get current block history
  router.get('/blocks', (req, res) => {
    try {
      const blockHistory = solanaController.getBlockHistory();
      res.json(blockHistory);
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch block history' });
    }
  });

  return router;
} 