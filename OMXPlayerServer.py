from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
from SocketServer import ThreadingMixIn
from omxplayer import OMXPlayer
from subprocess import call
import threading
import json
import os
import shutil
import time

HOME_PATH		= '/mnt/Download/Temp'	# home path when browsing from iPhone
HOST_NAME		= '192.168.10.116'	# ip adress of the raspberry pi
PORT			= 10023			# listening port
SUPPORTED_FORMATS	= ('.mkv', '.avi', '.mp4', '.mov')

class ServerHandler(BaseHTTPRequestHandler):
	def do_POST(self):
		global player
		global filename

		jsonData = json.loads(self.rfile.read(int(self.headers.getheader('content-length'))))

		print 'Data received from phone : '
		print jsonData

		command = jsonData['command'];
		if command == 'pause' and 'player' in globals(): 
			player.pause()
		elif command == 'seek_backward' and 'player' in globals():
			player.action(19)
		elif command == 'seek_forward' and 'player' in globals():
			player.action(20)
		elif command == 'seek_fast_forward' and 'player' in globals():
			player.action(22)
		elif command == 'seek_fast_backward' and 'player' in globals():
			player.action(21)
		elif command == 'stop' and 'player' in globals():
			filename = ''
			player.stop()
			player.quit()
		elif command == 'delete_file':
			os.remove(jsonData['path'])
		elif command == 'delete_folder':
			shutil.rmtree(jsonData['path'])
		elif command == 'poweroff':
			call(['sudo', 'poweroff'])	
		elif command == 'play':
			if 'player' in globals():
				player.stop()
				player.quit()

			filename = jsonData['path']
			player = OMXPlayer(jsonData['path'])
			player.play()
		elif command == 'is_playing':
			#playing = False if not 'player' in globals() else player.is_playing()
			SendResponse(self, {'command': command, 'path': filename})
		elif command == 'list_dir':
			path = jsonData['path'] if 'path' in jsonData else HOME_PATH

			files = [f for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and os.path.splitext(f)[1] in SUPPORTED_FORMATS]
			dirs = [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]

			files.sort()
			dirs.sort()

			SendResponse(self, {'command': command, 'path': path, 'files': files, 'dirs': dirs})

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""

def SendResponse(self, response):
	print 'Sending data to phone :'
	print response

	self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(response))

if __name__ == '__main__':
	filename = ''

	httpd = ThreadedHTTPServer((HOST_NAME, PORT), ServerHandler)
	httpd.serve_forever()

