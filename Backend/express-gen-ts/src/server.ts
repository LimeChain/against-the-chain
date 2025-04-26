import morgan from 'morgan';
import path from 'path';
import helmet from 'helmet';
import express, { Request, Response, NextFunction } from 'express';
import logger from 'jet-logger';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';

import BaseRouter from './routes';
import { initializeSolanaRoutes } from './routes/solana.routes';

import Paths from './common/constants/Paths';
import ENV from './common/constants/ENV';
import HttpStatusCodes from './common/constants/HttpStatusCodes';
import { RouteError } from './common/util/route-errors';
import { NodeEnvs } from './common/constants';


/******************************************************************************
                                Setup
******************************************************************************/

const app = express();
const httpServer = createServer(app);

// Configure Socket.IO with proper CORS
const io = new SocketServer(httpServer, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Log Socket.IO connection events
io.on('connection', (socket) => {
  logger.info('Client connected to Socket.IO');
  
  socket.on('disconnect', () => {
    logger.info('Client disconnected from Socket.IO');
  });
});


// **** Middleware **** //

// Basic middleware
app.use(express.json());
app.use(express.urlencoded({extended: true}));

// Show routes called in console during development
if (ENV.NodeEnv === NodeEnvs.Dev) {
  app.use(morgan('dev'));
}

// Security
if (ENV.NodeEnv === NodeEnvs.Production) {
  // eslint-disable-next-line n/no-process-env
  if (!process.env.DISABLE_HELMET) {
    app.use(helmet());
  }
}

// Add APIs, must be after middleware
app.use(Paths.Base, BaseRouter);
app.use('/solana', initializeSolanaRoutes(io));

// Add error handler
app.use((err: Error, _: Request, res: Response, next: NextFunction) => {
  if (ENV.NodeEnv !== NodeEnvs.Test.valueOf()) {
    logger.err(err, true);
  }
  let status = HttpStatusCodes.BAD_REQUEST;
  if (err instanceof RouteError) {
    status = err.status;
    res.status(status).json({ error: err.message });
  }
  return next(err);
});


// **** FrontEnd Content **** //

// Set views directory (html)
const viewsDir = path.join(__dirname, 'views');
app.set('views', viewsDir);

// Set static directory (js and css)
const staticDir = path.join(__dirname, 'public');
app.use(express.static(staticDir));

// Serve Socket.IO client
app.get('/socket.io/socket.io.js', (_, res) => {
  res.sendFile(path.join(__dirname, '../node_modules/socket.io/client-dist/socket.io.js'));
});

// Redirect to Solana monitor by default
app.get('/', (_: Request, res: Response) => {
  return res.redirect('/solana');
});


/******************************************************************************
                                Export default
******************************************************************************/

export { app, httpServer };
