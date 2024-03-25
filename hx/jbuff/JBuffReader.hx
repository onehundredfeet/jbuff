package jbuff;

using Lambda;

class JBuffReader_View {
    public var name(default, null) : String;
    public var desc(default, null) : String = "";
    public var type(default, null) : String = "";

    var _bytes : hl.Bytes;
    public var count(default, null) : Int;
    public var size(default, null) : Int;
    public var stride(default, null) : Int;

    public function new(name : String, desc : String, type : String, bytes : hl.Bytes, count : Int, size : Int, stride : Int) {
        this.name = name;
        this.desc = desc;
        this.type = type;
        this._bytes = bytes;
        this.count = count;
        this.size = size;
        this.stride = stride;
    }
}

class JBuffReader_Buffer {
    public var name(default, null) : String;
    public var desc(default, null) : String = "";
    public var type(default, null) : String = "";
    public var bytes(default, null) : hl.Bytes;
    public var length(default,null) : Int;
    var data : haxe.io.Bytes;

    public function new(name : String, desc:String, type:String, bytes : hl.Bytes, length : Int) {
        this.name = name;
        this.desc = desc;
        this.type = type;
        this.bytes = bytes;
        this.length = length;
    }
}

class JBuffReader {
    public var dom : Dynamic;

    var _bytes : haxe.io.Bytes;
    var _hlBytes : hl.Bytes;

    public var buffers(default, null) = new Array<JBuffReader_Buffer>();
    public var views(default, null) = new Array<JBuffReader_View>();

    public function new (file : JBuffFile, splitBuffers = false) {
        dom = file.dom;

        _bytes = haxe.crypto.Base64.decode( file.data_payload );
        _hlBytes = _bytes;

        if (file.data_length_zip > 0) {
            _bytes = haxe.zip.Uncompress.run(_bytes);
        }

        for (b in file.buffers) {
            var buffer : JBuffReader_Buffer;
            if (splitBuffers) {
                var subBuffer = _bytes.sub( b.offset, b.length );
                buffer = new JBuffReader_Buffer(b.name, b.desc, b.type, subBuffer, b.length);
                @:privateAccess buffer.data = subBuffer;
            } else {
                buffer = new JBuffReader_Buffer(b.name, b.desc, b.type, _hlBytes.offset( b.offset ), b.length);
            }
            buffers.push(buffer);
        }

        for (v in file.views) {
            var buffer = file.buffers.find(function(b) return b.name == v.buffer);
            var offset = buffer.offset + v.offset;
            var view = new JBuffReader_View(v.name, v.desc, v.type, _hlBytes.offset( offset ), v.count, v.size, v.stride);
            views.push(view);
        }
        if (splitBuffers) {
            _bytes = null;
            _hlBytes = null;
        }
    }
}