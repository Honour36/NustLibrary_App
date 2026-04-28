import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';

const router = Router();

// Get uploads for a specific user or all uploads
router.get('/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    let query = supabase.from('pdfs').select('*, categories(name)');
    
    if (userId && userId !== 'all' && userId !== 'null') {
      query = query.eq('user_id', userId);
    }
    
    const { data, error } = await query.order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error fetching uploads:', error);
      return res.status(400).json({ error: error.message });
    }
    
    return res.json(data);
  } catch (err) {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

// Helper: return null if a value is a mock/placeholder UUID
function realUuidOrNull(val: string | undefined | null): string | null {
  if (!val) return null;
  // Mock UUIDs we generated start with 00000000 or 10000000
  if (val.startsWith('00000000-') || val.startsWith('10000000-')) return null;
  return val;
}

// Create a new upload - inserts directly into pdfs table (no review queue)
router.post('/', async (req: Request, res: Response) => {
  const { title, description, category_id, faculty_id, program_id, year, author, file_url, user_id } = req.body;
  
  try {
    const safeCategoryId = realUuidOrNull(category_id);
    const safeFacultyId  = realUuidOrNull(faculty_id);
    const safeProgramId  = realUuidOrNull(program_id);

    const record: Record<string, any> = { 
      title, 
      description, 
      file_url, 
      author, 
      year: year || null,
      views: 0, 
      downloads: 0,
      featured: false,
    };

    // Only include FK fields if we have a real UUID
    if (safeCategoryId) record.category_id = safeCategoryId;
    if (safeFacultyId)  record.faculty_id  = safeFacultyId;
    if (safeProgramId)  record.program_id  = safeProgramId;
    if (user_id)        record.user_id     = user_id;

    const { data, error } = await supabase.from('pdfs').insert([record]).select().single();

    if (error) {
      console.error('Error creating direct upload:', error);
      return res.status(400).json({ error: error.message });
    }
    
    return res.status(201).json(data);
  } catch (err) {
    console.error('Critical error in direct upload:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
