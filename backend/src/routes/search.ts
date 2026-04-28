import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  const query = (req.query.query as string | undefined)?.trim();
  const categoryId = (req.query.category_id as string | undefined)?.trim();

  try {
    let searchQuery = supabase.from('pdfs').select('*, categories(name, icon)').limit(20).order('views', { ascending: false });
    if (query) searchQuery = searchQuery.or(`title.ilike.%${query}%,author.ilike.%${query}%`);
    if (categoryId) searchQuery = searchQuery.eq('category_id', categoryId);

    const [results, categories] = await Promise.all([
      searchQuery,
      supabase.from('categories').select('id, name, icon, description').order('name'),
    ]);

    if (results.error || categories.error) return res.status(400).json({ error: 'Search failed' });

    const suggestions = (results.data ?? []).slice(0, 5).map((item: any) => item.title);
    return res.json({
      results: results.data ?? [],
      suggestions,
      categories: categories.data ?? [],
    });
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
