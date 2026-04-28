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
// Get user bookmarks
router.get('/:user_id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { user_id } = req.params;
    try {
        const { data, error } = yield supabase_1.supabase
            .from('bookmarks')
            .select('*, pdfs(*, categories(name, icon))')
            .eq('user_id', user_id)
            .order('created_at', { ascending: false });
        if (error)
            return res.status(400).json({ error: error.message });
        return res.json(data);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Add bookmark
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { user_id, pdf_id } = req.body;
    try {
        const { data, error } = yield supabase_1.supabase.from('bookmarks').insert([{ user_id, pdf_id }]).select().single();
        if (error)
            return res.status(400).json({ error: error.message });
        return res.status(201).json(data);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Remove bookmark
router.delete('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { user_id, pdf_id } = req.body;
    try {
        const { error } = yield supabase_1.supabase.from('bookmarks').delete().eq('user_id', user_id).eq('pdf_id', pdf_id);
        if (error)
            return res.status(400).json({ error: error.message });
        return res.json({ message: 'Bookmark removed' });
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
