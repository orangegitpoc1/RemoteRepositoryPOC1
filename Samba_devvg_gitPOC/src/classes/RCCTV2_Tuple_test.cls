@isTest(SeeAllData=true)
//[15/01/14 OLE UST-01048 WIT-002037 RCCTv2]
public class RCCTV2_Tuple_test {

        public static testMethod void unitTest(){      
            Test.startTest();
            RCCTV2_Tuple oRCCT = new RCCTV2_Tuple();
            
            oRCCT.region = 'xxxx';
            system.assertEquals('xxxx', oRCCT.region, 'RCCTV2_Tuple_test failure on set/get region');

            oRCCT.cluster = 'xxxx';
            system.assertEquals('xxxx', oRCCT.cluster, 'RCCTV2_Tuple_test failure on set/get cluster');

            oRCCT.country = 'xxxx';
            system.assertEquals('xxxx', oRCCT.country, 'RCCTV2_Tuple_test failure on set/get country');

            oRCCT.territory = 'xxxx';
            system.assertEquals('xxxx', oRCCT.territory, 'RCCTV2_Tuple_test failure on set/get territory');

            Test.stopTest();

        }

}