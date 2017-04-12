@isTest(SeeAllData=true)
private class SMBW2_ACC_MatchIC01_Test {

    static testMethod void myUnitTest(){
        Account a = new account(Name = 'JHAZTest', RCE_ID__c = '12345',SMB_No_Referential_ID_available__c=true); //, Sales_Region__c = 'France');
        insert a;
        
        IC01__c i = new IC01__c(Name='Test', Customer_Name__c='JHAZTest', Account__c = null);
        insert i;
        IC01__c i2 = new IC01__c(Name='TestJHAZ', Customer_Name__c='JHAZTest', Account__c = null);
        insert i2;
        
        Test.startTest();
        ApexPages.StandardController scTest = new ApexPages.standardController(a);
        SMBW2_ACC_MatchIC01_VFC aTest = new SMBW2_ACC_MatchIC01_VFC(scTest);
        SMBW2_ACC_MatchIC01_VFC.ic01Wrapper iWrap = new SMBW2_ACC_MatchIC01_VFC.ic01Wrapper(i, true);
        SMBW2_ACC_MatchIC01_VFC.ic01Wrapper iWrap2 = new SMBW2_ACC_MatchIC01_VFC.ic01Wrapper(i2, true);
        aTest.cancel();
        aTest.globalValue = 'a';
        aTest.globalSearch();
        aTest.globalValue = 'at*';
        aTest.globalSearch();
        aTest.listIc01Wrapper.add(iWrap);
        aTest.listIc01SearchWrapper.add(iWrap2);
        aTest.matchIC();
        Test.stopTest();
    }
}