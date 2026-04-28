import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

router.get('/', async (_req: Request, res: Response) => {
  try {
    const { data, error } = await supabase
      .from('categories')
      .select('id, name, icon, description, pdfs(count)')
      .order('name');
    if (error) return res.status(400).json({ error: error.message });
    return res.json(
      (data ?? []).map((item: any) => ({
        id: item.id,
        name: item.name,
        icon: item.icon,
        description: item.description,
        resource_count: item.pdfs?.[0]?.count ?? 0,
      })),
    );
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/', async (req: Request, res: Response) => {
  const { name, icon, description } = req.body;
  try {
    const { data, error } = await supabase.from('categories').insert([{ name, icon, description }]).select().single();
    if (error) return res.status(400).json({ error: error.message });
    return res.status(201).json(data);
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
