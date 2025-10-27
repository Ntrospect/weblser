#!/usr/bin/env python3
"""
PDF Development Server - Live preview for PDF templates
Allows iterative development with hot-reload of PDF templates
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path
from http.server import HTTPServer, SimpleHTTPRequestHandler
import urllib.parse
from urllib.parse import urljoin

try:
    from playwright.sync_api import sync_playwright
except ImportError:
    print("ERROR: Playwright not installed. Run: python -m pip install playwright")
    sys.exit(1)

from jinja2 import Environment, FileSystemLoader, select_autoescape
from analyzer import WebsiteAnalyzer


class PDFPreviewHandler(SimpleHTTPRequestHandler):
    """HTTP handler for PDF preview server"""

    def do_GET(self):
        """Handle GET requests"""
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        query = urllib.parse.parse_qs(parsed_path.query)

        # Serve static files
        if path.endswith('.css') or path.endswith('.js') or path.endswith('.html'):
            return super().do_GET()

        # API endpoints
        if path == '/':
            self.serve_dashboard()
        elif path.startswith('/api/preview/'):
            self.preview_pdf(path, query)
        elif path.startswith('/api/generate/'):
            self.generate_test_data(path, query)
        else:
            self.send_error(404)

    def serve_dashboard(self):
        """Serve the development dashboard"""
        dashboard_html = """
<!DOCTYPE html>
<html>
<head>
    <title>PDF Development Preview</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }
        .container {
            max-width: 1600px;
            margin: 0 auto;
        }
        h1 {
            color: #1f2937;
            margin-bottom: 20px;
        }
        .controls {
            background: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .control-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #374151;
        }
        select, input {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
        }
        button {
            background: #9018ad;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.2s;
        }
        button:hover {
            background: #7b1293;
        }
        .preview-area {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-top: 20px;
        }
        .preview-panel {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .panel-header {
            background: #9018ad;
            color: white;
            padding: 15px;
            font-weight: 600;
        }
        iframe {
            width: 100%;
            height: 800px;
            border: none;
        }
        .editor-panel {
            display: flex;
            flex-direction: column;
        }
        textarea {
            flex: 1;
            padding: 15px;
            font-family: 'Monaco', 'Menlo', monospace;
            font-size: 12px;
            border: none;
            resize: none;
        }
        .info {
            background: #e0f2fe;
            border-left: 4px solid #0284c7;
            padding: 12px;
            margin-bottom: 15px;
            border-radius: 4px;
            font-size: 13px;
        }
        .status {
            padding: 10px;
            text-align: center;
            font-size: 12px;
            color: #6b7280;
        }
        @media (max-width: 1200px) {
            .preview-area {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎨 PDF Template Development Preview</h1>

        <div class="info">
            ℹ️ <strong>How to use:</strong> Select a template type and test data, then preview the PDF.
            Edit the template HTML on the right to see changes instantly.
        </div>

        <div class="controls">
            <div class="control-group">
                <label>Template Type</label>
                <select id="templateType">
                    <option value="summary">Summary Report</option>
                    <option value="audit">Audit Report</option>
                </select>
            </div>

            <div class="control-group">
                <label>Theme</label>
                <select id="theme">
                    <option value="light">Light Theme</option>
                    <option value="dark">Dark Theme</option>
                </select>
            </div>

            <div class="control-group">
                <label>Test Data</label>
                <select id="testData">
                    <option value="example">Example.com</option>
                    <option value="github">GitHub.com</option>
                    <option value="generate">Generate New</option>
                </select>
            </div>

            <button onclick="loadPreview()">Load Preview</button>
        </div>

        <div class="preview-area">
            <div class="preview-panel">
                <div class="panel-header">📄 PDF Preview</div>
                <iframe id="pdfFrame" src="about:blank"></iframe>
                <div class="status">Rendering PDF...</div>
            </div>

            <div class="preview-panel editor-panel">
                <div class="panel-header">✏️ Template Editor</div>
                <textarea id="templateEditor" placeholder="Template HTML will appear here..."></textarea>
                <button style="margin: 10px; border-radius: 0;" onclick="saveAndReload()">💾 Save & Reload</button>
            </div>
        </div>
    </div>

    <script>
        async function loadPreview() {
            const templateType = document.getElementById('templateType').value;
            const theme = document.getElementById('theme').value;
            const testData = document.getElementById('testData').value;

            // Load template
            const templateUrl = `/api/preview/${templateType}?theme=${theme}&data=${testData}`;
            document.getElementById('pdfFrame').src = templateUrl;

            // Load template editor
            fetch(`/api/template?type=${templateType}&theme=${theme}`)
                .then(r => r.text())
                .then(html => {
                    document.getElementById('templateEditor').value = html;
                })
                .catch(e => console.error('Error loading template:', e));
        }

        async function saveAndReload() {
            const templateType = document.getElementById('templateType').value;
            const theme = document.getElementById('theme').value;
            const templateHtml = document.getElementById('templateEditor').value;

            // Save template
            const response = await fetch(`/api/template`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    type: templateType,
                    theme: theme,
                    content: templateHtml
                })
            });

            if (response.ok) {
                // Reload preview
                loadPreview();
                alert('✅ Template saved and preview updated!');
            } else {
                alert('❌ Error saving template');
            }
        }

        // Load initial preview on page load
        window.addEventListener('load', loadPreview);
    </script>
</body>
</html>
        """
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        self.wfile.write(dashboard_html.encode())

    def preview_pdf(self, path, query):
        """Generate and serve PDF preview"""
        parts = path.split('/')
        template_type = parts[3] if len(parts) > 3 else 'summary'
        theme = query.get('theme', ['light'])[0]
        data_source = query.get('data', ['example'])[0]

        try:
            # Get test data
            test_data = self.get_test_data(data_source, template_type)

            # Render PDF
            pdf_bytes = self.render_pdf_to_bytes(template_type, theme, test_data)

            self.send_response(200)
            self.send_header('Content-type', 'application/pdf')
            self.send_header('Content-Length', str(len(pdf_bytes)))
            self.end_headers()
            self.wfile.write(pdf_bytes)
        except Exception as e:
            self.send_error(500, str(e))

    def get_test_data(self, source, template_type):
        """Get test data for preview"""
        if source == 'example':
            return {
                'url': 'https://example.com',
                'title': 'Example Domain',
                'meta_description': 'A demonstration website for technical documentation',
                'summary': 'This website (example.com) serves as a demonstration domain specifically created for use in technical documentation and examples. It\'s a safe, permission-free resource for developers, writers, and educators.',
                'timestamp': datetime.now().strftime('%B %d, %Y at %I:%M %p'),
                'report_date': datetime.now().strftime('%B %d, %Y'),
                'overall_score': 7.5 if template_type == 'audit' else None,
                'categories': {
                    'Performance': 8.2,
                    'Security': 7.1,
                    'SEO': 6.9,
                    'Accessibility': 7.5,
                    'Mobile Friendly': 8.1,
                    'Code Quality': 7.3,
                    'Page Speed': 7.8,
                    'User Experience': 7.4,
                    'Compliance': 7.6,
                    'Best Practices': 7.2
                } if template_type == 'audit' else None,
                'strengths': [
                    'Well-structured HTML and semantic markup',
                    'Fast page load times',
                    'Mobile responsive design',
                    'Good accessibility features',
                    'Regular security updates'
                ] if template_type == 'audit' else None,
                'company_name': 'Jumoki Agency LLC',
                'company_details': '1309 Coffeen Avenue STE 1200, Sheridan WY 82801, 1(307)650-2395, info@jumoki.agency',
                'websler_logo': None,
                'jumoki_logo': None
            }
        elif source == 'github':
            return {
                'url': 'https://github.com',
                'title': 'GitHub: Let\'s build from here',
                'meta_description': 'GitHub is where over 100 million developers shape the future of software',
                'summary': 'GitHub is a cloud-based platform that enables developers to collaborate on code projects, manage version control, and deploy applications. It hosts millions of open-source projects and serves as the central hub for modern software development.',
                'timestamp': datetime.now().strftime('%B %d, %Y at %I:%M %p'),
                'report_date': datetime.now().strftime('%B %d, %Y'),
                'overall_score': 8.7 if template_type == 'audit' else None,
                'categories': {
                    'Performance': 8.9,
                    'Security': 9.1,
                    'SEO': 8.3,
                    'Accessibility': 8.2,
                    'Mobile Friendly': 8.7,
                    'Code Quality': 8.8,
                    'Page Speed': 8.6,
                    'User Experience': 8.9,
                    'Compliance': 8.5,
                    'Best Practices': 8.7
                } if template_type == 'audit' else None,
                'strengths': [
                    'Excellent performance metrics',
                    'Industry-leading security practices',
                    'Comprehensive API documentation',
                    'Seamless user experience',
                    'Scalable infrastructure'
                ] if template_type == 'audit' else None,
                'company_name': 'Jumoki Agency LLC',
                'company_details': '1309 Coffeen Avenue STE 1200, Sheridan WY 82801, 1(307)650-2395, info@jumoki.agency',
                'websler_logo': None,
                'jumoki_logo': None
            }

    def render_pdf_to_bytes(self, template_type, theme, data):
        """Render PDF template to bytes using Playwright"""
        templates_dir = Path(__file__).parent / 'templates'
        template_file = f'jumoki_{template_type}_report_{theme}.html'
        template_path = templates_dir / template_file

        if not template_path.exists():
            raise FileNotFoundError(f"Template not found: {template_file}")

        # Load and render template
        env = Environment(
            loader=FileSystemLoader(str(templates_dir)),
            autoescape=select_autoescape(['html', 'xml'])
        )
        template = env.get_template(template_file)
        html_content = template.render(**data)

        # Convert HTML to PDF using Playwright
        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page()
            page.set_content(html_content)
            pdf_bytes = page.pdf()
            browser.close()

        return pdf_bytes

    def log_message(self, format, *args):
        """Suppress default logging"""
        pass


def start_server(port=8888):
    """Start the PDF development server"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, PDFPreviewHandler)
    print(f"""
╔══════════════════════════════════════════════════════════════╗
║          🎨 PDF Development Preview Server Started          ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  📍 Open in browser:  http://localhost:{port}                   ║
║                                                              ║
║  ✨ Features:                                                ║
║     • Live PDF preview                                      ║
║     • Template editor with hot-reload                       ║
║     • Multiple test datasets                                ║
║     • Light/Dark theme preview                              ║
║                                                              ║
║  📝 How to use:                                              ║
║     1. Select template type (Summary/Audit)                 ║
║     2. Choose theme (Light/Dark)                            ║
║     3. Pick test data (Example/GitHub)                      ║
║     4. Click "Load Preview"                                 ║
║     5. Edit template on the right                           ║
║     6. Click "Save & Reload" to see changes                 ║
║                                                              ║
║  Press Ctrl+C to stop                                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
    """)
    httpd.serve_forever()


if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8888
    start_server(port)
