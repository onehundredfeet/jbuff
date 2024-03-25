package jbuff;

import haxe.Json;
import haxe.Exception;

typedef JBuffFileViewData = {
    name : String,
    desc : String,
    type : String,
    buffer : String,
    offset: Int,
    count : Int,
    size: Int,
    stride : Int,
}

@:forward
abstract JBuffFileView(JBuffFileViewData) from JBuffFileViewData {
    public static function createEmpty() : JBuffFileView {
        return {
            name : "",
            desc : "",
            type : "",
            buffer : "",
            offset: 0,
            count : 0,
            size : 0,
            stride : 0
        };
    }
}


typedef JBuffFileBufferData = {
    name : String,
    desc : String,
    type : String,
    offset: Int,
    length : Int
}

@:forward
abstract JBuffFileBuffer(JBuffFileBufferData) from JBuffFileBufferData {
    public static function createEmpty() : JBuffFileBuffer {
        return {
            name : "",
            desc : "",
            type : "",
            offset: 0,
            length : 0
        };
    }
}

typedef JBuffFileData = {
    magic : String,
    version : String,
    views : Array<JBuffFileView>,
    buffers : Array<JBuffFileBuffer>,
    dom : Dynamic,
    data_length_raw : Int,
    data_length_zip : Int,
    data_payload: String
}

@:forward
abstract JBuffFile(JBuffFileData) from JBuffFileData {
    public static function createEmpty() : JBuffFile {
        return {
            magic : "JBUFF",
            version : "1.0.0",
            views : [],
            buffers : [],
            dom : {},
            data_length_raw : 0,
            data_length_zip : 0,
            data_payload : ""
        };
    }
    public static function fromPath( path:String ) : JBuffFile{
        try {
            var fileContents = sys.io.File.getContent(path);
            var json : JBuffFile = Json.parse(fileContents);    
            trace('json ${json}');
            if (json.magic != "JBUFF") {
                trace('${path} is not a JBuff file.');
                return null;
            }

            if (json.version != "1.0.0") {
                trace('${path} is not a JBuff version 1 file.');
                return null;
            }

            trace('views ${json.views}');
            trace('Buffers ${json.buffers}');
            trace('Dom ${json.dom}');
            trace('data [${json.data_length_raw}] : ${json.data_payload}');

            return json;
        }catch(e: Exception){
            trace('Error reading file: ${e}');
           return null;
        }

        return null;
    }

    public function writeToPath( path:String ) {
        try {
            var fileContents = Json.stringify(this);
            sys.io.File.saveContent(path, fileContents);
            
        }catch(e: Exception){
            trace('Error writing file: ${e}');
        }
    }
}