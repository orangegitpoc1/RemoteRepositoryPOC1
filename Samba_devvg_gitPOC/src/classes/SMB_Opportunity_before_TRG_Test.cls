@isTest
Public class SMB_Opportunity_before_TRG_Test{

     static testMethod void createOpportunity(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeghijkl@testorg.com', SMB_Bypass_VR__c=true, PAD_BypassTrigger__c=';SMBW3_Opportunity_TR009_OppSplit_TRG;');
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
            TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
            TestDataCreation.createSplitfinance(1, 'Finance');
            TestDataCreation.createcustomsetting_profile();
            Account acc=TestDataCreation.createAccounts(1)[0];
            Account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
            Opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
            Opp.StageName='4 Negotiation';
            update Opp;
            Opp.StageName='2 Qualification';
            update opp;
            opp.stageName='Closed Duplicate';
            update Opp;
            Opp.stageName='3 Proposal';
            update Opp;
            
        }
    }

}