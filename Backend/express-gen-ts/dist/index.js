"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const ENV_1 = __importDefault(require("@src/common/constants/ENV"));
const server_1 = require("./server");
const SERVER_START_MSG = ('Express server started on port: ' +
    ENV_1.default.Port.toString());
const port = process.env.PORT ?? 3000;
server_1.httpServer.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
