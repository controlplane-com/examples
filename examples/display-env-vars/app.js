const http = require('http');

const hostname = '0.0.0.0';
const port = 8080;

const server = http.createServer((req, res) => {
	res.statusCode = 200;
	res.setHeader('Content-Type', 'text/plain');

	const ordered = Object.keys(process.env).sort().reduce(
		(obj, key) => {
			obj[key] = process.env[key];
			return obj;
		},
		{}
	);

	var myArgs = process.argv;
	var newDate = new Date();

	res.end('Environment Variables\n\n' + JSON.stringify(ordered, null, 4) + '\n\nArguments:\n\n' + myArgs + '\n\nWelcome to Control Plane!\n\nThe time is: ' + newDate.toUTCString());
});


server.listen(port, hostname, () => {
	console.log(`Server running at http://${hostname}:${port}/`);
});

