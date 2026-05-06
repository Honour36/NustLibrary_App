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
const router = (0, express_1.Router)();
router.get('/', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c, _d;
    try {
        const [featured, trending, recent, categories] = yield Promise.all([
            supabase_1.supabase.from('pdfs').select('*, categories(name, icon)').order('downloads', { ascending: false }).limit(5),
            supabase_1.supabase.from('pdfs').select('*, categories(name, icon)').order('views', { ascending: false }).limit(8),
            supabase_1.supabase.from('pdfs').select('*, categories(name, icon)').order('created_at', { ascending: false }).limit(8),
            supabase_1.supabase.from('categories').select('id, name, icon, description').order('name'),
        ]);
        // Log errors but don't fail the whole request — return empty arrays instead
        if (featured.error)
            console.warn('featured error:', featured.error.message);
        if (trending.error)
            console.warn('trending error:', trending.error.message);
        if (recent.error)
            console.warn('recent error:', recent.error.message);
        if (categories.error)
            console.warn('categories error:', categories.error.message);
        const recentDocs = (_a = recent.data) !== null && _a !== void 0 ? _a : [];
        // Mock continue_reading from recent docs with a fake progress field
        const continueReading = recentDocs.slice(0, 3).map(doc => (Object.assign(Object.assign({}, doc), { reading_progress: Math.random() * 0.8 + 0.1 })));
        return res.json({
            featured: (_b = featured.data) !== null && _b !== void 0 ? _b : [],
            trending: (_c = trending.data) !== null && _c !== void 0 ? _c : [],
            recent: recentDocs,
            categories: (_d = categories.data) !== null && _d !== void 0 ? _d : [],
            continue_reading: continueReading,
        });
    }
    catch (err) {
        console.error('Home error:', err.message);
        // Return empty payload so the app still loads
        return res.json({
            featured: [],
            trending: [],
            recent: [],
            categories: [],
            continue_reading: [],
        });
    }
}));
exports.default = router;
