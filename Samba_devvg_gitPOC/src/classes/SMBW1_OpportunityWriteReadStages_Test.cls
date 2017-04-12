@isTest(SeeAllData=true)
private class SMBW1_OpportunityWriteReadStages_Test{
    /*static testMethod void myUnitTest(){            //Commented out for WIT337
        Test.startTest();
        
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(name = 'CocaFranceTest', RCE_ID__c = 'TestRCEId', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id, Sales_Region__c = 'France');
        insert AccTest;
        Opportunity OppTest= new Opportunity(SMB_OPP_S21_Analyze__c = false, Name='NameOpportunity', stageName='Pre-qualification',Amount= 23.00 ,CloseDate=Date.Today().addDays(1), AccountId =AccTest.id );
        insert OppTest;
        ApexPages.StandardController scTest1 = new ApexPages.standardController(OppTest);
        SMBW1_OpportunityWriteReadStages_VFC testUpdate = new SMBW1_OpportunityWriteReadStages_VFC(scTest1);
        OppTest.SMB_OPP_S21_Analyze__c = true;
        testUpdate.Save();
        System.assertEquals(OppTest.SMB_OPP_S21_Analyze__c, true);
        Test.stopTest();
    }*/
}