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
router.get('/:documentId', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { documentId } = req.params;
    return res.json(mockData_1.reviews.filter((review) => review.document_id === documentId));
}));
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c, _d;
    const review = {
        id: `review-${Date.now()}`,
        document_id: (_a = req.body.document_id) !== null && _a !== void 0 ? _a : '',
        user_name: (_b = req.body.user_name) !== null && _b !== void 0 ? _b : 'Anonymous',
        rating: Number((_c = req.body.rating) !== null && _c !== void 0 ? _c : 0),
        comment: (_d = req.body.comment) !== null && _d !== void 0 ? _d : '',
        created_at: new Date().toISOString(),
    };
    mockData_1.reviews.unshift(review);
    return res.status(201).json(review);
}));
exports.default = router;
