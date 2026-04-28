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
        if (featured.error || trending.error || recent.error || categories.error) {
            return res.status(400).json({ error: 'Unable to build home payload' });
        }
        return res.json({
            featured: (_a = featured.data) !== null && _a !== void 0 ? _a : [],
            trending: (_b = trending.data) !== null && _b !== void 0 ? _b : [],
            recent: (_c = recent.data) !== null && _c !== void 0 ? _c : [],
            categories: (_d = categories.data) !== null && _d !== void 0 ? _d : [],
        });
    }
    catch (_e) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
