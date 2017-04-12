@isTest(SeeAllData=true)
private class SMBW2_OPP_ChooseRecordType_Test {

    static testMethod void myUnitTest(){
        Account a = new account(Name = 'JHAZTest',RCE_ID__c = '12345',SMB_No_Referential_ID_available__c=true);
        insert a;
        
        Opportunity o = new Opportunity(Name = 'Test Oppty JHAZ', AccountId = a.Id, Amount = 10000000,
        StageName = '1 Pre-qualification', CloseDate = date.today().addDays(30));
        insert o;
        
        List<Recordtype> listOppType = [SELECT Id, Name, Description, DeveloperName FROM RecordType WHERE sObjectType ='Opportunity' AND isActive = true AND DeveloperName LIKE: 'SAMBA%' order by DeveloperName];
        
        Test.startTest();
        Apexpages.currentPage().getParameters().put('oppId', o.Id);
        ApexPages.StandardController scTest = new ApexPages.standardController(o);
        SMBW2_OPP_ChooseRecordType_VFC aTest = new SMBW2_OPP_ChooseRecordType_VFC(scTest);
        aTest.cancelOpp();
        aTest.saveOpp();
        aTest.nivelOpp();
        aTest.getItemsType();
        aTest.getOpptyTypeValue();
        aTest.setOpptyTypeValue(listOppType[0].Id);
        
        List<SMB_OPP_RecType_Translate__c> listRecTypeTranslate = aTest.getItemsTranslate();

        Apexpages.currentPage().getParameters().put('oppId', '');
        ApexPages.StandardController scTest2 = new ApexPages.standardController(o);
        SMBW2_OPP_ChooseRecordType_VFC aTest2 = new SMBW2_OPP_ChooseRecordType_VFC(scTest);
/*
        aTest2.cancelOpp();
        aTest2.saveOpp();
        aTest2.nivelOpp();
        aTest2.getItemsType();
        aTest2.getOpptyTypeValue();
        aTest2.setOpptyTypeValue(listOppType[0].Id);
*/
		
        Test.stopTest();
    }
}