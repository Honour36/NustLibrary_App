import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

router.get('/', async (_req: Request, res: Response) => {
  try {
    const [featured, trending, recent, categories] = await Promise.all([
      supabase.from('pdfs').select('*, categories(name, icon)').order('downloads', { ascending: false }).limit(5),
      supabase.from('pdfs').select('*, categories(name, icon)').order('views', { ascending: false }).limit(8),
      supabase.from('pdfs').select('*, categories(name, icon)').order('created_at', { ascending: false }).limit(8),
      supabase.from('categories').select('id, name, icon, description').order('name'),
    ]);

    // Log errors but don't fail the whole request — return empty arrays instead
    if (featured.error) console.warn('featured error:', featured.error.message);
    if (trending.error) console.warn('trending error:', trending.error.message);
    if (recent.error) console.warn('recent error:', recent.error.message);
    if (categories.error) console.warn('categories error:', categories.error.message);

    const recentDocs = recent.data ?? [];

    // Mock continue_reading from recent docs with a fake progress field
    const continueReading = recentDocs.slice(0, 3).map(doc => ({
      ...doc,
      reading_progress: Math.random() * 0.8 + 0.1,
    }));

    return res.json({
      featured: featured.data ?? [],
      trending: trending.data ?? [],
      recent: recentDocs,
      categories: categories.data ?? [],
      continue_reading: continueReading,
    });
  } catch (err: any) {
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
});

export default router;
