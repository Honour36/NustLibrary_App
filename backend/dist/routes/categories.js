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
    try {
        const { data, error } = yield supabase_1.supabase
            .from('categories')
            .select('id, name, icon, description, pdfs(count)')
            .order('name');
        if (error)
            return res.status(400).json({ error: error.message });
        return res.json((data !== null && data !== void 0 ? data : []).map((item) => {
            var _a, _b, _c;
            return ({
                id: item.id,
                name: item.name,
                icon: item.icon,
                description: item.description,
                resource_count: (_c = (_b = (_a = item.pdfs) === null || _a === void 0 ? void 0 : _a[0]) === null || _b === void 0 ? void 0 : _b.count) !== null && _c !== void 0 ? _c : 0,
            });
        }));
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { name, icon, description } = req.body;
    try {
        const { data, error } = yield supabase_1.supabase.from('categories').insert([{ name, icon, description }]).select().single();
        if (error)
            return res.status(400).json({ error: error.message });
        return res.status(201).json(data);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
