import Foundation
import zlib

enum LampsGzip {
    /// RFC 1952 gzip 压缩。
    static func compress(_ data: Data) -> Data? {
        guard !data.isEmpty else {
            return Data()
        }

        return data.withUnsafeBytes { srcBuffer -> Data? in
            guard let src = srcBuffer.bindMemory(to: Bytef.self).baseAddress else {
                return nil
            }

            var stream = z_stream()
            stream.next_in = UnsafeMutablePointer(mutating: src)
            stream.avail_in = uInt(srcBuffer.count)

            let windowBits: Int32 = 15 + 16
            let status = deflateInit2_(
                &stream,
                Z_DEFAULT_COMPRESSION,
                Z_DEFLATED,
                windowBits,
                8,
                Z_DEFAULT_STRATEGY,
                zlibVersion(),
                Int32(MemoryLayout<z_stream>.size)
            )
            guard status == Z_OK else {
                return nil
            }
            defer {
                deflateEnd(&stream)
            }

            let chunkSize = 16 * 1024
            var output = Data()
            var chunk = [UInt8](repeating: 0, count: chunkSize)
            var deflateStatus: Int32 = Z_OK
            while deflateStatus == Z_OK {
                deflateStatus = chunk.withUnsafeMutableBytes { destBuffer -> Int32 in
                    stream.next_out = destBuffer.bindMemory(to: Bytef.self).baseAddress
                    stream.avail_out = uInt(destBuffer.count)
                    return deflate(&stream, Z_FINISH)
                }
                let produced = chunkSize - Int(stream.avail_out)
                if produced > 0 {
                    output.append(chunk, count: produced)
                }
            }
            guard deflateStatus == Z_STREAM_END else {
                return nil
            }
            return output
        }
    }
}
