#!/bin/bash
# Toggle network debug logging in Acubiz iOS project
set -e

case "$1" in
    on|off|status|toggle) ACTION="$1"; PROJECT_ROOT="${2:-.}" ;;
    *) PROJECT_ROOT="${1:-.}"; ACTION="${2:-toggle}" ;;
esac

FILE="$PROJECT_ROOT/Acubiz/Acubiz/Networking/ACBApiManager.swift"
MARKER="// DEBUG_NETWORK_LOGGING"

is_on() { grep -q "$MARKER" "$FILE" 2>/dev/null; }

LOGGER_CODE='// DEBUG_NETWORK_LOGGING
class ACBNetworkLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        guard let r = request.request else { return }
        print("[REQ] \(r.httpMethod ?? "") \(r.url?.absoluteString ?? "")")
        if let body = r.httpBody, let s = String(data: body, encoding: .utf8) {
            print("Body: \(s.count > 500 ? String(s.prefix(500)) + "..." : s)")
        }
    }
    func request<V>(_ request: DataRequest, didParseResponse response: DataResponse<V, AFError>) {
        print("[RES] \(response.response?.statusCode ?? 0) \(request.request?.url?.absoluteString ?? "")")
        if let data = response.data, let s = String(data: data, encoding: .utf8) {
            print("Body: \(s.count > 1000 ? String(s.prefix(1000)) + "..." : s)")
        }
    }
}
// END_DEBUG_NETWORK_LOGGING'

enable() {
    [ ! -f "$FILE" ] && echo "Error: $FILE not found" && exit 1
    is_on && echo "Already on" && return
    LINE=$(grep -n "^import Alamofire$" "$FILE" | head -1 | cut -d: -f1)
    { head -n "$LINE" "$FILE"; echo "$LOGGER_CODE"; tail -n +$((LINE + 1)) "$FILE"; } > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
    sd -F 'Alamofire.Session(configuration: configuration)' 'Alamofire.Session(configuration: configuration, eventMonitors: [ACBNetworkLogger()])' "$FILE"
    echo "✅ ON"
}

disable() {
    is_on || { echo "Already off"; return; }
    sd -f ms '\n// DEBUG_NETWORK_LOGGING.*?// END_DEBUG_NETWORK_LOGGING' '' "$FILE"
    sd -F 'Alamofire.Session(configuration: configuration, eventMonitors: [ACBNetworkLogger()])' 'Alamofire.Session(configuration: configuration)' "$FILE"
    echo "✅ OFF"
}

case "$ACTION" in
    on) enable ;;
    off) disable ;;
    status) is_on && echo "✅ ON" || echo "❌ OFF" ;;
    toggle) is_on && disable || enable ;;
esac
