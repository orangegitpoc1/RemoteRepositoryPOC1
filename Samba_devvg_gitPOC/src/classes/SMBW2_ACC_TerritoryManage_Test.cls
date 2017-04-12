@isTest(SeeAllData=true)
private class SMBW2_ACC_TerritoryManage_Test {

    static testMethod void myUnitTest(){
        Account a = [SELECT Id FROM Account WHERE parentId =: null /*AND RecordType.DeveloperName ='Partner'*/ limit 1];
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
 
        System.RunAs(usr){
            Test.startTest();
            Apexpages.currentPage().getParameters().put('accId', a.Id);
            Apexpages.currentPage().getParameters().put('create', 'true');
            ApexPages.StandardController scTest = new ApexPages.standardController(a);
            SMBW2_ACC_TerritoryManage_VFC aTest = new SMBW2_ACC_TerritoryManage_VFC(scTest);
            aTest.init();
            Apexpages.currentPage().getParameters().put('create', 'false');
            ApexPages.StandardController scTest2 = new ApexPages.standardController(a);
            SMBW2_ACC_TerritoryManage_VFC aTest2 = new SMBW2_ACC_TerritoryManage_VFC(scTest2);
            aTest2.init();
            Test.stopTest();
        }
    }
}