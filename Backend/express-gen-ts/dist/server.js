"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.httpServer = exports.app = void 0;
const morgan_1 = __importDefault(require("morgan"));
const path_1 = __importDefault(require("path"));
const helmet_1 = __importDefault(require("helmet"));
const express_1 = __importDefault(require("express"));
const jet_logger_1 = __importDefault(require("jet-logger"));
const http_1 = require("http");
const socket_io_1 = require("socket.io");
const routes_1 = __importDefault(require("@src/routes"));
const solana_routes_1 = require("@src/routes/solana.routes");
const Paths_1 = __importDefault(require("@src/common/constants/Paths"));
const ENV_1 = __importDefault(require("@src/common/constants/ENV"));
const HttpStatusCodes_1 = __importDefault(require("@src/common/constants/HttpStatusCodes"));
const route_errors_1 = require("@src/common/util/route-errors");
const constants_1 = require("@src/common/constants");
const app = (0, express_1.default)();
exports.app = app;
const httpServer = (0, http_1.createServer)(app);
exports.httpServer = httpServer;
const io = new socket_io_1.Server(httpServer, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});
io.on('connection', (socket) => {
    jet_logger_1.default.info('Client connected to Socket.IO');
    socket.on('disconnect', () => {
        jet_logger_1.default.info('Client disconnected from Socket.IO');
    });
});
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
if (ENV_1.default.NodeEnv === constants_1.NodeEnvs.Dev) {
    app.use((0, morgan_1.default)('dev'));
}
if (ENV_1.default.NodeEnv === constants_1.NodeEnvs.Production) {
    if (!process.env.DISABLE_HELMET) {
        app.use((0, helmet_1.default)());
    }
}
app.use(Paths_1.default.Base, routes_1.default);
app.use('/solana', (0, solana_routes_1.initializeSolanaRoutes)(io));
app.use((err, _, res, next) => {
    if (ENV_1.default.NodeEnv !== constants_1.NodeEnvs.Test.valueOf()) {
        jet_logger_1.default.err(err, true);
    }
    let status = HttpStatusCodes_1.default.BAD_REQUEST;
    if (err instanceof route_errors_1.RouteError) {
        status = err.status;
        res.status(status).json({ error: err.message });
    }
    return next(err);
});
const viewsDir = path_1.default.join(__dirname, 'views');
app.set('views', viewsDir);
const staticDir = path_1.default.join(__dirname, 'public');
app.use(express_1.default.static(staticDir));
app.get('/socket.io/socket.io.js', (_, res) => {
    res.sendFile(path_1.default.join(__dirname, '../node_modules/socket.io/client-dist/socket.io.js'));
});
app.get('/', (_, res) => {
    return res.redirect('/solana');
});
