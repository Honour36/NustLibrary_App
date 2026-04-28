"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const mockData_1 = require("../store/mockData");
const router = (0, express_1.Router)();
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b;
    const flag = {
        id: `flag-${Date.now()}`,
        document_id: (_a = req.body.document_id) !== null && _a !== void 0 ? _a : '',
        reason: (_b = req.body.reason) !== null && _b !== void 0 ? _b : '',
        created_at: new Date().toISOString(),
    };
    mockData_1.flags.unshift(flag);
    return res.status(201).json(flag);
}));
exports.default = router;
