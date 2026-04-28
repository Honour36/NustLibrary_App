import { Router, Request, Response } from 'express';
import { downloads } from '../store/mockData';

const router = Router();

router.get('/:userId', async (req: Request, res: Response) => {
  const { userId } = req.params;
  return res.json(downloads.filter((item) => item.user_id === userId || userId === ''));
});

export default router;
