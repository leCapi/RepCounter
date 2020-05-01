using Toybox.Test;
using Toybox.System;

(:test)
function tHysteresis(logger)
{
    var settings = new Settings();
    settings.m_highThresholdValue = 2200;
    settings.m_lowThresholdValue = 1200;
    var hysteresis = new Hystersis(settings);
    var data50RopeSession = [1081, 1074, 1121, 1035, 1010, 1033, 948, 834, 966, 1163,
        981, 1008, 1025, 1045, 1232, 1291, 1170, 1383, 1272, 1293, 1302, 1073, 1159,
        1165, 950, 895, 1005, 951, 975, 1187, 1238, 1257, 1387, 1471, 1514, 1639, 1761,
        1902, 2186, 2012, 1874, 1638, 1247, 920, 700, 612, 614, 323, 967, 499, 1296, 853,
        1113, 1277, 967, 1132, 1514, 1705, 2318, 3480, 3244, 2289, 1495, 1876, 1479, 1553,
        1582, 1374, 1242, 1243, 618, 249, 271, 494, 1138, 1110, 2037, 2353, 2615, 3613, 2267,
        1600, 1482, 1255, 1669, 1415, 1315, 1792, 1613, 1064, 869, 720, 413, 460, 806, 1882, 2695,
        2990, 2172, 2453, 1816, 2237, 2158, 1768, 1493, 1933, 1119, 817, 855, 841, 593, 2068, 2914,
        3690, 1933, 2135, 1894, 2063, 1991, 1254, 1001, 1022, 1463, 1620, 695, 765, 1647, 1404, 2923,
        3192, 2178, 1778, 2040, 1853, 1737, 1400, 1137, 1352, 995, 1158, 636, 951, 827, 1238, 3508, 3267,
        2754, 2369, 1881, 1850, 1091, 965, 836, 1152, 1258, 1121, 757, 921, 1737, 3524, 3174, 2538, 2360,
        2174, 1786, 1016, 1222, 885, 1095, 1285, 1059, 653, 647, 2256, 3389, 2755, 2518, 2286, 2039, 1681,
        1205, 1017, 883, 1475, 1546, 675, 886, 1374, 2612, 2706, 2591, 2348, 1892, 1991, 1393, 1143, 1170,
        821, 1375, 1528, 589, 1592, 1003, 3418, 2568, 2546, 1832, 1964, 1503, 1161, 945, 851, 1065, 1411,
        1085, 571, 1070, 1519, 2862, 2481, 2612, 1849, 1815, 1303, 1112, 1483, 845, 905, 1169, 860, 1004,
        679, 1989, 3410, 2557, 2300, 2198, 1590, 1493, 1243, 1118, 791, 1190, 1290, 969, 739, 1184, 2402,
        3442, 2287, 2529, 1750, 1666, 1611, 942, 981, 713, 1272, 1160, 1042, 712, 1953, 3687, 2944, 2218,
        2582, 1473, 908, 854, 1168, 934, 1048, 1120, 997, 507, 1522, 3349, 2579, 2497, 2564, 1724, 1241,
        865, 828, 904, 966, 1256, 1232, 602, 1057, 2134, 3442, 2348, 3069, 2070, 1356, 839, 805, 918, 1010,
        1450, 1234, 767, 755, 2507, 2745, 2619, 2239, 1913, 1766, 1278, 831, 811, 630, 1037, 1376, 1003,
        1212, 1908, 3515, 2363, 2378, 1886, 1631, 1027, 714, 1237, 764, 1318, 1479, 1146, 919, 2119, 3130,
        2105, 2621, 1835, 1565, 1206, 1078, 671, 965, 1114, 1256, 959, 868, 2205, 2860, 2732, 2084,
        2272, 1530, 1194, 1153, 1229, 1412, 1259, 1341, 1067, 670, 1898, 2948, 3038, 2246, 2270, 1621,
        1171, 1406, 1191, 1119, 986, 1120, 1447, 996, 1695, 3257, 2701, 2546, 2212, 1513, 1146, 703, 1110,
        893, 991, 1474, 1310, 977, 1832, 3354, 2463, 2635, 1811, 1326, 1147, 1005, 889, 902, 947, 1157, 1283,
        732, 1954, 3105, 2959, 2660, 2178, 1602, 1517, 914, 1028, 1261, 1186, 1340, 1530, 844, 2272, 2826,
        2019, 1957, 2160, 1669, 1667, 910, 640, 1308, 1208, 1342, 1106, 1407, 1481, 2993, 2201, 2850, 1721,
        1326, 1178, 665, 1060, 869, 926, 1371, 1462, 1021, 2051, 3195, 2219, 2619, 1710, 1470, 2334, 1624,
        1177, 878, 811, 653, 917, 723, 1408, 960, 802, 1346, 2995, 2341, 2664, 1875, 1309, 1044, 741, 569,
        797, 1302, 1707, 1366, 1317, 1859, 2439, 1534, 2156, 1592, 1398, 901, 750, 716, 630, 1045, 1348,
        1564, 1639, 1014, 2422, 2785, 2184, 2049, 1276, 1231, 691, 883, 676, 597, 1443, 1523, 1306, 969,
        1770, 2988, 1777, 2146, 1757, 1415, 840, 946, 789, 631, 1084, 1443, 1644, 1298, 836, 2805, 2436,
        2145, 1883, 1552, 1257, 626, 966, 797, 1432, 1657, 1544, 1307, 1745, 2584, 1823, 2251, 1817, 1447,
        1119, 653, 1004, 913, 1122, 1578, 1313, 1526, 620, 2346, 2917, 2272, 2163, 1626, 1369, 549, 770,
        957, 770, 986, 1822, 1431, 598, 2302, 2853, 2122, 2614, 1583, 1181, 834, 1007, 928, 777, 901,
        1278, 1475, 899, 1378, 3559, 2544, 2281, 1941, 1297, 1084, 779, 1405, 668, 1109, 1484, 1547, 982,
        1849, 2753, 2302, 2576, 1789, 1363, 689, 827, 1119, 606, 1262, 1442, 1605, 1094, 1978, 2674, 2403,
        1903, 1707, 1217, 1132, 711, 901, 806, 1245, 1765, 1655, 1297, 910, 2441, 2133, 2167, 1950, 1664, 1721,
        1399, 1324, 1056, 1348, 1284, 1468, 907, 981, 1903, 3165, 2036, 2738, 1876, 1279, 880, 742, 1242, 884, 1203,
        1655, 1509, 1254, 2833, 2540, 2588, 2529, 1451, 884, 732, 869, 840, 855, 1297, 1396, 1210, 1110, 1630, 3280, 2050,
        2397, 1502, 1362, 1036, 693, 1100, 567, 1323, 1513, 1268, 1600, 1425, 2163, 2005, 1525, 2029, 1703, 1088, 723, 1097,
        793, 1016, 1173, 1760, 1291, 628, 2174, 2588, 1735, 1930, 1550, 1398, 840, 592, 1128, 1047, 1601, 1434, 1314,
        1299, 2348, 2358, 2083, 1977, 1687, 1396, 866, 804, 1054, 919, 1123, 1288, 1705, 831, 1596, 3378, 2058, 2117,
        1941, 1523, 754, 668, 1122, 679, 1425, 1424, 1332, 1115, 1201, 2338, 2422, 1998, 1745, 1445, 1091, 759, 880,
        802, 849, 1187, 1493, 994, 915, 2806, 2840, 1865, 2213, 1556, 1001, 570, 1130, 814, 1128, 1607, 1542, 1464,
        1135, 2393, 2606, 2039, 1682, 1409, 1080, 601, 1036, 736, 1008, 1040, 1619, 1508, 694, 2030, 2919, 2321,
        2237, 1282, 910, 834, 783, 380, 1216, 2417, 1630, 1074, 1188, 1125, 625, 641, 491, 1100, 1385, 1464,
        1351, 1208, 1030, 1057, 1082];

    hysteresis.compute(data50RopeSession);

    Test.assertEqualMessage(hysteresis.m_hysteresisCycles, 50, "wrong number of skips detected");
    return true;
}

(:test)
function tquantile(logger)
{
    var cal = new Calibration();
    cal.m_dataRecorded = [ 1212, 1401, 123, 123, 123, 1401, 90, 9800, 4, 5, 980 ];
    var indexQ90 = cal.quantileIndex(90);
    var expectedResult = 9;
    Test.assertEqualMessage(indexQ90 == expectedResult, true, "expected : " + expectedResult +
        ", got : " + indexQ90);
    return true;
}

(:test)
function tselectTopValues(logger)
{
    var cal = new Calibration();
    cal.m_dataRecorded = [ 1212, 1401, 123, 123, 123, 1401, 90, 9800, 4, 5, 980 ];
    var expectedResult = [ 9800, 1401, 1401, 1212, 980, 123, 123];
    cal.prepareTopValues(7);
    cal.m_sortIntervalSize = 6;
    var fcomp = cal.selectTopValues();
    Test.assertEqual(fcomp, true);
    var result = cal.m_sortedHighValues.slice(1,8);
    Test.assertEqualMessage(sameArray(expectedResult, result), true, "expected : " + expectedResult +
        ", got : " + result);

    cal = new Calibration();
    cal.m_dataRecorded = [ 1212, 1401, 123, 123, 123, 1401, 90, 9800, 4, 5, 980, 89 ];
    expectedResult = [ 9800, 1401, 1401, 1212, 980, 123, 123, 123, 90, 89 ];
    cal.prepareTopValues(10);
    cal.m_sortIntervalSize = 6;
    fcomp = cal.selectTopValues();
    Test.assertEqual(fcomp, false);
    fcomp = cal.selectTopValues();
    Test.assertEqual(fcomp, true);
    result = cal.m_sortedHighValues.slice(1,11);
    Test.assertEqualMessage(sameArray(expectedResult, result), true, "expected : " + expectedResult +
        ", got : " + result);

    cal = new Calibration();
    cal.m_dataRecorded = [ 5, 98, 8907, 456, 1, 7, 12, 24];
    cal.prepareTopValues(5);
    cal.m_sortIntervalSize = 3;
    expectedResult = [ 8907, 456, 98, 24, 12];
    fcomp = cal.selectTopValues();
    Test.assertEqual(fcomp, false);
    fcomp = cal.selectTopValues();
    Test.assertEqual(fcomp, true);
    result = cal.m_sortedHighValues.slice(1,6);
    Test.assertEqualMessage(sameArray(expectedResult, result), true, "expected : " + expectedResult +
        ", got : " + result);

    return true;
}

(:test)
function tselectBotValues(logger)
{
    var cal = new Calibration();
    cal.m_dataRecorded = [ 1212, 1401, 123, 123, 123, 1401, 90, 9800, 4, 5, 1212 ];
    var expectedResult = [ 4, 5, 90, 123, 123, 123, 1212];
    cal.prepareBotValues(7);
    cal.m_sortIntervalSize = 6;
    var fcomp = cal.selectBotValues();
    Test.assertEqual(fcomp, true);
    var result = cal.m_sortedLowValues.slice(1,8);
    Test.assertEqualMessage(sameArray(expectedResult, result), true, "expected : " + expectedResult +
        ", got : " + result);

    cal = new Calibration();
    cal.m_dataRecorded = [ 1212, 1401, 123, 123, 123, 1401, 90, 9800, 4, 5, 1212 ];
    expectedResult = [ 4, 5, 90, 123, 123, 123, 1212];
    cal.prepareBotValues(7);
    cal.m_sortIntervalSize = 5;
    fcomp = cal.selectBotValues();
    Test.assertEqual(fcomp, false);
    fcomp = cal.selectBotValues();
    Test.assertEqual(fcomp, true);
    result = cal.m_sortedLowValues.slice(1,8);
    Test.assertEqualMessage(sameArray(expectedResult, result), true, "expected : " + expectedResult +
        ", got : " + result);

    return true;
}

(:test)
function tTestSettingsClass(logger)
{
    var testSet1 = new TestSettings(20,90, 500, 1000);
    testSet1.m_score = 1;
    var testSet2 = new TestSettings(20,80, 500, 900);
    testSet2.m_score = 3;
    Test.assertEqual(testSet1.isBetter(testSet2), true);

    var testSet3 = new TestSettings(25,95, 500, 1100);
    testSet3.m_score = 1;
    Test.assertEqual(testSet1.isBetter(testSet3), false);

    var testSet4 = new TestSettings(15,85, 500, 1100);
    testSet4.m_score = 0;
    Test.assertEqual(testSet1.isBetter(testSet4), false);

    var testSet5 = new TestSettings(19, 89, 500, 999);
    testSet5.m_score = 1;
    Test.assertEqual(testSet1.isBetter(testSet5), true);

    return true;
}