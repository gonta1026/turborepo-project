import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import { describe, expect, it } from "vitest";

// Simple test component to verify setup
function TestApp() {
	return (
		<BrowserRouter>
			<div>
				<h1>Test App</h1>
				<p>Testing setup is working!</p>
			</div>
		</BrowserRouter>
	);
}

describe("App Testing Setup", () => {
	it("should render test component", () => {
		render(<TestApp />);

		expect(screen.getByText("Test App")).toBeInTheDocument();
		expect(screen.getByText("Testing setup is working!")).toBeInTheDocument();
	});
});
