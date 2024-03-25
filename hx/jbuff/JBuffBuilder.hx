package jbuff;

import haxe.zip.Compress;
import haxe.io.Bytes;
import jbuff.JBuffFile;


class JBuffBuilder_View {
    public var name : String;
    public var buffer : JBuffBuilder_Buffer;
    public var offset : Int;
    public var count : Int;
    public var size : Int;
    public var stride : Int;
    public var desc : String = "";
    public var type : String = "";

    public function new(name : String, buffer : JBuffBuilder_Buffer) {
        this.name = name;
        this.buffer = buffer;
        this.offset = 0;
        this.count = buffer.length;
        this.size = 1;
        this.stride = 1;
    }
    public function setDescription(desc : String) : JBuffBuilder_View {
        this.desc = desc;
        return this;
    }
    public function setType(type : String) : JBuffBuilder_View {
        this.type = type;
        return this;
    }
    public function setOffset(offset : Int) : JBuffBuilder_View {
        this.offset = offset;
        return this;
    }
    public function setCount(count : Int) : JBuffBuilder_View {
        this.count = count;
        return this;
    }
    public function setSize(size : Int) : JBuffBuilder_View {
        this.size = size;
        return this;
    }
    public function setStride(stride : Int) : JBuffBuilder_View {
        this.stride = stride;
        return this;
    }
}

class JBuffBuilder_Buffer {
    public var name : String;
    var _bytes : Bytes;
    public var desc : String = "";
    public var type : String = "";

    public var length(get,never) : Int;
    function get_length() : Int {
        return _bytes.length;
    }
    public var bytes(get,never) : Bytes;
    function get_bytes() : Bytes {
        return _bytes;
    }

    public function new(name : String, bytes : Bytes) {
        this.name = name;
        _bytes = bytes;
    }
    public function setDescription(desc : String) : JBuffBuilder_Buffer {
        this.desc = desc;
        return this;
    }
    public function setType(type : String) : JBuffBuilder_Buffer {
        this.type = type;
        return this;
    }
}

class JBuffBuilder {

    public var dom : Dynamic = {};
    var _buffers = [];
    var _views = [];

    public function new() {

    }

    public function addBuffer(name : String, bytes : Bytes) : JBuffBuilder_Buffer {
        var b = new JBuffBuilder_Buffer(name, bytes);

        _buffers.push(b);

        return b;
    }

    public function addView( name : String, buffer : JBuffBuilder_Buffer) {
        var v = new JBuffBuilder_View(name, buffer);
        _views.push(v);
        return v;
    }

    static final MIN_COMPRESSION_THRESHOLD = 0.8;

    public function asFile() : JBuffFile{
        var f = JBuffFile.createEmpty();

        f.dom = dom;
        var byteCount = 0;
        var buffers = new Array<JBuffFileBuffer>();
        for (b in _buffers) {
            var bf = JBuffFileBuffer.createEmpty();
            bf.offset = byteCount;
            bf.length = b.length;
            bf.name = b.name;
            bf.desc = b.desc;
            bf.type = b.type;

            buffers.push(bf);
            byteCount += b.length;
        }
        var bytes = Bytes.alloc(byteCount);

        for (i in 0...buffers.length) {
            var bf = buffers[i];
            var bs = _buffers[i];
            bytes.blit(bf.offset, bs.bytes, 0, bs.length);
        }

        f.buffers = buffers;

        var views = new Array<JBuffFileView>();
        for (v in _views) {
            var vf = JBuffFileView.createEmpty();
            vf.name = v.name;
            vf.buffer = v.buffer.name;
            vf.offset = v.offset;
            vf.count = v.count;
            vf.size = v.size;
            vf.stride = v.stride;
            vf.desc = v.desc;
            vf.type = v.type;

            views.push(vf);
        }

        f.views = views;
        f.data_length_raw = bytes.length;
        var compressed = Compress.run(bytes, 9);
        if (compressed.length < bytes.length * MIN_COMPRESSION_THRESHOLD) {
            f.data_length_zip = compressed.length;
            f.data_payload = haxe.crypto.Base64.encode( compressed );
        } else {
            f.data_length_zip = -1;
            f.data_payload = haxe.crypto.Base64.encode( bytes );            
        }


        return f;
    }
}