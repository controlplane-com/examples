const http = require('http');
const url = require('url');
const axios = require('axios');

const hostname = '0.0.0.0';
const port = 8080;

const server = http.createServer(async (req, res) => {

	const reqQuery = url.parse(req.url, true).query;

	res.statusCode = 200;
	res.setHeader('Content-Type', 'text/html');

	var data = ''

	if (reqQuery.url) {
		try {
			var serviceResponse = await axios.get(reqQuery.url);
			data = serviceResponse.data;
		} catch (error) {
			data = error.message;
		}

		data = `<html><body><hr/><b>${data}</b><hr/></body></html>`;

	} else {
		data = 'No URL in querystring'
	}

	var output = `<br/><br/>Hello! Version: 1.1<br/><br/>GVC Name: ${process.env['CPLN_GVC']}<br/>Location: ${process.env['CPLN_LOCATION']}<br/>Workload Name: ${process.env['CPLN_WORKLOAD']}<br/><br/>Response from URL:<br/><br/>${data}<br/><br/>`;
	res.end(output);
});


server.listen(port, hostname, () => {
	console.log(`Server running at http://${hostname}:${port}/`);
});

