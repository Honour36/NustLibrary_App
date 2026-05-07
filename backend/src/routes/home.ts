import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  const { user_id } = req.query;
  
  try {
    const [featured, trending, recent, categories] = await Promise.all([
      supabase.from('pdfs').select('*, categories(name, icon)').order('downloads', { ascending: false }).limit(5),
      supabase.from('pdfs').select('*, categories(name, icon)').order('views', { ascending: false }).limit(8),
      supabase.from('pdfs').select('*, categories(name, icon)').order('created_at', { ascending: false }).limit(8),
      supabase.from('categories').select('id, name, icon, description').order('name'),
    ]);

    let continueReading: any[] = [];
    if (user_id) {
      const { data: progressData } = await supabase
        .from('reading_progress')
        .select('progress, pdfs(*, categories(name, icon))')
        .eq('user_id', user_id)
        .order('updated_at', { ascending: false })
        .limit(3);
      
      if (progressData) {
        continueReading = progressData.map(p => ({
          ...p.pdfs,
          reading_progress: p.progress,
        }));
      }
    } else {
      // Fallback for guests or if no user_id - show recent docs with 0 progress
      continueReading = (recent.data ?? []).slice(0, 3).map(doc => ({
        ...doc,
        reading_progress: 0,
      }));
    }

    return res.json({
      featured: featured.data ?? [],
      trending: trending.data ?? [],
      recent: recent.data ?? [],
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
