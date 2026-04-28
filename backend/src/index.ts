import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth';
import pdfRoutes from './routes/pdfs';
import categoryRoutes from './routes/categories';
import bookmarkRoutes from './routes/bookmarks';
import homeRoutes from './routes/home';
import searchRoutes from './routes/search';
import uploadRoutes from './routes/uploads';
import moderationRoutes from './routes/moderation';
import downloadRoutes from './routes/downloads';
import ratingRoutes from './routes/ratings';
import flagRoutes from './routes/flags';
import adminRoutes from './routes/admin';
import onboardingRoutes from './routes/onboarding';
import storageRoutes from './routes/storage';

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'ok', message: 'NUST PDF Library API is running' });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/home', homeRoutes);
app.use('/api/pdfs', pdfRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/bookmarks', bookmarkRoutes);
app.use('/api/search', searchRoutes);
app.use('/api/uploads', uploadRoutes);
app.use('/api/moderation', moderationRoutes);
app.use('/api/downloads', downloadRoutes);
app.use('/api/ratings', ratingRoutes);
app.use('/api/flags', flagRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/onboarding', onboardingRoutes);
app.use('/api/storage', storageRoutes);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(port, () => {
  console.log(`🚀 NUST PDF Library API running on http://localhost:${port}`);
});

export default app;
