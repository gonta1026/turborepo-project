import { Header } from "@repo/ui";
import { Link } from "react-router-dom";

export const About = () => {
	return (
		<div className="page">
			<Header title="Dashboard - About" />

			<div className="content">
				<h2>About This Application</h2>

				<div className="about-content">
					<div className="feature-card">
						<h3>🚀 Modern Stack</h3>
						<p>
							Built with Vite, React, TypeScript, and Turborepo for optimal
							development experience.
						</p>
					</div>

					<div className="feature-card">
						<h3>📦 Monorepo Architecture</h3>
						<p>
							Organized as a monorepo with shared UI components and
							configurations across applications.
						</p>
					</div>

					<div className="feature-card">
						<h3>⚡ Fast Development</h3>
						<p>
							Hot module replacement and optimized build tools for rapid
							iteration.
						</p>
					</div>

					<div className="feature-card">
						<h3>🎨 Shared UI Library</h3>
						<p>
							Consistent design system with reusable components across the
							entire application.
						</p>
					</div>
				</div>

				<nav className="navigation">
					<Link to="/" className="nav-link">
						Back to Home
					</Link>
				</nav>
			</div>
		</div>
	);
};
