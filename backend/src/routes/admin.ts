import { Router, Request, Response } from 'express';
import { supabase } from '../config/supabase';
import { flags, reviews, uploads } from '../store/mockData';

import { facultiesData } from '../store/seed_onboarding';

const router = Router();

router.post('/seed-onboarding', async (_req: Request, res: Response) => {
  try {
    for (const faculty of facultiesData) {
      // Insert faculty
      const { data: facultyRecord, error: fError } = await supabase
        .from('faculties')
        .upsert({ name: faculty.name }, { onConflict: 'name' })
        .select()
        .single();

      if (fError) {
        console.error(`Error inserting faculty ${faculty.name}:`, fError);
        continue;
      }

      // Insert programs for this faculty
      const programs = faculty.programs.map((p) => ({
        name: p.name,
        level: p.level,
        faculty_id: facultyRecord.id,
      }));

      const { error: pError } = await supabase
        .from('programs')
        .upsert(programs, { onConflict: 'name, faculty_id' });

      if (pError) {
        console.error(`Error inserting programs for ${faculty.name}:`, pError);
      }
    }

    return res.json({ message: 'Onboarding data seeded successfully' });
  } catch (err) {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/dashboard', async (_req: Request, res: Response) => {
  try {
    const { data: docs } = await supabase.from('pdfs').select('*, categories(name, icon)').limit(5).order('views', { ascending: false });
    const summary = {
      documents: docs?.length ?? 0,
      pending_uploads: uploads.length,
      flags: flags.length,
      reviews: reviews.length,
    };

    return res.json({
      summary,
      flagged_documents: docs ?? [],
      recent_users: uploads.slice(0, 5).map((item) => ({
        name: item.user_name,
        email: `${item.user_name.toLowerCase().replace(/ /g, '.')}@student.nust.na`,
      })),
    });
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/documents', async (_req: Request, res: Response) => {
  try {
    const { data, error } = await supabase.from('pdfs').select('*, categories(name, icon)').order('created_at', { ascending: false }).limit(20);
    if (error) return res.status(400).json({ error: error.message });
    return res.json(data ?? []);
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/users', async (_req: Request, res: Response) => {
  return res.json(
    uploads.slice(0, 10).map((item) => ({
      name: item.user_name,
      email: `${item.user_name.toLowerCase().replace(/ /g, '.')}@student.nust.na`,
      status: item.status,
    })),
  );
});

router.get('/analytics', async (_req: Request, res: Response) => {
  try {
    const { data } = await supabase.from('pdfs').select('views, downloads');
    const totals = (data ?? []).reduce(
      (acc: { views: number; downloads: number }, item: any) => {
        acc.views += item.views ?? 0;
        acc.downloads += item.downloads ?? 0;
        return acc;
      },
      { views: 0, downloads: 0 },
    );

    return res.json({
      total_views: totals.views,
      total_downloads: totals.downloads,
      pending_flags: flags.length,
      pending_uploads: uploads.length,
    });
  } catch {
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
