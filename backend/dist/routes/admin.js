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
const supabase_1 = require("../config/supabase");
const mockData_1 = require("../store/mockData");
const router = (0, express_1.Router)();
router.get('/dashboard', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a;
    try {
        const { data: docs } = yield supabase_1.supabase.from('pdfs').select('*, categories(name, icon)').limit(5).order('views', { ascending: false });
        const summary = {
            documents: (_a = docs === null || docs === void 0 ? void 0 : docs.length) !== null && _a !== void 0 ? _a : 0,
            pending_uploads: mockData_1.uploads.length,
            flags: mockData_1.flags.length,
            reviews: mockData_1.reviews.length,
        };
        return res.json({
            summary,
            flagged_documents: docs !== null && docs !== void 0 ? docs : [],
            recent_users: mockData_1.uploads.slice(0, 5).map((item) => ({
                name: item.user_name,
                email: `${item.user_name.toLowerCase().replace(/ /g, '.')}@student.nust.na`,
            })),
        });
    }
    catch (_b) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
router.get('/documents', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { data, error } = yield supabase_1.supabase.from('pdfs').select('*, categories(name, icon)').order('created_at', { ascending: false }).limit(20);
        if (error)
            return res.status(400).json({ error: error.message });
        return res.json(data !== null && data !== void 0 ? data : []);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
router.get('/users', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    return res.json(mockData_1.uploads.slice(0, 10).map((item) => ({
        name: item.user_name,
        email: `${item.user_name.toLowerCase().replace(/ /g, '.')}@student.nust.na`,
        status: item.status,
    })));
}));
router.get('/analytics', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { data } = yield supabase_1.supabase.from('pdfs').select('views, downloads');
        const totals = (data !== null && data !== void 0 ? data : []).reduce((acc, item) => {
            var _a, _b;
            acc.views += (_a = item.views) !== null && _a !== void 0 ? _a : 0;
            acc.downloads += (_b = item.downloads) !== null && _b !== void 0 ? _b : 0;
            return acc;
        }, { views: 0, downloads: 0 });
        return res.json({
            total_views: totals.views,
            total_downloads: totals.downloads,
            pending_flags: mockData_1.flags.length,
            pending_uploads: mockData_1.uploads.length,
        });
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
