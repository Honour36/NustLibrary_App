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
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, _b, _c, _d, _e;
    const query = (_a = req.query.query) === null || _a === void 0 ? void 0 : _a.trim();
    const categoryId = (_b = req.query.category_id) === null || _b === void 0 ? void 0 : _b.trim();
    try {
        let searchQuery = supabase_1.supabase.from('pdfs').select('*, categories(name, icon)').limit(20).order('views', { ascending: false });
        if (query)
            searchQuery = searchQuery.or(`title.ilike.%${query}%,author.ilike.%${query}%`);
        if (categoryId)
            searchQuery = searchQuery.eq('category_id', categoryId);
        const [results, categories] = yield Promise.all([
            searchQuery,
            supabase_1.supabase.from('categories').select('id, name, icon, description').order('name'),
        ]);
        if (results.error || categories.error)
            return res.status(400).json({ error: 'Search failed' });
        const suggestions = ((_c = results.data) !== null && _c !== void 0 ? _c : []).slice(0, 5).map((item) => item.title);
        return res.json({
            results: (_d = results.data) !== null && _d !== void 0 ? _d : [],
            suggestions,
            categories: (_e = categories.data) !== null && _e !== void 0 ? _e : [],
        });
    }
    catch (_f) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
