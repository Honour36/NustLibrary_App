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
router.get('/:userId', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { userId } = req.params;
    const items = mockData_1.uploads
        .filter((item) => item.user_id === userId || userId === '')
        .map((item) => ({
        id: item.id,
        title: item.title,
        description: item.description,
        author: item.author,
        category_id: item.category_name.toLowerCase().replace(/ /g, '-'),
        category_name: item.category_name,
        file_url: item.file_url,
        views: 0,
        downloads: 0,
    }));
    return res.json(items);
}));
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c, _d, _e, _f, _g;
    const payload = req.body;
    const item = {
        id: `upload-${Date.now()}`,
        title: (_a = payload.title) !== null && _a !== void 0 ? _a : 'Untitled upload',
        author: (_b = payload.author) !== null && _b !== void 0 ? _b : 'Unknown',
        category_name: (_c = payload.category_name) !== null && _c !== void 0 ? _c : 'General',
        description: (_d = payload.description) !== null && _d !== void 0 ? _d : '',
        file_url: (_e = payload.file_url) !== null && _e !== void 0 ? _e : '',
        user_id: (_f = payload.user_id) !== null && _f !== void 0 ? _f : '',
        user_name: (_g = payload.user_name) !== null && _g !== void 0 ? _g : 'Student',
        status: 'pending',
        created_at: new Date().toISOString(),
    };
    mockData_1.uploads.unshift(item);
    return res.status(201).json(item);
}));
exports.default = router;
