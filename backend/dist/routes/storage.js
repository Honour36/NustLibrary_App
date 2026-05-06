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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const multer_1 = __importDefault(require("multer"));
const supabase_1 = require("../config/supabase");
const uuid_1 = require("uuid");
const router = (0, express_1.Router)();
const upload = (0, multer_1.default)({ storage: multer_1.default.memoryStorage() });
const BUCKET_NAME = 'pdfs';
// Initialize buckets
router.get('/init', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const buckets = ['pdfs', 'user-icons'];
    const results = [];
    for (const bucket of buckets) {
        try {
            const { data, error } = yield supabase_1.supabase.storage.createBucket(bucket, {
                public: true
            });
            if (error) {
                if (error.message.includes('already exists')) {
                    results.push({ bucket, status: 'already exists' });
                }
                else {
                    results.push({ bucket, status: 'error', error: error.message });
                }
            }
            else {
                results.push({ bucket, status: 'created', data });
            }
        }
        catch (err) {
            results.push({ bucket, status: 'exception', error: err.message });
        }
    }
    return res.json(results);
}));
// Sync bucket files to database
router.get('/sync', (_req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // 1. List all files in the bucket
        const { data: files, error: storageError } = yield supabase_1.supabase.storage
            .from(BUCKET_NAME)
            .list('pdfs'); // Check the 'pdfs' folder inside the bucket
        if (storageError) {
            // Try root if 'pdfs' folder doesn't exist
            const { data: rootFiles, error: rootError } = yield supabase_1.supabase.storage.from(BUCKET_NAME).list('');
            if (rootError)
                throw rootError;
            return syncFiles(rootFiles || [], '', res);
        }
        return syncFiles(files || [], 'pdfs/', res);
    }
    catch (error) {
        console.error('Sync Error:', error);
        return res.status(500).json({ error: 'Failed to sync storage with database', details: error.message });
    }
}));
function syncFiles(files, prefix, res) {
    return __awaiter(this, void 0, void 0, function* () {
        try {
            // 2. Get existing PDF URLs from database
            const { data: existingPdfs } = yield supabase_1.supabase.from('pdfs').select('file_url');
            const existingUrls = new Set((existingPdfs || []).map(p => p.file_url));
            // 3. Get a default category
            const { data: category } = yield supabase_1.supabase.from('categories').select('id').limit(1).single();
            const defaultCategoryId = category === null || category === void 0 ? void 0 : category.id;
            const imported = [];
            for (const file of files) {
                if (file.name === '.emptyFolderPlaceholder')
                    continue;
                const { data: urlData } = supabase_1.supabase.storage.from(BUCKET_NAME).getPublicUrl(`${prefix}${file.name}`);
                const url = urlData.publicUrl;
                if (!existingUrls.has(url)) {
                    // Create a record for the orphaned file
                    const title = file.name.split('-').slice(1).join('-').split('.').first() || file.name;
                    const { data: newDoc, error: insertError } = yield supabase_1.supabase.from('pdfs').insert({
                        title: title.replace(/%20/g, ' '),
                        file_url: url,
                        category_id: defaultCategoryId,
                        author: 'System Import',
                        views: 0,
                        downloads: 0
                    }).select().single();
                    if (!insertError)
                        imported.push(newDoc);
                }
            }
            return res.json({
                message: 'Sync complete',
                found: files.length,
                imported_count: imported.length,
                imported
            });
        }
        catch (error) {
            return res.status(500).json({ error: 'Sync failed during processing', details: error.message });
        }
    });
}
// Upload a file to Supabase Storage
router.post('/upload', upload.single('file'), (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    if (!req.file) {
        return res.status(400).json({ error: 'No file uploaded' });
    }
    const bucket = req.body.bucket || BUCKET_NAME;
    const folder = req.body.folder || 'pdfs';
    const fileName = `${folder}/${(0, uuid_1.v4)()}-${req.file.originalname}`;
    try {
        const { data, error } = yield supabase_1.supabase.storage
            .from(bucket)
            .upload(fileName, req.file.buffer, {
            contentType: req.file.mimetype,
            upsert: true
        });
        if (error)
            throw error;
        const { data: urlData } = supabase_1.supabase.storage.from(bucket).getPublicUrl(fileName);
        return res.json({
            message: 'File uploaded successfully',
            url: urlData.publicUrl,
            key: fileName
        });
    }
    catch (error) {
        console.error('Supabase Storage Upload Error:', error);
        return res.status(500).json({ error: 'Failed to upload file to storage', details: error.message });
    }
}));
// List files in a bucket/folder
router.get('/files', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const folder = req.query.folder || '';
    const bucket = req.query.bucket || BUCKET_NAME;
    try {
        const { data, error } = yield supabase_1.supabase.storage.from(bucket).list(folder);
        if (error)
            throw error;
        const files = (data || []).map((item) => {
            var _a;
            const { data: urlData } = supabase_1.supabase.storage.from(bucket).getPublicUrl(`${folder}/${item.name}`);
            return {
                key: item.name,
                size: (_a = item.metadata) === null || _a === void 0 ? void 0 : _a.size,
                lastModified: item.updated_at,
                url: urlData.publicUrl
            };
        });
        return res.json(files);
    }
    catch (error) {
        return res.status(500).json({ error: 'Failed to fetch files from storage', details: error.message });
    }
}));
exports.default = router;
