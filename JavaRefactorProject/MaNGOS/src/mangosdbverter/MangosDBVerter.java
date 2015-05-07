/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mangosdbverter;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
class QuestTemplate {
    
    int MOD_ADLER = 65521;
 
    long adler32(String st) /* where data is the location of the data in physical memory and 
                                                          len is the length of the data in bytes */
    {
        long a = 1, b = 0;
        int index;

        /* Process each byte of the data in order */
        for (index = 0; index < st.length(); ++index)
        {
            a = (a + st.charAt(index)) % MOD_ADLER;
            b = (b + a) % MOD_ADLER;
        }

        return (b << 16) | a;
    }
    
    long mixint(long base, long val){
        return ((base << 3)+ val)&0x00000000FFFFFFFFl;
    }
    
    int id;
    String title;
    int min;
    int recommended;
    int rc;
    int rr;
    int rs;
    int rsc;
    int suggestedplayers;
    int parentquest;
    String details;
    String objectivetext;
    
    String start, end;
    String startType, endType;

    QuestTemplate(int id, String title, int min, int recommended, int rr, int rc, int rs, int rsc, int suggestedplayers, int parentquest, String details, String objectivetext, String start, String end, String startType, String endType){
        this.id=id;this.title=title;this.min=min=this.recommended=recommended;this.rc=rc;this.rr=rr;this.rs=rs;this.rsc=rsc;this.suggestedplayers = suggestedplayers; this.parentquest = parentquest; this.details = details; this.objectivetext = objectivetext;
        this.start=start;this.end=end;
        this.startType=startType;this.endType=endType;
        System.out.println(title + ": " + min + ", " + recommended);
    }
    
    long hash = 0;
    
    public void calculateHash(){
        hash = adler32(title);
        hash = mixint(hash, id);
        hash = mixint(hash, recommended);
        hash = mixint(hash, adler32(objectivetext));
        hash = mixint(hash, rr|(rc<<16));

    }
    
}

class Vector4{
    float x, y, z;
    int map;
    public Vector4(int map, float x, float y, float z){
        this.x=x;this.y=y;this.z=z;
        this.map=map;
    }
    
}

class CreatureSpawns {
    ArrayList<Vector4> locs = new ArrayList<Vector4>();
}

/**
 *
 * @author Aero
 */
public class MangosDBVerter {

    /**
     * @param args the command line arguments
     */
    
    /*
        `entry` mediumint (8),
	`Method` tinyint (3),
	`ZoneOrSort` smallint (6),
	`MinLevel` tinyint (3),
	`QuestLevel` tinyint (3),
	`Type` smallint (5),
	`RequiredClasses` smallint (5),
	`RequiredRaces` smallint (5),
	`RequiredSkill` smallint (5),
	`RequiredSkillValue` smallint (5),
	`RepObjectiveFaction` smallint (5),
	`RepObjectiveValue` mediumint (9),
	`RequiredMinRepFaction` smallint (5),
	`RequiredMinRepValue` mediumint (9),
	`RequiredMaxRepFaction` smallint (5),
	`RequiredMaxRepValue` mediumint (9),
	`SuggestedPlayers` tinyint (3),
	`LimitTime` int (10),
	`QuestFlags` smallint (5),
	`SpecialFlags` tinyint (3),
	`PrevQuestId` mediumint (9),
	`NextQuestId` mediumint (9),
	`ExclusiveGroup` mediumint (9),
	`NextQuestInChain` mediumint (8),
	`SrcItemId` mediumint (8),
	`SrcItemCount` tinyint (3),
	`SrcSpell` mediumint (8),
	`Title` text ,
	`Details` text ,
	`Objectives` text ,
	`OfferRewardText` text ,
	`RequestItemsText` text ,
	`EndText` text ,
	`ObjectiveText1` text ,
	`ObjectiveText2` text ,
	`ObjectiveText3` text ,
	`ObjectiveText4` text ,
	`ReqItemId1` mediumint (8),
	`ReqItemId2` mediumint (8),
	`ReqItemId3` mediumint (8),
	`ReqItemId4` mediumint (8),
	`ReqItemCount1` smallint (5),
	`ReqItemCount2` smallint (5),
	`ReqItemCount3` smallint (5),
	`ReqItemCount4` smallint (5),
	`ReqSourceId1` mediumint (8),
	`ReqSourceId2` mediumint (8),
	`ReqSourceId3` mediumint (8),
	`ReqSourceId4` mediumint (8),
	`ReqSourceCount1` smallint (5),
	`ReqSourceCount2` smallint (5),
	`ReqSourceCount3` smallint (5),
	`ReqSourceCount4` smallint (5),
	`ReqCreatureOrGOId1` mediumint (9),
	`ReqCreatureOrGOId2` mediumint (9),
	`ReqCreatureOrGOId3` mediumint (9),
	`ReqCreatureOrGOId4` mediumint (9),
	`ReqCreatureOrGOCount1` smallint (5),
	`ReqCreatureOrGOCount2` smallint (5),
	`ReqCreatureOrGOCount3` smallint (5),
	`ReqCreatureOrGOCount4` smallint (5),
	`ReqSpellCast1` mediumint (8),
	`ReqSpellCast2` mediumint (8),
	`ReqSpellCast3` mediumint (8),
	`ReqSpellCast4` mediumint (8),
	`RewChoiceItemId1` mediumint (8),
	`RewChoiceItemId2` mediumint (8),
	`RewChoiceItemId3` mediumint (8),
	`RewChoiceItemId4` mediumint (8),
	`RewChoiceItemId5` mediumint (8),
	`RewChoiceItemId6` mediumint (8),
	`RewChoiceItemCount1` smallint (5),
	`RewChoiceItemCount2` smallint (5),
	`RewChoiceItemCount3` smallint (5),
	`RewChoiceItemCount4` smallint (5),
	`RewChoiceItemCount5` smallint (5),
	`RewChoiceItemCount6` smallint (5),
	`RewItemId1` mediumint (8),
	`RewItemId2` mediumint (8),
	`RewItemId3` mediumint (8),
	`RewItemId4` mediumint (8),
	`RewItemCount1` smallint (5),
	`RewItemCount2` smallint (5),
	`RewItemCount3` smallint (5),
	`RewItemCount4` smallint (5),
	`RewRepFaction1` smallint (5),
	`RewRepFaction2` smallint (5),
	`RewRepFaction3` smallint (5),
	`RewRepFaction4` smallint (5),
	`RewRepFaction5` smallint (5),
	`RewRepValue1` mediumint (9),
	`RewRepValue2` mediumint (9),
	`RewRepValue3` mediumint (9),
	`RewRepValue4` mediumint (9),
	`RewRepValue5` mediumint (9),
	`RewOrReqMoney` int (11),
	`RewMoneyMaxLevel` int (10),
	`RewSpell` mediumint (8),
	`RewSpellCast` mediumint (8),
	`RewMailTemplateId` mediumint (8),
	`RewMailDelaySecs` int (11),
	`PointMapId` smallint (5),
	`PointX` float ,
	`PointY` float ,
	`PointOpt` mediumint (8),
	`DetailsEmote1` smallint (5),
	`DetailsEmote2` smallint (5),
	`DetailsEmote3` smallint (5),
	`DetailsEmote4` smallint (5),
	`DetailsEmoteDelay1` int (11),
	`DetailsEmoteDelay2` int (11),
	`DetailsEmoteDelay3` int (11),
	`DetailsEmoteDelay4` int (11),
	`IncompleteEmote` smallint (5),
	`CompleteEmote` smallint (5),
	`OfferRewardEmote1` smallint (5),
	`OfferRewardEmote2` smallint (5),
	`OfferRewardEmote3` smallint (5),
	`OfferRewardEmote4` smallint (5),
	`OfferRewardEmoteDelay1` int (11),
	`OfferRewardEmoteDelay2` int (11),
	`OfferRewardEmoteDelay3` int (11),
	`OfferRewardEmoteDelay4` int (11),
	`StartScript` mediumint (8),
	`CompleteScript` mediumint (8)
    */
    
    public static String fixMaNGOSString(String raw){
        return raw.replaceAll("\\$B", "\\\\n").replaceAll("\\$N", "'..N..'").replaceAll("\\\\\"", "\"");
    }
    
       
    
    public static void main(String[] a) throws IOException {
        String s;
        BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosCreatureTemplate.sql")));
        HashMap<Integer, String> creaturenames = new HashMap<Integer, String>();
        HashMap<Integer, String> objectnames = new HashMap<Integer, String>();
        HashMap<Integer,CreatureSpawns> spawns = new HashMap<Integer, CreatureSpawns>();
        HashMap<Integer, Integer> guids = new HashMap<Integer, Integer>();
        HashMap<Integer,Integer> questStarters = new HashMap<Integer, Integer>(); // questid, starter
        HashMap<Integer,Integer> objectStarters = new HashMap<Integer, Integer>(); // questid, starter
        HashMap<Integer,Integer> questEnders = new HashMap<Integer, Integer>();
        HashMap<Integer,Integer> objectEnders = new HashMap<Integer, Integer>();
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `creature_template`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                creaturenames.put(Integer.parseInt(args[0].substring(1)), args[1]);
            }
        }
        
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosCreatureInvolvedRelation.sql")));
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `creature_involvedrelation`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                String t = args[1];
                t = t.substring(0, t.length()-1);
                questEnders.put(Integer.parseInt(t), Integer.parseInt(args[0].substring(1)));
            }
        }
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosObjectInvolvedRelation.sql")));
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `gameobject_involvedrelation`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                String t = args[1];
                t = t.substring(0, t.length()-1);
                objectEnders.put(Integer.parseInt(t), Integer.parseInt(args[0].substring(1)));
            }
        }
        
        
        
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosObjectTemplate.sql")));
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `gameobject_template`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                objectnames.put(Integer.parseInt(args[0].substring(1)), args[3]);
            }
        }
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosCreatureQuestrelation.sql")));
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `creature_questrelation`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                String t = args[1];
                t = t.substring(0, t.length()-1);
                questStarters.put(Integer.parseInt(t), Integer.parseInt(args[0].substring(1)));
            }
        }
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosGameObjectQuestrelation.sql")));
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `gameobject_questrelation`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                String t = args[1];
                t = t.substring(0, t.length()-1);
                objectStarters.put(Integer.parseInt(t), Integer.parseInt(args[0].substring(1)));
            }
        }
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosCreature.sql")));
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `creature`")){
                
                //create table `creature` (
                //`guid` int (10),
                //`id` mediumint (8),
                //`map` smallint (5),
                //`modelid` mediumint (8),
                //`equipment_id` mediumint (9),
                //`position_x` float ,
                //`position_y` float ,
                //`position_z` float ,
                //`orientation` float ,
                //`spawntimesecs` int (10),
                //`spawndist` float ,
                //`currentwaypoint` mediumint (8),
                //`curhealth` int (10),
                //`curmana` int (10),
                //`DeathState` tinyint (3),
                //`MovementType` tinyint (3)
                //); 
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
                String[] args = seg.split("'\\,'"); // this is safe
                int id = Integer.parseInt(args[1]);
                guids.put(id, Integer.parseInt(args[0].substring(1)));
                if (!spawns.containsKey(id)){
                    spawns.put(id, new CreatureSpawns());
                }
                CreatureSpawns c = spawns.get(id);
                int map = Integer.parseInt(args[2]);
                float x = Float.parseFloat(args[5]);
                float y = Float.parseFloat(args[6]);
                float z = Float.parseFloat(args[7]);
                c.locs.add(new Vector4(map, x, y, z));
            }
        }
        
        HashMap<String, Integer> needs = new HashMap<String, Integer>();
        HashMap<Integer, String> startedByNPCs = new HashMap<Integer, String>();
        HashMap<Integer, String> startedByObjects = new HashMap<Integer, String>();
        
        HashMap<Integer, String> finishedByNPCs = new HashMap<Integer, String>();
        HashMap<Integer, String> finishedByObjects = new HashMap<Integer, String>();
        
        for(Integer quest : questStarters.keySet()){ // 3267
            Integer npc = questStarters.get(quest);
            String name = creaturenames.get(npc);
            startedByNPCs.put(quest, name);
            CreatureSpawns spawn = spawns.get(npc);
            //System.out.println("Need " + name + "[" + npc + "] for quest " + quest);
            //if (spawn != null)
            needs.put(name, npc);
//            else System.out.println("No spawns for " + name);
        }
        for(Integer quest : objectStarters.keySet()){
            Integer obj = objectStarters.get(quest);
            String name = objectnames.get(obj);
            startedByObjects.put(quest, name);
        }
        for(Integer quest : objectEnders.keySet()){
            Integer obj = objectEnders.get(quest);
            String name = objectnames.get(obj);
            finishedByObjects.put(quest, name);
        }
        for(Integer quest : questEnders.keySet()){
            Integer obj = questEnders.get(quest);
            String name = creaturenames.get(obj);
            finishedByNPCs.put(quest, name);
        }
        int cn = 0;
        for(String ss : needs.keySet()){
            Integer v = needs.get(ss);
            if(guids.get(v) != null){
                System.out.println("table.insert(__TODOTABLE__, {['name']='"+ss+"',['guid']="+guids.get(v)+"});");cn++;}
        }
        System.out.println(cn);
        
        in = new BufferedReader(new InputStreamReader(new FileInputStream("C:\\MangosQuestTemplateTable.sql")));
        
        int tid = 0;
        HashMap<Integer, Integer> levelfucked = new HashMap<Integer, Integer>();
        ArrayList<QuestTemplate> qt = new ArrayList<QuestTemplate>();
        while((s=in.readLine())!= null){
            if(s.startsWith("insert into `quest_template`")){
                String seg = s.substring(0, s.length()-2).split("values\\(")[1];
//                System.out.println(seg);
                String[] args = seg.split("'\\,'"); // this is safe
//                for(String se : args) System.out.println(se);
                
                int questid = Integer.parseInt(args[0].substring(1));
                //System.out.println(questid);
                // skip
                // skip
                int minlevel = Integer.parseInt(args[3]);
                int recommendedlevel = Integer.parseInt(args[4]);
                
                // skip
                int rc = Integer.parseInt(args[6]);//`RequiredClasses` smallint (5),
                int rr = Integer.parseInt(args[7]);//`RequiredRaces` smallint (5),
                int rs = Integer.parseInt(args[8]);//`RequiredSkill` smallint (5),
                int rsc = Integer.parseInt(args[9]);//`RequiredSkillValue` smallint (5),
                
                System.out.println(questid+","+rc + ","+rr+","+rs+","+rsc);
                
                // skip `RepObjectiveFaction` smallint (5),
                // skip `RepObjectiveValue` mediumint (9),
                
                int requiredminrepfaction = Integer.parseInt(args[12]);
                int requiredminrepvalue = Integer.parseInt(args[13]);
                int requiredmaxrepfaction = Integer.parseInt(args[14]);
                int requiredmaxrepvalue = Integer.parseInt(args[15]);
                int suggestedplayers = Integer.parseInt(args[16]);
                //`LimitTime` int (10),  17
                //`QuestFlags` smallint (5),  18
                //`SpecialFlags` tinyint (3),  19
                int parentQuest = Integer.parseInt(args[20]);//`PrevQuestId` mediumint (9),  20
                int childQuest = Integer.parseInt(args[21]);//`NextQuestId` mediumint (9),  21
                //`ExclusiveGroup` mediumint (9),  22 
                //`NextQuestInChain` mediumint (8), 23
                //`SrcItemId` mediumint (8),  24
                //`SrcItemCount` tinyint (3),  25
                //`SrcSpell` mediumint (8),26
                String title = fixMaNGOSString(args[27]);//`Title` text , 27
                System.out.println(title + " -> " + minlevel);
                levelfucked.put(questid, minlevel);
                String details = fixMaNGOSString(args[28]);//`Details` text ,28
                String objectiveText = fixMaNGOSString(args[29]);//`Objectives` text ,29
                //`OfferRewardText` text , 30
                //`RequestItemsText` text , 31
                //`EndText` text , 32
                String obj1 = args[33];//`ObjectiveText1` text , 33
                String obj2 = args[34];//`ObjectiveText2` text , 34
                String obj3 = args[35];//`ObjectiveText3` text , 35
                String obj4 = args[36];//`ObjectiveText4` text , 36
                
                String startType;
                String endType;
                String start;
                String end;
                
                if(startedByNPCs.containsKey(questid)){
                    startType = "monster";
                    start = startedByNPCs.get(questid);
                }else if(startedByObjects.containsKey(questid)){
                    startType = "object";
                    start = startedByObjects.get(questid);
                }else{
                    startType = "item"; // assume
                    start = "unknown";
                    //System.out.println("UNKS: " + title);
                }
                
                if(finishedByNPCs.containsKey(questid)){
                    endType = "monster";
                    end = finishedByNPCs.get(questid);
                }else if(finishedByObjects.containsKey(questid)){
                    endType = "object";
                    end = finishedByObjects.get(questid);
                }else{
                    endType = "unknown";
                    end = "unknown";
                    
                    System.out.println("UNKE: " + title);
                }
                start = fixMaNGOSString(start);
                end = fixMaNGOSString(end);
                
               
                     //                      id,  title, min,      recommended,     rc,rr,rs,
                qt.add(new QuestTemplate(questid, title, minlevel, recommendedlevel,rr,rc,rs,rsc,suggestedplayers,parentQuest,details, objectiveText, start, end, startType, endType));

                tid++;
            }
        }
        System.out.println(tid);//3267
        for(QuestTemplate t : qt){
            t.calculateHash();
        }
        ArrayList<Long> collissioncheck = new ArrayList<Long>();
        HashMap<Long,String> dbg = new HashMap<Long, String>();
        HashMap<String, ArrayList<HashMap<String, Long>>> levlookup = new HashMap<String, ArrayList<HashMap<String, Long>>>();
        HashMap<Long, QuestTemplate> hashmap = new HashMap<Long, QuestTemplate>();
        HashMap<Integer, Long> idToHash = new HashMap<Integer, Long>();
        int idx = 0;
        for(QuestTemplate t : qt){
            if(collissioncheck.contains(t.hash)){
                //System.out.println("FOUND DUPLICATE " + idx + "/" + qt.size());
                System.out.println(t.id + " " + t.title + t.objectivetext + " conflicts with " + dbg.get(t.hash));
                System.exit(-1);
            }
            idx++;
            collissioncheck.add(t.hash);
            dbg.put(t.hash, t.title);
            if(!levlookup.containsKey(t.title)){
                levlookup.put(t.title, new ArrayList<HashMap<String, Long>>());
            }
            ArrayList<HashMap<String, Long>> tm = levlookup.get(t.title);
            HashMap<String, Long> tem = new HashMap<String, Long>();
            tem.put(t.objectivetext, t.hash);
            tm.add(tem);
            hashmap.put(t.hash, t);
            idToHash.put(t.id, t.hash);
        }
        for(Long l : hashmap.keySet()){
            QuestTemplate t = hashmap.get(l);
            System.out.println(" [" + l + "]={");
            System.out.println("  ['name']='" +t.title + "',");
            System.out.println("  ['startedType']='" +t.startType + "',");
            System.out.println("  ['finishedType']='" +t.endType + "',");
            System.out.println("  ['startedBy']='" +t.start + "',");
            System.out.println("  ['finishedBy']='" +t.end + "',");
            System.out.print("  ['level']=" +levelfucked.get(t.id)+ "");
            if(t.rr != 0)System.out.print(",\n  ['rr']=" +t.rr+ "");
            if(t.rc != 0)System.out.print(",\n  ['rc']=" +t.rc+ "");
            if(t.rs != 0)System.out.print(",\n  ['rs']=" +t.rs+ "");
            if(t.rsc != 0)System.out.print(",\n  ['rsc']=" +t.rsc+ "");
            if(t.parentquest != 0)System.out.print(",\n  ['rq']=" +idToHash.get(t.parentquest)+ "");
            System.out.println();
//                ['coin'] = 0,
//                ['startedType'] = "monster",
//                ['finishedType'] = "monster",
//                ['xp'] = 225,
//                ['finishedBy'] = "Tundra MacGrann",
//                ['name'] = "Tundra MacGrann's Stolen Stash",
//                ['id'] = 312,
//                ['rr'] = 77,
//                ['level'] = 7,
//                ['startedBy'] = "Tundra MacGrann"
            System.out.println(" },");
        }
//        for(String st : levlookup.keySet()){
//            System.out.println(" ['" + st + "']={");
//            for(HashMap<String, Long> l : levlookup.get(st)){
//                for(String str : l.keySet()){
//                    System.out.println("  ['" + str + "']={"+hashmap.get(l.get(str)).rr+"," + l.get(str)+"},");
//                }
//            }
//            System.out.println(" },");
//        }
    }
    
}
