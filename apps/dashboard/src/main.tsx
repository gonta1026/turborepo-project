import { createRoot } from 'react-dom/client'
import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { About } from './pages/About'
import { Home } from './pages/Home'
import { Todos } from './pages/Todos'
import './style.css'

const App = () => (
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/about" element={<About />} />
      <Route path="/todos" element={<Todos />} />
    </Routes>
  </BrowserRouter>
)

const app = document.getElementById('app') as HTMLElement
createRoot(app).render(<App />)
