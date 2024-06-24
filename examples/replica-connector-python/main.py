import websocket
import json

## Variables ##
CONNECTION_URL = "wss://<deployment.status.remote>/remote"
REQUEST = {
    "token": "<token>",
    "org": "<org-name>",
    "gvc": "<gvc-name>",
    "pod": "<replica-name>",
    "container": "<container-name>",
    "command": ["echo", "hello", "world"],
}


## Functions ##
def on_message(ws, message):
    print(f"Message from server: {message}")


def on_error(ws, error):
    print(f"Error: {error}")


def on_close(ws, close_status_code, close_msg):
    print(f"Connection closed, exit code: {close_status_code}")


def on_open(ws):
    print("Connection opened")

    # Establish a connection with the replica
    ws.send(json.dumps(REQUEST, indent=4))


## START ##

# Enable detailed logging to help with debugging
# websocket.enableTrace(True)

# Create a WebSocketApp instance, specifying the server URL and the callback function
ws = websocket.WebSocketApp(
    CONNECTION_URL,
    on_open=on_open,
    on_message=on_message,
    on_error=on_error,
    on_close=on_close,
)

# Start the WebSocket connection and keep it open, processing incoming and outgoing messages
ws.run_forever()
