import socket

conn = socket.create_connection(("", 2000))
print("connected to port 2000")

print("*" * 80)
print("conn =", conn)
print("*" * 80)

print(conn.recv(6))
print(conn.send(b"CoWasm"))

conn.shutdown(socket.SHUT_RD)
