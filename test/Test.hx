package ;

import haxe.io.Bytes;
import jbuff.JBuffBuilder;
import jbuff.JBuffFile;
import jbuff.JBuffReader;


class Test {
    public static function main() {
        var jb = JBuffFile.fromPath("test/manual.jbuff");

        var ja = JBuffFile.createEmpty();

        ja.writeToPath( "test/auto.jbuff");

        var jb = new JBuffBuilder();

        var bytes = Bytes.ofString("Hello World");
        var buffer = jb.addBuffer("buffer_helloworld", bytes);
        jb.dom.name = "helloworld";
        jb.dom.something = "nope";
        var jbv = jb.addView("view_helloworld", buffer);
        var jbf = jb.asFile();
        jbf.writeToPath("test/helloworld.jbuff");

        var jc = JBuffFile.fromPath("test/helloworld.jbuff");
        var jcr = new JBuffReader(jc);

        trace('dom: ' + jcr.dom);
        trace('num buffers ' + jcr.buffers.length);
        for (b in jcr.buffers) {
            trace('buffer: ' + b.name + ' ' + b.length);
        }

        for (v in jcr.views) {
            trace('view: name ' + v.name + ' desc ' + v.desc + ' count ' + v.count);
        }
    }
}