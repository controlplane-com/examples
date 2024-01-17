import os
import subprocess
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler

class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            try:
                postgres_user = os.getenv('POSTGRES_USER', 'default_user')
                location = os.getenv('CPLN_LOCATION', '').split('/')[-1]
                server = None

                # Finding the correct PGEDGE server
                for i in range(10):
                    if os.getenv(f'PGEDGE_{i}_LOCATION') == location:
                        server = os.getenv(f'PGEDGE_{i}_SERVER')
                        break

                if not server:
                    logging.error("PGEDGE server not found for location.")
                    self.send_response(500)
                    self.end_headers()
                    return

                pgedge_domain, pgedge_port = server.split(':')

                # Run pg_isready command
                result = subprocess.run(
                    ["pg_isready", "-U", postgres_user, "-h", pgedge_domain, "-p", pgedge_port],
                    capture_output=True
                )

                # Determine the response based on pg_isready command
                if result.returncode == 0:
                    self.send_response(200)
                else:
                    self.send_response(500)
                self.end_headers()
            except Exception as e:
                logging.error(f"Error in processing request: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            self.send_response(404)
            self.end_headers()

def run(server_class=HTTPServer, handler_class=HealthCheckHandler):
    logging.basicConfig(level=logging.INFO)
    server_address = ('', 8091)
    httpd = server_class(server_address, handler_class)
    logging.info("Starting httpd...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()
