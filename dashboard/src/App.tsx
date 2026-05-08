import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { motion, useSpring, useTransform } from 'framer-motion';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api',
});

const App: React.FC = () => {
  const [loading, setLoading] = useState(true);
  
  // Spring animation for the number
  const count = useSpring(0, {
    stiffness: 40,
    damping: 20,
    restDelta: 0.001
  });
  
  const displayCount = useTransform(count, (latest) => {
    const val = Math.floor(latest);
    return val < 10 ? `0${val}` : val.toString();
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await api.get('/admin/dashboard');
        const users = response.data.summary.total_users || 0;
        // Start animation after a small delay
        setTimeout(() => {
          count.set(users);
        }, 500);
      } catch (error) {
        console.error('Error fetching dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [count]);

  return (
    <div className="dashboard-wrapper">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
      >
        <div className="label">Total Library Users</div>
        <motion.div className="counter">
          {displayCount}
        </motion.div>
        
        {loading && (
          <div className="loading-bar">
            <motion.div 
              className="loading-progress"
              animate={{ width: "100%" }}
              transition={{ duration: 1, repeat: Infinity }}
            />
          </div>
        )}
      </motion.div>
    </div>
  );
};

export default App;
