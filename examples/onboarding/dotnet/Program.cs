using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using System.Net;
using System.Net.Sockets;

namespace runtime
{
    class Program
    {
        static void Main(string[] args)
        {
            // string port = Environment.GetEnvironmentVariable("PORT");
            TcpListener server = new TcpListener(IPAddress.Any, 8080);

            server.Start();

            while (true)
            {
                ;

                TcpClient client = server.AcceptTcpClient();
                NetworkStream ns = client.GetStream();

                string document = "Hello World";

                string payload = @"HTTP/1.1 200 OK
Accept-Ranges: bytes
Content-Length: " + Encoding.UTF8.GetByteCount(document) + @"
Connection: close
Content-Type: text/html; charset=utf-8

" + document;

                byte[] msg = new byte[System.Text.ASCIIEncoding.Unicode.GetByteCount(payload)];
                msg = Encoding.Default.GetBytes(payload);
                ns.Write(msg, 0, msg.Length);

                Console.WriteLine("Workload Name:: " + Environment.GetEnvironmentVariable("CPLN_WORKLOAD"));
                Console.WriteLine("Location: " + Environment.GetEnvironmentVariable("CPLN_LOCATION"))

                client.Close();
            }
        }
    }
}
