import { Router, Request, Response } from 'express';
import { uploads } from '../store/mockData';

const router = Router();

router.get('/queue', async (_req: Request, res: Response) => {
  return res.json(
    uploads.map((item) => ({
      id: item.id,
      title: item.title,
      status: item.status,
      created_at: item.created_at,
    })),
  );
});

export default router;
