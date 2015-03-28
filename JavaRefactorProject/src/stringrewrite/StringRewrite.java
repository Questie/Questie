/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package stringrewrite;

import com.sun.xml.internal.ws.util.StringUtils;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JFrame;
import stringrewrite.LuaObject.Type;
class LuaObject {
    
    boolean expanded = false;

    void write(OutputStream out, int tur, boolean last) throws IOException {

        if(name.startsWith("DAT")) return;
        for(int i = 0; i < tur*2; i++) out.write(' ');
        if(name.contains("\"")) name = inQuotes(name);
        if(name.startsWith("[") && name.endsWith("]")) name=name.substring(1, name.length()-1);
        name = name.replaceAll("\'", "\\\\\'");
        name = name.replace("\\\\", "\\");
        boolean numeric = false;
        try{
            Integer.parseInt(name);
            numeric = true;
        }catch(Throwable t){}
        
        if(numeric) out.write('['); else out.write("['".getBytes());
        out.write(name.getBytes());
        if(numeric) out.write("] = ".getBytes()); else out.write("'] = ".getBytes());
        String q = "";
        switch(type){
            case INTARRAY:
                long[] d = (long[]) value;
                q += "{" + d[0];
                for(int i = 1; i < d.length; i++) q+= ", " + d[i];
                q += "}";
                out.write(q.getBytes());
                break;
            case FLOATARRAY:
                double[] da = (double[]) value;
                q += "{" + da[0];
                for(int i = 1; i < da.length; i++) q+= ", " + da[i];
                q += "}";
                out.write(q.getBytes());
                break;
            case DOUBLEINTARRAY:
                long[][] vda = (long[][]) value;
                q = "{{";
                for(int m = 0; m < vda.length; m++){
                    q += vda[m][0];
                    for(int k = 1; k < vda[m].length; k++){
                        q += ","+vda[m][k];
                    }
                    q += "},{";
                }
                q = q.substring(0, q.length()-2) + "}";
                out.write(q.getBytes());
                break;
            case DOUBLEFLOATARRAY:
                double[][] vd = (double[][]) value;
                q = "{{";
                for(int m = 0; m < vd.length; m++){
                    q += vd[m][0];
                    for(int k = 1; k < vd[m].length; k++){
                        q += ","+vd[m][k];
                    }
                    q += "},{";
                }
                q = q.substring(0, q.length()-2) + "}";
                out.write(q.getBytes());
                break;
            case STRING: case INTEGER: case FLOAT: case BOOLEAN:
                if(value == null)
                    out.write("null".getBytes());
                else{
                    q = value.toString();
                    q=q.replaceAll("\'", "\\\\\'");
                    q = q.replace("\\\\", "\\");
                    if(q.endsWith(",")){
                        System.out.println("NEW");
                        q = q.substring(0, q.length()-1).trim();
                        System.out.println(q);
                    }
                    if(q.contains("\\{") || q.contains("\\}")){
                        System.out.println("SERIOUS ISSUE BRACE WHERE BAD");
                        System.out.println(q);
                        System.exit(11);
                    }
                    if(type == Type.STRING)
                        out.write('\'');
                    out.write(q.getBytes());
                    if(type == Type.STRING)
                        out.write('\'');
                }
                break;
            case TABLE:
                out.write('{');
                out.write('\n');
                ConcurrentHashMap<String, LuaObject> ref = (ConcurrentHashMap<String, LuaObject>)value;
                int len = ref.size();
                int in = 0;
                for(String s : ref.keySet()){
                    ref.get(s).write(out, tur+1, len-in<2);
                    in++;
                }
                for(int i = 0; i < tur*2; i++) out.write(' ');
                out.write('}');
                break;
        }
        if(!last)out.write(',');
        out.write('\n');
    }
    
    enum Type {
        STRING,
        TABLE, 
        INTEGER,
        FLOAT,
        INTARRAY,
        FLOATARRAY,
        BOOLEAN,
        DOUBLEFLOATARRAY,
        DOUBLEINTARRAY
    }
    
    Object value;
    Type type;
    String name;
    
    int tier = 0;
    
    boolean table = false;
    
    String inQuotes(String s){
        int i, e;
        if(!s.startsWith("\"") && !s.startsWith("[")) s = "\"" + s;
        if(!s.endsWith("\"") && !s.endsWith("]")) s += "\"";
        for(i = 0; i < s.length(); i++){
            if(s.charAt(i)== '"') break;
        }
        
        for(e = s.length()-1; e>0; e--){
            if(s.charAt(e)== '"') break;
        }
        System.out.println("--"+s);
        String n = s.substring(i+1, e);

        if(n.endsWith("\""))n = n.substring(0, n.length()-1);

        System.out.println(s + "->" + n);
//        System.exit(-1);
        return s.substring(i+1, e);
    }
    
    boolean numeric(char f){
        return (f >= '0' && f <= '9');
    }
    
    public LuaObject(String name, String body, int tier){
        this(name, body, tier, true);
        if(name.contains("{")||name.contains("}")){
            System.out.println("SERIOUS ERROR BRACES IN NAME " + name);
            System.exit(-1);
        }
        if(type == null){
//            if(body.trim().equals("nil")){
//                type = Type.STRING;
//                value = body;
//            }else{
                System.out.println("ERROR: NullType: " + body);
                System.exit(-1);
//            }
        }
        String data = "";
        switch(type){
            case TABLE: 
                data = "[" + ((ConcurrentHashMap<String, LuaObject>)value).size() + "]";
                break;
            case INTEGER: case FLOAT: case STRING:
                data = " " + value;
                break;
                
            default: break;
        }
        String tr = "";
        for(int i = 0; i < tier*2; i++)tr += "_";
        if(value != null)System.out.println("Parsed " + tr + name.trim() + " as " + type + data);
        if(name.equals("object") && type == Type.TABLE){
            ConcurrentHashMap<String, LuaObject> contents = (ConcurrentHashMap<String, LuaObject>) value;
            for(String s : contents.keySet()){
                StringRewrite.objects.put(s, contents.get(s));
            }
        }else if(name.equals("event") && type == Type.TABLE){
//            System.out.println(name);
//            System.exit(-1);
            ConcurrentHashMap<String, LuaObject> contents = (ConcurrentHashMap<String, LuaObject>) value;
            for(String s : contents.keySet()){
                StringRewrite.events.put(s, contents.get(s));
            }
        }else if(name.equals("item") && type == Type.TABLE){
//            System.out.println(name);
//            System.exit(-1);
            ConcurrentHashMap<String, LuaObject> contents = (ConcurrentHashMap<String, LuaObject>) value;
            for(String s : contents.keySet()){
                StringRewrite.itemdb.put(s, contents.get(s));
            }
        }else
        if(name.equals("monster") && type == Type.TABLE){
            ConcurrentHashMap<String, LuaObject> contents = (ConcurrentHashMap<String, LuaObject>) value;
            for(String s : contents.keySet()){
                StringRewrite.monsterdb.put(s, contents.get(s));
            }
        }else
        if(name.equals("quest") && type == Type.TABLE){
            ConcurrentHashMap<String, LuaObject> contents = (ConcurrentHashMap<String, LuaObject>) value;
            for(String s : contents.keySet()){
                StringRewrite.questdb.put(s, contents.get(s));
            }
        }else
        if(type == Type.TABLE){
            try{
//                Integer.parseInt(name.split("\\[")[1].split("\\]")[0]);
                ConcurrentHashMap<String, LuaObject> contents = (ConcurrentHashMap<String, LuaObject>) value;
                for(String s : contents.keySet()){
                    StringRewrite.questdb.put(s, contents.get(s));
                }
            }catch(Exception e){
                e.printStackTrace();System.exit(0);
            }
        }
    }
    static int haaax = 0;
    private LuaObject(String name, String body, int tier, boolean wrapped){

        if(name.startsWith(",")){
            System.out.println("NSW");
//            System.exit(-1);
            name = name.substring(1);
            name = name.trim();
            System.out.println(name);
            System.exit(-1);
        }
        if(name.endsWith(",")){
            System.out.println("NEW");
//            System.exit(-1);
            name = name.substring(1);
            name = name.trim();
            System.out.println(name);
            System.exit(-1);
        }
        this.tier = tier;
        this.name = name;
//        if(!name.equals("root")){
//            for(int g = 0; g < (tier-1)*2; g++) System.out.print(' ');
//            System.out.println("" + name + "->" + body.replaceAll("\\s+",""));
//        }
        int cut = 0;
        char[] chars = body.toCharArray();
        boolean valid = false;
        boolean canquo = true;
        boolean quo = false;
        while(cut < body.length()){
            char cher = chars[cut];

            if(table){
                ConcurrentHashMap<String, LuaObject> ref = (ConcurrentHashMap<String, LuaObject>) value;
                for(int i = cut; i < chars.length; i++){
                    char t = chars[i];
                    switch(t){
                        case '=':
                            String vname = new String(chars, cut, i-cut);
//                            for(int g = 0; g < tier*4; g++) System.out.print(' ');
//                            System.out.print("->>->>"+vname.trim());
                            String sbody = "";
                            boolean fin = false;
                            int q;
                            int dents = 0;
                            quo = false;
                            canquo = true;
//                            System.out.println("Getting body for " + vname.trim());
                            for(q = i+1; q < chars.length; q++){
//                                if(haaax++%640==32)System.out.println(q + " / " + chars.length);
                                t = chars[q];
//                                System.out.write(t);
                                switch(t){
                                    case '\\':
                                        canquo = false;
                                        break;
                                    case '"':
                                        if(canquo)quo=!quo;
                                        canquo = true;
                                        break;
                                    case '{':
                                        dents++;canquo = true;
//                                        System.out.print("+");
//                                        System.out.println("Heir++: " + dents);
                                        break;
                                    case '}':
                                        dents--;canquo = true;
//                                        System.out.println("Heir--: " + dents);
//                                        System.out.print("-");
//                                        System.out.println("dents-- ( " + t + " )");
                                        if(dents == -1 || dents == 0) {fin=true;/*System.out.println(q + " / " + chars.length)*/}
                                        break;
                                    case ',':canquo = true; if(dents==0&&!quo){fin=true;} break; 
                                    default:canquo = true; break;
                                }
                                
                                if(fin&&dents==0&& t != ',')sbody += t;
                                if(fin)break;
//                                sbody += t;
                            }
                            sbody = body.substring(i+1, q);
////////////////////////                            String sbody = "";
////////////////////////                            boolean fin = false;
////////////////////////                            int q;
////////////////////////                            int dents = 0;
////////////////////////                            System.out.println("Getting body for " + vname.trim());
////////////////////////                            for(q = i+1; q < chars.length; q++){
////////////////////////                                if(haaax++%640==32)System.out.println(q + " / " + chars.length);
////////////////////////                                t = chars[q];
//////////////////////////                                System.out.write(t);
////////////////////////                                switch(t){
////////////////////////                                    case '{':
////////////////////////                                        dents++;
////////////////////////                                        System.out.print("+");
//////////////////////////                                        System.out.println("Heir++: " + dents);
////////////////////////                                        break;
////////////////////////                                    case '}':
////////////////////////                                        dents--;
//////////////////////////                                        System.out.println("Heir--: " + dents);
////////////////////////                                        System.out.print("-");
//////////////////////////                                        System.out.println("dents-- ( " + t + " )");
////////////////////////                                        if(dents == -1 || dents == 0) {fin=true;System.out.println(q + " / " + chars.length);}
////////////////////////                                        break;
////////////////////////                                    case ',': if(dents==0){fin=true;} break; 
////////////////////////                                    default: break;
////////////////////////                                }
////////////////////////                                if(fin&&dents==0&& t != ',')sbody += t;
////////////////////////                                if(fin)break;
////////////////////////                                sbody += t;
////////////////////////                            }
//                            System.out.println("Broke on " + t);
                            cut = q+2;
                            i = q+2;
//                            System.out.println ("=" + sbody.trim());
//                            System.out.println("Generating " + vname.trim());
                            ref.put(vname, new LuaObject(vname.trim(), sbody, tier+1));
                            break;
                    }
                }
            }else{

                if(   chars[cut]=='D'
                      &&chars[cut+1]=='A'
                      &&chars[cut+2]=='T'
                ){
                    int xrid = Integer.parseInt(body.substring(cut).split("DAT\\[")[1].split("\\]")[0]);
                    LuaObject obj = StringRewrite.rootmap.get("DAT[" + xrid + "]");
//                    System.out.println("XREF");
                    type = obj.type;
                    value = obj.value;
                    valid = true;
                    break;
                }else if(cher == '"' && !body.contains("=")){
                    type = Type.STRING;
                    value = inQuotes(body);
                    valid = true;
                    break;
                }else
                if(numeric(cher)){
//                    System.out.println("Numeric: " + body + "[" + cher + "]");
//                    System.out.println("Numeric");
                    
                    if(body.contains(".")){
//                        System.out.println("FLOAT");
                        type = Type.FLOAT;
                        value = Double.parseDouble(body);
                    }else{
//                        System.out.println("INT");
                        type = Type.INTEGER;
                        value = Long.parseLong(body);
                    }
//                    System.out.println("INT__"+body);
                    valid = true;
                    break;
                }else if(
                        chars[cut]=='t'
                      &&chars[cut+1]=='r'
                      &&chars[cut+2]=='u'
                      &&chars[cut+3]=='e'
                ){
//                    System.out.println("boolean");
                    type = Type.BOOLEAN;
                    value = true;
                    valid = true;
                    break;
                }else if(
                        chars[cut]=='f'
                      &&chars[cut+1]=='a'
                      &&chars[cut+2]=='l'
                      &&chars[cut+3]=='s'
                      &&chars[cut+4]=='e'
                ){
//                    System.out.println("boolean");
                    valid = true;
                    value = false;
                    type = Type.BOOLEAN;
                    break;
                }else
                switch(cher){
                    case '\\':
                        canquo = false;
                        break;
                    case '"':
                        if(!body.contains("=")){
                            type = Type.STRING;
                            value = inQuotes(body);
                            valid = true;
                        }
                        if(canquo)quo = !quo;
                        canquo = true;
                         // assume string
                        break;
                    case '{':
//                        if(!name.equals("root"))System.out.println("Table:" + body);
                        canquo = true;
                        if(body.contains("=")){
//                            System.out.println("eq");
                            table = true;
                            type = Type.TABLE;
                            if(!name.equals("root"))value = new ConcurrentHashMap<String, LuaObject>();
                            else value = StringRewrite.rootmap;
                            valid = true;
                        }else{
                            valid = true;
                            body = body.replaceAll("\\s+","");
                            boolean flt = body.contains(".");
//                            int dimens = body.length() - body.replace("{", "").length();
                            int dimens = 0;
                            while(true){
                                if(body.charAt(dimens) != '{') break;
                                dimens++;
                            }
                            if(dimens == 2 && !(body.contains("},{")||body.contains("},DAT"))) dimens = 1; // fake2d
//                            if(body.contains("{{") && body.contains("}}")) dimens --; // might be a bad idea
//                            System.out.println("Dimensions: " + dimens + " [[=-   " + body  + "  -=]]");
                            if(body.startsWith("{DAT") || body.startsWith("DAT")){
                                System.out.println("XREF");
//                                type = Type.STRING;
                                int xrid = Integer.parseInt(body.split("DAT\\[")[1].split("\\]")[0]);
                                LuaObject obj = StringRewrite.rootmap.get("DAT[" + xrid + "]");
            //                    System.out.println("XREF");
                                type = obj.type;
                                value = obj.value;
                                valid = true;
                            }else if(body.startsWith("{\"")){
                                System.out.println("STRANG");
                                type = Type.STRING;
                                value = body.split("\"")[1];
                            }else{
                                if(body.contains("DAT")){
                                    String[] splts = body.split("DAT\\[");
                                    for(int i = 1; i < splts.length; i++){
                                        int xref = Integer.parseInt(splts[i].split("\\]")[0]);
                                        System.out.println("XREFINARR=>" + xref);
//                                        System.exit(-1);
                                        LuaObject ref = StringRewrite.rootmap.get("DAT[" + xref + "]");
                                        String repl = "";
                                        switch(ref.type){
                                            case FLOATARRAY:
                                                double[] v = (double[])ref.value;
                                                repl = "{" + v[0];
                                                for(int q = 1; q < v.length; q++) repl += "," + v[q];
                                                repl += "}";
                                                break;
                                            case INTARRAY:
                                                long[] vi = (long[])ref.value;
                                                repl = "{" + vi[0];
                                                for(int q = 1; q < vi.length; q++) repl += "," + vi[q];
                                                repl += "}";
                                                break;
                                            case DOUBLEFLOATARRAY:
                                                double[][] vd = (double[][]) ref.value;
                                                repl = "{{";
                                                for(int m = 0; m < vd.length; m++){
                                                    repl += vd[m][0];
                                                    for(int k = 1; k < vd[m].length; k++){
                                                        repl += ","+vd[m][k];
                                                    }
                                                    repl += "},{";
                                                }
                                                repl = repl.substring(0, repl.length()-2) + "}";
                                                break;
                                            case DOUBLEINTARRAY:
                                                long[][] vdl = (long[][]) ref.value;
                                                repl = "{{";
                                                for(int m = 0; m < vdl.length; m++){
                                                    repl += vdl[m][0];
                                                    for(int k = 1; k < vdl[m].length; k++){
                                                        repl += ","+vdl[m][k];
                                                    }
                                                    repl += "},{";
                                                }
                                                repl = repl.substring(0, repl.length()-2) + "}";
                                                break;
                                            default:break;
                                        }
                                        body = body.replaceAll("DAT\\[" + xref + "\\]", repl);
                                    }
                                    if(body.contains("DAT")){
                                        System.out.println("BODY STILL CONTAINS XREFS");
                                        System.out.println(body);
                                        System.exit(-1);
                                    }
                                }
                                if(flt){
                                    type = Type.FLOATARRAY;
                                    if(dimens == 1){
                                        body = body.replaceAll("\\{", "").replaceAll("\\}", "");
                                        String[] derp = body.split("\\,");
                                        double[] val = new double[derp.length];
                                        for(int e = 0; e < val.length; e++){
                                            val[e] = Double.parseDouble(derp[e]);
                                        }
                                        value = val;
                                    }else{
                                        type = Type.DOUBLEFLOATARRAY;
                                        body = body.substring(2, body.length()-2); // remove unneeded braces
                                        String[] herp = body.split("\\}\\,\\{");
                                        String[] derp = herp[0].split("\\,");
                                        double[][] val = new double[herp.length][derp.length];
                                        for(int i = 0; i < herp.length; i++){
                                            derp = herp[i].split("\\,");
                                            for(int o = 0; o < derp.length; o++){
                                                double d = Double.parseDouble(derp[o]);
                                                val[i][o] = d;
                                            }
                                        }
                                        value = val;
                                        
                                    }
    //                                System.out.println("LELELEELLELELE");
                                }else{
                                    if(dimens == 1){
                                        body = body.replaceAll("\\{", "").replaceAll("\\}", "");
                                        String[] derp = body.split("\\,");
                                        int[] val = new int[derp.length];
                                        for(int e = 0; e < val.length; e++){

                                            val[e] = Integer.parseInt(derp[e]);
                                        }
                                        value = val;
                                    }else{
                                        type = Type.DOUBLEINTARRAY;
                                        body = body.substring(2, body.length()-2); // remove unneeded braces
                                        String[] herp = body.split("\\}\\,\\{");
                                        String[] derp = herp[0].split("\\,");
                                        long[][] val = new long[herp.length][derp.length];
                                        for(int i = 0; i < herp.length; i++){
                                            derp = herp[i].split("\\,");
                                            for(int o = 0; o < derp.length; o++){
                                                long d = Long.parseLong(derp[o]);
                                                val[i][o] = d;
                                            }
                                        }
                                        value = val;
                                    }
                                    type = Type.INTARRAY;
    //                                System.out.println("LELELEELLELELE");
                                }
                            }
                            return;
//                            System.out.println("neq");
                        }
//                        System.out.println("Tabluh");
                        break;
                    case ',': case '\n': case '}':canquo = true; if(!quo)return;else break;
                    default: canquo = true; break;
                }
            }
            cut++;
        }
        if(!valid){
            if(body.length()>0)System.out.println("Could not find valid type for " + body);
//            value = body;
            type = Type.STRING;
        }
    }

    @Override
    public String toString() {
        if(value == null) return "null";else
        return value.toString();
    }
}
/**
 *
 * @author Admin
 */
public class StringRewrite {

    /**
     * @param args the command line arguments
     */
    
    static ConcurrentHashMap<String, LuaObject> rootmap = new ConcurrentHashMap<String, LuaObject>();
    
    public static void main(String[] args) throws IOException {
        new Thread(new Runnable() {
            boolean nmp = false;
            int mx = 0, my = 0;
            @Override
            public void run() {
                final JFrame j = new JFrame("RandR");
                j.addMouseMotionListener(new MouseMotionListener() {

                    @Override
                    public void mouseDragged(MouseEvent e) {
                    }

                    @Override
                    public void mouseMoved(MouseEvent e) {
                        mx = e.getX();
                        my = e.getY();
                        j.repaint();
                    }
                });
                j.addMouseListener(new MouseListener() {

                    @Override
                    public void mouseClicked(MouseEvent e) {
//                        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
                    }

                    @Override
                    public void mousePressed(MouseEvent e) {
                        nmp = true;
                        mx = e.getX();
                        my = e.getY();
                        j.repaint();
//                        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
                    }

                    @Override
                    public void mouseReleased(MouseEvent e) {
//                        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
                    }

                    @Override
                    public void mouseEntered(MouseEvent e) {
//                        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
                    }

                    @Override
                    public void mouseExited(MouseEvent e) {
//                        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
                    }
                });
                j.add(new Component() {
                    
                    final Font fon = new Font(Font.MONOSPACED, Font.PLAIN, 12);
                    
                    {
                        setSize(640, 350);
                        setPreferredSize(new Dimension(640, 350));
                    }
                    
                    void drawObject(Graphics g, LuaObject o, String name, int dent){
                        if(idx>900)return;
                        if(o.name.startsWith("DAT")) return;
                        if(my-12 < idx+11&&my-12>idx){
                            g.fillRect(dent-12, idx-10, 640, 11);
                            g.setColor(Color.BLACK);
                            if(nmp){
                                o.expanded = !o.expanded;
                                nmp = false;
                            }
                        }else g.setColor(Color.GREEN);
                        if(o.expanded){
                            g.drawString("- " + o.name, dent-10, idx);
                        }else{
                            g.drawString("+ "+ o.name, dent-10, idx);
                        }
                        g.setColor(Color.GREEN);
                        String q = "";
                        if(o.expanded){
                            idx += 10;
                            switch(o.type){
                                case STRING: g.drawString("[STR] " + o.value.toString(), dent, idx); break;
                                case TABLE:
                                    ConcurrentHashMap<String, LuaObject> ref = (ConcurrentHashMap<String, LuaObject>)o.value;
                                    for(String s : ref.keySet()){
                                        if(!o.name.equals("quest") || s.contains("Bounty on Garrick Padfoot"))
                                            drawObject(g, ref.get(s), s, dent+10);
                                        if(idx>900)break;
                                    }
                                    idx -= 10;
//                                    for(String s : o.data.keySet()){
//                                        drawObject(g, o.data.get(s), s, dent+10);
//                                    }
                                    break;
                                case INTEGER: g.drawString("[INT] " + o.value.toString(), dent, idx); break;
                                case FLOAT: g.drawString("[FLOAT] " + o.value.toString(), dent, idx);break;
                                case INTARRAY:
                                    long[] d = (long[]) o.value;
                                    q += "[" + d[0];
                                    for(int i = 1; i < d.length; i++) q+= ", " + d[i];
                                    q += "]";
                                    g.drawString("[INTARRAY] " + q, dent, idx);
                                    break;
                                case FLOATARRAY:
                                    double[] da = (double[]) o.value;
                                    q += "[" + da[0];
                                    for(int i = 1; i < da.length; i++) q+= ", " + da[i];
                                    q += "]";
                                    g.drawString("[FLOATARRAY] " + q, dent, idx);
                                    break;
                                case DOUBLEINTARRAY:
                                    long[][] vda = (long[][]) o.value;
                                    q = "[[";
                                    for(int m = 0; m < vda.length; m++){
                                        q += vda[m][0];
                                        for(int k = 1; k < vda[m].length; k++){
                                            q += ","+vda[m][k];
                                        }
                                        q += "],[";
                                    }
                                    q = q.substring(0, q.length()-2) + "]";
                                    g.drawString("[DOUBLEINTARRAY] " + q, dent, idx);
                                    break;
                                case DOUBLEFLOATARRAY:
                                    double[][] vd = (double[][]) o.value;
                                    q = "[[";
                                    for(int m = 0; m < vd.length; m++){
                                        q += vd[m][0];
                                        for(int k = 1; k < vd[m].length; k++){
                                            q += ","+vd[m][k];
                                        }
                                        q += "],[";
                                    }
                                    q = q.substring(0, q.length()-2) + "]";
                                    g.drawString("[DOUBLEFLOATARRAY] " + q, dent, idx);
                                    break;
//                                case INTARRAY:
//                                    array = "";
//                                    for(int i : o.val_intarray) array += " " + i;
//                                    g.drawString("[ARRAY(INT)] " + array, dent, idx);break;
//                                case FLOATARRAY: 
//                                    array = "";
//                                    for(double d: o.val_floatarray) array += " " + d;
//                                    g.drawString("[ARRAY(FLOAT)] " + array, dent, idx);break;
                                case BOOLEAN: g.drawString("[BOOL] " + o.value.toString(), dent, idx);break;
                            }
                        }
                        idx+=10;
                    }
                    int idx = 0;
                    String array = "";
                    boolean rptstrobe = false;
                    @Override
                    public void paint(Graphics g) {
                        g.setFont(fon);
                        g.setColor(Color.BLACK);
                        g.fillRect(0,0,640,350);
                        g.setColor(Color.GREEN);
                        g.fillRect(0,0,640, 11);
                        g.setColor(Color.BLACK);
                        g.drawString("LuaHaxTerm -- LolTTY Edition", 20, 10);
                        if(rptstrobe = !rptstrobe){
                            g.fillRect(0,0,11,11);
                        }
                        g.setColor(Color.GREEN);
                        idx = 20;
                        for(String s : StringRewrite.rootmap.keySet()){
                            LuaObject o = StringRewrite.rootmap.get(s);
                            
                            drawObject(g, o, s, 10);
                            
                            if(idx>900)break;
                        }
                    }
                    
                });
                j.pack();
                j.setLocationRelativeTo(null);
                j.setVisible(true);
                new Thread(new Runnable() {

                    @Override
                    public void run() {
                        while(true){
                            try {
                                Thread.sleep(1000);
                                j.repaint();
                            } catch (InterruptedException ex) {
                            }
                        }
                    }
                }).start();
            }
            
        }).start();
        
//        if(true){
//            String hax = "'Fishbine and prawn\\\\'s'";
//            hax = hax.replace("\\\\", "\\");
//            System.out.println(hax);
//            return;
//        }
//        BufferedReader r = new BufferedReader(new InputStreamReader(new FileInputStream("D:\\strp.lua")));
        InputStream in = new FileInputStream("D:\\eng.lua");
        ByteArrayOutputStream out = new ByteArrayOutputStream(5642360);
        String full = "";
        String line = "";
        int chart=0;
        byte[] b = new byte[8192];
        int r = 0;
        while((r=in.read(b))>-1){
            out.write(b,0,r);
            chart += r;
//                System.out.println("Read line " + chart);
        }
        full = "{"+new String(out.toByteArray())+"}";
        LuaObject root = new LuaObject("root", full, 0);
//        root.write(new FileOutputStream("D:\\presto.lua"), 0, false);
        System.out.println("DONE");
//        
////        LuaObject idbhax = new LuaObject("root", "", 0);
////        idbhax.type = Type.TABLE;
////        idbhax.value = itemdb;
////        idbhax.write(new FileOutputStream("D:\\sitems.lua"), 0, false);
//        
//        for(String s : objects.keySet()){
//            LuaObject obj = objects.get(s);
//            ConcurrentHashMap<String, LuaObject> pardat = (ConcurrentHashMap<String, LuaObject>)obj.value;
//            LuaObject refactor = new LuaObject(obj.name, "", 1);
//            refactor.type = Type.TABLE;
//            ConcurrentHashMap<String, LuaObject> dat = new ConcurrentHashMap<String, LuaObject>();
//            for(String sa : pardat.keySet()){
//                LuaObject hoho = pardat.get(sa);
//                if(hoho.name.equals("pos")){
//                    LuaObject pos = pardat.get(sa);
//                    LuaObject locations = new LuaObject("locations", "", 2);
//                    locations.type = Type.TABLE;
//                    ConcurrentHashMap<String, LuaObject> locs = new ConcurrentHashMap<String, LuaObject>();
//                    switch(pos.type){
//                        case INTARRAY: case FLOATARRAY:
//                            LuaObject neu = new LuaObject("1", "", 3);
//                            neu.type = Type.FLOATARRAY;
//                            neu.value = pos.value;
//                            locs.put("1", neu);
//                            dat.put("locationCount", new LuaObject("locationCount", "1", 2));
//                            break;
//                        case DOUBLEINTARRAY: case DOUBLEFLOATARRAY:
//                            double[][] vel = (double[][]) pos.value;
//                            for(int i = 0; i < vel.length; i++){
//                                LuaObject nuu = new LuaObject(String.valueOf(i+1), "", 3);
//                                nuu.type = Type.FLOATARRAY;
//                                nuu.value = vel[i];
//                                locs.put(String.valueOf(i+1), nuu);
//                            }
//                            dat.put("locationCount", new LuaObject("locationCount", String.valueOf(vel.length), 2));
//                            break;
//                    }
//                    locations.value = locs;
//                    dat.put("locations", locations);
//                }else dat.put(sa, hoho);
//            }
//            
//            
//            refactor.value = dat;
//            refactordb.put(s, refactor);
//        }
//        
//        for(String s : questdb.keySet()){
//            LuaObject qst = questdb.get(s);
//            if(qst.type == Type.TABLE){
//                ConcurrentHashMap<String, LuaObject> ref = (ConcurrentHashMap<String, LuaObject>) qst.value;
//                for(String k : ref.keySet()){
//                    LuaObject o = ref.get(k);
//                    if(o.name.equals("finish")){
//                        o.name = qst.name;
//                        String t = (String) o.value;
//                        t = t.replaceAll("'", "`");
//                        t = t.replaceAll("\'", "`");
//                        o.value = t;
//                        finishers.put(qst.name, o);
//                    }
//                }
//            }
////            ConcurrentHashMap<String, LuaObject> ref = (ConcurrentHashMap<String, LuaObject>) qst.value;
////            for(String sa : ref.keySet()){
////                System.out.println(sa);
////            }
////            System.exit(0);
////            hashers.put(qst.name, ref.get("hash"));
//            hashers.put(qst.name, new LuaObject(qst.name, String.valueOf(qst.hashCode()), 1));
//            
//        }
//        System.exit(0);

//        System.out.println(full);
//        while((line=r.readLine()) != null){
//            full += line;
//            linee++;

//        }
        ArrayList<String> nams = new ArrayList<String>();
        ConcurrentHashMap<String, LuaObject> remap = new ConcurrentHashMap<String, LuaObject>();
        for(String s : objects.keySet()){
            System.out.println(s);
            LuaObject item = objects.get(s);
            if(item.name.charAt(0) != '[') item.name = "[\"" + item.name + "\"]";
            if(nams.contains(item.name)){
                System.out.println("--->>>" + item.name);
                item.value = mergeTable((ConcurrentHashMap<String, LuaObject>)item.value, (ConcurrentHashMap<String, LuaObject>)remap.get(item.name).value);
            }
            remap.put(item.name, item);
            nams.add(item.name);
        }
        System.exit(0);
        for(String s : remap.keySet()){
            System.err.println(s);
        }
        for(String s : remap.keySet()){
            LuaObject obj = remap.get(s);
            ConcurrentHashMap<String, LuaObject> pardat = (ConcurrentHashMap<String, LuaObject>)obj.value;
            LuaObject refactor = new LuaObject(obj.name, "", 1);
            refactor.type = Type.TABLE;
            ConcurrentHashMap<String, LuaObject> dat = new ConcurrentHashMap<String, LuaObject>();
            for(String sa : pardat.keySet()){
                LuaObject hoho = pardat.get(sa);
                if(hoho.name.equals("pos")){
                    LuaObject pos = pardat.get(sa);
                    LuaObject locations = new LuaObject("locations", "", 2);
                    locations.type = Type.TABLE;
                    ConcurrentHashMap<String, LuaObject> locs = new ConcurrentHashMap<String, LuaObject>();
                    switch(pos.type){
                        case INTARRAY: case FLOATARRAY:
                            LuaObject neu = new LuaObject("1", "", 3);
                            neu.type = Type.FLOATARRAY;
                            neu.value = pos.value;
                            locs.put("1", neu);
                            dat.put("locationCount", new LuaObject("locationCount", "1", 2));
                            break;
                        case DOUBLEINTARRAY: case DOUBLEFLOATARRAY:
                            double[][] vel = (double[][]) pos.value;
                            for(int i = 0; i < vel.length; i++){
                                LuaObject nuu = new LuaObject(String.valueOf(i+1), "", 3);
                                nuu.type = Type.FLOATARRAY;
                                nuu.value = vel[i];
                                locs.put(String.valueOf(i+1), nuu);
                            }
                            dat.put("locationCount", new LuaObject("locationCount", String.valueOf(vel.length), 2));
                            break;
                    }
                    locations.value = locs;
                    dat.put("locations", locations);
                }else dat.put(sa, hoho);
            }
            
            
            refactor.value = dat;
            refactordb.put(s, refactor);
        }
        
        
        LuaObject mdbhax = new LuaObject("root", "", 0);
        mdbhax.type = Type.TABLE;
        mdbhax.value = refactordb;
        mdbhax.write(new FileOutputStream("D:\\newitems.lua"), 0, false);
    }
    
    static ConcurrentHashMap<String, LuaObject> mergeTable(ConcurrentHashMap<String, LuaObject> one, ConcurrentHashMap<String, LuaObject> two){
        ConcurrentHashMap<String, LuaObject> ret = new ConcurrentHashMap<String, LuaObject>();
        for(String s : one.keySet()){
            LuaObject obj = one.get(s);
            String name = obj.name; // more reliable
            if(ret.containsKey(name)){
                LuaObject merge = ret.get(name);
                if(merge.type == obj.type){
                    switch(obj.type){
                        case TABLE: obj.value = mergeTable((ConcurrentHashMap<String, LuaObject>)obj.value, (ConcurrentHashMap<String, LuaObject>)merge.value); break;
                        case DOUBLEINTARRAY: 
                            long[][] neu = (long[][])obj.value;
                            long[][] old = (long[][])merge.value;
                            long[][] dfa = new long[neu.length+old.length][];
                            int index = 0;
                            for(long[] l : old)dfa[index++] = l;
                            for(long[] l : neu)dfa[index++] = l;
                            obj.value = dfa;
                            break;
                        case DOUBLEFLOATARRAY: 
                            double[][] dneu = (double[][])obj.value;
                            double[][] dold = (double[][])merge.value;
                            double[][] ddfa = new double[dneu.length+dold.length][];
                            int dindex = 0;
                            for(double[] l : dold)ddfa[dindex++] = l;
                            for(double[] l : dneu)ddfa[dindex++] = l;
                            obj.value = ddfa;
                            break;
                        default: break;
                    }
                    ret.put(name, obj);
                }// else theres nothing we can do :C
            }else{
                ret.put(name, obj);
            }
        }
        
        return ret;
    }
    
    static ConcurrentHashMap<String, LuaObject> monsterdb = new ConcurrentHashMap<String, LuaObject>();
    static ConcurrentHashMap<String, LuaObject> refactordb = new ConcurrentHashMap<String, LuaObject>();
    static ConcurrentHashMap<String, LuaObject> itemdb = new ConcurrentHashMap<String, LuaObject>();
    static ConcurrentHashMap<String, LuaObject> events = new ConcurrentHashMap<String, LuaObject>();
    
    static ConcurrentHashMap<String, LuaObject> questdb = new ConcurrentHashMap<String, LuaObject>();
    
    static ConcurrentHashMap<String, LuaObject> hashers = new ConcurrentHashMap<String, LuaObject>();
    static ConcurrentHashMap<String, LuaObject> finishers = new ConcurrentHashMap<String, LuaObject>();
    
    static ConcurrentHashMap<String, LuaObject> objects = new ConcurrentHashMap<String, LuaObject>();
    
}
