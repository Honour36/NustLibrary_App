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
            .select('*, pdfs(id, title, description, file_url, author, year, views, downloads, categories(name, icon))')
            .eq('user_id', user_id)
            .order('created_at', { ascending: false });
        if (error) {
            console.warn('Bookmarks fetch error:', error.message);
            return res.json([]); // Return empty instead of erroring
        }
        return res.json(data !== null && data !== void 0 ? data : []);
    }
    catch (_a) {
        return res.json([]);
    }
}));
// Toggle bookmark (add if not exists, remove if exists)
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { user_id, pdf_id } = req.body;
    if (!user_id || !pdf_id) {
        return res.status(400).json({ error: 'user_id and pdf_id are required' });
    }
    try {
        // Check if bookmark already exists
        const { data: existing } = yield supabase_1.supabase
            .from('bookmarks')
            .select('id')
            .eq('user_id', user_id)
            .eq('pdf_id', pdf_id)
            .single();
        if (existing) {
            // Remove it
            const { error } = yield supabase_1.supabase
                .from('bookmarks')
                .delete()
                .eq('user_id', user_id)
                .eq('pdf_id', pdf_id);
            if (error)
                throw error;
            return res.json({ saved: false, message: 'Bookmark removed' });
        }
        else {
            // Add it
            const { data, error } = yield supabase_1.supabase
                .from('bookmarks')
                .insert([{ user_id, pdf_id }])
                .select()
                .single();
            if (error)
                throw error;
            return res.status(201).json({ saved: true, message: 'Bookmark added', data });
        }
    }
    catch (err) {
        console.error('Bookmark toggle error:', err.message);
        return res.status(400).json({ error: err.message });
    }
}));
// Check if a specific PDF is bookmarked
router.get('/:user_id/check/:pdf_id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { user_id, pdf_id } = req.params;
    try {
        const { data } = yield supabase_1.supabase
            .from('bookmarks')
            .select('id')
            .eq('user_id', user_id)
            .eq('pdf_id', pdf_id)
            .single();
        return res.json({ saved: !!data });
    }
    catch (_a) {
        return res.json({ saved: false });
    }
}));
exports.default = router;
