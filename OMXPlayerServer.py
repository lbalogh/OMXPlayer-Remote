from BaseHTTPServer import HTTPServer, BaseHTTPRequestHandler
from SocketServer import ThreadingMixIn
from omxplayer import OMXPlayer
from subprocess import call
import threading
import json
import os
import shutil
import time
import sys
import getopt

SUPPORTED_FORMATS	= ('.mkv', '.avi', '.mp4', '.mov', '.srt')

class ServerHandler(BaseHTTPRequestHandler):
	def do_POST(self):
		global player
		global filename
		global home_path

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
		elif command == 'seek_fast_backward' and 'player' in globals():
			player.action(21)
		elif command == 'seek_fast_forward' and 'player' in globals():
			player.action(22)
		elif command == 'previous_subtitle_stream' and 'player' in globals():
			player.action(10)
		elif command == 'next_subtitle_stream' and 'player' in globals():
			player.action(11)
		elif command == 'decrease_subtitle_delay' and 'player' in globals():
			player.action(13)
		elif command == 'increase_subtitle_delay' and 'player' in globals():
			player.action(14)
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
		elif command == 'reboot':
			call(['sudo', 'reboot'])
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
			path = jsonData['path'] if 'path' in jsonData else home_path

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

def PrintUsage():
	print 'Usage : python OMXPlayerServer.py -a <server ip> -p <server port> -d <home path>'

if __name__ == '__main__':
	server_ip = ''
	server_port = ''
	home_path = ''
	filename = ''

	try:
		opts, args = getopt.getopt(sys.argv[1:], 'ha:p:d:')
	except getopt.GetoptError:
		PrintUsage()
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			PrintUsage()
			sys.exit()
		elif opt in ("-a"):
			server_ip = arg
		elif opt in ("-p"):
			server_port = arg
		elif opt in ("-d"):
			home_path = arg

	httpd = ThreadedHTTPServer((server_ip, int(server_port)), ServerHandler)
	httpd.serve_forever()
