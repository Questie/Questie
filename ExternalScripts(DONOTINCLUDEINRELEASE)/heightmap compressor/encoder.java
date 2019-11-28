import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.zip.DeflaterOutputStream;
import javax.imageio.ImageIO;

public class SPS {
    
    static ArrayList<Vector3f> getMangosData(int mapid, Vector3f v1, Vector3f v2) throws IOException {
        // call C++ code here
		
		/*
		uint32 mapid;
				
		Map* m = sMapMgr.FindMap(mapid, 0);
		
		PathFinder path(NULL, m);
		
		int lh = 999999;
		
		float left = v1.x;
		float top = v1.y;
		float right = v2.x;
		float bottom = v2.y;
		float resolution = v1.z;
		
        float stepSizeX = -(left - right) / resolution;
        float stepSizeY = -(top - bottom) / resolution;
		
		for (float _x = left; right < left ? _x > right : _x < right; _x += stepSizeX) {
			for (float _y = top; bottom < top ? _y > bottom : _y < bottom; _y += stepSizeY) {
				float testx = _y; // flipped ree
				float testy = _x;
				lh = 999999;
				for(float d = -5000; d < 7000; d+=10){
					path.clear();
					bool result = path.calculate(testx, testy, d, false, testx, testy, d, m); // this is more accurate than the normal heightmap functions
					if(result){
						Movement::PointsArray const& pointPath = path.getPath();
						int hv = static_cast<int>(pointPath[1].z);
						if (hv != static_cast<int>(d) && hv != lh){
							lh = hv;
							float isOutside = m->GetTerrain()->IsOutdoors(testx, testy, pointPath[1].z) ? 1 : 0;
							java << new Vector3f(testx, testy,pointPath[1].z, isOutside)
						}
					}
				}
			}
		}
		*/
		
        return null;
    }
	
    static WorldMapArea[] wma = new WorldMapArea[108];

    static class WorldMapArea {

        String name;
        int id, map, zone;
        public double left, right, top, bottom;

        public double x, y, width, height;

        public WorldMapArea(int id, int map, int area, String name, double left, double right, double top, double bottom) {
            this.id = id;
            this.zone = area;
            this.map = map;
            this.name = name;
            this.left = left;
            this.right = right;
            this.top = top;
            this.bottom = bottom;
            x = left;
            y = top;
            width = right - left;
            height = bottom - top;
        }
    }
	
    static class Vector3f{
        public double x,y,z;
        public double isInside = 0;
        public Vector3f(double x, double y, double z){this.x=x;this.y=y;this.z=z;}
        public Vector3f(double x, double y, double z, double isInside){this.x=x;this.y=y;this.z=z;this.isInside = isInside;}
		
        public boolean isInside(){ 
            return isInside < 0.5;
        }

        @Override
        public boolean equals(Object obj) {
            if(!(obj instanceof Vector3f)) return false;
            Vector3f c = (Vector3f)obj;
            return ((int)c.x) == (int)x && ((int)c.y) == (int)y && ((int)c.z) == (int)z && c.isInside() == isInside();
        }

        @Override
        public String toString() {
            return "Vector3f(" + x+","+ y+","+z+")";
        }
    }
    
    public static int CRC(int crc, int val){
        return (31 * crc + val) & 0xFFFFFFFF;
    }
	
    public static String enc(int v){ // horrible btw
        String st = String.valueOf(v);
        while(st.length()<3)
            st = "0" + st;
        return "\\" + st;
    }

    public static void main(String[] args) throws IOException {
        System.out.println("Staring up...");
        wma[0] = new WorldMapArea(512, 607, 4384, "StrandoftheAncients", 787.5, -956.24994, 1883.3333, 720.8333);
        wma[1] = new WorldMapArea(4, 1, 14, "Durotar", -1962.4999, -7249.9995, 1808.3333, -1716.6666);
        wma[2] = new WorldMapArea(261, 1, 1377, "Silithus", 2537.5, -945.834, -5958.334, -8281.25);
        wma[3] = new WorldMapArea(520, 576, 4265, "TheNexus", 0.0, 0.0, 0.0, 0.0);
        wma[4] = new WorldMapArea(9, 1, 215, "Mulgore", 2047.9166, -3089.5833, -272.91666, -3697.9165);
        wma[5] = new WorldMapArea(521, 595, 4100, "CoTStratholme", 2152.0833, 327.0833, 2297.9165, 1081.25);
        wma[6] = new WorldMapArea(522, 619, 4494, "Ahnkahet", -233.33333, -1206.25, 849.99994, 202.08333);
        wma[7] = new WorldMapArea(11, 1, 17, "Barrens", 2622.9165, -7510.4165, 1612.4999, -5143.75);
        wma[8] = new WorldMapArea(523, 574, 206, "UtgardeKeep", 0.0, 0.0, 0.0, 0.0);
        wma[9] = new WorldMapArea(524, 575, 1196, "UtgardePinnacle", 3274.9998, -3274.9998, 2166.6665, -2200.0);
        wma[10] = new WorldMapArea(13, 1, 0, "Kalimdor", 17066.6, -19733.21, 12799.9, -11733.3);
        wma[11] = new WorldMapArea(525, 602, 4272, "HallsofLightning", 2500.0, -899.99994, 2200.0, -66.666664);
        wma[12] = new WorldMapArea(14, 0, 0, "Azeroth", 18171.97, -22569.21, 11176.344, -15973.344);
        wma[13] = new WorldMapArea(526, 599, 4264, "Ulduar77", 2766.6665, -633.3333, 2200.0, -66.666664);
        wma[14] = new WorldMapArea(15, 0, 36, "Alterac", 783.3333, -2016.6666, 1500.0, -366.66666);
        wma[15] = new WorldMapArea(527, 616, 4500, "TheEyeofEternity", 2766.6665, -633.3333, 2200.0, -66.666664);
        wma[16] = new WorldMapArea(16, 0, 45, "Arathi", -866.6666, -4466.6665, -133.33333, -2533.3333);
        wma[17] = new WorldMapArea(528, 578, 4228, "Nexus80", 2337.5, -262.5, 1956.2499, 222.91666);
        wma[18] = new WorldMapArea(17, 0, 3, "Badlands", -2079.1665, -4566.6665, -5889.583, -7547.9165);
        wma[19] = new WorldMapArea(529, 603, 4273, "Ulduar", 1583.3333, -1704.1666, 1168.75, -1022.9166);
        wma[20] = new WorldMapArea(530, 604, 4416, "Gundrak", 1310.4166, 166.66666, 2122.9165, 1360.4166);
        wma[21] = new WorldMapArea(19, 0, 4, "BlastedLands", -1241.6666, -4591.6665, -10566.666, -12800.0);
        wma[22] = new WorldMapArea(531, 615, 4493, "TheObsidianSanctum", 1133.3333, -29.166666, 3616.6665, 2841.6665);
        wma[23] = new WorldMapArea(20, 0, 85, "Tirisfal", 3033.3333, -1485.4166, 3837.4998, 824.99994);
        wma[24] = new WorldMapArea(532, 624, 4603, "VaultofArchavon", 1033.3333, -1566.6666, 600.0, -1133.3333);
        wma[25] = new WorldMapArea(21, 0, 130, "Silverpine", 3449.9998, -750.0, 1666.6666, -1133.3333);
        wma[26] = new WorldMapArea(533, 601, 4277, "AzjolNerub", 1020.8333, -52.083332, 872.9166, 158.33333);
        wma[27] = new WorldMapArea(22, 0, 28, "WesternPlaguelands", 416.66666, -3883.3333, 3366.6665, 499.99997);
        wma[28] = new WorldMapArea(534, 600, 4196, "DrakTharonKeep", -377.0833, -1004.1666, -168.75, -587.5);
        wma[29] = new WorldMapArea(23, 0, 139, "EasternPlaguelands", -2287.5, -6318.75, 3704.1665, 1016.6666);
        wma[30] = new WorldMapArea(535, 533, 3456, "Naxxramas", -2520.8333, -4377.083, 3597.9165, 2360.4165);
        wma[31] = new WorldMapArea(24, 0, 267, "Hilsbrad", 1066.6666, -2133.3333, 400.0, -1733.3333);
        wma[32] = new WorldMapArea(536, 608, 4415, "VioletHold", 983.3333, 600.0, 2006.2499, 1749.9999);
        wma[33] = new WorldMapArea(281, 1, 618, "Winterspring", -316.66666, -7416.6665, 8533.333, 3799.9998);
        wma[34] = new WorldMapArea(26, 0, 47, "Hinterlands", -1575.0, -5425.0, 1466.6666, -1100.0);
        wma[35] = new WorldMapArea(27, 0, 1, "DunMorogh", 1802.0833, -3122.9165, -3877.0833, -7160.4165);
        wma[36] = new WorldMapArea(28, 0, 51, "SearingGorge", -322.91666, -2554.1665, -6100.0, -7587.4995);
        wma[37] = new WorldMapArea(540, 628, 4710, "IsleofConquest", 525.0, -2125.0, 1708.3333, -58.333332);
        wma[38] = new WorldMapArea(29, 0, 46, "BurningSteppes", -266.66666, -3195.8333, -7031.2495, -8983.333);
        wma[39] = new WorldMapArea(541, 571, 4742, "HrothgarsLanding", 2797.9165, -879.1666, 10781.25, 8329.166);
        wma[40] = new WorldMapArea(30, 0, 12, "Elwynn", 1535.4166, -1935.4166, -7939.583, -10254.166);
        wma[41] = new WorldMapArea(542, 650, 4723, "TheArgentColiseum", 2100.0, -499.99997, 2200.0, 466.66666);
        wma[42] = new WorldMapArea(543, 649, 4722, "TheArgentColiseum", 2100.0, -499.99997, 2200.0, 466.66666);
        wma[43] = new WorldMapArea(32, 0, 41, "DeadwindPass", -833.3333, -3333.3333, -9866.666, -11533.333);
        wma[44] = new WorldMapArea(34, 0, 10, "Duskwood", 833.3333, -1866.6666, -9716.666, -11516.666);
        wma[45] = new WorldMapArea(35, 0, 38, "LochModan", -1993.7499, -4752.083, -4487.5, -6327.083);
        wma[46] = new WorldMapArea(36, 0, 44, "Redridge", -1570.8333, -3741.6665, -8575.0, -10022.916);
        wma[47] = new WorldMapArea(37, 0, 33, "Stranglethorn", 2220.8333, -4160.4165, -11168.75, -15422.916);
        wma[48] = new WorldMapArea(38, 0, 8, "SwampOfSorrows", -2222.9165, -4516.6665, -9620.833, -11150.0);
        wma[49] = new WorldMapArea(39, 0, 40, "Westfall", 3016.6665, -483.3333, -9400.0, -11733.333);
        wma[50] = new WorldMapArea(40, 0, 11, "Wetlands", -389.5833, -4525.0, -2147.9165, -4904.1665);
        wma[51] = new WorldMapArea(41, 1, 141, "Teldrassil", 3814.5833, -1277.0833, 11831.25, 8437.5);
        wma[52] = new WorldMapArea(42, 1, 148, "Darkshore", 2941.6665, -3608.3333, 8333.333, 3966.6665);
        wma[53] = new WorldMapArea(43, 1, 331, "Ashenvale", 1699.9999, -4066.6665, 4672.9165, 829.1666);
        wma[54] = new WorldMapArea(301, 0, 1519, "Stormwind", 1380.971436, 36.700630, -8278.850586, -9175.205078);
        wma[55] = new WorldMapArea(61, 1, 400, "ThousandNeedles", -433.3333, -4833.333, -3966.6665, -6899.9995);
        wma[56] = new WorldMapArea(321, 1, 1637, "Ogrimmar", -3680.601, -5083.2056, 2273.8772, 1338.4606);
        wma[57] = new WorldMapArea(81, 1, 406, "StonetalonMountains", 3245.8333, -1637.4999, 2916.6665, -339.5833);
        wma[58] = new WorldMapArea(341, 0, 1537, "Ironforge", -713.5914, -1504.2164, -4569.241, -5096.8457);
        wma[59] = new WorldMapArea(601, 632, 4809, "TheForgeofSouls", 7033.333, -4366.6665, 6466.6665, -1133.3333);
        wma[60] = new WorldMapArea(602, 658, 4813, "PitofSaron", 839.5833, -693.75, 1256.25, 233.33333);
        wma[61] = new WorldMapArea(603, 668, 4820, "HallsofReflection", 7033.333, -5966.6665, 6466.6665, -2200.0);
        wma[62] = new WorldMapArea(604, 631, 4812, "IcecrownCitadel", 6366.6665, -5833.333, 5933.333, -2200.0);
        wma[63] = new WorldMapArea(609, 724, 4987, "TheRubySanctum", 902.0833, 150.0, 3429.1665, 2927.0833);
        wma[64] = new WorldMapArea(101, 1, 405, "Desolace", 4233.333, -262.5, 452.0833, -2545.8333);
        wma[65] = new WorldMapArea(362, 1, 1638, "ThunderBluff", 516.6666, -527.0833, -849.99994, -1545.8333);
        wma[66] = new WorldMapArea(121, 1, 357, "Feralas", 5441.6665, -1508.3333, -2366.6665, -6999.9995);
        wma[67] = new WorldMapArea(381, 1, 1657, "Darnassis", 2938.3628, 1880.0295, 10238.316, 9532.587);
        wma[68] = new WorldMapArea(382, 0, 1497, "Undercity", 873.1926, -86.1824, 1877.9453, 1237.8412);
        wma[69] = new WorldMapArea(141, 1, 15, "Dustwallow", -974.99994, -6225.0, -2033.3333, -5533.333);
        wma[70] = new WorldMapArea(401, 30, 2597, "AlteracValley", 1781.2499, -2456.25, 1085.4166, -1739.5833);
        wma[71] = new WorldMapArea(161, 1, 440, "Tanaris", -218.74998, -7118.7495, -5875.0, -10475.0);
        wma[72] = new WorldMapArea(181, 1, 16, "Aszhara", -3277.0833, -8347.916, 5341.6665, 1960.4166);
        wma[73] = new WorldMapArea(182, 1, 361, "Felwood", 1641.6666, -4108.333, 7133.333, 3299.9998);
        wma[74] = new WorldMapArea(443, 489, 3277, "WarsongGulch", 2041.6666, 895.8333, 1627.0833, 862.49994);
        wma[75] = new WorldMapArea(201, 1, 490, "UngoroCrater", 533.3333, -3166.6665, -5966.6665, -8433.333);
        wma[76] = new WorldMapArea(461, 529, 3358, "ArathiBasin", 1858.3333, 102.08333, 1508.3333, 337.5);
        wma[77] = new WorldMapArea(462, 530, 3430, "EversongWoods", -4487.5, -9412.5, 11041.666, 7758.333);
        wma[78] = new WorldMapArea(463, 530, 3433, "Ghostlands", -5283.333, -8583.333, 8266.666, 6066.6665);
        wma[79] = new WorldMapArea(464, 530, 3524, "AzuremystIsle", -10500.0, -14570.833, -2793.75, -5508.333);
        wma[80] = new WorldMapArea(465, 530, 3483, "Hellfire", 5539.583, 375.0, 1481.25, -1962.4999);
        wma[81] = new WorldMapArea(466, 530, 0, "Expansion01", 12996.039, -4468.039, 5821.3594, -5821.3594);
        wma[82] = new WorldMapArea(467, 530, 3521, "Zangarmarsh", 9475.0, 4447.9165, 1935.4166, -1416.6666);
        wma[83] = new WorldMapArea(471, 530, 3557, "TheExodar", -11066.367, -12123.138, -3609.6833, -4314.371);
        wma[84] = new WorldMapArea(473, 530, 3520, "ShadowmoonValley", 4225.0, -1275.0, -1947.9166, -5614.583);
        wma[85] = new WorldMapArea(475, 530, 3522, "BladesEdgeMountains", 8845.833, 3420.8333, 4408.333, 791.6666);
        wma[86] = new WorldMapArea(476, 530, 3525, "BloodmystIsle", -10075.0, -13337.499, -758.3333, -2933.3333);
        wma[87] = new WorldMapArea(477, 530, 3518, "Nagrand", 10295.833, 4770.833, 41.666664, -3641.6665);
        wma[88] = new WorldMapArea(478, 530, 3519, "TerokkarForest", 7083.333, 1683.3333, -999.99994, -4600.0);
        wma[89] = new WorldMapArea(479, 530, 3523, "Netherstorm", 5483.333, -91.666664, 5456.25, 1739.5833);
        wma[90] = new WorldMapArea(480, 530, 3487, "SilvermoonCity", -6400.75, -7612.2085, 10153.709, 9346.938);
        wma[91] = new WorldMapArea(481, 530, 3703, "ShattrathCity", 6135.259, 4829.009, -1473.9545, -2344.7878);
        wma[92] = new WorldMapArea(482, 566, 3820, "NetherstormArena", 2660.4165, 389.5833, 2918.75, 1404.1666);
        wma[93] = new WorldMapArea(485, 571, 0, "Northrend", 9217.152, -8534.246, 10593.375, -1240.89);
        wma[94] = new WorldMapArea(486, 571, 3537, "BoreanTundra", 8570.833, 2806.25, 4897.9165, 1054.1666);
        wma[95] = new WorldMapArea(488, 571, 65, "Dragonblight", 3627.0833, -1981.2499, 5575.0, 1835.4166);
        wma[96] = new WorldMapArea(490, 571, 394, "GrizzlyHills", -1110.4166, -6360.4165, 5516.6665, 2016.6666);
        wma[97] = new WorldMapArea(491, 571, 495, "HowlingFjord", -1397.9166, -7443.7495, 3116.6665, -914.5833);
        wma[98] = new WorldMapArea(492, 571, 210, "IcecrownGlacier", 5443.75, -827.0833, 9427.083, 5245.833);
        wma[99] = new WorldMapArea(493, 571, 3711, "SholazarBasin", 6929.1665, 2572.9165, 7287.4995, 4383.333);
        wma[100] = new WorldMapArea(495, 571, 67, "TheStormPeaks", 1841.6666, -5270.833, 10197.916, 5456.25);
        wma[101] = new WorldMapArea(496, 571, 66, "ZulDrak", -600.0, -5593.75, 7668.7495, 4339.583);
        wma[102] = new WorldMapArea(241, 1, 493, "Moonglade", -1381.25, -3689.5833, 8491.666, 6952.083);
        wma[103] = new WorldMapArea(499, 530, 4080, "Sunwell", -5302.083, -8629.166, 13568.749, 11350.0);
        wma[104] = new WorldMapArea(501, 571, 4197, "LakeWintergrasp", 4329.1665, 1354.1666, 5716.6665, 3733.3333);
        wma[105] = new WorldMapArea(502, 609, 4298, "ScarletEnclave", -4047.9165, -7210.4165, 3087.5, 979.1666);
        wma[106] = new WorldMapArea(504, 571, 4395, "Dalaran", 0.0, 0.0, 0.0, 0.0);
        wma[107] = new WorldMapArea(510, 571, 2817, "CrystalsongForest", 1443.75, -1279.1666, 6502.083, 4687.5);

        System.out.println("Scanning maps..."); 
        
        if(true){
            int chunkResDivisor = 4;
            int chunkSize = 64;
            WorldMapArea w = new WorldMapArea(20, 0, 85, "Tirisfal", 3033.3333, -1485.4166, 3837.4998, 824.99994);
            
            int directionX = 1;
            int directionY = 1;
            if(w.left > w.right)
                directionX = -1;
            if(w.top > w.bottom)
                directionY = -1;
            FileOutputStream ffo = new FileOutputStream("./" + w.name + ".lua");
            PrintWriter pw = new PrintWriter(ffo);
            pw.println("-- generated at "+System.currentTimeMillis()+" using wishful thinking and black magic\r\nHM_toEncode={}");
            for (double __x = w.left; w.right < w.left ? __x > w.right : __x < w.right; __x += chunkResDivisor*chunkSize*directionX) {
                for (double __y = w.top; w.bottom < w.top ? __y > w.bottom : __y < w.bottom; __y += chunkResDivisor*chunkSize*directionY) {
                    double _x = Math.round(__x);
                    double _y = Math.round(__y);
                    File deadFile = new File("./dead/dead." +w.name + "."+ Math.round(_x) + "." + Math.round(_y) + "." + chunkSize + "." + chunkResDivisor + ".dead");
                    File done = new File("./done/done." + w.name + "." + (int)Math.round(_x) + "." + (int)Math.round(_y) + ".done");
                    if(!deadFile.exists() /*&& !done.exists()*/){
                        ArrayList<Vector3f> result = getMangosData(w.map, new Vector3f(_x, _y, chunkSize), new Vector3f(_x+chunkResDivisor*chunkSize*directionX, _y+chunkResDivisor*chunkSize*directionY, 0));
                        System.out.println("RSC: " + result.size());
                        if(result.size() == 0){
                            deadFile.createNewFile();
                        }
                        if (result.size() > 0) {
                            
                            BufferedImage im = new BufferedImage(chunkSize, chunkSize, BufferedImage.TYPE_INT_ARGB);
                            Graphics2D g = im.createGraphics();
                            int[][] height1 = new int[chunkSize][chunkSize];
                            int[][] height1c = new int[chunkSize][chunkSize];
                            for(int i = 0; i < chunkSize; i++){
                                height1[i] = new int[chunkSize];
                                height1c[i] = new int[chunkSize];
                            }
                            ArrayList<Vector3f>[][] heightLists = new ArrayList[(int)chunkSize][(int)chunkSize];
                            for(int x = 0; x < (int)chunkSize; x++){
                                heightLists[x] = new ArrayList[(int)chunkSize];
                                for(int y = 0; y < (int)chunkSize; y++){
                                    heightLists[x][y] = new ArrayList<>();
                                }
                            }
                            for(Vector3f v : result){
                                int ix = (int) -Math.round((Math.round(v.x) - Math.round(_y))/chunkResDivisor);
                                int iy = (int) -Math.round((Math.round(v.y) - Math.round(_x))/chunkResDivisor);
                                if(v.z > -300){
                                    height1[ix][iy] += (int)Math.round(v.z);
                                    height1c[ix][iy]++;
                                }
                                heightLists[ix][iy].add(v);
                            }
                            
                            
                            ByteArrayOutputStream temp = new ByteArrayOutputStream();
                            DataOutputStream out = new DataOutputStream(temp);
                            out.writeShort(chunkSize);
                            out.write(chunkResDivisor);
                            int lastValue = 0;
                            int toSkipRLE = 0;
                            int crc = 5381;
                            boolean isInside = false;
                            for (int x = 0; x < (int) chunkSize; x++) {
                                for (int y = 0; y < (int) chunkSize; y++) {
                                    ArrayList<Vector3f> lst = heightLists[x][y];
                                    if(lst.size() == 0)
                                        lst.add(new Vector3f(0,0,0,0));
                                    for(Vector3f v : lst){
                                        crc = CRC(crc, (int)Math.round(v.z));
                                        if(v.isInside())
                                            crc = CRC(crc, 1);
                                    }
                                    if(toSkipRLE-->0)
                                        continue;
                                    if(lst.size() == 1){
                                        int v = (int)Math.round(lst.get(0).z);
                                        int diff = v - lastValue;
                                        if(diff == 0 && lst.get(0).isInside() == isInside){
                                            // try for RLE
                                            int RLEL = 0;
                                            boolean stillGood = true;
                                            boolean firstRun = true;
                                            for (int rx = x; rx < (int) chunkSize; rx++) {
                                                if(!stillGood)break;
                                                for (int ry = firstRun ? y : 0; ry < (int) chunkSize; ry++) {
                                                    firstRun = false;
                                                    ArrayList<Vector3f> lst2 =  heightLists[rx][ry];
                                                    if(lst2.size() == 0)
                                                        lst2.add(new Vector3f(0,0,0,0));
                                                    if(lst2.size() != 1){
                                                        stillGood = false;
                                                        break;
                                                    }else if((((int)Math.round(lst2.get(0).z)) - lastValue) != diff || lst.get(0).isInside() != isInside){
                                                        stillGood = false;
                                                        break;
                                                    }else RLEL++;
                                                }
                                            }
                                            if(RLEL > 1){
                                                if(RLEL>255)
                                                    RLEL = 255;
                                                toSkipRLE = RLEL-1;
                                                out.write(5);
                                                out.write(RLEL);
                                                System.out.println("Did RLE: " + RLEL);
                                            }else{
                                                out.write(diff + 127);
                                            }
                                        }else{
                                            System.out.println("Did normal value: " + v);
                                            if(isInside != lst.get(0).isInside()){
                                                out.write(3);
                                                isInside = !isInside;
                                            }
                                            if(Math.abs(diff)<120){
                                                out.write(diff + 127);
                                                lastValue = v;
                                            }else{
                                                if(v < 0){
                                                    out.write(2);
                                                    out.writeShort(Math.abs(v));
                                                    lastValue = v;
                                                }else{
                                                    out.write(1);
                                                    out.writeShort(v);
                                                    lastValue = v;
                                                }
                                            }
                                        }
                                    }else{
                                        System.out.println("Did group value: " + lst.size());
                                        out.write(4);
                                        out.write(lst.size());
                                        for(Vector3f _v : lst){
                                            int v =  (int)Math.round(_v.z);
                                            int diff = v - lastValue;
                                            if(isInside != lst.get(0).isInside()){
                                                out.write(3);
                                                isInside = !isInside;
                                            }
                                            if(Math.abs(diff)<120){
                                                out.write(diff + 127);
                                                lastValue = v;
                                            }else{
                                                if(v < 0){
                                                    out.write(2);
                                                    out.writeShort(Math.abs(v));
                                                    lastValue = v;
                                                }else{
                                                    out.write(1);
                                                    out.writeShort(v);
                                                    lastValue = v;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
							
                            System.out.println("Finished with CRC 0x" + Integer.toHexString(crc).toUpperCase() + " and toSkipRLE " + toSkipRLE);
                            out.writeInt(crc);
                            byte[] b = temp.toByteArray();
                            FileOutputStream fo = new FileOutputStream("./" + w.name + "." + (int)Math.round(_x) + "." + (int)Math.round(_y) + ".bin");
                            fo.write(b);
                            fo.close();

                            int lshort_ctrl = 237;
                            int lshort_zero = 238;
                            ArrayList<Integer> lshort_control_table = new ArrayList<Integer>();
                            lshort_control_table.add(lshort_ctrl);
                            lshort_control_table.add(lshort_zero);
                            String shrt = "";
                            
                            pw.print("HM_toEncode[\"" + (int)Math.round(_y) + ","+ (int)Math.round(_x) +"\"] = \"");
                            for(byte by : b)
                                pw.print(enc(((int)by)&0xFF));
                            pw.println("\"");
                            pw.flush();
                            
                            for (int x = 0; x < chunkSize; x++) {
                                for (int y = 0; y < chunkSize; y++) {
                                    int v = (height1[x][y] / (height1c[x][y] > 0 ? height1c[x][y] : 1));

                                    if (v < 0) {
                                        v = 0;
                                    }
                                    if (v > 255) {
                                        v = 255;
                                    }
                                    g.setColor(new Color(v, v, v));
                                    g.drawLine(y, x, y, x);
                                }
                            }
                            ImageIO.write(im, "PNG", new File("./" + w.name + "." + (int)Math.round(_x) + "." + (int)Math.round(_y) + ".png"));
                            done.createNewFile();
							
                        }
                    }
                }
            }
            pw.close();
            ffo.close();
            return;
        }
    }

}
