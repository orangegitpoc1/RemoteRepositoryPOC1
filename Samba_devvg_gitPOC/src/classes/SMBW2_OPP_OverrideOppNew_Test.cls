@isTest(SeeAllData=true)
private class SMBW2_OPP_OverrideOppNew_Test {

    static testMethod void myUnitTest(){
        Account a = new account(Name = 'JHAZTest', RCE_ID__c = '12345',SMB_No_Referential_ID_available__c=true); //, Sales_Region__c = 'France');
        insert a;
        
        Test.startTest();
        ApexPages.StandardController scTest = new ApexPages.standardController(new Opportunity());
        SMBW2_OPP_OverrideOppNew_VFC aTest = new SMBW2_OPP_OverrideOppNew_VFC(scTest);
        aTest.oppty.Name = 'Test Oppty JHAZ';
        aTest.oppty.AccountId = a.Id;
        aTest.cancelOpp();
        aTest.saveOpp();
        Test.stopTest();
    }
}