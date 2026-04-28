"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const dotenv_1 = __importDefault(require("dotenv"));
const auth_1 = __importDefault(require("./routes/auth"));
const pdfs_1 = __importDefault(require("./routes/pdfs"));
const categories_1 = __importDefault(require("./routes/categories"));
const bookmarks_1 = __importDefault(require("./routes/bookmarks"));
const home_1 = __importDefault(require("./routes/home"));
const search_1 = __importDefault(require("./routes/search"));
const uploads_1 = __importDefault(require("./routes/uploads"));
const moderation_1 = __importDefault(require("./routes/moderation"));
const downloads_1 = __importDefault(require("./routes/downloads"));
const ratings_1 = __importDefault(require("./routes/ratings"));
const flags_1 = __importDefault(require("./routes/flags"));
const admin_1 = __importDefault(require("./routes/admin"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const port = process.env.PORT || 3000;
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Health check
app.get('/health', (_req, res) => {
    res.status(200).json({ status: 'ok', message: 'NUST PDF Library API is running' });
});
// Routes
app.use('/api/auth', auth_1.default);
app.use('/api/home', home_1.default);
app.use('/api/pdfs', pdfs_1.default);
app.use('/api/categories', categories_1.default);
app.use('/api/bookmarks', bookmarks_1.default);
app.use('/api/search', search_1.default);
app.use('/api/uploads', uploads_1.default);
app.use('/api/moderation', moderation_1.default);
app.use('/api/downloads', downloads_1.default);
app.use('/api/ratings', ratings_1.default);
app.use('/api/flags', flags_1.default);
app.use('/api/admin', admin_1.default);
// 404 handler
app.use((_req, res) => {
    res.status(404).json({ error: 'Route not found' });
});
app.listen(port, () => {
    console.log(`🚀 NUST PDF Library API running on http://localhost:${port}`);
});
exports.default = app;
