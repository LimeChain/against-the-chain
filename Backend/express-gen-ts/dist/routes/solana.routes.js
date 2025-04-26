"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializeSolanaRoutes = initializeSolanaRoutes;
const express_1 = require("express");
const solana_controller_1 = require("../controllers/solana.controller");
const path_1 = __importDefault(require("path"));
function initializeSolanaRoutes(io) {
    const router = (0, express_1.Router)();
    const solanaController = new solana_controller_1.SolanaController(io);
    router.get('/', (_, res) => {
        res.sendFile(path_1.default.join(__dirname, '../views/solana.html'));
    });
    router.get('/blocks', (req, res) => {
        try {
            const blockHistory = solanaController.getBlockHistory();
            res.json(blockHistory);
        }
        catch (error) {
            res.status(500).json({ error: 'Failed to fetch block history' });
        }
    });
    return router;
}
