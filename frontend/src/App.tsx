import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Home from './pages/Home';


const App: React.FC = () => {
  return (
    <html data-theme="light">
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<h1>About</h1>} />
        </Routes>
      </Router>
    </html>
  );
};

export default App;
