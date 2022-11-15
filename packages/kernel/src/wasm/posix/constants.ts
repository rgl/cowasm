import debug from "debug";
const log = debug("posix:constants");

// These are purely for typescript, and I can only update this (when the zig code changes)
// by just printing out the constants at runtime.
const CONSTANTS = [
  "AT_FDCWD",
  "E2BIG",
  "EACCES",
  "EAGAIN",
  "EBADF",
  "EBUSY",
  "ECHILD",
  "EDEADLK",
  "EEXIST",
  "EFAULT",
  "EFBIG",
  "EINTR",
  "EINVAL",
  "EIO",
  "EISDIR",
  "EMFILE",
  "EMLINK",
  "ENFILE",
  "ENODEV",
  "ENOENT",
  "ENOEXEC",
  "ENOMEM",
  "ENOSPC",
  "ENOTDIR",
  "ENOTTY",
  "ENXIO",
  "EPERM",
  "EPIPE",
  "EROFS",
  "ESPIPE",
  "ESRCH",
  "ETXTBSY",
  "EXDEV",
  "ENOTCONN",
  "EADDRINUSE",
  "EADDRNOTAVAIL",
  "EAFNOSUPPORT",
  "EALREADY",
  "ECONNREFUSED",
  "EFAULT",
  "EHOSTUNREACH",
  "EINPROGRESS",
  "EISCONN",
  "ENETDOWN",
  "ENETUNREACH",
  "ENOBUFS",
  "ENOTSOCK",
  "ENOPROTOOPT",
  "EOPNOTSUPP",
  "EPROTOTYPE",
  "ETIMEDOUT",
  "ECONNRESET",
  "ELOOP",
  "ENAMETOOLONG",
  "SIG_BLOCK",
  "SIG_UNBLOCK",
  "SIG_SETMASK",
  "AF_INET",
  "AF_INET6",
  "F_ULOCK",
  "F_LOCK",
  "F_TLOCK",
  "F_TEST",
  "IFNAMSIZ",
  "ENOTSUP",
  "WNOHANG",
  "WUNTRACED",
  "MSG_OOB",
  "MSG_PEEK",
  "MSG_WAITALL",
  "MSG_DONTROUTE",
  "O_CLOEXEC",
  "O_NONBLOCK",
  "O_APPEND",
  "SO_ACCEPTCONN",
  "SO_ATTACH_BPF",
  "SO_ATTACH_FILTER",
  "SO_ATTACH_REUSEPORT_CBPF",
  "SO_ATTACH_REUSEPORT_EBPF",
  "SO_BINDTODEVICE",
  "SO_BINDTOIFINDEX",
  "SO_BPF_EXTENSIONS",
  "SO_BROADCAST",
  "SO_BSDCOMPAT",
  "SO_BUSY_POLL",
  "SO_CNX_ADVICE",
  "SO_COOKIE",
  "SO_DEBUG",
  "SO_DETACH_BPF",
  "SO_DETACH_FILTER",
  "SO_DETACH_REUSEPORT_BPF",
  "SO_DOMAIN",
  "SO_DONTROUTE",
  "SO_ERROR",
  "SO_GET_FILTER",
  "SO_INCOMING_CPU",
  "SO_INCOMING_NAPI_ID",
  "SO_KEEPALIVE",
  "SO_LINGER",
  "SO_LOCK_FILTER",
  "SO_MARK",
  "SO_MAX_PACING_RATE",
  "SO_MEMINFO",
  "SO_NOFCS",
  "SO_NO_CHECK",
  "SO_OOBINLINE",
  "SO_PASSCRED",
  "SO_PASSSEC",
  "SO_PEEK_OFF",
  "SO_PEERCRED",
  "SO_PEERGROUPS",
  "SO_PEERNAME",
  "SO_PEERSEC",
  "SO_PRIORITY",
  "SO_PROTOCOL",
  "SO_RCVBUF",
  "SO_RCVBUFFORCE",
  "SO_RCVLOWAT",
  "SO_RCVTIMEO",
  "SO_REUSEADDR",
  "SO_REUSEPORT",
  "SO_RXQ_OVFL",
  "SO_SECURITY_AUTHENTICATION",
  "SO_SECURITY_ENCRYPTION_NETWORK",
  "SO_SECURITY_ENCRYPTION_TRANSPORT",
  "SO_SELECT_ERR_QUEUE",
  "SO_SNDBUF",
  "SO_SNDBUFFORCE",
  "SO_SNDLOWAT",
  "SO_SNDTIMEO",
  "SO_TIMESTAMP",
  "SO_TIMESTAMPING",
  "SO_TIMESTAMPNS",
  "SO_TXTIME",
  "SO_TYPE",
  "SO_WIFI_STATUS",
  "SO_ZEROCOPY",
  "SOL_SOCKET",
  "POLLIN",
  "POLLOUT",
] as const;

export type Constant = typeof CONSTANTS[number];

const constants: { [name: string]: number } = {};
export default constants;

function recvJsonObject({ callFunction, recv }, name: string) {
  let ptr = callFunction(name);
  if (ptr == 0) {
    throw Error("unable to receive JSON object");
  }
  return JSON.parse(recv.string(ptr));
}

export function initConstants(context) {
  const { names, values } = recvJsonObject(context, "getConstants");
  for (let i = 0; i < names.length; i++) {
    constants[names[i]] = values[i];
  }
  log(constants);
}
