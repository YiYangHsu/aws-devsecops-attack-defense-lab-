from http.server import BaseHTTPRequestHandler, HTTPServer

class RequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == "/health":
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"healthy")
            return
        
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"AWS DevSecOps Attack & Defense Lab")

server = HTTPServer(("0.0.0.0",8080),RequestHandler)

print("Application listening on port 8080")
server.serve_forever()
