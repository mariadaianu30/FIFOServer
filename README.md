# FIFO Server

## Overview
This project implements a client-server communication system using Bash scripts and FIFO special files. The server listens for requests from clients, processes them, and responds with the manual page of the requested shell command.

## Features
- A well-known FIFO file for client-server communication
- Clients send requests to the server specifying a command
- The server responds with the `man` page content of the requested command
- Each client receives responses in a dedicated FIFO file
- The client automatically deletes its FIFO file after reading the response

## Files
- `proiectFIFOServer.sh` - The server script
- `clientFIFOServer.sh` - The client script
- `server_config` - Configuration file containing the well-known FIFO path

## How It Works
1. The server script creates a well-known FIFO (if not already present) and continuously listens for requests.
2. A client script sends a request in the following format:
   ```
   BEGIN-REQ [client-pid: command-name] END-REQ
   ```
3. The server extracts the client's PID and command name, then creates a unique FIFO for the client (e.g., `/tmp/server-reply-XXXX`).
4. The server executes `man command-name` and writes the output to the client's FIFO.
5. The client reads the response from its FIFO and deletes the file afterward.

## Usage

### Running the Server
Start the server by executing:
```bash
./proiectFIFOServer.sh
```
This will create the well-known FIFO and wait for client requests.

### Running a Client
To request the manual for a command (e.g., `ls`), run:
```bash
./clientFIFOServer.sh ls
```
The client will send a request to the server and wait for the response. Once received, the manual page content will be displayed.

## Cleanup
To stop the server, use `Ctrl + C`. The script ensures proper cleanup by removing the FIFO file upon termination.

## Notes
- Ensure that the server is running before starting a client.
- The server script must have execution permissions (`chmod +x proiectFIFOServer.sh`).
- Clients must also have execution permissions (`chmod +x clientFIFOServer.sh`)
