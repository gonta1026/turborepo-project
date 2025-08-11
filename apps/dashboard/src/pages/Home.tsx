import { Counter, Header } from '@repo/ui'
import { Link } from 'react-router-dom'
import typescriptLogo from '/typescript.svg'

export const Home = () => {
  return (
    <div className="page">
      <div className="logo-container">
        <a href="https://vitejs.dev" target="_blank" rel="noopener">
          <img src="/vite.svg" className="logo" alt="Vite logo" />
        </a>
        <a href="https://www.typescriptlang.org/" target="_blank" rel="noopener">
          <img src={typescriptLogo} className="logo vanilla" alt="TypeScript logo" />
        </a>
      </div>

      <Header title="Dashboard - Home" />

      <div className="content">
        <h2>Welcome to the Home Page_2</h2>
        <p>This is the main dashboard where you can interact with the counter.</p>

        <div className="card">
          <Counter />
        </div>

        <nav className="navigation">
          <Link to="/about" className="nav-link">
            Go to About Page
          </Link>
        </nav>
      </div>
    </div>
  )
}
