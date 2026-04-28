import { Router, Request, Response } from 'express';
import { reviews } from '../store/mockData';

const router = Router();

router.get('/:documentId', async (req: Request, res: Response) => {
  const { documentId } = req.params;
  return res.json(reviews.filter((review) => review.document_id === documentId));
});

router.post('/', async (req: Request, res: Response) => {
  const review = {
    id: `review-${Date.now()}`,
    document_id: req.body.document_id ?? '',
    user_name: req.body.user_name ?? 'Anonymous',
    rating: Number(req.body.rating ?? 0),
    comment: req.body.comment ?? '',
    created_at: new Date().toISOString(),
  };
  reviews.unshift(review);
  return res.status(201).json(review);
});

export default router;
