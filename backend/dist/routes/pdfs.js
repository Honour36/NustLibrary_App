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
// Get featured/trending PDFs
router.get('/featured/list', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { data, error } = yield supabase_1.supabase
            .from('pdfs')
            .select('*, categories(name, icon)')
            .order('views', { ascending: false })
            .limit(10);
        if (error)
            return res.status(400).json({ error: error.message });
        return res.json(data);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Get all PDFs (with optional search, category filter)
router.get('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { search, category_id, sort = 'recent', page = '1', limit = '20' } = req.query;
    const pageNum = parseInt(page);
    const limitNum = parseInt(limit);
    const offset = (pageNum - 1) * limitNum;
    try {
        let query = supabase_1.supabase
            .from('pdfs')
            .select('*, categories(name, icon)', { count: 'exact' })
            .range(offset, offset + limitNum - 1)
            .order(sort === 'popular' ? 'downloads' : 'created_at', { ascending: false });
        if (search)
            query = query.ilike('title', `%${search}%`);
        if (category_id)
            query = query.eq('category_id', category_id);
        const { data, error, count } = yield query;
        if (error)
            return res.status(400).json({ error: error.message });
        return res.json({ data, total: count, page: pageNum, limit: limitNum });
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Get single PDF by ID
router.get('/:id', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    try {
        const { data, error } = yield supabase_1.supabase
            .from('pdfs')
            .select('*, categories(name, icon)')
            .eq('id', id)
            .single();
        if (error)
            return res.status(404).json({ error: 'PDF not found' });
        // Increment view count
        yield supabase_1.supabase.from('pdfs').update({ views: (data.views || 0) + 1 }).eq('id', id);
        return res.json(data);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Upload PDF metadata
router.post('/', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { title, description, category_id, file_url, file_size, author, year, tags } = req.body;
    try {
        const { data, error } = yield supabase_1.supabase.from('pdfs').insert([
            { title, description, category_id, file_url, file_size, author, year, tags, views: 0, downloads: 0 },
        ]).select().single();
        if (error)
            return res.status(400).json({ error: error.message });
        return res.status(201).json(data);
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
// Get download URL (increment download count)
router.post('/:id/download', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { id } = req.params;
    try {
        const { data, error } = yield supabase_1.supabase.from('pdfs').select('file_url, downloads, title').eq('id', id).single();
        if (error)
            return res.status(404).json({ error: 'PDF not found' });
        yield supabase_1.supabase.from('pdfs').update({ downloads: (data.downloads || 0) + 1 }).eq('id', id);
        return res.json({ file_url: data.file_url, title: data.title });
    }
    catch (_a) {
        return res.status(500).json({ error: 'Internal server error' });
    }
}));
exports.default = router;
